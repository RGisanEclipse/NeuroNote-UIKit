//
//  OTPServerMessage.swift
//  NeuroNote-UIKit
//
//  Created by Eclipse on 20/07/25.
//

enum OTPServerMessage: String, Codable {
    case invalidEmail           = "invalid email"
    case deliveryFailed         = "delivery failed"
    case otpVerificationFailed  = "otp verification failed"
    case tooManyRequests        = "too many requests"
    case otpExpired             = "otp expired"
    case unknown                = "unknown"
    
    init(from message: String?) {
        self = OTPServerMessage(rawValue: message ?? Constants.empty) ?? .unknown
    }
}

// MARK: - Error Presentation
extension OTPServerMessage {
    var presentation: AlertContent {
        switch self {
        case .invalidEmail:          return OTPAlert.invalidEmail
        case .deliveryFailed:        return OTPAlert.deliveryFailed
        case .tooManyRequests:        return NetworkAlert.tooManyRequests
        default:                     return OTPAlert.unknown
        }
    }
}
