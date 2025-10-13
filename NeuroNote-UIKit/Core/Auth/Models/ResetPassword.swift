//
//  ResetPasswordRequest.swift
//  NeuroNote-UIKit
//
//  Created by Eclipse on 13/10/25.
//

struct ResetPasswordRequest: Codable {
    let userId: String
    let password: String
}

struct ResetPasswordResponse: Codable {
    let success: Bool
    let message: String?
}
