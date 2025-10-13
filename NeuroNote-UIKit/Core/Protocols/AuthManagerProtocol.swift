//
//  AuthManagerProtocol.swift
//  NeuroNote-UIKit
//
//  Created by Eclipse on 13/10/25.
//

protocol AuthManagerProtocol {
    func authenticate(
        email: String,
        password: String,
        mode: AuthManager.Mode
    ) async throws -> AuthSession
    
    func resetPassword(
        payload: ResetPasswordRequest
    ) async throws -> Bool
}
