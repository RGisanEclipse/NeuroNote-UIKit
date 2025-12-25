//
//  OnboardingManager.swift
//  NeuroNote-UIKit
//
//  Created by Eclipse on 11/12/25.
//

import Foundation

final class OnboardingManager: OnboardingManagerProtocol {
    
    private let networkService: NetworkService
    
    init(networkService: NetworkService = NetworkService()) {
        self.networkService = networkService
    }
    
    // MARK: - Onboard User
    func onboardUser(onboardingData: OnboardingData) async throws {
        let request = try makeRequest(with: onboardingData)

        do {
            let (data, response) = try await networkService.performRequest(request: request)
            let _ = try validate(response: response, data: data)

            let apiResponse = try JSONDecoder().decode(SuccessAPIResponse.self, from: data)

            guard apiResponse.success else {
                throw try decodeAPIError(from: data)
            }

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
    
    // MARK: - Request Helpers

    private func makeRequest(with body: OnboardingData) throws -> URLRequest {
        guard let url = URL(string: Routes.base + Routes.onboardUser) else {
            throw AuthError.badURL
        }

        guard let token = KeychainHelper.standard.read(
            forKey: Constants.KeychainHelperKeys.authToken
        ) else {
            throw AuthError.missingToken
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.timeoutInterval = 10
        request.httpBody = try JSONEncoder().encode(body)

        return request
    }

    private func validate(response: URLResponse, data: Data) throws -> HTTPURLResponse {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw AuthError.invalidResponse
        }

        Logger.shared.debug("Onboarding Response", fields: [
            "statusCode": httpResponse.statusCode,
            "body": String(data: data, encoding: .utf8) ?? "",
            "request-id": httpResponse.value(
                forHTTPHeaderField: Constants.HTTPFields.requestId
            ) ?? ""
        ])

        return httpResponse
    }

    private func decodeAPIError(from data: Data) throws -> APIError {
        let errorResponse = try JSONDecoder().decode(APIErrorResponse.self, from: data)
        return errorResponse.error
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
