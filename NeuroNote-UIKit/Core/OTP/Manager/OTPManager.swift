// OTPManager.swift
// NeuroNote-UIKit
//
// Created by Eclipse on 20/07/25.
//

import Foundation

final class OTPManager: OTPManagerProtocol {
    
    private let networkService: NetworkService
    static let shared = OTPManager()
    
    init(networkService: NetworkService = NetworkService()) {
        self.networkService = networkService
    }
    
    // MARK: - Request OTP
    @discardableResult
    func requestOTP(requestData: OTPRequestData, purpose: OTPPurpose) async throws -> OTPResponse {
        let endpoint = getRequestEndpoint(for: purpose)
        let request = try makeRequest(urlPath: endpoint, body: requestData)
        
        do {
            let (data, response) = try await networkService.performRequest(request: request)
            let httpResponse = try validate(response: response, data: data)
            
            // Check for error status codes first
            if httpResponse.statusCode >= 400 {
                throw try decodeAPIError(from: data)
            }
            
            let apiResponse = try JSONDecoder().decode(SuccessAPIResponse.self, from: data)
            guard apiResponse.success else {
                throw try decodeAPIError(from: data)
            }
            
            // For forgot password, save userId from cookie
            if purpose == .ForgotPassword {
                extractUserIdCookie(from: httpResponse)
            }
            
            return apiResponse.response
            
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
    
    // MARK: - Verify OTP
    @discardableResult
    func verifyOTP(_ code: String, userId: String, purpose: OTPPurpose) async throws -> OTPResponse {
        let endpoint = getVerifyEndpoint(for: purpose)
        let request = try makeRequest(urlPath: endpoint, body: OTPVerifyRequest(code: code, userId: userId))
        
        do {
            let (data, response) = try await networkService.performRequest(request: request)
            let httpResponse = try validate(response: response, data: data)
            
            // Check for error status codes first
            if httpResponse.statusCode >= 400 {
                throw try decodeAPIError(from: data)
            }
            
            let apiResponse = try JSONDecoder().decode(SuccessAPIResponse.self, from: data)
            guard apiResponse.success else {
                throw try decodeAPIError(from: data)
            }
            
            return apiResponse.response
            
        } catch let error as URLError {
            throw mapURLError(error)
        } catch let apiError as APIError {
            Logger.shared.debug("OTP Verification Error", fields: [
                "code": apiError.code,
                "message": apiError.message
            ])
            throw apiError
        } catch let networkError as NetworkError {
            throw networkError
        } catch {
            Logger.shared.error("Unexpected OTP verification error", fields: [
                "error": error.localizedDescription
            ])
            throw AuthError.unexpectedError
        }
    }
    
    // MARK: - Helpers
    private func makeRequest<T: Encodable>(urlPath: String, body: T) throws -> URLRequest {
        guard let url = URL(string: Routes.base + urlPath) else {
            throw AuthError.badURL
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let token = KeychainHelper.standard.read(forKey: Constants.KeychainHelperKeys.authToken) {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        request.timeoutInterval = 10
        request.httpBody = try JSONEncoder().encode(body)
        return request
    }
    
    private func validate(response: URLResponse, data: Data) throws -> HTTPURLResponse {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw AuthError.invalidResponse
        }
        Logger.shared.debug("OTP Response", fields: [
            "statusCode": httpResponse.statusCode,
            "body": String(data: data, encoding: .utf8) ?? "",
            "request-id": httpResponse.value(forHTTPHeaderField: Constants.HTTPFields.requestId) ?? ""
        ])
        return httpResponse
    }
    
    private func decodeAPIError(from data: Data) throws -> APIError {
        let errorResponse = try JSONDecoder().decode(APIErrorResponse.self, from: data)
        return errorResponse.error
    }
    
    private func extractUserIdCookie(from response: HTTPURLResponse) {
        guard
            let headerFields = response.allHeaderFields as? [String: String],
            let url = response.url
        else { return }
        
        let cookies = HTTPCookie.cookies(withResponseHeaderFields: headerFields, for: url)
        if let userIdCookie = cookies.first(where: { $0.name == Constants.HTTPFields.userId }) {
            KeychainHelper.standard.save(userIdCookie.value, forKey: Constants.KeychainHelperKeys.userId)
        }
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
    
    private func getRequestEndpoint(for purpose: OTPPurpose) -> String {
        switch purpose {
        case .Signup:
            return Routes.requestSignupOTP
        case .ForgotPassword:
            return Routes.requestForgotPasswordOTP
        }
    }
    
    private func getVerifyEndpoint(for purpose: OTPPurpose) -> String {
        switch purpose {
        case .Signup:
            return Routes.verifySignupOTP
        case .ForgotPassword:
            return Routes.verifyForgotPasswordOTP
        }
    }
}
