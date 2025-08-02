//
//  AuthNetworkService.swift
//  NeuroNote-UIKit
//
//  Created by Eclipse on 26/07/25.
//

import Foundation
// Network Service for private routes
class AuthNetworkService {
    private let session: NetworkSession
    private let tokenManager: TokenManagerProtocol
    private let maxRetries = 1

    init(session: NetworkSession = URLSession.shared, tokenManager: TokenManagerProtocol = TokenManager.shared) {
        self.session = session
        self.tokenManager = tokenManager
    }

    func performRequest(request: URLRequest) async throws -> (Data, URLResponse) {
        var currentRequest = request
        var retries = 0

        while retries <= maxRetries {
            do {
                let (data, response) = try await session.data(for: currentRequest)

                if let httpResponse = response as? HTTPURLResponse {
                    if httpResponse.statusCode == 401 {
                        print("Token expired or unauthorized. Attempting to refresh token.")
                        do {
                            let (newAccessToken, _) = try await tokenManager.refreshToken()
                            if currentRequest.value(forHTTPHeaderField: "Authorization") != nil {
                                currentRequest.setValue("Bearer \(newAccessToken)", forHTTPHeaderField: "Authorization")
                            }
                            
                            retries += 1
                            continue
                        } catch {
                            // If token refresh fails, propagate the error
                            print("Token refresh failed: \(error.localizedDescription)")
                            throw AuthNetworkError.tokenRefreshFailed
                        }
                    }
                }
                return (data, response)
            } catch let urlError as URLError {
                switch urlError.code {
                case .notConnectedToInternet, .networkConnectionLost:
                    throw NetworkError.noInternet
                case .cannotFindHost, .cannotConnectToHost:
                    throw NetworkError.cannotReachServer
                case .timedOut:
                    throw NetworkError.timeout
                default:
                    throw NetworkError.generic(message: urlError.localizedDescription)
                }
            } catch {
                throw AuthNetworkError.underlyingError(error)
            }
        }
        throw AuthNetworkError.unauthorized
    }
}
