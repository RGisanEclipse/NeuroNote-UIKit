//
//  OTPVerifyRequest.swift
//  NeuroNote-UIKit
//
//  Created by Eclipse on 20/07/25.
//

struct OTPVerifyRequest: Encodable {
    let otp: String
    let purpose: String
}
