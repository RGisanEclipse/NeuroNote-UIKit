//
//  OTPVerifyRequest.swift
//  NeuroNote-UIKit
//
//  Created by Eclipse on 20/07/25.
//

struct OTPVerifyRequest: Encodable {
    let code: String
    let userId: String
}
