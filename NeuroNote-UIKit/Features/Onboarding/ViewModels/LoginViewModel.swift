//
//  LoginViewModel.swift
//  NeuroNote
//
//  Created by Eclipse on 29/06/25.
//

import Foundation

@MainActor
class LoginViewModel {
    
    var onMessage:                  ((AlertContent) -> Void)?
    var onAsyncStart:               (() -> Void)?
    var onSigninSuccess:            ((Bool) -> Void)?
    var onForgotPasswordOTPSuccess: (() -> Void)?
    var onOTPRequired:              (() -> Void)?
    var onOnboardingRequired:       (() -> Void)?
    
    private let authManager: AuthManagerProtocol
    private let otpManager: OTPManagerProtocol
    init(
        authManager: AuthManagerProtocol = AuthManager.shared,
        otpManager: OTPManagerProtocol = OTPManager.shared
    ) {
        self.authManager = authManager
        self.otpManager = otpManager
    }
    
    func forgotPasswordButtonTapped(email: String) {
        guard !email.isEmpty else {
            onMessage?(AuthAlert.fieldsMissing)
            return
        }
        if let emailAlert = EmailValidator.validate(email: email) {
            onMessage?(emailAlert)
            return
        }
        // Network call to Backend
        Task { [weak self] in
            guard let self = self else { return }
            onAsyncStart?()
            do {
                _ = try await otpManager.requestOTP(
                    requestData: ForgotPasswordOTPRequest(email: email),
                    purpose: OTPPurpose.ForgotPassword
                )
                self.onForgotPasswordOTPSuccess?()
            } catch {
                let alertContent = mapErrorToAlert(error, context: ["email": email])
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    self.onMessage?(alertContent)
                }
            }
        }
    }
    
    @MainActor
    func signInButtonTapped(email: String,
                            password: String,
                            confirmPassword: String?,
                            mode: AuthMode)
    {
        guard !email.isEmpty, !password.isEmpty else {
            onMessage?(AuthAlert.fieldsMissing)
            return
        }
        
        if let emailAlert = EmailValidator.validate(email: email) {
            onMessage?(emailAlert)
            return
        }
        
        if mode == .signup {
            if password != confirmPassword {
                onMessage?(AuthAlert.passwordMismatch)
                return
            }
            
            if let validationError = PasswordValidator.validate(password) {
                onMessage?(validationError)
                return
            }
        }
        
        Task { [weak self] in
            guard let self = self else { return }
            onAsyncStart?()
            do {
                let session = try await authManager.authenticate(
                    email: email,
                    password: password,
                    mode: mode == .signup ? .signup : .signin
                )
                
                if session.isVerified {
                    if session.isOnboarded {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                            self.onSigninSuccess?(true)
                        }
                    } else{
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                            self.onSigninSuccess?(false)
                        }
                    }
                    
                } else {
                    guard let userId = KeychainHelper.standard.getUserID() else {
                        Logger.shared.error("User Id not found in Keychain")
                        return
                    }
                    _ = try await otpManager.requestOTP(
                        requestData: SignupOTPRequest(userId: userId),
                        purpose: OTPPurpose.Signup
                    )
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        self.onOTPRequired?()
                    }
                }
            }
            catch {
                let alertContent = mapErrorToAlert(error, context: [
                    "email": email,
                    "mode": mode == .signup ? "signup" : "signin"
                ])
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
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
        
        Logger.shared.error("API Error", fields: logFields)
        
        if let apiError = error as? APIError {
            return apiError.serverCode.presentation
        }
        
        if let networkErr = error as? NetworkError {
            return networkErr.presentation
        }
        
        return AuthAlert.unknown
    }
}
