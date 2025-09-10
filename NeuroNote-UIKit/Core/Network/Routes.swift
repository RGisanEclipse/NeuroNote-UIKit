//
//  Route.swift
//  NeuroNote
//
//  Created by Eclipse on 05/07/25.
//

import Foundation

enum Routes {

    static let base = "https://127.0.0.1:8443"   // Base URL, shall be updated to production later
    static let signUp = "/api/v1/auth/signup"
    static let signIn = "/api/v1/auth/signin"
    static let requestOTP = "/api/v1/auth/otp/request"
    static let verifyOTP = "/api/v1/auth/otp/verify"
    static let refreshToken = "/api/v1/auth/token/refresh"
}
