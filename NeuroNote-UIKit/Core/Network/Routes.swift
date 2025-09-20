//
//  Route.swift
//  NeuroNote
//
//  Created by Eclipse on 05/07/25.
//

import Foundation

enum Routes {
    // Auth Service Routes
    static let base                     = "https://127.0.0.1:8443"   // Base URL, shall be updated to production later
    static let signUp                   = "/api/v1/auth/signup"
    static let signIn                   = "/api/v1/auth/signin"
    static let requestSignupOTP         = "/api/v1/auth/signup/otp"
    static let verifySignupOTP          = "/api/v1/auth/signup/otp/verify"
    static let requestForgotPasswordOTP = "/api/v1/auth/password/otp"
    static let verifyForgotPasswordOTP  = "/api/v1/auth/password/otp/verify"
    static let resetPassword            = "/api/v1/auth/password/reset"
    static let refreshToken             = "/api/v1/auth/token/refresh"
}
