//
//  AuthManager.swift
//  NeuroNote
//
//  Created by Eclipse on 05/07/25.
//

//
//  AuthManager.swift
//  NeuroNote
//
//  Created by Eclipse on 05/07/25.
//

import Foundation

final class AuthManager: AuthManagerProtocol {

    static let shared = AuthManager()
    private let session: NetworkSession

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

    // MARK: - Authenticate
    @discardableResult
    func authenticate(
        email: String,
        password: String,
        mode: Mode
    ) async throws -> AuthSession {

        let request = try makeRequest(
            path: mode.path,
            body: AuthRequest(email: email, password: password)
        )

        do {
            let (data, response) = try await session.data(for: request)

            let httpResponse = try validate(response: response, data: data)

            let apiResponse = try JSONDecoder()
                .decode(AuthAPIResponse.self, from: data)

            let payload = apiResponse.response
            let token = payload.token
            let isVerified = payload.isVerified

            extractRefreshToken(from: httpResponse)

            if mode == .signup {
                guard
                    let userId = AuthTokenDecoder.standard
                        .decodeJWT(token: token)?
                        .userId
                else {
                    throw AuthError.noUserIdReceived
                }
                saveUserId(userId)
            }

            saveToken(token)

            return AuthSession(
                token: token,
                refreshToken: KeychainHelper.standard.getRefreshToken() ?? "",
                isVerified: isVerified
            )

        } catch let error as URLError {
            throw mapURLError(error)
        } catch let apiError as APIError {
            throw apiError
        } catch let networkError as NetworkError {
            throw networkError
        } catch {
            throw AuthError.unexpectedError
        }
    }

    // MARK: - Reset Password
    func resetPassword(payload: ResetPasswordRequest) async throws -> Bool {

        let request = try makeRequest(
            path: Routes.resetPassword,
            body: payload
        )

        do {
            let (data, response) = try await session.data(for: request)

            _ = try validate(response: response, data: data)

            let apiResponse = try JSONDecoder()
                .decode(SuccessAPIResponse.self, from: data)

            return apiResponse.success

        } catch let error as URLError {
            throw mapURLError(error)
        } catch let apiError as APIError {
            throw apiError
        } catch let networkError as NetworkError {
            throw networkError
        } catch {
            throw AuthError.unexpectedError
        }
    }

    // MARK: - Helpers

    private func makeRequest<T: Encodable>(
        path: String,
        body: T
    ) throws -> URLRequest {

        guard let url = URL(string: Routes.base + path) else {
            throw AuthError.badURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 10
        request.httpBody = try JSONEncoder().encode(body)
        return request
    }

    private func validate(
        response: URLResponse,
        data: Data
    ) throws -> HTTPURLResponse {

        guard let httpResponse = response as? HTTPURLResponse else {
            throw AuthError.invalidResponse
        }

        Logger.shared.debug("API Response", fields: [
            "statusCode": httpResponse.statusCode,
            "body": String(data: data, encoding: .utf8) ?? "",
            "request-id": httpResponse.value(
                forHTTPHeaderField: Constants.HTTPFields.requestId
            ) ?? ""
        ])

        guard (200...299).contains(httpResponse.statusCode) else {
            throw try decodeAPIError(from: data)
        }

        return httpResponse
    }

    private func decodeAPIError(from data: Data) throws -> APIError {
        let errorResponse = try JSONDecoder()
            .decode(APIErrorResponse.self, from: data)
        return errorResponse.error
    }

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
        KeychainHelper.standard
            .delete(forKey: Constants.KeychainHelperKeys.authToken)
        KeychainHelper.standard
            .delete(forKey: Constants.KeychainHelperKeys.userId)
    }

    func currentToken() -> String? {
        KeychainHelper.standard
            .read(forKey: Constants.KeychainHelperKeys.authToken)
    }

    func currentUser() -> String? {
        KeychainHelper.standard
            .read(forKey: Constants.KeychainHelperKeys.userId)
    }

    private func saveToken(_ token: String) {
        KeychainHelper.standard.save(
            token,
            forKey: Constants.KeychainHelperKeys.authToken
        )
    }

    private func saveRefreshToken(_ token: String) {
        KeychainHelper.standard.save(
            token,
            forKey: Constants.KeychainHelperKeys.refreshToken
        )
    }

    private func saveUserId(_ userId: String) {
        KeychainHelper.standard.save(
            userId,
            forKey: Constants.KeychainHelperKeys.userId
        )
    }

    private func mapURLError(_ error: URLError) -> NetworkError {
        switch error.code {
        case .notConnectedToInternet, .networkConnectionLost:
            return .noInternet
        case .cannotFindHost, .cannotConnectToHost:
            return .cannotReachServer
        case .timedOut:
            return .timeout
        default:
            return .generic(message: error.localizedDescription)
        }
    }
}
