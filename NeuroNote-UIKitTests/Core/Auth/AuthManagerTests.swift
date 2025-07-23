//  AuthManagerTests.swift
//  NeuroNote
//
//  Created by Eclipse on 09/07/25.
//

import XCTest
@testable import NeuroNote_UIKit

final class AuthManagerTests: XCTestCase {
    
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
        let mock = MockNetworkSession()
        let token = makeMockJWT(userId: Constants.Tests.userId)
        let response = AuthResponse(
            success: true,
            message: "ok",
            token: token,
            isVerified: true
        )
        mock.mockData = try? JSONEncoder().encode(response)
        mock.mockResponse = makeHTTP200Response()
        
        let manager = AuthManager(session: mock)
        
        do {
            let session = try await manager.authenticate(
                email: Constants.Tests.validEmail,
                password: Constants.Tests.validPassword,
                mode: .signin
            )
            XCTAssertEqual(session.token, token)
            XCTAssertEqual(manager.currentToken(), token)
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
            token: token,
            isVerified: false
        )
        mock.mockData = try? JSONEncoder().encode(response)
        mock.mockResponse = makeHTTP200Response()
        
        let manager = AuthManager(session: mock)
        
        do {
            let session = try await manager.authenticate(
                email: Constants.Tests.validEmail,
                password: Constants.Tests.validPassword,
                mode: .signin
            )
            XCTAssertEqual(session.token, token)
            XCTAssertEqual(session.userId, Constants.Tests.userId)
            XCTAssertFalse(session.isVerified)
        } catch {
            XCTFail("Expected success but got error: \(error)")
        }
    }
    
    // MARK: - AuthError tests
    func testInvalidResponseThrows() async {
        let mock = MockNetworkSession()
        mock.mockData = Data()
        mock.mockResponse = URLResponse()
        let manager = AuthManager(session: mock)
        
        await XCTAssertThrowsErrorAsync(try await manager.authenticate(
            email: Constants.Tests.validEmail,
            password: Constants.Tests.validPassword,
            mode: .signin
        )) { error in
            XCTAssertEqual(error as? AuthError, .invalidResponse)
        }
    }
    
    func testDecodingFailureThrows() async {
        let mock = MockNetworkSession()
        mock.mockData = "Not JSON".data(using: .utf8)
        mock.mockResponse = makeHTTP200Response()
        let manager = AuthManager(session: mock)
        
        await XCTAssertThrowsErrorAsync(try await manager.authenticate(
            email: Constants.Tests.validEmail,
            password: Constants.Tests.validPassword,
            mode: .signin
        )) { error in
            XCTAssertEqual(error as? AuthError, .decodingFailed)
        }
    }
    
    func testNoTokenThrows() async {
        let mock = MockNetworkSession()
        let response = AuthResponse(
            success: true,
            message: "ok",
            token: nil,
            isVerified: true
        )
        mock.mockData = try? JSONEncoder().encode(response)
        mock.mockResponse = makeHTTP200Response()
        let manager = AuthManager(session: mock)
        
        await XCTAssertThrowsErrorAsync(try await manager.authenticate(
            email: Constants.Tests.validEmail,
            password: Constants.Tests.validPassword,
            mode: .signin
        )) { error in
            XCTAssertEqual(error as? AuthError, .noTokenReceived)
        }
    }
    
    func testNoUserIdThrows() async {
        let mock = MockNetworkSession()
        let response = AuthResponse(
            success: true,
            message: "ok",
            token: "demotoken",
            isVerified: false
        )
        mock.mockData = try? JSONEncoder().encode(response)
        mock.mockResponse = makeHTTP200Response()
        let manager = AuthManager(session: mock)
        
        await XCTAssertThrowsErrorAsync(try await manager.authenticate(
            email: Constants.Tests.validEmail,
            password: Constants.Tests.validPassword,
            mode: .signin
        )) { error in
            XCTAssertEqual(error as? AuthError, .noUserIdReceived)
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
