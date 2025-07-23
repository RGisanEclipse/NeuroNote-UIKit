//
//  OTPManager.swift
//  NeuroNote-UIKit
//
//  Created by Eclipse on 20/07/25.
//

import Foundation

protocol OTPManagerProtocol {
    func requestOTP() async throws -> OTPResponse
    func verifyOTP(_ code: String) async throws -> OTPVerifyResponse
}

class OTPManager : OTPManagerProtocol {
    
    private let session: NetworkSession
    static let shared = OTPManager()
    
    // Allow injection of custom session (default to real session for production)
    init(session: NetworkSession = URLSession.shared) {
        self.session = session
    }
    
    @discardableResult
    func requestOTP() async throws -> OTPResponse{
        guard let url = URL(string: Routes.base + Routes.requestOTP) else {
            throw OTPError.badURL
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if let token = KeychainHelper.standard.read(forKey: Constants.KeychainHelperKeys.authToken) {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        request.httpBody = try? JSONEncoder().encode([String: String]())
        request.timeoutInterval = 10
        
        do {
            let (data, response) = try await session.data(for: request)
            
            guard response is HTTPURLResponse else {
                throw OTPError.invalidResponse
            }
            
            guard let parsed = try? JSONDecoder().decode(
                OTPResponse.self,
                from: data
            ) else {
                throw OTPError.decodingFailed
            }
            
            if !parsed.success {
                let serverError = OTPServerMessage(from: parsed.errorMessage)
                throw OTPError.serverError(serverError)
            }
            
            return OTPResponse(
                success: parsed.success,
                errorMessage: parsed.errorMessage
            )
        } catch let error as URLError {
            switch error.code {
            case .notConnectedToInternet,
                    .networkConnectionLost:
                throw NetworkError.noInternet
                
            case .cannotFindHost,
                    .cannotConnectToHost:
                throw NetworkError.cannotReachServer
                
            case .timedOut:
                throw NetworkError.timeout
                
            default:
                throw NetworkError.generic(message: error.localizedDescription)
            }
        } catch let otpErr as OTPError {
            throw otpErr
        } catch {
            throw OTPError.unexpectedError
        }
    }
    
    func verifyOTP(_ code: String) async throws -> OTPVerifyResponse{
        guard let url = URL(string: Routes.base + Routes.verifyOTP) else {
            throw OTPError.badURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if let token = KeychainHelper.standard.read(forKey: Constants.KeychainHelperKeys.authToken) {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        let body = try JSONEncoder().encode([
            "otp": code,
        ])
        request.httpBody = body
        request.timeoutInterval = 10
        
        do {
            let (data, response) = try await session.data(for: request)
            
            guard response is HTTPURLResponse else {
                throw OTPError.invalidResponse
            }
            
            guard let parsed = try? JSONDecoder().decode(OTPVerifyResponse.self, from: data) else {
                throw OTPError.decodingFailed
            }
            
            if !parsed.success {
                let message = OTPServerMessage(from: parsed.message)
                throw OTPError.serverError(message)
            }
            return OTPVerifyResponse(success: true, message: nil)
            
        } catch let error as URLError {
            switch error.code {
            case .notConnectedToInternet, .networkConnectionLost:
                throw NetworkError.noInternet
            case .cannotFindHost, .cannotConnectToHost:
                throw NetworkError.cannotReachServer
            case .timedOut:
                throw NetworkError.timeout
            default:
                throw NetworkError.generic(message: error.localizedDescription)
            }
        } catch let otpErr as OTPError {
            throw otpErr
        } catch {
            throw OTPError.unexpectedError
        }
    }
}
