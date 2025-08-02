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
        guard response is HTTPURLResponse else {
            throw AuthError.invalidResponse
        }

        let parsed = try JSONDecoder().decode(AuthResponse.self, from: data)
        guard let newAccessToken = parsed.token, let newRefreshToken = parsed.refreshToken else {
            throw AuthError.noTokenReceived
        }

        KeychainHelper.standard.save(newAccessToken, forKey: Constants.KeychainHelperKeys.authToken)
        KeychainHelper.standard.save(newRefreshToken, forKey: Constants.KeychainHelperKeys.refreshToken)

        return (newAccessToken, newRefreshToken)
    }

    func logout() {
        KeychainHelper.standard.delete(forKey: Constants.KeychainHelperKeys.authToken)
        KeychainHelper.standard.delete(forKey: Constants.KeychainHelperKeys.refreshToken)
        KeychainHelper.standard.delete(forKey: Constants.KeychainHelperKeys.userId)
    }
}
