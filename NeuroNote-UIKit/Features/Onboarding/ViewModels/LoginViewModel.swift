//
//  LoginViewModel.swift
//  NeuroNote
//
//  Created by Eclipse on 29/06/25.
//

import Foundation

struct AlertContent {
    let title: String
    let message: String
    let shouldBeRed: Bool
    let animationName: String
}

@MainActor
class LoginViewModel {
    
    var onMessage: ((AlertContent) -> Void)?
    var onAsyncStart: (() -> Void)?
    var onSigninSuccess: (() -> Void)?
    var onForgotPasswordOTPSuccess: (() -> Void)?
    var onOTPRequired: (() -> Void)?
    
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
        guard !email.isEmpty else{
            onMessage?(AuthAlert.fieldsMissing)
            return
        }
        if let emailAlert = EmailValidator.validate(email: email){
            onMessage?(emailAlert)
            return
        }
        // Network call to Backend
        Task{ [weak self] in
            guard let self = self else { return }
            onAsyncStart?()
            do {
                let otpResponse = try await otpManager.requestOTP(requestData: ForgotPasswordOTPRequest(email: email), purpose: OTPPurpose.ForgotPassword)
                if otpResponse.success {
                    // Ask the view controller to navigate back to the OTP screen
                    self.onForgotPasswordOTPSuccess?()
                }
            } catch {
                // If the success is false, it's going to automatically catch the APIError/NetworkError
                // and show the alert
                let alertContent: AlertContent
                
                Logger.shared.error("Error during Forgot Password Request", fields: [
                    "email": email,
                    "errorType": String(describing: type(of: error)),
                    "error": error.localizedDescription
                ])
                
                if let apiError = error as? APIError {
                    if let authCode = AuthServerCode(rawValue: apiError.code) {
                        alertContent = authCode.presentation
                    }
                    else {
                        alertContent = AuthAlert.unknown
                    }
                }
                
                else if let networkErr = error as? NetworkError {
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
            
            if let validationError = PasswordValidator.validate(password, email: email) {
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
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        self.onSigninSuccess?()
                    }
                } else {
                    guard let userId = KeychainHelper.standard.getUserID() else {
                        Logger.shared.error("User Id not found in Keychain")
                        return
                    }
                    let otpResponse = try await otpManager.requestOTP(requestData: SignupOTPRequest(userId: userId), purpose: OTPPurpose.Signup)
                    if otpResponse.success {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                            self.onOTPRequired?()
                        }
                    } else {
                        throw APIError(code: "UNKNOWN", message: "OTP request failed", status: 0)
                    }
                }
            }
            catch {
                let alertContent: AlertContent
                
                Logger.shared.error("Error during Auth", fields: [
                    "email": email,
                    "mode": mode == .signup ? "signup" : "signin",
                    "errorType": String(describing: type(of: error)),
                    "error": error.localizedDescription
                ])
                
                if let apiError = error as? APIError {
                    if let authCode = AuthServerCode(rawValue: apiError.code) {
                        alertContent = authCode.presentation
                    }
                    else {
                        alertContent = AuthAlert.unknown
                    }
                }
                
                else if let networkErr = error as? NetworkError {
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
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    self.onMessage?(alertContent)
                }
            }
        }
    }
}
