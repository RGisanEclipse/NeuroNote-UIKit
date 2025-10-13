//
//  MockAuthManager.swift
//  NeuroNote
//
//  Created by Eclipse on 09/07/25.
//

import Foundation
@testable import NeuroNote_UIKit

class MockAuthManager: AuthManagerProtocol {
    
    var shouldThrowServerError = false
    var shouldThrowUnknownError = false
    var shouldThrowNetworkError = false
    var shouldThrowAPIError = false
    var serverMessageToThrow: AuthServerCode = .internalServerError
    var resetPasswordShouldSucceed = true
    var resetPasswordDelay: TimeInterval = 0.1
    
    func authenticate(email: String, password: String, mode: AuthManager.Mode) async throws -> AuthSession {
        if shouldThrowServerError {
            throw AuthError.server(serverMessageToThrow)
        }
        
        if shouldThrowUnknownError {
            throw NSError(domain: "Test", code: -1, userInfo: nil)
        }
        
        return AuthSession(token: "mock_user_token_123", refreshToken: "random_refresh_token", isVerified: true)
    }
    
    func resetPassword(payload: ResetPasswordRequest) async throws -> Bool {
        // Simulate network delay
        try await Task.sleep(nanoseconds: UInt64(resetPasswordDelay * 1_000_000_000))
        
        if shouldThrowNetworkError {
            throw NetworkError.noInternet
        }
        
        if shouldThrowAPIError {
            throw APIError(code: "API-ERROR", message: "Internal Server Error", status: 500)
        }
        
        if shouldThrowServerError {
            throw AuthError.server(serverMessageToThrow)
        }
        
        if shouldThrowUnknownError {
            throw NSError(domain: "Test", code: -1, userInfo: nil)
        }
        
        return resetPasswordShouldSucceed
    }
}
