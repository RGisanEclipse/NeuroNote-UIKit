//
//  Route.swift
//  AVYO
//
//  Created by Eclipse on 05/07/25.
//

import Foundation

struct Route {
    let path: String
    let method: HTTPMethod
}

enum Routes {
    // Auth Service Routes
    static let base                     = "https://192.168.1.4:8443"   // Base URL, shall be updated to production later
    static let signUp                   = Route(path: "/api/v1/auth/signup", method: .post)
    static let signIn                   = Route(path: "/api/v1/auth/signin", method: .post)
    static let requestSignupOTP         = Route(path: "/api/v1/auth/signup/otp", method: .post)
    static let verifySignupOTP          = Route(path: "/api/v1/auth/signup/otp/verify", method: .post)
    static let requestForgotPasswordOTP = Route(path: "/api/v1/auth/password/otp", method: .post)
    static let verifyForgotPasswordOTP  = Route(path: "/api/v1/auth/password/otp/verify", method: .post)
    static let resetPassword            = Route(path: "/api/v1/auth/password/reset", method: .post)
    static let refreshToken             = Route(path: "/api/v1/auth/token/refresh", method: .post)
    static let onboardUser              = Route(path: "/api/v1/onboarding/onboard", method: .post)
    
    // Mood Service Routes
    static let logMood                  = Route(path: "/api/v1/mood", method: .post)
    
    // Dashboard Routes
    static let dashboard                = Route(path: "/api/v1/dashboard", method: .get)
    static let monthlyTopMoods          = Route(path: "/api/v1/mood/monthly/top-moods", method: .get)
    static let weeklyMoodStrip          = Route(path: "/api/v1/mood/weekly/mood-strip", method: .get)
    static let syncDashboard            = Route(path: "/api/v1/dashboard/sync", method: .post)
}
