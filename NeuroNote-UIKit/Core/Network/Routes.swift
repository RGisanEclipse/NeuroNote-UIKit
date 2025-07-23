//
//  Route.swift
//  NeuroNote
//
//  Created by Eclipse on 05/07/25.
//

import Foundation

enum Routes {

    static let base = "http://127.0.0.1:8080"   // Base URL, shall be updated to production later
    static let signUp = "/signup"
    static let signIn = "/signin"
    static let requestOTP = "/auth/request-otp"
    static let verifyOTP = "/auth/verify-otp"
}
