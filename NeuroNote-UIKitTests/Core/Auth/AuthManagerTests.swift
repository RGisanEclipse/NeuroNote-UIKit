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
    
    // MARK: - Happy-AuthCase test
    func testAuthenticateReturnsTokenOnSuccess() async {
        let mock = MockNetworkSession()
        let response = AuthResponse(
            success: true,
            message: "ok",
            token: "testToken123",
            userId: "user123"
        )
        mock.mockData = try? JSONEncoder().encode(response)
        mock.mockResponse = makeHTTP200Response()
        
        let manager = AuthManager(session: mock)
        
        do {
            let token = try await manager.authenticate(
                email: Constants.Tests.validEmail,
                password: Constants.Tests.validPassword,
                mode: .signin
            )
            XCTAssertEqual(token, "testToken123")
            XCTAssertEqual(manager.currentToken(), "testToken123")
            XCTAssertEqual(manager.currentUser(), "user123")
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
            userId: "123445"
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
            userId: nil
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
