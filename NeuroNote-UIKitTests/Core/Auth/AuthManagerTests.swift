//
//  AuthManagerTests.swift
//  NeuroNote
//
//  Created by Eclipse on 09/07/25.
//

import XCTest
@testable import NeuroNote_UIKit

final class AuthManagerTests: XCTestCase {
    
    class MockNetworkSession: NetworkSession {
        var shouldThrowURLError = false
        var mockData: Data?
        var mockResponse: URLResponse?
        
        func data(for request: URLRequest) async throws -> (Data, URLResponse) {
            if shouldThrowURLError {
                throw URLError(.notConnectedToInternet)
            }
            return (mockData ?? Data(), mockResponse ?? URLResponse())
        }
    }
    
    func testInvalidResponseThrows() async {
        let mock = MockNetworkSession()
        mock.mockData = Data()
        mock.mockResponse = URLResponse() // Not HTTPURLResponse
        let manager = AuthManager(session: mock)
        
        do {
            _ = try await manager.authenticate(email: "a@b.com", password: "123", mode: .signin)
            XCTFail("Expected invalidResponse error")
        } catch let error as AuthError {
            XCTAssertEqual(error, .invalidResponse)
        } catch{
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func testDecodingFailureThrows() async {
        let mock = MockNetworkSession()
        mock.mockData = "Not JSON".data(using: .utf8)
        mock.mockResponse = HTTPURLResponse(url: URL(string: "https://neuronote.com")!,
                                            statusCode: 200, httpVersion: nil, headerFields: nil)
        let manager = AuthManager(session: mock)
        
        do {
            _ = try await manager.authenticate(email: "a@b.com", password: "123", mode: .signin)
            XCTFail("Expected decodingFailed error")
        } catch let error as AuthError {
            XCTAssertEqual(error, .decodingFailed)
        } catch{
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func testNoTokenThrows() async {
        let mock = MockNetworkSession()
        let response = AuthResponse(success: true, message: "ok", token: nil)
        mock.mockData = try? JSONEncoder().encode(response)
        mock.mockResponse = HTTPURLResponse(url: URL(string: "https://neuronote.com")!,
                                            statusCode: 200, httpVersion: nil, headerFields: nil)
        let manager = AuthManager(session: mock)
        
        do {
            _ = try await manager.authenticate(email: "a@b.com", password: "123", mode: .signin)
            XCTFail("Expected noTokenReceived error")
        } catch let error as AuthError {
            XCTAssertEqual(error, .noTokenReceived)
        } catch{
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func testUnexpectedErrorThrows() async {
        class BrokenSession: NetworkSession {
            func data(for request: URLRequest) async throws -> (Data, URLResponse) {
                throw NSError(domain: "test", code: 999, userInfo: nil)
            }
        }
        
        let manager = AuthManager(session: BrokenSession())
        
        do {
            _ = try await manager.authenticate(email: "a@b.com", password: "123", mode: .signin)
            XCTFail("Expected unexpectedError")
        } catch let error as AuthError {
            XCTAssertEqual(error, .unexpectedError)
        } catch{
            XCTFail("Unexpected error: \(error)")
        }
    }
}
