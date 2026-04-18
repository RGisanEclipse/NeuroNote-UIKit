// OTPManager.swift
// AVYO
//
// Created by Eclipse on 20/07/25.
//

import Foundation

final class OTPManager: OTPManagerProtocol {
    
    static let shared = OTPManager()
    private let apiClient: APIClientProtocol
    
    init(apiClient: APIClientProtocol = APIClient.shared) {
        self.apiClient = apiClient
    }
    
    // MARK: - Request OTP
    
    @discardableResult
    func requestOTP(requestData: OTPRequestData, purpose: OTPPurpose) async throws -> OTPResponse {
        let route = getRequestRoute(for: purpose)
        
        let (apiResponse, httpResponse): (SuccessAPIResponse, HTTPURLResponse) = try await apiClient.requestWithResponse(
            route: route,
            body: requestData,
            requiresAuth: false  // All OTP routes are public
        )
        
            guard apiResponse.success else {
            throw APIClientError.invalidResponse
            }
            
            // For forgot password, save userId from cookie
            if purpose == .ForgotPassword {
                extractUserIdCookie(from: httpResponse)
            }
            
            return apiResponse.response
    }
    
    // MARK: - Verify OTP
    
    @discardableResult
    func verifyOTP(_ code: String, userId: String, purpose: OTPPurpose) async throws -> OTPResponse {
        let route = getVerifyRoute(for: purpose)
        let body = OTPVerifyRequest(code: code, userId: userId)
        
        let apiResponse: SuccessAPIResponse = try await apiClient.request(
            route: route,
            body: body,
            requiresAuth: false  // All OTP routes are public
        )
        
        guard apiResponse.success else {
            throw APIClientError.invalidResponse
        }
        
        return apiResponse.response
    }
    
    // MARK: - Cookie Extraction
    
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
    
    // MARK: - Endpoint Helpers
    
    private func getRequestRoute(for purpose: OTPPurpose) -> Route {
        switch purpose {
        case .Signup:
            return Routes.requestSignupOTP
        case .ForgotPassword:
            return Routes.requestForgotPasswordOTP
        }
    }
    
    private func getVerifyRoute(for purpose: OTPPurpose) -> Route {
        switch purpose {
        case .Signup:
            return Routes.verifySignupOTP
        case .ForgotPassword:
            return Routes.verifyForgotPasswordOTP
        }
    }
}
