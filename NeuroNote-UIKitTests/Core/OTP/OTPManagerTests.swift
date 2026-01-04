//
//  OTPManagerTests.swift
//  NeuroNote-UIKit
//
//  Created by Eclipse on 20/07/25.
//

import XCTest
@testable import NeuroNote_UIKit

final class OTPManagerTests: XCTestCase {
    
    var mockAPIClient: MockAPIClient!
    var otpManager: OTPManager!
    
    override func setUp() {
        super.setUp()
        mockAPIClient = MockAPIClient()
        otpManager = OTPManager(apiClient: mockAPIClient)
    }
    
    override func tearDown() {
        super.tearDown()
        KeychainHelper.standard.clearTestKeys()
        mockAPIClient.reset()
        mockAPIClient = nil
        otpManager = nil
    }
    
    // MARK: - Helper Methods
    
    private func makeSuccessResponse() -> SuccessAPIResponse {
        return SuccessAPIResponse(
            success: true,
            status: 200,
            response: SuccessMessageData(success: true, message: "OTP sent successfully")
        )
    }
    
    private func makeHTTPResponse(withUserIdCookie: Bool = false) -> HTTPURLResponse {
        var headers: [String: String]? = nil
        if withUserIdCookie {
            headers = ["Set-Cookie": "userId=test_user_id; Path=/; HttpOnly"]
        }
        return HTTPURLResponse(
            url: URL(string: "https://tests.com")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: headers
        )!
    }
    
    // MARK: - Signup OTP Tests
    
    func testRequestSignupOTPSuccess() async throws {
        // Given
        mockAPIClient.mockResponseData = makeSuccessResponse()
        mockAPIClient.mockHTTPResponse = makeHTTPResponse()
        
        let requestData = SignupOTPRequest(userId: "test_user")
        
        // When
        let result = try await otpManager.requestOTP(requestData: requestData, purpose: .Signup)
        
        // Then
        XCTAssertTrue(result.success)
        XCTAssertEqual(mockAPIClient.lastEndpoint, Routes.requestSignupOTP)
        XCTAssertEqual(mockAPIClient.lastMethod, .post)
    }
    
    func testVerifySignupOTPSuccess() async throws {
        // Given
        mockAPIClient.mockResponseData = makeSuccessResponse()
        mockAPIClient.mockHTTPResponse = makeHTTPResponse()
        
        // When
        let result = try await otpManager.verifyOTP("123456", userId: "test_user", purpose: .Signup)
        
        // Then
        XCTAssertTrue(result.success)
        XCTAssertEqual(mockAPIClient.lastEndpoint, Routes.verifySignupOTP)
        XCTAssertEqual(mockAPIClient.lastMethod, .post)
    }
    
    // MARK: - Forgot Password OTP Tests
    
    func testRequestForgotPasswordOTPSuccess() async throws {
        // Given
        mockAPIClient.mockResponseData = makeSuccessResponse()
        mockAPIClient.mockHTTPResponse = makeHTTPResponse(withUserIdCookie: true)
        
        let requestData = ForgotPasswordOTPRequest(email: "test@example.com")
        
        // When
        let result = try await otpManager.requestOTP(requestData: requestData, purpose: .ForgotPassword)
        
        // Then
        XCTAssertTrue(result.success)
        XCTAssertEqual(mockAPIClient.lastEndpoint, Routes.requestForgotPasswordOTP)
        XCTAssertEqual(mockAPIClient.lastMethod, .post)
    }
    
    func testVerifyForgotPasswordOTPSuccess() async throws {
        // Given
        mockAPIClient.mockResponseData = makeSuccessResponse()
        mockAPIClient.mockHTTPResponse = makeHTTPResponse()
        
        // When
        let result = try await otpManager.verifyOTP("123456", userId: "test_user", purpose: .ForgotPassword)
        
        // Then
        XCTAssertTrue(result.success)
        XCTAssertEqual(mockAPIClient.lastEndpoint, Routes.verifyForgotPasswordOTP)
        XCTAssertEqual(mockAPIClient.lastMethod, .post)
    }
    
    // MARK: - Error Handling Tests
    
    func testRequestOTPWithAPIError() async throws {
        // Given
        let apiError = APIError(code: "AUTH_001", message: "Invalid email", status: 400, data: nil)
        mockAPIClient.mockError = apiError
        
        let requestData = SignupOTPRequest(userId: "test_user")
        
        // When & Then
        do {
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
        // Given
        let apiError = APIError(code: "OTP_004", message: "Invalid OTP", status: 400, data: nil)
        mockAPIClient.mockError = apiError
        
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

    // MARK: - Network Error Tests
    
    func testRequestOTPWithNetworkError() async throws {
        // Given
        mockAPIClient.mockError = NetworkError.noInternet
        let requestData = SignupOTPRequest(userId: "test_user")
        
        // When & Then
        do {
            _ = try await otpManager.requestOTP(requestData: requestData, purpose: .Signup)
            XCTFail("Expected NetworkError to be thrown")
        } catch let error as NetworkError {
            XCTAssertEqual(error, .noInternet)
        } catch {
            XCTFail("Expected NetworkError, got \(type(of: error))")
        }
    }
    
    func testVerifyOTPWithNetworkError() async throws {
        // Given
        mockAPIClient.mockError = NetworkError.timeout
        
        // When & Then
        do {
            _ = try await otpManager.verifyOTP("123456", userId: "test_user", purpose: .Signup)
            XCTFail("Expected NetworkError to be thrown")
        } catch let error as NetworkError {
            XCTAssertEqual(error, .timeout)
        } catch {
            XCTFail("Expected NetworkError, got \(type(of: error))")
        }
    }
    
    // MARK: - Endpoint Verification Tests
    
    func testSignupOTPUsesCorrectEndpoint() async throws {
        // Given
        mockAPIClient.mockResponseData = makeSuccessResponse()
        mockAPIClient.mockHTTPResponse = makeHTTPResponse()
        
        // When
        let requestData = SignupOTPRequest(userId: "test_user")
        _ = try await otpManager.requestOTP(requestData: requestData, purpose: .Signup)
        
        // Then
        XCTAssertEqual(mockAPIClient.lastEndpoint, Routes.requestSignupOTP)
    }
    
    func testForgotPasswordOTPUsesCorrectEndpoint() async throws {
        // Given
        mockAPIClient.mockResponseData = makeSuccessResponse()
        mockAPIClient.mockHTTPResponse = makeHTTPResponse()
        
        // When
        let requestData = ForgotPasswordOTPRequest(email: "test@example.com")
        _ = try await otpManager.requestOTP(requestData: requestData, purpose: .ForgotPassword)
        
        // Then
        XCTAssertEqual(mockAPIClient.lastEndpoint, Routes.requestForgotPasswordOTP)
    }
    
    func testVerifySignupOTPUsesCorrectEndpoint() async throws {
        // Given
        mockAPIClient.mockResponseData = makeSuccessResponse()
        mockAPIClient.mockHTTPResponse = makeHTTPResponse()
        
        // When
        _ = try await otpManager.verifyOTP("123456", userId: "test_user", purpose: .Signup)
        
        // Then
        XCTAssertEqual(mockAPIClient.lastEndpoint, Routes.verifySignupOTP)
    }
    
    func testVerifyForgotPasswordOTPUsesCorrectEndpoint() async throws {
        // Given
        mockAPIClient.mockResponseData = makeSuccessResponse()
        mockAPIClient.mockHTTPResponse = makeHTTPResponse()
        
        // When
        _ = try await otpManager.verifyOTP("123456", userId: "test_user", purpose: .ForgotPassword)
        
        // Then
        XCTAssertEqual(mockAPIClient.lastEndpoint, Routes.verifyForgotPasswordOTP)
    }
    
    // MARK: - Request Count Tests
    
    func testMultipleOTPRequestsTracked() async throws {
        // Given
        mockAPIClient.mockResponseData = makeSuccessResponse()
        mockAPIClient.mockHTTPResponse = makeHTTPResponse()
        
        // When
        let requestData = SignupOTPRequest(userId: "test_user")
        _ = try await otpManager.requestOTP(requestData: requestData, purpose: .Signup)
        _ = try await otpManager.requestOTP(requestData: requestData, purpose: .Signup)
        _ = try await otpManager.requestOTP(requestData: requestData, purpose: .Signup)
        
        // Then
        XCTAssertEqual(mockAPIClient.requestCount, 3)
    }
}
