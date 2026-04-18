//
//  ResetPasswordViewModel.swift
//  AVYO
//
//  Created by Eclipse on 13/10/25.
//

import Foundation

@MainActor
class ResetPasswordViewModel {
    
    // MARK: - Properties
    var onMessage: ((AlertContent) -> Void)?
    var onAsyncStart: (() -> Void)?
    var onResetSuccess: (() -> Void)?
    
    private let authManager: AuthManagerProtocol
    init(
        authManager: AuthManagerProtocol = AuthManager.shared
    ) {
        self.authManager = authManager
    }
    
    func submitButtonTapped(password: String, confirmPassword: String) {
        if password != confirmPassword {
            onMessage?(AuthAlert.passwordMismatch)
            return
        }
        if let validationError = PasswordValidator.validate(password) {
            onMessage?(validationError)
            return
        }
        guard let userId = KeychainHelper.standard.getUserID() else {
            Logger.shared.error("User-Id not found")
            onMessage?(AuthAlert.unknown)
            return
        }
        
        guard ConnectivityMonitor.shared.isConnected else {
            onMessage?(NetworkError.noInternet.presentation)
            return
        }
        // Make call to Backend
        Task { [weak self] in
            guard let self = self else { return }
            onAsyncStart?()
            
            do {
                let request = ResetPasswordRequest(userId: userId, password: password)
                let success = try await authManager.resetPassword(payload: request)
                
                if success {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        self.onResetSuccess?()
                    }
                }
            } catch {
                let alertContent = mapErrorToAlert(error, context: ["userId": userId])
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.onMessage?(alertContent)
                }
            }
        }
    }
    
    // MARK: - Error Mapping Helper
    
    private func mapErrorToAlert(_ error: Error, context: [String: String] = [:]) -> AlertContent {
        var logFields: [String: Any] = [
            "errorType": String(describing: type(of: error)),
            "error": error.localizedDescription
        ]
        context.forEach { logFields[$0.key] = $0.value }
        
        Logger.shared.error("Password Reset Error", fields: logFields)
        
        if let apiError = error as? APIError {
            return apiError.presentation
        }
        
        if let clientError = error as? APIClientError {
            return clientError.presentation
        }
        
        if let networkErr = error as? NetworkError {
            return networkErr.presentation
        }
        
        return AuthAlert.unknown
    }
}
