//
//  AuthManager.swift
//  NeuroNote
//
//  Created by Eclipse on 05/07/25.
//

import Foundation

final class AuthManager: AuthManagerProtocol {

    static let shared = AuthManager()
    private let apiClient: APIClientProtocol

    init(apiClient: APIClientProtocol = APIClient.shared) {
        self.apiClient = apiClient
    }

    enum Mode {
        case signup
        case signin

        var route: Route {
            switch self {
            case .signup: return Routes.signUp
            case .signin: return Routes.signIn
            }
        }
    }

    // MARK: - Authenticate
    
    @discardableResult
    func authenticate(
        email: String,
        password: String,
        mode: Mode
    ) async throws -> AuthSession {
        
        let deviceId = KeychainHelper.standard.getOrCreateDeviceId()
        let body = AuthRequest(email: email, password: password, deviceId: deviceId)
        
        let (apiResponse, httpResponse): (AuthAPIResponse, HTTPURLResponse) = try await apiClient.requestWithResponse(
            route: mode.route,
            body: body,
            requiresAuth: false
        )

            let payload = apiResponse.response
            let token = payload.token
            let isVerified = payload.isVerified
            let isOnboarded = payload.isOnboarded

            extractRefreshToken(from: httpResponse)

            if mode == .signup {
            guard let userId = AuthTokenDecoder.standard.decodeJWT(token: token)?.userId else {
                    throw AuthError.noUserIdReceived
                }
                saveUserId(userId)
            }

            saveToken(token)

            return AuthSession(
                token: token,
                refreshToken: KeychainHelper.standard.getRefreshToken() ?? "",
                isVerified: isVerified,
                isOnboarded: isOnboarded
            )
    }

    // MARK: - Reset Password
    
    func resetPassword(payload: ResetPasswordRequest) async throws -> Bool {
        let (apiResponse, _): (SuccessAPIResponse, HTTPURLResponse) = try await apiClient.requestWithResponse(
            route: Routes.resetPassword,
            body: payload,
            requiresAuth: false
        )

            return apiResponse.success
    }

    // MARK: - Cookie Extraction

    private func extractRefreshToken(from response: HTTPURLResponse) {
        guard
            let headerFields = response.allHeaderFields as? [String: String],
            let url = response.url
        else { return }

        let cookies = HTTPCookie.cookies(
            withResponseHeaderFields: headerFields,
            for: url
        )

        if let refreshToken = cookies.first(
            where: { $0.name == Constants.HTTPFields.refreshToken }
        ) {
            saveRefreshToken(refreshToken.value)
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

    private func saveRefreshToken(_ token: String) {
        KeychainHelper.standard.save(token, forKey: Constants.KeychainHelperKeys.refreshToken)
    }

    private func saveUserId(_ userId: String) {
        KeychainHelper.standard.save(userId, forKey: Constants.KeychainHelperKeys.userId)
    }
}
