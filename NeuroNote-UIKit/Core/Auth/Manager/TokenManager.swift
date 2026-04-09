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

final class TokenManager: TokenManagerProtocol {

    static let shared = TokenManager()
    private let session: NetworkSession

    init(session: NetworkSession = {
        #if DEBUG
        return NetworkService.defaultSession
        #else
        return URLSession.shared
        #endif
    }()) {
        self.session = session
    }

    // MARK: - Refresh Token
    func refreshToken() async throws -> (accessToken: String, refreshToken: String) {

        guard
            let refreshToken = KeychainHelper.standard.read(
                forKey: Constants.KeychainHelperKeys.refreshToken
            )
        else {
            throw AuthError.noRefreshToken
        }
        
        let deviceId = KeychainHelper.standard.getOrCreateDeviceId()
        
        let request = try makeRequest(
            path: Routes.refreshToken.path,
            body: RefreshTokenRequest(refresh_token: refreshToken, deviceID: deviceId)
        )

        do {
            let (data, response) = try await session.data(for: request)
            let httpResponse = try validate(response: response, data: data)

            let apiResponse = try JSONDecoder()
                .decode(TokenRefreshAPIResponse.self, from: data)

            guard apiResponse.success else {
                throw try decodeAPIError(from: data)
            }

            let newAccessToken = apiResponse.response.accessToken
            saveAccessToken(newAccessToken)

            let newRefreshToken = try extractRefreshToken(from: httpResponse)
            saveRefreshToken(newRefreshToken)

            return (
                accessToken: newAccessToken,
                refreshToken: newRefreshToken
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

        Logger.shared.debug("Token Refresh Response", fields: [
            "statusCode": httpResponse.statusCode,
            "body": String(data: data, encoding: .utf8) ?? "",
            "request-id": httpResponse.value(
                forHTTPHeaderField: Constants.HTTPFields.requestId
            ) ?? ""
        ])

        return httpResponse
    }

    private func decodeAPIError(from data: Data) throws -> APIError {
        let errorResponse = try JSONDecoder()
            .decode(APIErrorResponse.self, from: data)
        return errorResponse.error
    }

    private func extractRefreshToken(from response: HTTPURLResponse) throws -> String {
        guard
            let headerFields = response.allHeaderFields as? [String: String],
            let url = response.url
        else {
            throw AuthError.noTokenReceived
        }

        let cookies = HTTPCookie.cookies(
            withResponseHeaderFields: headerFields,
            for: url
        )

        guard let refreshToken = cookies.first(
            where: { $0.name == Constants.HTTPFields.refreshToken }
        ) else {
            throw AuthError.noTokenReceived
        }

        return refreshToken.value
    }

    // MARK: - Token Storage

    private func saveAccessToken(_ token: String) {
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

    // MARK: - Logout

    func logout() {
        KeychainHelper.standard.delete(
            forKey: Constants.KeychainHelperKeys.authToken
        )
        KeychainHelper.standard.delete(
            forKey: Constants.KeychainHelperKeys.refreshToken
        )
        KeychainHelper.standard.delete(
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
