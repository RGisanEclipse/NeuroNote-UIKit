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
    var serverMessageToThrow: AuthServerCode = .internalServerError
    
    func authenticate(email: String, password: String, mode: AuthManager.Mode) async throws -> AuthSession {
        if shouldThrowServerError {
            throw AuthError.server(serverMessageToThrow)
        }
        
        if shouldThrowUnknownError {
            throw NSError(domain: "Test", code: -1, userInfo: nil)
        }
        
        return AuthSession(token: "mock_user_token_123", refreshToken: "random_refresh_token", isVerified: true)
    }
}
