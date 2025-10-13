//
//  OTPRequest.swift
//  NeuroNote-UIKit
//
//  Created by Eclipse on 17/08/25.
//

struct SignupOTPRequest: OTPRequestData {
    let userId: String
}

struct ForgotPasswordOTPRequest: OTPRequestData {
    let email: String
}
