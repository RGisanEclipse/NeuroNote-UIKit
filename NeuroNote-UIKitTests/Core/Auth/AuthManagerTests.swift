//  AuthManagerTests.swift
//  NeuroNote
//
//  Created by Eclipse on 09/07/25.
//

import XCTest
@testable import NeuroNote_UIKit

final class AuthManagerTests: XCTestCase {
    
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
