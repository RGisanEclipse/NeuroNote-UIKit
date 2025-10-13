//
//  MockOTPManager.swift
//  NeuroNote-UIKit
//
//  Created by Eclipse on 20/07/25.
//
import Foundation
@testable import NeuroNote_UIKit

class MockOTPManager: OTPManagerProtocol {
    
    var shouldSucceed = true
    var simulateNetworkError: NetworkError?
    var simulateAPIError: APIError?
    
    // Purpose-specific responses
    var forgotPasswordShouldSucceed = true
    var signupShouldSucceed = true
    var forgotPasswordDelay: TimeInterval = 0
    var signupDelay: TimeInterval = 0

    func requestOTP(requestData: NeuroNote_UIKit.OTPRequestData, purpose: NeuroNote_UIKit.OTPPurpose) async throws -> NeuroNote_UIKit.OTPResponse {
        // Simulate network delay
        let delay = purpose == .ForgotPassword ? forgotPasswordDelay : signupDelay
        if delay > 0 {
            try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
        }
        
        if let networkError = simulateNetworkError {
            throw networkError
        }
        if let apiError = simulateAPIError {
            throw apiError
        }
        
        // Check purpose-specific success
        let shouldSucceedForPurpose = purpose == .ForgotPassword ? forgotPasswordShouldSucceed : signupShouldSucceed
        
        if !shouldSucceed || !shouldSucceedForPurpose {
            let errorCode = purpose == .ForgotPassword ? "AUTH_015" : "AUTH_014"
            let errorMessage = purpose == .ForgotPassword ? "Failed to send forgot password OTP" : "Failed to send signup OTP"
            throw APIError(code: errorCode, message: errorMessage, status: 500)
        }
        
        return NeuroNote_UIKit.OTPResponse(success: true, errorCode: nil)
    }
    
    func verifyOTP(_ code: String, userId: String, purpose: NeuroNote_UIKit.OTPPurpose) async throws -> NeuroNote_UIKit.OTPResponse {
        if let networkError = simulateNetworkError {
            throw networkError
        }
        if let apiError = simulateAPIError {
            throw apiError
        }
        if !shouldSucceed {
            throw APIError(code: "OTP_004", message: "invalid otp", status: 400)
        }
        return NeuroNote_UIKit.OTPResponse(
            success: true,
            errorCode: nil)
    }
}
