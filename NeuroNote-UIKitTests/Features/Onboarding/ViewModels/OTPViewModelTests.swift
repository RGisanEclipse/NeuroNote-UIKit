//
//  OTPViewModelTests.swift
//  NeuroNote-UIKitTests
//
//  Created by Eclipse on 20/07/25.
//

import XCTest
@testable import NeuroNote_UIKit

final class OTPViewModelTests: XCTestCase {
    
    class MockOTPManager: OTPManagerProtocol {
        var shouldSucceed = true
        var simulateNetworkError: NetworkError?
        var simulateAPIError: APIError?
        var didCallVerify = false
        var didCallRequest = false
        var lastVerifyCode: String?
        var lastVerifyUserId: String?
        var lastVerifyPurpose: NeuroNote_UIKit.OTPPurpose?
        var lastRequestUserId: String?
        var lastRequestPurpose: NeuroNote_UIKit.OTPPurpose?
        
        func requestOTP(userId: String, purpose: NeuroNote_UIKit.OTPPurpose) async throws -> NeuroNote_UIKit.OTPResponse {
            didCallRequest = true
            lastRequestUserId = userId
            lastRequestPurpose = purpose
            
            if let networkError = simulateNetworkError {
                throw networkError
            }
            if let apiError = simulateAPIError {
                throw apiError
            }
            if !shouldSucceed {
                throw APIError(code: "AUTH_014", message: "failed to send OTP", status: 500)
            }
            return NeuroNote_UIKit.OTPResponse(success: true, errorCode: nil)
        }
        
        func verifyOTP(_ code: String, userId: String, purpose: NeuroNote_UIKit.OTPPurpose) async throws -> NeuroNote_UIKit.OTPResponse {
            didCallVerify = true
            lastVerifyCode = code
            lastVerifyUserId = userId
            lastVerifyPurpose = purpose
            
            if let networkError = simulateNetworkError {
                throw networkError
            }
            if let apiError = simulateAPIError {
                throw apiError
            }
            if !shouldSucceed {
                throw APIError(code: "OTP_004", message: "invalid otp", status: 400)
            }
            return NeuroNote_UIKit.OTPResponse(success: true, errorCode: nil)
        }
    }
    
    class MockUserIDStore: UserIDStore {
        var storedUserID: String?
        
        func saveUserID(_ userID: String) {
            storedUserID = userID
        }
        
        func getUserID() -> String? {
            return storedUserID ?? "test_user"
        }
        
        func deleteUserID() {
            storedUserID = nil
        }
    }
    
    var mockOTPManager: MockOTPManager!
    var mockUserIDStore: MockUserIDStore!
    var viewModel: OTPViewModel!
    
    override func setUp() {
        super.setUp()
        mockOTPManager = MockOTPManager()
        mockUserIDStore = MockUserIDStore()
        viewModel = OTPViewModel(manager: mockOTPManager, userIdStore: mockUserIDStore)
    }
    
    override func tearDown() {
        super.tearDown()
        mockOTPManager = nil
        mockUserIDStore = nil
        viewModel = nil
    }
    
    // MARK: - Signup OTP Tests
    
    @MainActor
    func testVerifySignupOTPSuccess() {
        let exp = expectation(description: "OTP verified")
        viewModel.onOTPVerified = { exp.fulfill() }
        viewModel.onAsyncStart = {}
        viewModel.onAsyncEnd = {}
        
        viewModel.verify(otp: "123456", userId: "test_user", purpose: .Signup)
        
        wait(for: [exp], timeout: 2)
        XCTAssertTrue(mockOTPManager.didCallVerify)
        XCTAssertEqual(mockOTPManager.lastVerifyCode, "123456")
        XCTAssertEqual(mockOTPManager.lastVerifyUserId, "test_user")
        XCTAssertEqual(mockOTPManager.lastVerifyPurpose, .Signup)
    }
    
    @MainActor
    func testResendSignupOTPSuccess() {
        let exp = expectation(description: "Timer started")
        viewModel.onTimerUpdate = { remaining in
            if remaining == 59 {
                exp.fulfill()
            }
        }
        viewModel.onAsyncStart = {}
        viewModel.onAsyncEnd = {}
        
        viewModel.resendOTP(userId: "test_user", purpose: .Signup)
        
        wait(for: [exp], timeout: 2)
        XCTAssertTrue(mockOTPManager.didCallRequest)
        XCTAssertEqual(mockOTPManager.lastRequestUserId, "test_user")
        XCTAssertEqual(mockOTPManager.lastRequestPurpose, .Signup)
    }
    
    // MARK: - Forgot Password OTP Tests
    
    @MainActor
    func testVerifyForgotPasswordOTPSuccess() {
        let exp = expectation(description: "OTP verified for forgot password")
        viewModel.onOTPVerified = { exp.fulfill() }
        viewModel.onAsyncStart = {}
        viewModel.onAsyncEnd = {}
        
        viewModel.verify(otp: "123456", userId: "test_user", purpose: .ForgotPassword)
        
        wait(for: [exp], timeout: 2)
        XCTAssertTrue(mockOTPManager.didCallVerify)
        XCTAssertEqual(mockOTPManager.lastVerifyCode, "123456")
        XCTAssertEqual(mockOTPManager.lastVerifyUserId, "test_user")
        XCTAssertEqual(mockOTPManager.lastVerifyPurpose, .ForgotPassword)
    }
    
    @MainActor
    func testResendForgotPasswordOTPSuccess() {
        let exp = expectation(description: "Timer started for forgot password")
        viewModel.onTimerUpdate = { remaining in
            if remaining == 59 {
                exp.fulfill()
            }
        }
        viewModel.onAsyncStart = {}
        viewModel.onAsyncEnd = {}
        
        viewModel.resendOTP(userId: "test_user", purpose: .ForgotPassword)
        
        wait(for: [exp], timeout: 2)
        XCTAssertTrue(mockOTPManager.didCallRequest)
        XCTAssertEqual(mockOTPManager.lastRequestUserId, "test_user")
        XCTAssertEqual(mockOTPManager.lastRequestPurpose, .ForgotPassword)
    }
    
    // MARK: - Error Handling Tests
    
    @MainActor
    func testVerifyOTPWithAPIError() {
        mockOTPManager.simulateAPIError = APIError(code: "OTP_004", message: "invalid otp", status: 400)
        
        let exp = expectation(description: "OTP failed")
        viewModel.onOTPFailed = { exp.fulfill() }
        viewModel.onAsyncStart = {}
        viewModel.onAsyncEnd = {}
        
        viewModel.verify(otp: "123456", userId: "test_user", purpose: .Signup)
        
        wait(for: [exp], timeout: 2)
        XCTAssertTrue(mockOTPManager.didCallVerify)
    }
    
    @MainActor
    func testVerifyOTPWithNetworkError() {
        mockOTPManager.simulateNetworkError = .noInternet
        
        let exp = expectation(description: "Network error")
        viewModel.onNetworkError = { message in
            XCTAssertTrue(message.contains("Please check your internet connection"))
            exp.fulfill()
        }
        viewModel.onAsyncStart = {}
        viewModel.onAsyncEnd = {}
        
        viewModel.verify(otp: "123456", userId: "test_user", purpose: .Signup)
        
        wait(for: [exp], timeout: 2)
        XCTAssertTrue(mockOTPManager.didCallVerify)
    }
    
    @MainActor
    func testResendOTPWithAPIError() {
        mockOTPManager.simulateAPIError = APIError(code: "AUTH_014", message: "failed to send OTP", status: 500)
        
        let exp = expectation(description: "Server error")
        viewModel.onServerError = { exp.fulfill() }
        viewModel.onAsyncStart = {}
        viewModel.onAsyncEnd = {}
        
        viewModel.resendOTP(userId: "test_user", purpose: .Signup)
        
        wait(for: [exp], timeout: 2)
        XCTAssertTrue(mockOTPManager.didCallRequest)
    }
    
    @MainActor
    func testResendOTPWithNetworkError() {
        mockOTPManager.simulateNetworkError = .timeout
        
        let exp = expectation(description: "Network error")
        viewModel.onNetworkError = { message in
            XCTAssertTrue(message.contains("Please try again"))
            exp.fulfill()
        }
        viewModel.onAsyncStart = {}
        viewModel.onAsyncEnd = {}
        
        viewModel.resendOTP(userId: "test_user", purpose: .Signup)
        
        wait(for: [exp], timeout: 2)
        XCTAssertTrue(mockOTPManager.didCallRequest)
    }
    
    // MARK: - Async State Management Tests
    
    @MainActor
    func testAsyncStartAndEndCallbacks() {
        let startExp = expectation(description: "Async start")
        let endExp = expectation(description: "Async end")
        
        viewModel.onAsyncStart = { startExp.fulfill() }
        viewModel.onAsyncEnd = { endExp.fulfill() }
        
        viewModel.verify(otp: "123456", userId: "test_user", purpose: .Signup)
        
        wait(for: [startExp, endExp], timeout: 2, enforceOrder: true)
    }
    
    @MainActor
    func testResendAsyncStartAndEndCallbacks() {
        let startExp = expectation(description: "Async start")
        let endExp = expectation(description: "Async end")
        
        viewModel.onAsyncStart = { startExp.fulfill() }
        viewModel.onAsyncEnd = { endExp.fulfill() }
        
        viewModel.resendOTP(userId: "test_user", purpose: .Signup)
        
        wait(for: [startExp, endExp], timeout: 2, enforceOrder: true)
    }
    
    // MARK: - Error Code Handling Tests
    
    @MainActor
    func testOTP003ErrorCode() {
        mockOTPManager.simulateAPIError = APIError(code: "OTP_003", message: "OTP expired", status: 400)
        
        let exp = expectation(description: "OTP failed")
        viewModel.onOTPFailed = { exp.fulfill() }
        viewModel.onAsyncStart = {}
        viewModel.onAsyncEnd = {}
        
        viewModel.verify(otp: "123456", userId: "test_user", purpose: .Signup)
        
        wait(for: [exp], timeout: 2)
    }
    
    @MainActor
    func testOTP004ErrorCode() {
        mockOTPManager.simulateAPIError = APIError(code: "OTP_004", message: "Invalid OTP", status: 400)
        
        let exp = expectation(description: "OTP failed")
        viewModel.onOTPFailed = { exp.fulfill() }
        viewModel.onAsyncStart = {}
        viewModel.onAsyncEnd = {}
        
        viewModel.verify(otp: "123456", userId: "test_user", purpose: .Signup)
        
        wait(for: [exp], timeout: 2)
    }
    
    @MainActor
    func testUnknownErrorCode() {
        mockOTPManager.simulateAPIError = APIError(code: "UNKNOWN_ERROR", message: "Unknown error", status: 500)
        
        let exp = expectation(description: "Server error")
        viewModel.onServerError = { exp.fulfill() }
        viewModel.onAsyncStart = {}
        viewModel.onAsyncEnd = {}
        
        viewModel.verify(otp: "123456", userId: "test_user", purpose: .Signup)
        
        wait(for: [exp], timeout: 2)
    }
    
    // MARK: - Network Error Handling Tests
    
    @MainActor
    func testNoInternetError() {
        mockOTPManager.simulateNetworkError = .noInternet
        
        let exp = expectation(description: "No internet error")
        viewModel.onNetworkError = { message in
            XCTAssertTrue(message.contains("Please check your internet connection"))
            exp.fulfill()
        }
        viewModel.onAsyncStart = {}
        viewModel.onAsyncEnd = {}
        
        viewModel.verify(otp: "123456", userId: "test_user", purpose: .Signup)
        
        wait(for: [exp], timeout: 2)
    }
    
    @MainActor
    func testTimeoutError() {
        mockOTPManager.simulateNetworkError = .timeout
        
        let exp = expectation(description: "Timeout error")
        viewModel.onNetworkError = { message in
            XCTAssertTrue(message.contains("Please try again"))
            exp.fulfill()
        }
        viewModel.onAsyncStart = {}
        viewModel.onAsyncEnd = {}
        
        viewModel.verify(otp: "123456", userId: "test_user", purpose: .Signup)
        
        wait(for: [exp], timeout: 2)
    }
    
    @MainActor
    func testCannotReachServerError() {
        mockOTPManager.simulateNetworkError = .cannotReachServer
        
        let exp = expectation(description: "Cannot reach server error")
        viewModel.onNetworkError = { message in
            XCTAssertTrue(message.contains("Please try again"))
            exp.fulfill()
        }
        viewModel.onAsyncStart = {}
        viewModel.onAsyncEnd = {}
        
        viewModel.verify(otp: "123456", userId: "test_user", purpose: .Signup)
        
        wait(for: [exp], timeout: 2)
    }
    
    @MainActor
    func testGenericNetworkError() {
        mockOTPManager.simulateNetworkError = .generic(message: "Custom network error")
        
        let exp = expectation(description: NetworkAlert.generic("").title)
        viewModel.onNetworkError = { message in
            XCTAssertEqual(message, NetworkAlert.generic("").title)
            exp.fulfill()
        }
        viewModel.onAsyncStart = {}
        viewModel.onAsyncEnd = {}
        
        viewModel.verify(otp: "123456", userId: "test_user", purpose: .Signup)
        
        wait(for: [exp], timeout: 2)
    }
}
