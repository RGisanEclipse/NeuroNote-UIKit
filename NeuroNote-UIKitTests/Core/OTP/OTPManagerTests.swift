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
    
    // MARK: - Signup OTP Tests
    
    func testRequestSignupOTPSuccess() async throws {
        let expectedResponse = NeuroNote_UIKit.OTPResponse(success: true, errorCode: nil)
        mockSession.nextData = try JSONEncoder().encode(expectedResponse)
        mockSession.nextResponse = HTTPURLResponse(
            url: URL(string: "https://tests.com")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )
        
        let requestData = SignupOTPRequest(userId: "test_user")
        let result = try await otpManager.requestOTP(requestData: requestData, purpose: .Signup)
        
        XCTAssertTrue(result.success)
        XCTAssertNil(result.errorCode)
        
        guard let request = mockSession.lastRequest else {
            XCTFail("No request was made")
            return
        }
        XCTAssertTrue(request.url?.absoluteString.contains("/api/v1/auth/signup/otp") == true)
    }
    
    func testVerifySignupOTPSuccess() async throws {
        
        let expectedResponse = NeuroNote_UIKit.OTPResponse(success: true, errorCode: nil)
        mockSession.nextData = try JSONEncoder().encode(expectedResponse)
        mockSession.nextResponse = HTTPURLResponse(
            url: URL(string: "https://tests.com")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )
        
        let result = try await otpManager.verifyOTP("123456", userId: "test_user", purpose: .Signup)
        
        XCTAssertTrue(result.success)
        XCTAssertNil(result.errorCode)
        
        // Verify the correct endpoint was called
        guard let request = mockSession.lastRequest else {
            XCTFail("No request was made")
            return
        }
        XCTAssertTrue(request.url?.absoluteString.contains("/api/v1/auth/signup/otp/verify") == true)
    }
    
    // MARK: - Forgot Password OTP Tests
    
    func testRequestForgotPasswordOTPSuccess() async throws {
        
        let expectedResponse = NeuroNote_UIKit.OTPResponse(success: true, errorCode: nil)
        mockSession.nextData = try JSONEncoder().encode(expectedResponse)
        mockSession.nextResponse = HTTPURLResponse(
            url: URL(string: "https://tests.com")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )
        
        let requestData = ForgotPasswordOTPRequest(email: "test@example.com")
        let result = try await otpManager.requestOTP(requestData: requestData, purpose: .ForgotPassword)
        
        XCTAssertTrue(result.success)
        XCTAssertNil(result.errorCode)
        
        // Verify the correct endpoint was called
        guard let request = mockSession.lastRequest else {
            XCTFail("No request was made")
            return
        }
        XCTAssertTrue(request.url?.absoluteString.contains("/api/v1/auth/password/otp") == true)
    }
    
    func testVerifyForgotPasswordOTPSuccess() async throws {
        
        let expectedResponse = NeuroNote_UIKit.OTPResponse(success: true, errorCode: nil)
        mockSession.nextData = try JSONEncoder().encode(expectedResponse)
        mockSession.nextResponse = HTTPURLResponse(
            url: URL(string: "https://tests.com")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )
        
        let result = try await otpManager.verifyOTP("123456", userId: "test_user", purpose: .ForgotPassword)
        
        XCTAssertTrue(result.success)
        XCTAssertNil(result.errorCode)
        
        // Verify the correct endpoint was called
        guard let request = mockSession.lastRequest else {
            XCTFail("No request was made")
            return
        }
        XCTAssertTrue(request.url?.absoluteString.contains("/api/v1/auth/password/otp/verify") == true)
    }
    
    // MARK: - Error Handling Tests
    
    func testRequestOTPWithAPIError() async throws {
        
        let errorResponse = APIErrorResponse(success: false, error: APIError(code: "AUTH_001", message: "Invalid email", status: 400), data: nil)
        mockSession.nextData = try JSONEncoder().encode(errorResponse)
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
        
        let errorResponse = APIErrorResponse(success: false, error: APIError(code: "OTP_004", message: "Invalid OTP", status: 400), data: nil)
        mockSession.nextData = try JSONEncoder().encode(errorResponse)
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
        
        let expectedResponse = NeuroNote_UIKit.OTPResponse(success: true, errorCode: nil)
        mockSession.nextData = try JSONEncoder().encode(expectedResponse)
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
        
        let expectedResponse = NeuroNote_UIKit.OTPResponse(success: true, errorCode: nil)
        mockSession.nextData = try JSONEncoder().encode(expectedResponse)
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
