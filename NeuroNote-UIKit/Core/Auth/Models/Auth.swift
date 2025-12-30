//
//  Auth.swift
//  NeuroNote
//
//  Created by Eclipse on 05/07/25.
//

// MARK: - Request Models

struct AuthRequest: Codable {
    let email:    String
    let password: String
    let deviceId: String
}

// MARK: - Session Model (Internal use)

struct AuthSession {
    let token:        String
    let refreshToken: String?
    let isVerified:   Bool
    let isOnboarded:  Bool
}
