//
//  ResetPasswordRequest.swift
//  AVYO
//
//  Created by Eclipse on 13/10/25.
//

struct ResetPasswordRequest: Codable {
    let userId: String
    let password: String
}
