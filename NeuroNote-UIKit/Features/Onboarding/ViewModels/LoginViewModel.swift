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
    private let authManager: AuthManagerProtocol
    
    init(authManager: AuthManagerProtocol = AuthManager.shared) {
        self.authManager = authManager
    }
    
    func forgotPasswordButtonTapped(email: String) {
        onMessage?(AlertContent(
            title: "Forgot Password?",
            message: "Don't worry, we've got you!",
            shouldBeRed: false,
            animationName: Constants.animations.unsureStar
        ))
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
        
        if mode == .signup, password != confirmPassword {
            onMessage?(AuthAlert.passwordMismatch)
            return
        }
        
        if mode == .signup, let validationError = PasswordValidator.validate(password, email: email) {
            onMessage?(validationError)
            return
        }
        
        Task {
            do {
                _ = try await authManager.authenticate(
                    email: email,
                    password: password,
                    mode: mode == .signup ? .signup : .signin
                )
                
                let alert = mode == .signup ? AuthAlert.signupSuccess
                : AuthAlert.signinSuccess
                onMessage?(alert)
                
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
                
                onMessage?(alertContent)
            }
        }
    }
}
