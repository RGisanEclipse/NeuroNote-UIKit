//
//  MockNetworkSession.swift
//  NeuroNote
//
//  Created by Eclipse on 09/07/25.
//

import Foundation
@testable import NeuroNote_UIKit

class MockNetworkSession: NetworkSession {
    var nextData: Data?
    var nextResponse: URLResponse?
    var shouldThrowError = false

    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        if shouldThrowError {
            throw URLError(.badServerResponse)
        }
        return (nextData ?? Data(), nextResponse ?? HTTPURLResponse())
    }
}
