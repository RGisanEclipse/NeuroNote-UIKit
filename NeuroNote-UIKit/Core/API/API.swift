//
//  API.swift
//  NeuroNote-UIKit
//
//  Created by Eclipse on 20/09/25.
//

import Foundation

// MARK: - Generic API Response Envelope

struct APIResponse<Payload: Decodable>: Decodable {
    let success: Bool
    let status: Int
    let response: Payload
}

// MARK: - Error Response

struct APIErrorResponse: Decodable {
    let status: Int
    let response: APIErrorDetail

    var error: APIError {
        APIError(
            code: response.errorCode,
            message: response.message,
            status: status,
            data: response.data
        )
    }
}

struct APIErrorDetail: Decodable {
    let errorCode: String
    let message: String
    let data: [String: AnyCodable]?
}

struct AnyCodable: Codable, Equatable {
    let value: Any

    init(_ value: Any) {
        self.value = value
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        if container.decodeNil() {
            value = NSNull()
        } else if let bool = try? container.decode(Bool.self) {
            value = bool
        } else if let int = try? container.decode(Int.self) {
            value = int
        } else if let double = try? container.decode(Double.self) {
            value = double
        } else if let string = try? container.decode(String.self) {
            value = string
        } else if let array = try? container.decode([AnyCodable].self) {
            value = array.map { $0.value }
        } else if let dictionary = try? container.decode([String: AnyCodable].self) {
            value = dictionary.mapValues { $0.value }
        } else {
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Unsupported JSON value"
            )
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()

        switch value {
        case is NSNull:
            try container.encodeNil()
        case let v as Bool:
            try container.encode(v)
        case let v as Int:
            try container.encode(v)
        case let v as Double:
            try container.encode(v)
        case let v as String:
            try container.encode(v)
        case let v as [Any]:
            try container.encode(v.map { AnyCodable($0) })
        case let v as [String: Any]:
            try container.encode(v.mapValues { AnyCodable($0) })
        default:
            throw EncodingError.invalidValue(
                value,
                .init(codingPath: container.codingPath,
                      debugDescription: "Unsupported value")
            )
        }
    }

    static func == (lhs: AnyCodable, rhs: AnyCodable) -> Bool {
        switch (lhs.value, rhs.value) {
        case (is NSNull, is NSNull): return true
        case let (l as Bool, r as Bool): return l == r
        case let (l as Int, r as Int): return l == r
        case let (l as Double, r as Double): return l == r
        case let (l as String, r as String): return l == r
        default: return false
        }
    }
}

// MARK: - Server Error Codes

enum ServerErrorCode: String {
    // AUTH
    case emailDoesNotExist      = "AUTH_001"
    case emailAlreadyExists    = "AUTH_002"
    case incorrectPassword     = "AUTH_003"
    case unauthorized          = "AUTH_009"
    case userNotFound           = "AUTH_010"
    case invalidRefreshToken   = "AUTH_011"
    case refreshTokenMismatch  = "AUTH_012"
    case passwordOTPNotVerified = "AUTH_016"
    case userNotVerified       = "AUTH_021"

    // EMAIL
    case emailRequired         = "EMAIL_001"
    case invalidEmailFormat    = "EMAIL_002"

    // PASSWORD
    case passwordRequired      = "PASSWORD_001"
    case passwordTooShort      = "PASSWORD_002"
    case passwordTooLong       = "PASSWORD_003"
    case passwordNoUppercase   = "PASSWORD_004"
    case passwordNoLowercase   = "PASSWORD_005"
    case passwordNoDigit       = "PASSWORD_006"
    case passwordNoSpecialChar = "PASSWORD_007"
    case passwordHasWhitespace = "PASSWORD_008"

    // OTP
    case emailEmptyForUser     = "OTP_002"
    case otpExpiredOrNotFound  = "OTP_003"
    case invalidOTP            = "OTP_004"
    case invalidOTPPurpose     = "OTP_005"

    // ONBOARDING
    case nameTooLong           = "OB_001"
    case nameTooShort          = "OB_002"
    case ageOutOfRange         = "OB_003"
    case invalidGender         = "OB_004"
    case userAlreadyOnboarded  = "OB_005"

    // SERVER
    case internalServerError   = "SERVER_004"
    case tooManyRequests       = "SERVER_006"
    case badRequest            = "SERVER_008"

    // Fallback
    case unknown               = "UNKNOWN"
}

// MARK: - ServerErrorCode Presentation
extension ServerErrorCode {
    var presentation: AlertContent {
        switch self {
        // AUTH
        case .emailDoesNotExist:      return AuthAlert.emailDoesNotExist
        case .emailAlreadyExists:     return AuthAlert.emailAlreadyExists
        case .incorrectPassword:      return AuthAlert.incorrectPassword
        case .unauthorized:           return AuthAlert.unauthorized
        case .userNotFound:           return AuthAlert.emailDoesNotExist
        case .invalidRefreshToken:    return AuthAlert.tokenInvalid
        case .refreshTokenMismatch:   return AuthAlert.tokenInvalid
        case .passwordOTPNotVerified: return OTPAlert.notVerified
        case .userNotVerified:        return AuthAlert.userNotVerified
            
        // EMAIL
        case .emailRequired:          return EmailAlert.required
        case .invalidEmailFormat:     return EmailAlert.invalid
            
        // PASSWORD
        case .passwordRequired:       return PasswordAlert.required
        case .passwordTooShort:       return PasswordAlert.tooShort
        case .passwordTooLong:        return PasswordAlert.tooLong
        case .passwordNoUppercase:    return PasswordAlert.noUppercase
        case .passwordNoLowercase:    return PasswordAlert.noLowercase
        case .passwordNoDigit:        return PasswordAlert.noDigit
        case .passwordNoSpecialChar:  return PasswordAlert.noSpecialChar
        case .passwordHasWhitespace:  return PasswordAlert.hasWhitespace
            
        // OTP
        case .emailEmptyForUser:      return OTPAlert.deliveryFailed
        case .otpExpiredOrNotFound:   return OTPAlert.expired
        case .invalidOTP:             return OTPAlert.invalid
        case .invalidOTPPurpose:      return OTPAlert.unknown
            
        // ONBOARDING
        case .nameTooLong:            return OnboardingAlert.nameTooLong
        case .nameTooShort:           return OnboardingAlert.nameTooShort
        case .ageOutOfRange:          return OnboardingAlert.ageOutOfRange
        case .invalidGender:          return OnboardingAlert.invalidGender
        case .userAlreadyOnboarded:   return OnboardingAlert.alreadyOnboarded
            
        // SERVER
        case .internalServerError:    return AuthAlert.internalServerError
        case .tooManyRequests:        return ServerAlert.tooManyRequests
        case .badRequest:             return AuthAlert.invalidRequestBody
            
        // FALLBACK
        case .unknown:                return AuthAlert.unknown
        }
    }
}

// MARK: - Endpoint-Specific Payloads

struct AuthResponseData: Decodable {
    let token: String
    let isVerified: Bool
    let isOnboarded: Bool
}

struct TokenRefreshData: Decodable {
    let accessToken: String
}

struct SuccessMessageData: Decodable {
    let success: Bool
    let message: String
}

// MARK: - Typealiases

typealias AuthAPIResponse = APIResponse<AuthResponseData>
typealias TokenRefreshAPIResponse = APIResponse<TokenRefreshData>
typealias SuccessAPIResponse = APIResponse<SuccessMessageData>
typealias DashboardAPIResponse = APIResponse<DashboardPayload>
typealias MonthlyTopMoodsAPIResponse = APIResponse<MonthlyTopMoodsPayload>
typealias WeeklyMoodStripAPIResponse = APIResponse<WeeklyMoodStripPayload>