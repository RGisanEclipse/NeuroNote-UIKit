//
//  RefreshTokenRequest.swift
//  NeuroNote-UIKit
//
//  Created by Eclipse on 25/12/25.
//

struct RefreshTokenRequest: Codable{
    let refresh_token: String
    let deviceID:      String
}
