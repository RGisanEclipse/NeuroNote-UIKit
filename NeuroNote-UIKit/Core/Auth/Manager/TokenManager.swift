//
//  TokenManager.swift
//  NeuroNote-UIKit
//
//  Created by Eclipse on 26/07/25.
//

import Foundation

protocol TokenManagerProtocol {
    func refreshToken() async throws -> (accessToken: String, refreshToken: String)
    func logout()
}

class TokenManager: TokenManagerProtocol {
    static let shared = TokenManager()
    private let session: NetworkSession

    init(session: NetworkSession = URLSession.shared) {
        self.session = session
    }

    func refreshToken() async throws -> (accessToken: String, refreshToken: String) {
        guard let url = URL(string: Routes.base + Routes.refreshToken) else {
            throw AuthError.badURL
        }
        guard let refreshToken = KeychainHelper.standard.read(forKey: Constants.KeychainHelperKeys.refreshToken) else {
            throw AuthError.noRefreshToken
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(["refresh_token": refreshToken])
        request.timeoutInterval = 10
        
        let (data, response) = try await session.data(for: request)
        
        guard let response = response as? HTTPURLResponse else {
            throw AuthError.invalidResponse
        }
        
        let parsed = try JSONDecoder().decode(AuthResponse.self, from: data)
        
        if !parsed.success {
            let serverMsg = AuthServerMessage(from: parsed.message)
            throw AuthError.server(serverMsg)
        }
        
        guard
            let headerFields = response.allHeaderFields as? [String: String],
            let url = response.url
        else {
            throw AuthError.noTokenReceived
        }

        let cookies = HTTPCookie.cookies(withResponseHeaderFields: headerFields, for: url)
        guard let refreshTokenCookie = cookies.first(where: { $0.name == "refreshToken" }) else {
            throw AuthError.noTokenReceived
        }
        
        let newRefreshToken = refreshTokenCookie.value
        KeychainHelper.standard.save(newRefreshToken, forKey: Constants.KeychainHelperKeys.refreshToken)
        
        guard let newAccessToken = parsed.token else {
            throw AuthError.noTokenReceived
        }

        KeychainHelper.standard.save(newAccessToken, forKey: Constants.KeychainHelperKeys.authToken)

        return (accessToken: newAccessToken, refreshToken: newRefreshToken)
    }

    func logout() {
        KeychainHelper.standard.delete(forKey: Constants.KeychainHelperKeys.authToken)
        KeychainHelper.standard.delete(forKey: Constants.KeychainHelperKeys.refreshToken)
        KeychainHelper.standard.delete(forKey: Constants.KeychainHelperKeys.userId)
    }
}
