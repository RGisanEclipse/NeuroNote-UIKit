//
//  AuthNetworkError.swift
//  NeuroNote-UIKit
//
//  Created by Eclipse on 26/07/25.
//

enum AuthNetworkError: Error {
    case unauthorized
    case tokenRefreshFailed
    case underlyingError(Error)
}
