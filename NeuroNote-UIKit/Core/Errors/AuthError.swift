//
//  AuthError.swift
//  NeuroNote
//
//  Created by Eclipse on 05/07/25.
//

import Foundation

enum AuthError: LocalizedError, Equatable {
    case badURL
    case invalidResponse
    case decodingFailed
    case unexpectedError
    case noTokenReceived
    case noUserIdReceived
    case server(AuthServerMessage)

    var errorDescription: String? {
        switch self {
        case .badURL:              return "Invalid URL"
        case .invalidResponse:     return "Invalid server response"
        case .decodingFailed:      return "Failed to read server data"
        case .noTokenReceived:     return "No token received"
        case .noUserIdReceived:     return "No user id received"
        case .server(let msg):     return msg.rawValue
        case .unexpectedError:     return "Unexpected error"
        }
    }
}
