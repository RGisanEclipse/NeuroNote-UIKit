//
//  APIClient.swift
//  AVYO
//
//  Created by Eclipse on 04/01/26.
//

import Foundation

// MARK: - HTTP Method

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case patch = "PATCH"
    case delete = "DELETE"
}

// MARK: - API Client

final class APIClient: APIClientProtocol {
    
    static let shared = APIClient()
    
    private let networkService: NetworkService
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder
    
    init(networkService: NetworkService = NetworkService()) {
        self.networkService = networkService
        self.decoder = JSONDecoder()
        self.encoder = JSONEncoder()
    }
    
    // MARK: - Generic Request (with response)
    
    /// Performs an authenticated API request and decodes the response
    func request<T: Decodable>(
        endpoint: String,
        method: HTTPMethod = .get,
        body: Encodable? = nil,
        requiresAuth: Bool = true
    ) async throws -> T {
        let request = try buildRequest(
            endpoint: endpoint,
            method: method,
            body: body,
            requiresAuth: requiresAuth
        )
        
        let (data, response) = try await networkService.performRequest(request: request, requiresAuth: requiresAuth)
        try validateResponse(response, data: data, endpoint: endpoint)
        
        return try decoder.decode(T.self, from: data)
    }
    
    // MARK: - Void Request (no response body needed)
    
    /// Performs an authenticated API request that expects a success response
    func requestSuccess(
        endpoint: String,
        method: HTTPMethod = .post,
        body: Encodable? = nil,
        requiresAuth: Bool = true
    ) async throws {
        let request = try buildRequest(
            endpoint: endpoint,
            method: method,
            body: body,
            requiresAuth: requiresAuth
        )
        
        let (data, response) = try await networkService.performRequest(request: request, requiresAuth: requiresAuth)
        try validateResponse(response, data: data, endpoint: endpoint)
        
        let apiResponse = try decoder.decode(SuccessAPIResponse.self, from: data)
        
        guard apiResponse.success else {
            throw try decodeAPIError(from: data)
        }
    }
    
    // MARK: - Request with Raw Response (for cookie extraction, etc.)
    
    /// Performs a request and returns both decoded data and raw HTTPURLResponse
    func requestWithResponse<T: Decodable>(
        endpoint: String,
        method: HTTPMethod = .post,
        body: Encodable? = nil,
        requiresAuth: Bool = false
    ) async throws -> (data: T, response: HTTPURLResponse) {
        let request = try buildRequest(
            endpoint: endpoint,
            method: method,
            body: body,
            requiresAuth: requiresAuth
        )
        
        let (data, response) = try await networkService.performRequest(request: request, requiresAuth: requiresAuth)
        try validateResponse(response, data: data, endpoint: endpoint)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIClientError.invalidResponse
        }
        
        let decoded = try decoder.decode(T.self, from: data)
        return (data: decoded, response: httpResponse)
    }

    func request<T: Decodable>(
        route: Route,
        body: Encodable? = nil,
        requiresAuth: Bool = true
    ) async throws -> T {
        try await request(
            endpoint: route.path,
            method: route.method,
            body: body,
            requiresAuth: requiresAuth
        )
    }

    func requestSuccess(
        route: Route,
        body: Encodable? = nil,
        requiresAuth: Bool = true
    ) async throws {
        try await requestSuccess(
            endpoint: route.path,
            method: route.method,
            body: body,
            requiresAuth: requiresAuth
        )
    }

    func requestWithResponse<T: Decodable>(
        route: Route,
        body: Encodable? = nil,
        requiresAuth: Bool = false
    ) async throws -> (data: T, response: HTTPURLResponse) {
        try await requestWithResponse(
            endpoint: route.path,
            method: route.method,
            body: body,
            requiresAuth: requiresAuth
        )
    }
    
    // MARK: - Request Builder
    
    private func buildRequest(
        endpoint: String,
        method: HTTPMethod,
        body: Encodable?,
        requiresAuth: Bool
    ) throws -> URLRequest {
        guard let url = URL(string: Routes.base + endpoint) else {
            throw APIClientError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.timeoutInterval = 10
        
        if requiresAuth {
            guard let token = KeychainHelper.standard.read(
                forKey: Constants.KeychainHelperKeys.authToken
            ) else {
                throw APIClientError.missingToken
            }
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        if let body = body {
            request.httpBody = try encoder.encode(body)
        }
        
        return request
    }
    
    // MARK: - Response Validation
    
    private func validateResponse(_ response: URLResponse, data: Data, endpoint: String) throws {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIClientError.invalidResponse
        }
        
        Logger.shared.debug("API Response: \(endpoint)", fields: [
            "statusCode": httpResponse.statusCode,
            "body": String(data: data, encoding: .utf8) ?? "",
            "request-id": httpResponse.value(
                forHTTPHeaderField: Constants.HTTPFields.requestId
            ) ?? ""
        ])
        
        // Handle error status codes
        switch httpResponse.statusCode {
        case 200...299:
            return // Success
        case 400...499:
            // Try to decode the API error from response body first
            // Server often sends meaningful error messages (e.g., "email does not exist")
            do {
                let apiError = try decodeAPIError(from: data)
                throw apiError
            } catch let decodingError as DecodingError {
                Logger.shared.error("Failed to decode API error", fields: [
                    "statusCode": httpResponse.statusCode,
                    "decodingError": String(describing: decodingError),
                    "body": String(data: data, encoding: .utf8) ?? ""
                ])
                // Fallback to generic client errors if decoding fails
                switch httpResponse.statusCode {
                case 401: throw APIClientError.unauthorized
                case 403: throw APIClientError.forbidden
                case 404: throw APIClientError.notFound
                default: throw APIClientError.invalidResponse
                }
            }
        case 500...599:
            throw APIClientError.serverError(code: httpResponse.statusCode)
        default:
            throw try decodeAPIError(from: data)
        }
    }
    
    // MARK: - Error Decoding
    
    private func decodeAPIError(from data: Data) throws -> APIError {
        let errorResponse = try decoder.decode(APIErrorResponse.self, from: data)
        return errorResponse.error
    }
}

// MARK: - API Client Errors

enum APIClientError: LocalizedError, Equatable {
    case invalidURL
    case missingToken
    case invalidResponse
    case unauthorized
    case forbidden
    case notFound
    case serverError(code: Int)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .missingToken:
            return "Authentication required"
        case .invalidResponse:
            return "Invalid server response"
        case .unauthorized:
            return "Session expired. Please login again."
        case .forbidden:
            return "Access denied"
        case .notFound:
            return "Resource not found"
        case .serverError(let code):
            return "Server error (\(code))"
        }
    }
    
    var presentation: AlertContent {
        switch self {
        case .invalidURL, .invalidResponse:
            return AuthAlert.unknown
        case .missingToken, .unauthorized:
            return AuthAlert.tokenInvalid
        case .forbidden:
            return AuthAlert.unauthorized
        case .notFound:
            return AuthAlert.unknown
        case .serverError:
            return AuthAlert.internalServerError
        }
    }
}

