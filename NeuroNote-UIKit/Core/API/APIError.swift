//
//  APIError.swift
//  NeuroNote-UIKit
//
//  Created by Eclipse on 20/09/25.
//


import Foundation

private struct SuccessWrapper: Codable {
    let success: Bool
}

struct APIErrorResponse: Codable {
    let success: Bool
    let error: APIError
    let data: CodableValue? // optional, if server returns any extra data
}

struct APIError: Error,Codable {
    let code: String
    let message: String
    let status: Int
}

struct CodableValue: Codable {}
