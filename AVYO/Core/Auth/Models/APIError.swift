//
//  APIError.swift
//  AVYO
//
//  Created by Eclipse on 25/12/25.
//

struct APIError: Error, Equatable {
    let code: String
    let message: String
    let status: Int
    let data: [String: AnyCodable]?
    
    init(code: String, message: String, status: Int, data: [String: AnyCodable]? = nil) {
        self.code = code
        self.message = message
        self.status = status
        self.data = data
    }

    static func == (lhs: APIError, rhs: APIError) -> Bool {
        lhs.code == rhs.code && lhs.status == rhs.status
    }

    var serverCode: ServerErrorCode {
        ServerErrorCode(rawValue: code) ?? .unknown
    }
    
    /// Returns the appropriate presentation for this error.
    /// For known error codes, uses the mapped AlertContent.
    /// For unknown codes, uses the actual server message.
    var presentation: AlertContent {
        let knownCode = ServerErrorCode(rawValue: code)
        if let known = knownCode {
            return known.presentation
        }
        // Unknown code - use actual server message
        return AlertContent(
            title: "Oops 😬",
            message: message,
            shouldBeRed: true,
            animationName: Constants.animations.unsureStar
        )
    }
}
