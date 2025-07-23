//
//  AuthTokenDecoder.swift
//  NeuroNote-UIKit
//
//  Created by Eclipse on 23/07/25.
//

import Foundation

struct AuthJWT: Codable {
    let userId: String
}

struct AuthTokenDecoder {
    static let standard = AuthTokenDecoder()
    
    func decodeJWT(token: String) -> AuthJWT? {
        let segments = token.components(separatedBy: ".")
        guard segments.count > 1 else { return nil }

        var base64String = segments[1]
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")

        let requiredLength = (4 - (base64String.count % 4)) % 4
        base64String += String(repeating: "=", count: requiredLength)

        guard let payloadData = Data(base64Encoded: base64String) else {
            return nil
        }

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase

        guard let decoded = try? decoder.decode(AuthJWT.self, from: payloadData) else {
            return nil
        }

        return decoded
    }
}
