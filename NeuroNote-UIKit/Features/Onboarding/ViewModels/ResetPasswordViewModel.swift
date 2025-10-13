//
//  ResetPasswordViewModel.swift
//  NeuroNote-UIKit
//
//  Created by Eclipse on 13/10/25.
//

import Foundation

@MainActor
class ResetPasswordViewModel{
    
    // MARK: - Properties
    var onMessage: ((AlertContent)->Void)?
    var onAsyncStart: (() -> Void)?
    var onResetSuccess: (() -> Void)?
    
    private let authManager: AuthManagerProtocol
    init(
        authManager: AuthManagerProtocol = AuthManager.shared
    ) {
        self.authManager = authManager
    }
    
    func submitButtonTapped(password: String, confirmPassword: String){
        if password != confirmPassword{
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
                let alertContent: AlertContent
                
                Logger.shared.error("Error during Password Reset", fields: [
                    "userId": userId,
                    "errorType": String(describing: type(of: error)),
                    "error": error.localizedDescription
                ])
                
                if let apiError = error as? APIError {
                    if let authCode = AuthServerCode(rawValue: apiError.code) {
                        alertContent = authCode.presentation
                    } else {
                        alertContent = AuthAlert.unknown
                    }
                } else if let networkErr = error as? NetworkError {
                    switch networkErr {
                    case .noInternet:
                        alertContent = NetworkAlert.noInternet
                    case .timeout:
                        alertContent = NetworkAlert.timeout
                    case .cannotReachServer:
                        alertContent = NetworkAlert.cannotReachServer
                    case .generic(let msg):
                        alertContent = NetworkAlert.generic(msg)
                    }
                } else {
                    alertContent = AuthAlert.unknown
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.onMessage?(alertContent)
                }
            }
        }
    }
}
