//  AuthManagerTests.swift
//  AVYO
//
//  Created by Eclipse on 09/07/25.
//

import XCTest
@testable import NeuroNote_UIKit

final class AuthManagerTests: XCTestCase {
    var mockAuthManager = MockAuthManager()
    var mockAPIClient: MockAPIClient!
    
    override func setUp() {
        super.setUp()
        KeychainHelper.standard.clearTestKeys()
        mockAPIClient = MockAPIClient()
    }
    
    override func tearDown() {
        super.tearDown()
        KeychainHelper.standard.clearTestKeys()
        mockAPIClient.reset()
    }
    
    // MARK: - Helper Methods
    
    private func makeMockJWT(userId: String) -> String {
        let payloadDict = ["user_id": userId]
        let jsonData = try! JSONSerialization.data(withJSONObject: payloadDict, options: [])
        var base64 = jsonData.base64EncodedString()
        base64 = base64
            .replacingOccurrences(of: "=", with: "")
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
        return "header.\(base64).signature"
    }
    
    private func makeAuthAPIResponse(token: String, isVerified: Bool, isOnboarded: Bool = true) -> AuthAPIResponse {
        return AuthAPIResponse(
            success: true,
            status: 200,
            response: AuthResponseData(
                token: token,
                isVerified: isVerified,
                isOnboarded: isOnboarded
            )
        )
    }
    
    private func makeHTTPResponse(withCookie: Bool = true) -> HTTPURLResponse {
        var headers: [String: String]? = nil
        if withCookie {
            headers = ["Set-Cookie": "refreshToken=mock_refresh_token; Path=/; HttpOnly"]
        }
        return HTTPURLResponse(
            url: URL(string: "https://neuronote.com")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: headers
        )!
    }
    
    // MARK: - Happy-path Tests
    
    func testAuthenticateReturnsTokenOnSuccess() async {
        // Given
        KeychainHelper.standard.clearTestKeys()
        let token = makeMockJWT(userId: Constants.Tests.userId)
        mockAPIClient.mockResponseData = makeAuthAPIResponse(token: token, isVerified: true)
        mockAPIClient.mockHTTPResponse = makeHTTPResponse()
        
        let manager = AuthManager(apiClient: mockAPIClient)
        
        // When
        do {
            let session = try await manager.authenticate(
                email: Constants.Tests.validEmail,
                password: Constants.Tests.validPassword,
                mode: .signin
            )
            
            // Then
            XCTAssertEqual(session.token, token)
            XCTAssertEqual(manager.currentToken(), token)
            XCTAssertEqual(mockAPIClient.lastEndpoint, Routes.signIn.path)
            XCTAssertEqual(mockAPIClient.lastMethod, .post)
        } catch {
            XCTFail("Expected success but got error: \(error)")
        }
    }
    
    func testAuthenticateSignupSavesUserId() async {
        // Given
        KeychainHelper.standard.clearTestKeys()
        let token = makeMockJWT(userId: Constants.Tests.userId)
        mockAPIClient.mockResponseData = makeAuthAPIResponse(token: token, isVerified: true)
        mockAPIClient.mockHTTPResponse = makeHTTPResponse()
        
        let manager = AuthManager(apiClient: mockAPIClient)
        
        // When
        do {
            let session = try await manager.authenticate(
                email: Constants.Tests.validEmail,
                password: Constants.Tests.validPassword,
                mode: .signup
            )
            
            // Then
            XCTAssertEqual(session.token, token)
            XCTAssertEqual(manager.currentToken(), token)
            XCTAssertEqual(manager.currentUser(), Constants.Tests.userId)
            XCTAssertEqual(mockAPIClient.lastEndpoint, Routes.signUp.path)
        } catch {
            XCTFail("Expected success but got error: \(error)")
        }
    }
    
    func testAuthenticateReturnsUnverifiedUserCorrectly() async {
        // Given
        let token = makeMockJWT(userId: Constants.Tests.userId)
        mockAPIClient.mockResponseData = makeAuthAPIResponse(token: token, isVerified: false)
        mockAPIClient.mockHTTPResponse = makeHTTPResponse()
        
        let manager = AuthManager(apiClient: mockAPIClient)
        
        // When
        do {
            let session = try await manager.authenticate(
                email: Constants.Tests.validEmail,
                password: Constants.Tests.validPassword,
                mode: .signin
            )
            
            // Then
            XCTAssertEqual(session.token, token)
            XCTAssertFalse(session.isVerified)
        } catch {
            XCTFail("Expected success but got error: \(error)")
        }
    }
    
    // MARK: - Network Error Tests
    
    func testNetworkErrorNoInternet() async {
        // Given
        mockAPIClient.mockError = NetworkError.noInternet
        let manager = AuthManager(apiClient: mockAPIClient)
        
        // When & Then
        await XCTAssertThrowsErrorAsync(
            try await manager.authenticate(
                email: Constants.Tests.validEmail,
                password: Constants.Tests.validPassword,
                mode: .signin
            )
        ) { error in
            XCTAssertEqual(error as? NetworkError, .noInternet)
        }
    }
    
    func testNetworkErrorCannotReachServer() async {
        // Given
        mockAPIClient.mockError = NetworkError.cannotReachServer
        let manager = AuthManager(apiClient: mockAPIClient)
        
        // When & Then
        await XCTAssertThrowsErrorAsync(
            try await manager.authenticate(
                email: Constants.Tests.validEmail,
                password: Constants.Tests.validPassword,
                mode: .signin
            )
        ) { error in
            XCTAssertEqual(error as? NetworkError, .cannotReachServer)
        }
    }
    
    func testNetworkErrorTimeout() async {
        // Given
        mockAPIClient.mockError = NetworkError.timeout
        let manager = AuthManager(apiClient: mockAPIClient)
        
        // When & Then
        await XCTAssertThrowsErrorAsync(
            try await manager.authenticate(
                email: Constants.Tests.validEmail,
                password: Constants.Tests.validPassword,
                mode: .signin
            )
        ) { error in
            XCTAssertEqual(error as? NetworkError, .timeout)
        }
    }
    
    // MARK: - API Error Tests
    
    func testAPIClientError() async {
        // Given
        mockAPIClient.mockError = APIClientError.unauthorized
        let manager = AuthManager(apiClient: mockAPIClient)
        
        // When & Then
        await XCTAssertThrowsErrorAsync(
            try await manager.authenticate(
                email: Constants.Tests.validEmail,
                password: Constants.Tests.validPassword,
                mode: .signin
            )
        ) { error in
            XCTAssertEqual(error as? APIClientError, .unauthorized)
        }
    }
    
    // MARK: - Reset Password Tests (using MockAuthManager)
    
    func testResetPasswordSuccess() async {
        // Given
        let request = ResetPasswordRequest(userId: "test_user_123", password: "NewPassword123!")
        mockAuthManager.resetPasswordShouldSucceed = true
        
        // When
        do {
            let result = try await mockAuthManager.resetPassword(payload: request)
            
            // Then
            XCTAssertTrue(result)
        } catch {
            XCTFail("Reset password should succeed: \(error)")
        }
    }
    
    func testResetPasswordWithDifferentUserIds() async {
        // Given
        let userIds = ["user1", "user2", "user3@domain.com", "user_123"]
        
        for userId in userIds {
            let request = ResetPasswordRequest(userId: userId, password: "NewPassword123!")
            mockAuthManager.resetPasswordShouldSucceed = true
            
            // When
            do {
                let result = try await mockAuthManager.resetPassword(payload: request)
                
                // Then
                XCTAssertTrue(result, "Reset password should succeed for userId: \(userId)")
            } catch {
                XCTFail("Reset password should succeed for userId: \(userId), error: \(error)")
            }
        }
    }
    
    func testResetPasswordWithDifferentPasswords() async {
        // Given
        let passwords = [
            "SimplePass123!",
            "ComplexP@ssw0rd!@#",
            "VeryLongPassword123!@#$%^&*()",
            "Unicode密码123!"
        ]
        
        for password in passwords {
            let request = ResetPasswordRequest(userId: "test_user", password: password)
            mockAuthManager.resetPasswordShouldSucceed = true
            
            // When
            do {
                let result = try await mockAuthManager.resetPassword(payload: request)
                
                // Then
                XCTAssertTrue(result, "Reset password should succeed for password: \(password)")
            } catch {
                XCTFail("Reset password should succeed for password: \(password), error: \(error)")
            }
        }
    }
    
    // MARK: - Network Error Tests (Reset Password)
    
    func testResetPasswordWithNoInternetError() async {
        // Given
        let request = ResetPasswordRequest(userId: "test_user", password: "NewPassword123!")
        mockAuthManager.shouldThrowNetworkError = true
        
        // When & Then
        do {
            _ = try await mockAuthManager.resetPassword(payload: request)
            XCTFail("Should throw network error")
        } catch let error as NetworkError {
            XCTAssertEqual(error, .noInternet)
        } catch {
            XCTFail("Should throw NetworkError.noInternet, got: \(error)")
        }
    }
    
    func testResetPasswordWithTimeoutError() async {
        // Given
        let request = ResetPasswordRequest(userId: "test_user", password: "NewPassword123!")
        mockAuthManager.shouldThrowNetworkError = true
        mockAuthManager.resetPasswordDelay = 0.1
        
        // When & Then
        do {
            _ = try await mockAuthManager.resetPassword(payload: request)
            XCTFail("Should throw network error")
        } catch let error as NetworkError {
            XCTAssertEqual(error, .noInternet)
        } catch {
            XCTFail("Should throw NetworkError, got: \(error)")
        }
    }
    
    // MARK: - API Error Tests (Reset Password)
    
    func testResetPasswordWithAPIError() async {
        // Given
        let request = ResetPasswordRequest(userId: "test_user", password: "NewPassword123!")
        mockAuthManager.shouldThrowAPIError = true
        
        // When & Then
        do {
            _ = try await mockAuthManager.resetPassword(payload: request)
            XCTFail("Should throw API error")
        } catch let error as APIError {
            XCTAssertEqual(error.message, "Internal Server Error")
        } catch {
            XCTFail("Should throw APIError, got: \(error)")
        }
    }
    
    // MARK: - Server Error Tests
    
    func testResetPasswordWithServerError() async {
        // Given
        let request = ResetPasswordRequest(userId: "test_user", password: "NewPassword123!")
        mockAuthManager.shouldThrowServerError = true
        mockAuthManager.serverCodeToThrow = .internalServerError
        
        // When & Then
        do {
            _ = try await mockAuthManager.resetPassword(payload: request)
            XCTFail("Should throw server error")
        } catch let error as AuthError {
            if case .server(let code) = error {
                XCTAssertEqual(code, .internalServerError)
            } else {
                XCTFail("Should throw AuthError.server, got: \(error)")
            }
        } catch {
            XCTFail("Should throw AuthError, got: \(error)")
        }
    }
    
    func testResetPasswordWithDifferentServerErrors() async {
        // Given
        let serverCodes: [ServerErrorCode] = [
            .internalServerError,
            .unauthorized,
        ]
        
        for serverCode in serverCodes {
            let request = ResetPasswordRequest(userId: "test_user", password: "NewPassword123!")
            mockAuthManager.shouldThrowServerError = true
            mockAuthManager.serverCodeToThrow = serverCode
            
            // When & Then
            do {
                _ = try await mockAuthManager.resetPassword(payload: request)
                XCTFail("Should throw server error for code: \(serverCode)")
            } catch let error as AuthError {
                if case .server(let code) = error {
                    XCTAssertEqual(code, serverCode)
                } else {
                    XCTFail("Should throw AuthError.server for code: \(serverCode), got: \(error)")
                }
            } catch {
                XCTFail("Should throw AuthError for code: \(serverCode), got: \(error)")
            }
        }
    }
    
    // MARK: - Reset Password Failure Tests
    
    func testResetPasswordFailure() async {
        // Given
        let request = ResetPasswordRequest(userId: "test_user", password: "NewPassword123!")
        mockAuthManager.resetPasswordShouldSucceed = false
        
        // When
        do {
            let result = try await mockAuthManager.resetPassword(payload: request)
            
            // Then
            XCTAssertFalse(result)
        } catch {
            XCTFail("Should not throw error when resetPasswordShouldSucceed is false: \(error)")
        }
    }
    
    // MARK: - Edge Cases
    
    func testResetPasswordWithEmptyUserId() async {
        // Given
        let request = ResetPasswordRequest(userId: "", password: "NewPassword123!")
        mockAuthManager.resetPasswordShouldSucceed = true
        
        // When
        do {
            let result = try await mockAuthManager.resetPassword(payload: request)
            
            // Then
            XCTAssertTrue(result)
        } catch {
            XCTFail("Reset password should succeed with empty userId: \(error)")
        }
    }
    
    func testResetPasswordWithEmptyPassword() async {
        // Given
        let request = ResetPasswordRequest(userId: "test_user", password: "")
        mockAuthManager.resetPasswordShouldSucceed = true
        
        // When
        do {
            let result = try await mockAuthManager.resetPassword(payload: request)
            
            // Then
            XCTAssertTrue(result)
        } catch {
            XCTFail("Reset password should succeed with empty password: \(error)")
        }
    }
    
    func testResetPasswordWithSpecialCharacters() async {
        // Given
        let request = ResetPasswordRequest(userId: "user@domain.com", password: "P@ssw0rd!@#$%^&*()")
        mockAuthManager.resetPasswordShouldSucceed = true
        
        // When
        do {
            let result = try await mockAuthManager.resetPassword(payload: request)
            
            // Then
            XCTAssertTrue(result)
        } catch {
            XCTFail("Reset password should succeed with special characters: \(error)")
        }
    }
    
    func testResetPasswordWithUnicodeCharacters() async {
        // Given
        let request = ResetPasswordRequest(userId: "用户123", password: "密码123!")
        mockAuthManager.resetPasswordShouldSucceed = true
        
        // When
        do {
            let result = try await mockAuthManager.resetPassword(payload: request)
            
            // Then
            XCTAssertTrue(result)
        } catch {
            XCTFail("Reset password should succeed with unicode characters: \(error)")
        }
    }
    
    // MARK: - Performance Tests
    
    func testResetPasswordPerformance() {
        // Given
        let request = ResetPasswordRequest(userId: "test_user", password: "NewPassword123!")
        mockAuthManager.resetPasswordDelay = 0.01
        
        // When & Then
        measure {
            let expectation = XCTestExpectation(description: "Reset password performance")
            
            Task {
                do {
                    _ = try await mockAuthManager.resetPassword(payload: request)
                    expectation.fulfill()
                } catch {
                    XCTFail("Performance test should not fail: \(error)")
                }
            }
            
            wait(for: [expectation], timeout: 1.0)
        }
    }
    
    // MARK: - Concurrent Tests
    
    func testConcurrentResetPasswordRequests() async {
        // Given
        let request1 = ResetPasswordRequest(userId: "user1", password: "Password1!")
        let request2 = ResetPasswordRequest(userId: "user2", password: "Password2!")
        let request3 = ResetPasswordRequest(userId: "user3", password: "Password3!")
        
        mockAuthManager.resetPasswordShouldSucceed = true
        
        // When
        async let result1 = mockAuthManager.resetPassword(payload: request1)
        async let result2 = mockAuthManager.resetPassword(payload: request2)
        async let result3 = mockAuthManager.resetPassword(payload: request3)
        
        // Then
        do {
            let (success1, success2, success3) = try await (result1, result2, result3)
            XCTAssertTrue(success1)
            XCTAssertTrue(success2)
            XCTAssertTrue(success3)
        } catch {
            XCTFail("Concurrent reset password requests should succeed: \(error)")
        }
    }
}

// MARK: - Async helper for cleaner tests
extension XCTestCase {
    func XCTAssertThrowsErrorAsync<T>(_ expression: @autoclosure () async throws -> T,
                                      _ errorHandler: (Error) -> Void,
                                      file: StaticString = #file, line: UInt = #line) async {
        do {
            _ = try await expression()
            XCTFail("Expected error but got success", file: file, line: line)
        } catch {
            errorHandler(error)
        }
    }
}
