//
//  AuthManager.swift
//  NeuroNote
//
//  Created by Eclipse on 05/07/25.
//

import Foundation

protocol NetworkSession {
    func data(for request: URLRequest) async throws -> (Data, URLResponse)
}

extension URLSession: NetworkSession {}

protocol AuthManagerProtocol {
    func authenticate(email: String, password: String, mode: AuthManager.Mode) async throws -> String
}

class AuthManager: AuthManagerProtocol {
    
    static let shared = AuthManager()
    private let session: NetworkSession

    // Allow injection of custom session (default to real session for production)
    init(session: NetworkSession = URLSession.shared) {
        self.session = session
    }

    enum Mode {
        case signup
        case signin
        
        var path: String {
            switch self {
            case .signup: return Routes.signUp
            case .signin: return Routes.signIn
            }
        }
    }

    @discardableResult
    func authenticate(email: String, password: String, mode: Mode) async throws -> String {
        guard let url = URL(string: Routes.base + mode.path) else {
            throw AuthError.badURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(AuthRequest(email: email, password: password))

        do {
            let (data, response) = try await session.data(for: request)

            guard response is HTTPURLResponse else {
                throw AuthError.invalidResponse
            }

            guard let parsed = try? JSONDecoder().decode(AuthResponse.self, from: data) else {
                throw AuthError.decodingFailed
            }

            if !parsed.success {
                let serverMsg = AuthServerMessage(from: parsed.message)
                throw AuthError.server(serverMsg)
            }

            guard let token = parsed.token else {
                throw AuthError.noTokenReceived
            }

            saveToken(token)
            return token

        } catch let authErr as AuthError {
            throw authErr
        } catch {
            throw AuthError.unexpectedError
        }
    }

    // MARK: - Token Helpers
    func logout() {
        KeychainHelper.standard.delete(forKey: Constants.KeychainHelperKeys.authToken)
    }

    func currentToken() -> String? {
        KeychainHelper.standard.read(forKey: Constants.KeychainHelperKeys.authToken)
    }

    private func saveToken(_ token: String) {
        KeychainHelper.standard.save(token, forKey: Constants.KeychainHelperKeys.authToken)
    }
}
