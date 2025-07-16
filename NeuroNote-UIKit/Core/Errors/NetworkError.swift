//
//  NetworkError.swift
//  NeuroNote-UIKit
//
//  Created by Eclipse on 14/07/25.
//

enum NetworkError: Error {
    case noInternet
    case timeout
    case cannotReachServer
    case generic(message: String)
}

extension NetworkError: Equatable {
    var userMessage: String {
        switch self {
        case .noInternet:
            return "No Internet Connection"
        case .timeout:
            return "Request timed out."
        case .cannotReachServer:
            return "Cannot Reach Server"
        case .generic(let msg):
            return msg
        }
    }
}

extension NetworkError {
    var presentation: AlertContent {
        switch self {
        case .noInternet:             return NetworkAlert.noInternet
        case .timeout:                return NetworkAlert.timeout
        case .cannotReachServer:      return NetworkAlert.cannotReachServer
        case .generic(let msg):       return NetworkAlert.generic(msg)
        }
    }
}
