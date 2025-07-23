//
//  AuthServerMessage.swift
//  NeuroNote
//
//  Created by Eclipse on 05/07/25.
//

enum AuthServerMessage: String {
    case emailAlreadyExists     = "email already exists"
    case emailDoesNotExist      = "email does not exist"
    case incorrectPassword      = "incorrect password"
    case tokenInvalid           = "invalid token"
    case internalServerError    = "internal server error"
    case unauthorized           = "unauthorized access"
    case invalidRequestBody     = "invalid request body"
    case tooManyRequests        = "too many requests"
    case unknown                = "unknown"
    
    init(from message: String) {
        self = AuthServerMessage(rawValue: message) ?? .unknown
    }
}

// MARK: - Error Presentation
extension AuthServerMessage {
    var presentation: AlertContent {
        switch self {
        case .emailAlreadyExists:    return AuthAlert.emailAlreadyExists
        case .emailDoesNotExist:     return AuthAlert.emailDoesNotExist
        case .incorrectPassword:     return AuthAlert.incorrectPassword
        case .tokenInvalid:          return AuthAlert.tokenInvalid
        case .internalServerError:   return AuthAlert.internalServerError
        case .unauthorized:          return AuthAlert.unauthorized
        case .invalidRequestBody:    return AuthAlert.invalidRequestBody
        case .tooManyRequests:       return NetworkAlert.tooManyRequests
        case .unknown:               return AuthAlert.unknown
        }
    }
}

