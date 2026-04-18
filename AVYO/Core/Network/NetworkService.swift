//
//  AuthNetworkService.swift
//  AVYO
//
//  Created by Eclipse on 26/07/25.
//

import Foundation

// MARK: - Debug SSL Bypass

#if DEBUG
private class SSLBypassDelegate: NSObject, URLSessionDelegate {
    static let shared = SSLBypassDelegate()

    func urlSession(
        _ session: URLSession,
        didReceive challenge: URLAuthenticationChallenge,
        completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
    ) {
        guard challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust,
              let serverTrust = challenge.protectionSpace.serverTrust else {
            completionHandler(.performDefaultHandling, nil)
            return
        }
        completionHandler(.useCredential, URLCredential(trust: serverTrust))
    }
}
#endif

// MARK: - Network Service

class NetworkService {
    private let session: NetworkSession
    private let tokenManager: TokenManagerProtocol
    private let maxRetries = 1

    #if DEBUG
    static let defaultSession: URLSession = URLSession(
        configuration: .default,
        delegate: SSLBypassDelegate.shared,
        delegateQueue: nil
    )
    #endif

    init(session: NetworkSession = {
        #if DEBUG
        return NetworkService.defaultSession
        #else
        return URLSession.shared
        #endif
    }(), tokenManager: TokenManagerProtocol = TokenManager.shared) {
        self.session = session
        self.tokenManager = tokenManager
    }

    /// Performs a network request
    /// - Parameters:
    ///   - request: The URLRequest to perform
    ///   - requiresAuth: If true, attempts token refresh on 401. If false, returns 401 as-is.
    func performRequest(request: URLRequest, requiresAuth: Bool = true) async throws -> (Data, URLResponse) {
        var currentRequest = request
        var retries = 0

        while retries <= maxRetries {
            do {
                let (data, response) = try await session.data(for: currentRequest)

                if let httpResponse = response as? HTTPURLResponse {
                    // Only attempt token refresh for authenticated routes
                    if httpResponse.statusCode == 401 && requiresAuth {
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
