//
//  AuthServerCode.swift
//  NeuroNote
//
//  Created by Eclipse on 20/09/25.
//

enum AuthServerCode: String {
    case emailAlreadyExists       = "AUTH_002"
    case emailDoesNotExist        = "AUTH_001"
    case incorrectPassword        = "AUTH_003"
    case tokenInvalid             = "AUTH_008"
    case unauthorized             = "AUTH_009"
    case invalidRequestBody       = "AUTH_004"
    case internalServerError      = "AUTH_013"
    case unknown                  = "UNKNOWN"
    
    init(from code: String) {
        self = AuthServerCode(rawValue: code) ?? .unknown
    }
}

// MARK: - Error Presentation
extension AuthServerCode {
    var presentation: AlertContent {
        switch self {
        case .emailAlreadyExists:    return AuthAlert.emailAlreadyExists
        case .emailDoesNotExist:     return AuthAlert.emailDoesNotExist
        case .incorrectPassword:     return AuthAlert.incorrectPassword
        case .tokenInvalid:          return AuthAlert.tokenInvalid
        case .unauthorized:          return AuthAlert.unauthorized
        case .invalidRequestBody:    return AuthAlert.invalidRequestBody
        case .internalServerError:   return AuthAlert.internalServerError
        case .unknown:               return AuthAlert.unknown
        }
    }
}
