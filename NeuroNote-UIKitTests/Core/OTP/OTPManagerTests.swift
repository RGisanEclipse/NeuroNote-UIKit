//
//  OTPManagerTests.swift
//  NeuroNote-UIKit
//
//  Created by Eclipse on 20/07/25.
//

import XCTest
@testable import NeuroNote_UIKit

final class OTPManagerTests: XCTestCase {
    
    override func tearDown() {
        super.tearDown()
        KeychainHelper.standard.clearTestKeys()
    }
    
    func testRequestOTPSuccess() async throws {
        let mockSession = MockNetworkSession()
        let mockAuthService = MockAuthNetworkService(session: mockSession)
        let response = OTPResponse(success: true, errorMessage: nil)
        mockSession.nextData = try JSONEncoder().encode(response)
        mockSession.nextResponse = HTTPURLResponse(url: URL(string: "https://tests.com")!,
                                                   statusCode: 200,
                                                   httpVersion: nil,
                                                   headerFields: nil)

        let manager = OTPManager(networkService: mockAuthService)
        let result = try await manager.requestOTP()
        XCTAssertTrue(result.success)
    }

    func testRequestOTPFailureWithInvalidEmail() async throws {
        let mockSession = MockNetworkSession()
        let mockAuthService = MockAuthNetworkService(session: mockSession)
        let failureResponse = OTPResponse(success: false, errorMessage: "invalid email")
        mockSession.nextData = try JSONEncoder().encode(failureResponse)
        mockSession.nextResponse = HTTPURLResponse(url: URL(string: "https://tests.com")!,
                                                   statusCode: 200,
                                                   httpVersion: nil,
                                                   headerFields: nil)

        let manager = OTPManager(networkService: mockAuthService)

        do {
            _ = try await manager.requestOTP()
            XCTFail("Expected OTPError was not thrown")
        } catch let error as OTPError {
            switch error {
            case .serverError(let reason):
                XCTAssertEqual(reason, .invalidEmail)
            default:
                XCTFail("Unexpected OTPError: \(error)")
            }
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }
    
    func testRequestOTPFailureWithURLError() async {
        let mockSession = MockNetworkSession()
        let mockAuthService = MockAuthNetworkService(session: mockSession)
        mockSession.shouldThrowError = true

        let manager = OTPManager(networkService: mockAuthService)
        
        do {
            _ = try await manager.requestOTP()
            XCTFail("Expected error was not thrown")
        } catch let error as NetworkError {
            switch error {
            case .generic(let message):
                XCTAssertTrue(message.contains("The operation couldn’t be completed"))
            default:
                XCTFail("Expected .generic, got \(error)")
            }
        } catch {
            XCTFail("Expected NetworkError, got \(error)")
        }
    }
    
    func testVerifyOTPWithInvalidOTP() async {
        let mockSession = MockNetworkSession()
        let mockAuthService = MockAuthNetworkService(session: mockSession)
        let failure = OTPResponse(success: false, errorMessage: "otp verification failed")
        mockSession.nextData = try! JSONEncoder().encode(failure)
        mockSession.nextResponse = HTTPURLResponse(url: URL(string: "https://tests.com")!,
                                                   statusCode: 200,
                                                   httpVersion: nil,
                                                   headerFields: nil)

        let manager = OTPManager(networkService: mockAuthService)

        do {
            _ = try await manager.verifyOTP(Constants.Tests.otp)
            XCTFail("Expected OTPError was not thrown")
        } catch let error as OTPError {
            switch error {
            case .serverError(let reason):
                XCTAssertEqual(reason.rawValue, "otp verification failed")
            default:
                XCTFail("Unexpected OTPError: \(error)")
            }
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }
    func testVerifyOTPIncludesAuthHeader() async throws {
        let mockSession = MockNetworkSession()
        let mockAuthService = MockAuthNetworkService(session: mockSession)
        let response = OTPResponse(success: true, errorMessage: nil)
        mockSession.nextData = try JSONEncoder().encode(response)
        mockSession.nextResponse = HTTPURLResponse(url: URL(string: "https://tests.com")!,
                                                   statusCode: 200,
                                                   httpVersion: nil,
                                                   headerFields: nil)
        
        KeychainHelper.standard.save("dummy_token", forKey: Constants.KeychainHelperKeys.authToken)

        let manager = OTPManager(networkService: mockAuthService)
        _ = try await manager.verifyOTP("123456")

        guard let request = mockSession.lastRequest else {
            XCTFail("No request was made")
            return
        }

        XCTAssertEqual(request.httpMethod, "POST")

        let authHeader = request.value(forHTTPHeaderField: "Authorization")
        XCTAssertEqual(authHeader, "Bearer dummy_token", "Authorization header not correctly set")
    }
}
