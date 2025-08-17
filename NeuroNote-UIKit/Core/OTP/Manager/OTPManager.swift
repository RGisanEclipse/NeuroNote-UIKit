//
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
    func requestOTP(purpose: OTPPurpose) async throws -> OTPResponse {
        guard let url = URL(string: Routes.base + Routes.requestOTP) else {
            throw OTPError.badURL
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if let token = KeychainHelper.standard.read(forKey: Constants.KeychainHelperKeys.authToken) {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        let body = OTPRequest(purpose: purpose.rawValue)
        request.httpBody = try JSONEncoder().encode(body)
        request.timeoutInterval = 10
        
        do {
            let (data, response) = try await networkService.performRequest(request: request)
            guard response is HTTPURLResponse else {
                throw OTPError.invalidResponse
            }
            
            guard let parsed = try? JSONDecoder().decode(OTPResponse.self, from: data) else {
                throw OTPError.decodingFailed
            }
            
            if !parsed.success {
                let serverError = OTPServerMessage(from: parsed.errorMessage)
                throw OTPError.serverError(serverError)
            }
            
            return parsed
        } catch let authError as AuthNetworkError {
            switch authError {
            case .unauthorized, .tokenRefreshFailed:
                TokenManager.shared.logout()
                throw OTPError.authenticationRequired
            case .underlyingError(let error):
                if let networkError = error as? NetworkError {
                    throw networkError
                } else if let otpError = error as? OTPError {
                    throw otpError
                } else {
                    throw OTPError.unexpectedError
                }
            }
        } catch let networkError as NetworkError {
            throw networkError
        } catch let otpErr as OTPError {
            throw otpErr
        } catch {
            throw OTPError.unexpectedError
        }
    }
    
    func verifyOTP(_ code: String, purpose: OTPPurpose) async throws -> OTPResponse {
        guard let url = URL(string: Routes.base + Routes.verifyOTP) else {
            throw OTPError.badURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if let token = KeychainHelper.standard.read(forKey: Constants.KeychainHelperKeys.authToken) {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        let body = OTPVerifyRequest(otp: code, purpose: purpose.rawValue)
        request.httpBody = try JSONEncoder().encode(body)
        request.timeoutInterval = 10
        
        do {
            let (data, response) = try await networkService.performRequest(request: request)
            guard response is HTTPURLResponse else {
                throw OTPError.invalidResponse
            }
            
            guard let parsed = try? JSONDecoder().decode(OTPResponse.self, from: data) else {
                throw OTPError.decodingFailed
            }
            
            if !parsed.success {
                let message = OTPServerMessage(from: parsed.errorMessage)
                throw OTPError.serverError(message)
            }
            return parsed
        } catch let authError as AuthNetworkError {
            switch authError {
            case .unauthorized, .tokenRefreshFailed:
                TokenManager.shared.logout()
                throw OTPError.authenticationRequired
            case .underlyingError(let error):
                if let networkError = error as? NetworkError {
                    throw networkError
                } else if let otpError = error as? OTPError {
                    throw otpError
                } else {
                    throw OTPError.unexpectedError
                }
            }
        } catch let networkError as NetworkError {
            throw networkError
        } catch let otpErr as OTPError {
            throw otpErr
        } catch {
            throw OTPError.unexpectedError
        }
    }
}
