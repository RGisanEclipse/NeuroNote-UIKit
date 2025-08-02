//
//  OTPError.swift
//  NeuroNote-UIKit
//
//  Created by Eclipse on 20/07/25.
//

enum OTPError: Error, Codable {
    case badURL
    case invalidResponse
    case decodingFailed
    case authenticationRequired
    case serverError(OTPServerMessage)
    case unexpectedError
}
