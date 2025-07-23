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
    var onSuccess: (() -> Void)?
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
        onMessage?(AuthAlert.forgotPassword)
    }
    
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
                        self.onSuccess?()
                    }
                } else {
                    let otpResponse = try await otpManager.requestOTP()
                    
                    if otpResponse.success {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                            self.onOTPRequired?()
                        }
                    } else {
                        throw OTPError.invalidResponse
                    }
                }
            }
            catch {
                let alertContent: AlertContent
                
                if let authErr = error as? AuthError,
                   case let .server(serverMsg) = authErr {
                    let pres = serverMsg.presentation
                    alertContent = AlertContent(
                        title: pres.title,
                        message: pres.message,
                        shouldBeRed: pres.shouldBeRed,
                        animationName: pres.animationName
                    )
                } else if let otpErr = error as? OTPError,
                          case .serverError(let msg) = otpErr{
                    let pres = msg.presentation
                    alertContent = AlertContent(
                        title: pres.title,
                        message: pres.message,
                        shouldBeRed: pres.shouldBeRed,
                        animationName: pres.animationName
                    )
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
