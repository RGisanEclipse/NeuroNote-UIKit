//
//  AuthResponse.swift
//  NeuroNote
//
//  Created by Eclipse on 05/07/25.
//

struct AuthResponse: Codable {
    let success: Bool
    let message: String
    let data: AuthData
}

struct AuthData: Codable {
    let token: String?
    let isVerified: Bool?
}
