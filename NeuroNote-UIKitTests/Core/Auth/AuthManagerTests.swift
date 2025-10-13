//  AuthManagerTests.swift
//  NeuroNote
//
//  Created by Eclipse on 09/07/25.
//

import XCTest
@testable import NeuroNote_UIKit

final class AuthManagerTests: XCTestCase {
    var mockAuthManager = MockAuthManager()
    override func setUp() {
        super.setUp()
        KeychainHelper.standard.clearTestKeys()
    }
    
    override func tearDown() {
        super.tearDown()
        KeychainHelper.standard.clearTestKeys()
    }
    
    // MARK: - Mock NetworkSession
    class MockNetworkSession: NetworkSession {
        var injectedURLError: URLError.Code?
        var mockData: Data?
        var mockResponse: URLResponse?
        
        func data(for request: URLRequest) async throws -> (Data, URLResponse) {
            if let code = injectedURLError {
                throw URLError(code)
            }
            return (mockData ?? Data(), mockResponse ?? URLResponse())
        }
    }
    
    // MARK: - Happy-path helpers
    private func makeHTTP200Response() -> HTTPURLResponse {
        HTTPURLResponse(url: URL(string: "https://neuronote.com")!,
                        statusCode: 200,
                        httpVersion: nil,
                        headerFields: nil)!
    }
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
    
    // MARK: - Happy-AuthCase test
    func testAuthenticateReturnsTokenOnSuccess() async {
        // Ensure clean keychain state
        KeychainHelper.standard.clearTestKeys()
        
        let mock = MockNetworkSession()
        let token = makeMockJWT(userId: Constants.Tests.userId)
        let response = AuthResponse(
            success: true,
            message: "ok",
            data: AuthData(token: token, isVerified: true)
        )
        mock.mockData = try? JSONEncoder().encode(response)
        
        let httpResponse = HTTPURLResponse(url: URL(string: "https://neuronote.com")!,
                                         statusCode: 200,
                                         httpVersion: nil,
                                         headerFields: ["Set-Cookie": "refreshToken=mock_refresh_token; Path=/; HttpOnly"])!
        mock.mockResponse = httpResponse
        
        let manager = AuthManager(session: mock)
        
        do {
            let session = try await manager.authenticate(
                email: Constants.Tests.validEmail,
                password: Constants.Tests.validPassword,
                mode: .signin
            )
            XCTAssertEqual(session.token, token)
            XCTAssertEqual(manager.currentToken(), token)
        } catch {
            XCTFail("Expected success but got error: \(error)")
        }
    }
    
    func testAuthenticateSignupSavesUserId() async {
        // Ensure clean keychain state
        KeychainHelper.standard.clearTestKeys()
        
        let mock = MockNetworkSession()
        let token = makeMockJWT(userId: Constants.Tests.userId)
        let response = AuthResponse(
            success: true,
            message: "ok",
            data: AuthData(token: token, isVerified: true)
        )
        mock.mockData = try? JSONEncoder().encode(response)
        
        let httpResponse = HTTPURLResponse(url: URL(string: "https://neuronote.com")!,
                                         statusCode: 200,
                                         httpVersion: nil,
                                         headerFields: ["Set-Cookie": "refreshToken=mock_refresh_token; Path=/; HttpOnly"])!
        mock.mockResponse = httpResponse
        
        let manager = AuthManager(session: mock)
        
        do {
            let session = try await manager.authenticate(
                email: Constants.Tests.validEmail,
                password: Constants.Tests.validPassword,
                mode: .signup
            )
            XCTAssertEqual(session.token, token)
            XCTAssertEqual(manager.currentToken(), token)
            // For signup mode, user ID should be saved to keychain
            XCTAssertEqual(manager.currentUser(), Constants.Tests.userId)
        } catch {
            XCTFail("Expected success but got error: \(error)")
        }
    }
    
    func testAuthenticateReturnsUnverifiedUserCorrectly() async {
        let mock = MockNetworkSession()
        let token = makeMockJWT(userId: Constants.Tests.userId)
        let response = AuthResponse(
            success: true,
            message: "ok",
            data: AuthData(token: token, isVerified: false)
        )
        mock.mockData = try? JSONEncoder().encode(response)
        // Create a response with refresh token cookie
        let httpResponse = HTTPURLResponse(url: URL(string: "https://neuronote.com")!,
                                         statusCode: 200,
                                         httpVersion: nil,
                                         headerFields: ["Set-Cookie": "refreshToken=mock_refresh_token; Path=/; HttpOnly"])!
        mock.mockResponse = httpResponse
        
        let manager = AuthManager(session: mock)
        
        do {
            let session = try await manager.authenticate(
                email: Constants.Tests.validEmail,
                password: Constants.Tests.validPassword,
                mode: .signin
            )
            XCTAssertEqual(session.token, token)
            XCTAssertFalse(session.isVerified)
        } catch {
            XCTFail("Expected success but got error: \(error)")
        }
    }
    
    func testUnexpectedErrorThrows() async {
        struct BrokenSession: NetworkSession {
            func data(for request: URLRequest) async throws -> (Data, URLResponse) {
                throw NSError(
                    domain: "test",
                    code: 999,
                    userInfo: nil
                )
            }
        }
        let manager = AuthManager(session: BrokenSession())
        
        await XCTAssertThrowsErrorAsync(try await manager.authenticate(
            email: Constants.Tests.validEmail,
            password: Constants.Tests.validPassword,
            mode: .signin
        )) { error in
            XCTAssertEqual(error as? AuthError, .unexpectedError)
        }
    }
    
    // MARK: - NetworkError tests
    func testNetworkConnectionLostMapsToNoInternet() async {
        let mock = MockNetworkSession()
        mock.injectedURLError = .networkConnectionLost
        let manager = AuthManager(session: mock)
        
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
    
    func testCannotFindHostMapsToCannotReachServer() async {
        let mock = MockNetworkSession()
        mock.injectedURLError = .cannotFindHost
        let manager = AuthManager(session: mock)
        
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
    
    func testCannotConnectToHostMapsToCannotReachServer() async {
        let mock = MockNetworkSession()
        mock.injectedURLError = .cannotConnectToHost
        let manager = AuthManager(session: mock)
        
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
    
    func testUnhandledURLErrorMapsToGeneric() async {
        let mock = MockNetworkSession()
        mock.injectedURLError = .badURL
        let manager = AuthManager(session: mock)
        
        await XCTAssertThrowsErrorAsync(
            try await manager.authenticate(
                email: Constants.Tests.validEmail,
                password: Constants.Tests.validPassword,
                mode: .signin
            )
        ) { error in
            guard case .generic(_) = error as? NetworkError else {
                return XCTFail("Expected .generic NetworkError")
            }
        }
    }
    
    // MARK: - Successful Reset Password Tests
    
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
    
    // MARK: - Network Error Tests
    
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
    
    // MARK: - API Error Tests
    
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
        mockAuthManager.serverMessageToThrow = .internalServerError
        
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
        let serverCodes: [AuthServerCode] = [
            .internalServerError,
            .unauthorized,
        ]
        
        for serverCode in serverCodes {
            let request = ResetPasswordRequest(userId: "test_user", password: "NewPassword123!")
            mockAuthManager.shouldThrowServerError = true
            mockAuthManager.serverMessageToThrow = serverCode
            
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
        mockAuthManager.resetPasswordDelay = 0.01 // Very fast for performance testing
        
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
