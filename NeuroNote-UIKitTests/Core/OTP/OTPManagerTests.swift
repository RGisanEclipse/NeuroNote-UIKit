//
//  OTPManagerTests.swift
//  NeuroNote-UIKit
//
//  Created by Eclipse on 20/07/25.
//

import XCTest
@testable import NeuroNote_UIKit

final class OTPManagerTests: XCTestCase {
    
    var mockSession: MockNetworkSession!
    var mockAuthService: MockAuthNetworkService!
    var otpManager: OTPManager!
    
    override func setUp() {
        super.setUp()
        mockSession = MockNetworkSession()
        mockAuthService = MockAuthNetworkService(session: mockSession)
        otpManager = OTPManager(networkService: mockAuthService)
    }
    
    override func tearDown() {
        super.tearDown()
        KeychainHelper.standard.clearTestKeys()
        mockSession = nil
        mockAuthService = nil
        otpManager = nil
    }
    
    // MARK: - Helper to create success response matching backend structure
    
    private func makeSuccessResponse() throws -> Data {
        // Backend format: { "success": true, "status": 200, "response": { "success": true, "message": "..." } }
        let jsonString = """
        {
            "success": true,
            "status": 200,
            "response": {
                "success": true,
                "message": "OTP sent successfully"
            }
        }
        """
        return jsonString.data(using: .utf8)!
    }
    
    private func makeErrorResponse(code: String, message: String, status: Int) throws -> Data {
        // Backend format: { "success": false, "status": 4xx, "response": { "errorCode": "...", "message": "..." } }
        let jsonString = """
        {
            "success": false,
            "status": \(status),
            "response": {
                "errorCode": "\(code)",
                "message": "\(message)"
            }
        }
        """
        return jsonString.data(using: .utf8)!
    }
    
    // MARK: - Signup OTP Tests
    
    func testRequestSignupOTPSuccess() async throws {
        mockSession.nextData = try makeSuccessResponse()
        mockSession.nextResponse = HTTPURLResponse(
            url: URL(string: "https://tests.com")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )
        
        let requestData = SignupOTPRequest(userId: "test_user")
        let result = try await otpManager.requestOTP(requestData: requestData, purpose: .Signup)
        
        XCTAssertTrue(result.success)
        
        guard let request = mockSession.lastRequest else {
            XCTFail("No request was made")
            return
        }
        XCTAssertTrue(request.url?.absoluteString.contains("/api/v1/auth/signup/otp") == true)
    }
    
    func testVerifySignupOTPSuccess() async throws {
        mockSession.nextData = try makeSuccessResponse()
        mockSession.nextResponse = HTTPURLResponse(
            url: URL(string: "https://tests.com")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )
        
        let result = try await otpManager.verifyOTP("123456", userId: "test_user", purpose: .Signup)
        
        XCTAssertTrue(result.success)
        
        // Verify the correct endpoint was called
        guard let request = mockSession.lastRequest else {
            XCTFail("No request was made")
            return
        }
        XCTAssertTrue(request.url?.absoluteString.contains("/api/v1/auth/signup/otp/verify") == true)
    }
    
    // MARK: - Forgot Password OTP Tests
    
    func testRequestForgotPasswordOTPSuccess() async throws {
        mockSession.nextData = try makeSuccessResponse()
        mockSession.nextResponse = HTTPURLResponse(
            url: URL(string: "https://tests.com")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )
        
        let requestData = ForgotPasswordOTPRequest(email: "test@example.com")
        let result = try await otpManager.requestOTP(requestData: requestData, purpose: .ForgotPassword)
        
        XCTAssertTrue(result.success)
        
        // Verify the correct endpoint was called
        guard let request = mockSession.lastRequest else {
            XCTFail("No request was made")
            return
        }
        XCTAssertTrue(request.url?.absoluteString.contains("/api/v1/auth/password/otp") == true)
    }
    
    func testVerifyForgotPasswordOTPSuccess() async throws {
        mockSession.nextData = try makeSuccessResponse()
        mockSession.nextResponse = HTTPURLResponse(
            url: URL(string: "https://tests.com")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )
        
        let result = try await otpManager.verifyOTP("123456", userId: "test_user", purpose: .ForgotPassword)
        
        XCTAssertTrue(result.success)
        
        // Verify the correct endpoint was called
        guard let request = mockSession.lastRequest else {
            XCTFail("No request was made")
            return
        }
        XCTAssertTrue(request.url?.absoluteString.contains("/api/v1/auth/password/otp/verify") == true)
    }
    
    // MARK: - Error Handling Tests
    
    func testRequestOTPWithAPIError() async throws {
        mockSession.nextData = try makeErrorResponse(code: "AUTH_001", message: "Invalid email", status: 400)
        mockSession.nextResponse = HTTPURLResponse(
            url: URL(string: "https://tests.com")!,
            statusCode: 400,
            httpVersion: nil,
            headerFields: nil
        )
        
        // When & Then
        do {
            let requestData = SignupOTPRequest(userId: "test_user")
            _ = try await otpManager.requestOTP(requestData: requestData, purpose: .Signup)
            XCTFail("Expected APIError to be thrown")
        } catch let error as APIError {
            XCTAssertEqual(error.code, "AUTH_001")
            XCTAssertEqual(error.message, "Invalid email")
            XCTAssertEqual(error.status, 400)
        } catch {
            XCTFail("Expected APIError, got \(type(of: error))")
        }
    }
    
    func testVerifyOTPWithAPIError() async throws {
        mockSession.nextData = try makeErrorResponse(code: "OTP_004", message: "Invalid OTP", status: 400)
        mockSession.nextResponse = HTTPURLResponse(
            url: URL(string: "https://tests.com")!,
            statusCode: 400,
            httpVersion: nil,
            headerFields: nil
        )
        
        // When & Then
        do {
            _ = try await otpManager.verifyOTP("123456", userId: "test_user", purpose: .Signup)
            XCTFail("Expected APIError to be thrown")
        } catch let error as APIError {
            XCTAssertEqual(error.code, "OTP_004")
            XCTAssertEqual(error.message, "Invalid OTP")
            XCTAssertEqual(error.status, 400)
        } catch {
            XCTFail("Expected APIError, got \(type(of: error))")
        }
    }

    
    // MARK: - Timeout Tests
    
    func testRequestOTPTimeout() async throws {
        mockSession.nextData = try makeSuccessResponse()
        mockSession.nextResponse = HTTPURLResponse(
            url: URL(string: "https://tests.com")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )
        
        let requestData = SignupOTPRequest(userId: "test_user")
        _ = try await otpManager.requestOTP(requestData: requestData, purpose: .Signup)
        
        guard let request = mockSession.lastRequest else {
            XCTFail("No request was made")
            return
        }
        
        XCTAssertEqual(request.timeoutInterval, 10)
    }
    
    func testVerifyOTPTimeout() async throws {
        mockSession.nextData = try makeSuccessResponse()
        mockSession.nextResponse = HTTPURLResponse(
            url: URL(string: "https://tests.com")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )
        
        _ = try await otpManager.verifyOTP("1234", userId: "test_user", purpose: .Signup)
        
        guard let request = mockSession.lastRequest else {
            XCTFail("No request was made")
            return
        }
        
        XCTAssertEqual(request.timeoutInterval, 10)
    }
}
