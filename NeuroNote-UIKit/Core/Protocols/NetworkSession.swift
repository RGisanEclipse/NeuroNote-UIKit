//
//  NetworkSession.swift
//  NeuroNote-UIKit
//
//  Created by Eclipse on 20/07/25.
//
import Foundation

protocol NetworkSession {
    func data(for request: URLRequest) async throws -> (Data, URLResponse)
}

extension URLSession: NetworkSession {}
