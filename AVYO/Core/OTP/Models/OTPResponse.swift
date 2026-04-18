//
//  OTPResponse.swift
//  AVYO
//
//  Created by Eclipse on 20/07/25.
//

// Note: OTP endpoints now use the unified SuccessAPIResponse from API.swift
// This file is kept for backwards compatibility but the response structure
// matches: { "success": true, "status": 200, "response": { "success": true, "message": "..." } }

// Legacy typealias - OTP responses now use SuccessAPIResponse
typealias OTPResponse = SuccessMessageData
