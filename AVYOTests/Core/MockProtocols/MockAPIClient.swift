//
//  MockAPIClient.swift
//  AVYO
//
//  Created by Eclipse on 04/01/26.
//

import Foundation
@testable import NeuroNote_UIKit

final class MockAPIClient: APIClientProtocol {
    
    // MARK: - Configurable Response Data
    var mockResponseData: Any?
    var mockHTTPResponse: HTTPURLResponse?
    var mockError: Error?
    
    // MARK: - Tracking
    var lastEndpoint: String?
    var lastMethod: HTTPMethod?
    var lastBody: Encodable?
    var requestCount = 0
    
    // MARK: - APIClientProtocol
    
    func request<T: Decodable>(
        endpoint: String,
        method: HTTPMethod,
        body: Encodable?,
        requiresAuth: Bool
    ) async throws -> T {
        trackRequest(endpoint: endpoint, method: method, body: body)
        
        if let error = mockError {
            throw error
        }
        
        guard let response = mockResponseData as? T else {
            throw APIClientError.invalidResponse
        }
        
        return response
    }

    func request<T: Decodable>(
        route: Route,
        body: Encodable?,
        requiresAuth: Bool
    ) async throws -> T {
        trackRequest(endpoint: route.path, method: route.method, body: body)

        if let error = mockError {
            throw error
        }

        guard let response = mockResponseData as? T else {
            throw APIClientError.invalidResponse
        }

        return response
    }
    
    func requestSuccess(
        endpoint: String,
        method: HTTPMethod,
        body: Encodable?,
        requiresAuth: Bool
    ) async throws {
        trackRequest(endpoint: endpoint, method: method, body: body)
        
        if let error = mockError {
            throw error
        }
    }

    func requestSuccess(
        route: Route,
        body: Encodable?,
        requiresAuth: Bool
    ) async throws {
        trackRequest(endpoint: route.path, method: route.method, body: body)

        if let error = mockError {
            throw error
        }
    }
    
    func requestWithResponse<T: Decodable>(
        endpoint: String,
        method: HTTPMethod,
        body: Encodable?,
        requiresAuth: Bool
    ) async throws -> (data: T, response: HTTPURLResponse) {
        trackRequest(endpoint: endpoint, method: method, body: body)
        
        if let error = mockError {
            throw error
        }
        
        guard let responseData = mockResponseData as? T else {
            throw APIClientError.invalidResponse
        }
        
        let httpResponse = mockHTTPResponse ?? HTTPURLResponse(
            url: URL(string: "https://test.com")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )!
        
        return (data: responseData, response: httpResponse)
    }

    func requestWithResponse<T: Decodable>(
        route: Route,
        body: Encodable?,
        requiresAuth: Bool
    ) async throws -> (data: T, response: HTTPURLResponse) {
        trackRequest(endpoint: route.path, method: route.method, body: body)

        if let error = mockError {
            throw error
        }

        guard let responseData = mockResponseData as? T else {
            throw APIClientError.invalidResponse
        }

        let httpResponse = mockHTTPResponse ?? HTTPURLResponse(
            url: URL(string: "https://test.com")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )!

        return (data: responseData, response: httpResponse)
    }
    
    // MARK: - Helpers
    
    private func trackRequest(endpoint: String, method: HTTPMethod, body: Encodable?) {
        lastEndpoint = endpoint
        lastMethod = method
        lastBody = body
        requestCount += 1
    }
    
    func reset() {
        mockResponseData = nil
        mockHTTPResponse = nil
        mockError = nil
        lastEndpoint = nil
        lastMethod = nil
        lastBody = nil
        requestCount = 0
    }
}



