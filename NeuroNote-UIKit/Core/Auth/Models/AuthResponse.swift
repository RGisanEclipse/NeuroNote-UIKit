//
//  AuthResponse.swift
//  NeuroNote
//
//  Created by Eclipse on 05/07/25.
//

struct AuthResponse: Codable {
    let success: Bool
    let message: String
    let token: String?
    let userId: String?
}
