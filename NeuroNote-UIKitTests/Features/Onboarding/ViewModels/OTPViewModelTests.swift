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
        
        var shouldThrow: Error?
        var didCallVerify = false
        var didCallRequest = false
        
        func verifyOTP(_ otp: String, purpose: OTPPurpose) async throws -> OTPResponse{
            didCallVerify = true
            if let error = shouldThrow {
                throw error
            }
            return OTPResponse(success: true, errorMessage: nil)
        }
        
        func requestOTP(purpose: OTPPurpose) async throws -> OTPResponse {
            didCallRequest = true
            if let error = shouldThrow {
                throw error
            }
            return OTPResponse(success: true, errorMessage: nil)
        }
    }
    
    class MockUserIDStore: UserIDStore {
        func saveUserID(_ userID: String) {}
        func getUserID() -> String? { return Constants.Tests.userId }
        func deleteUserID() {}
    }
    
    @MainActor
    func testVerifyOTPSuccess() {
        let mockManager = MockOTPManager()
        let viewModel = OTPViewModel(manager: mockManager, userIdStore: MockUserIDStore())
        
        let exp = expectation(description: "OTP verified")
        viewModel.onOTPVerified = { exp.fulfill() }
        viewModel.onAsyncStart = {}
        viewModel.onAsyncEnd = {}
        
        viewModel.verify(otp: Constants.Tests.otp, purpose: OTPPurpose.signup)
        
        wait(for: [exp], timeout: 2)
        XCTAssertTrue(mockManager.didCallVerify)
    }
    
    @MainActor
    func testVerifyOTPFailure() {
        let mockManager = MockOTPManager()
        mockManager.shouldThrow = OTPError.serverError(.otpVerificationFailed)
        let viewModel = OTPViewModel(manager: mockManager, userIdStore: MockUserIDStore())
        
        let exp = expectation(description: "OTP failed")
        viewModel.onOTPFailed = { exp.fulfill() }
        viewModel.onAsyncStart = {}
        viewModel.onAsyncEnd = {}
        
        viewModel.verify(otp: Constants.Tests.otp, purpose: OTPPurpose.signup)
        
        wait(for: [exp], timeout: 2)
        XCTAssertTrue(mockManager.didCallVerify)
    }
    
    @MainActor
    func testResendOTPSuccess() {
        let mockManager = MockOTPManager()
        let viewModel = OTPViewModel(manager: mockManager, userIdStore: MockUserIDStore())
        
        let exp = expectation(description: "Timer started")
        viewModel.onTimerUpdate = { remaining in
            if remaining == 59 {
                exp.fulfill()
            }
        }
        viewModel.onAsyncStart = {}
        viewModel.onAsyncEnd = {}
        
        viewModel.resendOTP(purpose: OTPPurpose.signup)
        
        wait(for: [exp], timeout: 2)
        XCTAssertTrue(mockManager.didCallRequest)
    }
    
    @MainActor
    func testResendOTPNetworkError() {
        let mockManager = MockOTPManager()
        mockManager.shouldThrow = NetworkError.noInternet
        let viewModel = OTPViewModel(manager: mockManager, userIdStore: MockUserIDStore())
        
        let exp = expectation(description: "Network error")
        viewModel.onNetworkError = { message in
            XCTAssertTrue(message.contains("Please check your internet connection"))
            exp.fulfill()
        }
        viewModel.onAsyncStart = {}
        viewModel.onAsyncEnd = {}
        
        viewModel.resendOTP(purpose: OTPPurpose.signup)
        
        wait(for: [exp], timeout: 2)
        XCTAssertTrue(mockManager.didCallRequest)
    }
}
