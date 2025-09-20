// OTPManager.swift
// NeuroNote-UIKit
//
// Created by Eclipse on 20/07/25.
//

import Foundation

class OTPManager: OTPManagerProtocol {
    private let networkService: AuthNetworkService
    static let shared = OTPManager()
    
    init(networkService: AuthNetworkService = AuthNetworkService()) {
        self.networkService = networkService
    }
    
    @discardableResult
    func requestOTP(userId: String) async throws -> OTPResponse {
        guard let url = URL(string: Routes.base + Routes.requestSignupOTP) else {
            throw AuthError.badURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if let token = KeychainHelper.standard.read(forKey: Constants.KeychainHelperKeys.authToken) {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        let body = OTPRequest(userId: userId)
        request.httpBody = try JSONEncoder().encode(body)
        request.timeoutInterval = 10
        
        do {
            let (data, response) = try await networkService.performRequest(request: request)
            
            guard response is HTTPURLResponse else {
                throw AuthError.invalidResponse
            }
            
            struct SuccessWrapper: Codable { let success: Bool }
            let wrapper = try JSONDecoder().decode(SuccessWrapper.self, from: data)
            
            if wrapper.success {
                return try JSONDecoder().decode(OTPResponse.self, from: data)
            } else {
                let apiErrorResponse = try JSONDecoder().decode(APIErrorResponse.self, from: data)
                throw apiErrorResponse.error
            }
            
        } catch let networkError as NetworkError {
            throw networkError
        } catch let apiError as APIError {
            throw apiError
        } catch {
            throw AuthError.unexpectedError
        }
    }
    
    @discardableResult
    func verifyOTP(_ code: String, userId: String) async throws -> OTPResponse {
        guard let url = URL(string: Routes.base + Routes.verifySignupOTP) else {
            throw AuthError.badURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if let token = KeychainHelper.standard.read(forKey: Constants.KeychainHelperKeys.authToken) {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        let body = OTPVerifyRequest(code: code, userId: userId)
        request.httpBody = try JSONEncoder().encode(body)
        request.timeoutInterval = 10
        
        do {
            let (data, response) = try await networkService.performRequest(request: request)
            
            guard response is HTTPURLResponse else {
                throw AuthError.invalidResponse
            }

            struct SuccessWrapper: Codable { let success: Bool }
            let wrapper = try JSONDecoder().decode(SuccessWrapper.self, from: data)

            if wrapper.success {
                return try JSONDecoder().decode(OTPResponse.self, from: data)
            } else {
                let apiErrorResponse = try JSONDecoder().decode(APIErrorResponse.self, from: data)
                throw apiErrorResponse.error
            }

        } catch let networkError as NetworkError {
            throw networkError
        } catch let apiError as APIError {
            print("Parsed APIError: \(apiError)")
            throw apiError
        } catch {
            print("Unexpected error during OTP verification: \(error)")
            throw AuthError.unexpectedError
        }
    }
}
