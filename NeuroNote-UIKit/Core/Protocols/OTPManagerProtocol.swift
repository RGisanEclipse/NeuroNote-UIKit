//
//  OTPManagerProtocol.swift
//  NeuroNote-UIKit
//
//  Created by Eclipse on 17/08/25.
//

protocol OTPManagerProtocol {
    func requestOTP(userId: String, purpose: OTPPurpose) async throws -> OTPResponse
    func verifyOTP(_ code: String, userId: String, purpose: OTPPurpose) async throws -> OTPResponse
}
