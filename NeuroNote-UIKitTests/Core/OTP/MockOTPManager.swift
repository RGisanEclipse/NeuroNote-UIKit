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

    func requestOTP(userId: String, purpose: NeuroNote_UIKit.OTPPurpose) async throws -> NeuroNote_UIKit.OTPResponse {
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
