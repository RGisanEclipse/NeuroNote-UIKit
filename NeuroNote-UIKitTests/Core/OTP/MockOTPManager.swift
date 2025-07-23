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
    var simulateServerError: OTPServerMessage?

    func verifyOTP(_ otp: String) async throws -> OTPVerifyResponse{
        if let networkError = simulateNetworkError {
            throw networkError
        }
        if let serverError = simulateServerError {
            throw OTPError.serverError(serverError)
        }
        if !shouldSucceed {
            throw OTPError.serverError(.otpVerificationFailed)
        }
        return OTPVerifyResponse(
            success: true,
            message: nil)
    }

    func requestOTP() async throws -> OTPResponse {
        if let networkError = simulateNetworkError {
            throw networkError
        }
        if !shouldSucceed {
            throw OTPError.serverError(.deliveryFailed)
        }
        return OTPResponse(success: true, errorMessage: nil)
    }
}
