//
//  AuthManager.swift
//  NeuroNote
//
//  Created by Eclipse on 05/07/25.
//

import Foundation

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
    func authenticate(email: String, password: String, mode: Mode) async throws -> AuthSession {
        guard let url = URL(string: Routes.base + mode.path) else {
            throw AuthError.badURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(AuthRequest(email: email, password: password))
        request.timeoutInterval = 10

        do {
            let (data, response) = try await session.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw AuthError.invalidResponse
            }

            let bodyString = String(data: data, encoding: .utf8) ?? "<Unable to decode body>"
            Logger.shared.debug("Authentication Response", fields: [
                "statusCode": httpResponse.statusCode,
                "body": bodyString,
                "request-id": httpResponse.value(forHTTPHeaderField: Constants.HTTPFields.requestId) ?? Constants.empty
            ])
            struct SuccessWrapper: Codable { let success: Bool }
            let wrapper = try JSONDecoder().decode(SuccessWrapper.self, from: data)

            if wrapper.success {
                let parsed = try JSONDecoder().decode(AuthResponse.self, from: data)

                guard let token = parsed.data.token else { throw AuthError.noTokenReceived }
                let isVerified = parsed.data.isVerified ?? false
                
                if let headerFields = httpResponse.allHeaderFields as? [String: String] {
                    let cookies = HTTPCookie.cookies(withResponseHeaderFields: headerFields, for: httpResponse.url!)
                    if let refreshTokenCookie = cookies.first(where: { $0.name == Constants.HTTPFields.refreshToken }) {
                        saveRefreshToken(refreshTokenCookie.value)
                    }
                }

                if mode == .signup {
                    guard let userId = AuthTokenDecoder.standard.decodeJWT(token: token)?.userId else {
                        throw AuthError.noUserIdReceived
                    }
                    print(userId)
                    saveUserId(userId)

                }
                saveToken(token)

                return AuthSession(
                    token: token,
                    refreshToken: KeychainHelper.standard.getRefreshToken() ?? Constants.empty,
                    isVerified: isVerified
                )

            } else {
                let apiErrorResponse = try JSONDecoder().decode(APIErrorResponse.self, from: data)
                Logger.shared.error("API Error Response", fields: [
                    "code": apiErrorResponse.error.code,
                    "message": apiErrorResponse.error.message,
                    "status": apiErrorResponse.error.status,
                    "request-id": httpResponse.value(forHTTPHeaderField: Constants.HTTPFields.requestId) ?? Constants.empty
                ])
                throw apiErrorResponse.error
            }

        } catch let error as URLError {
            switch error.code {
            case .notConnectedToInternet, .networkConnectionLost:
                throw NetworkError.noInternet
            case .cannotFindHost, .cannotConnectToHost:
                throw NetworkError.cannotReachServer
            case .timedOut:
                throw NetworkError.timeout
            default:
                throw NetworkError.generic(message: error.localizedDescription)
            }
        } catch let apiError as APIError {
            throw apiError
        } catch {
            throw AuthError.unexpectedError
        }
    }
    
    func resetPassword(payload: ResetPasswordRequest) async throws -> Bool {
        
        guard let url = URL(string: Routes.base + Routes.resetPassword) else {
            throw AuthError.badURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(ResetPasswordRequest(userId: payload.userId,
                                                                         password: payload.password))
        request.timeoutInterval = 10
        
        do{
            let (data, response) = try await session.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse else {
                throw AuthError.invalidResponse
            }

            let bodyString = String(data: data, encoding: .utf8) ?? "<Unable to decode body>"
            Logger.shared.debug("Authentication Response", fields: [
                "statusCode": httpResponse.statusCode,
                "body": bodyString,
                "request-id": httpResponse.value(forHTTPHeaderField: Constants.HTTPFields.requestId) ?? Constants.empty
            ])
            struct SuccessWrapper: Codable { let success: Bool }
            let wrapper = try JSONDecoder().decode(SuccessWrapper.self, from: data)
            
            if wrapper.success{
                return true
            } else{
                let apiErrorResponse = try JSONDecoder().decode(APIErrorResponse.self, from: data)
                Logger.shared.error("API Error Response", fields: [
                    "code": apiErrorResponse.error.code,
                    "message": apiErrorResponse.error.message,
                    "status": apiErrorResponse.error.status,
                    "request-id": httpResponse.value(forHTTPHeaderField: Constants.HTTPFields.requestId) ?? Constants.empty
                ])
                throw apiErrorResponse.error
            }
            
        } catch let error as URLError {
            switch error.code {
            case .notConnectedToInternet, .networkConnectionLost:
                throw NetworkError.noInternet
            case .cannotFindHost, .cannotConnectToHost:
                throw NetworkError.cannotReachServer
            case .timedOut:
                throw NetworkError.timeout
            default:
                throw NetworkError.generic(message: error.localizedDescription)
            }
        } catch let apiError as APIError {
            throw apiError
        } catch {
            throw AuthError.unexpectedError
        }
    }
    
    // MARK: - Token Helpers
    func logout() {
        KeychainHelper.standard.delete(forKey: Constants.KeychainHelperKeys.authToken)
        KeychainHelper.standard.delete(forKey: Constants.KeychainHelperKeys.userId)
    }
    
    func currentToken() -> String? {
        KeychainHelper.standard.read(forKey: Constants.KeychainHelperKeys.authToken)
    }
    
    func currentUser() -> String? {
        KeychainHelper.standard.read(forKey: Constants.KeychainHelperKeys.userId)
    }
    
    private func saveToken(_ token: String) {
        KeychainHelper.standard.save(token, forKey: Constants.KeychainHelperKeys.authToken)
    }
    private func saveRefreshToken(_ token: String){
        KeychainHelper.standard.save(token, forKey: Constants.KeychainHelperKeys.refreshToken)
    }
    private func saveUserId(_ userId: String) {
        KeychainHelper.standard.save(userId, forKey: Constants.KeychainHelperKeys.userId)
    }
}
