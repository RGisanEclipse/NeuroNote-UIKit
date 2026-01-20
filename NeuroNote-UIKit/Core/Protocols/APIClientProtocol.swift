//
//  APIClientProtocol.swift
//  NeuroNote-UIKit
//
//  Created by Eclipse on 04/01/26.
//

import Foundation

protocol APIClientProtocol {
    func request<T: Decodable>(
        endpoint: String,
        method: HTTPMethod,
        body: Encodable?,
        requiresAuth: Bool
    ) async throws -> T

    func request<T: Decodable>(
        route: Route,
        body: Encodable?,
        requiresAuth: Bool
    ) async throws -> T
    
    func requestSuccess(
        endpoint: String,
        method: HTTPMethod,
        body: Encodable?,
        requiresAuth: Bool
    ) async throws

    func requestSuccess(
        route: Route,
        body: Encodable?,
        requiresAuth: Bool
    ) async throws
    
    func requestWithResponse<T: Decodable>(
        endpoint: String,
        method: HTTPMethod,
        body: Encodable?,
        requiresAuth: Bool
    ) async throws -> (data: T, response: HTTPURLResponse)

    func requestWithResponse<T: Decodable>(
        route: Route,
        body: Encodable?,
        requiresAuth: Bool
    ) async throws -> (data: T, response: HTTPURLResponse)
}

// Default parameter values via extension
extension APIClientProtocol {
    func request<T: Decodable>(
        endpoint: String,
        method: HTTPMethod = .get,
        body: Encodable? = nil,
        requiresAuth: Bool = true
    ) async throws -> T {
        try await request(endpoint: endpoint, method: method, body: body, requiresAuth: requiresAuth)
    }

    func request<T: Decodable>(
        route: Route,
        body: Encodable? = nil,
        requiresAuth: Bool = true
    ) async throws -> T {
        try await request(route: route, body: body, requiresAuth: requiresAuth)
    }
    
    func requestSuccess(
        endpoint: String,
        method: HTTPMethod = .post,
        body: Encodable? = nil,
        requiresAuth: Bool = true
    ) async throws {
        try await requestSuccess(endpoint: endpoint, method: method, body: body, requiresAuth: requiresAuth)
    }

    func requestSuccess(
        route: Route,
        body: Encodable? = nil,
        requiresAuth: Bool = true
    ) async throws {
        try await requestSuccess(route: route, body: body, requiresAuth: requiresAuth)
    }
    
    func requestWithResponse<T: Decodable>(
        endpoint: String,
        method: HTTPMethod = .post,
        body: Encodable? = nil,
        requiresAuth: Bool = false
    ) async throws -> (data: T, response: HTTPURLResponse) {
        try await requestWithResponse(endpoint: endpoint, method: method, body: body, requiresAuth: requiresAuth)
    }

    func requestWithResponse<T: Decodable>(
        route: Route,
        body: Encodable? = nil,
        requiresAuth: Bool = false
    ) async throws -> (data: T, response: HTTPURLResponse) {
        try await requestWithResponse(route: route, body: body, requiresAuth: requiresAuth)
    }
}



