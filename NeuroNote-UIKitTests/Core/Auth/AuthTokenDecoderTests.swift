//
//  AuthTokenDecoderTests.swift
//  NeuroNote-UIKit
//
//  Created by Eclipse on 23/07/25.
//

import XCTest
@testable import NeuroNote_UIKit

final class AuthTokenDecoderTests: XCTestCase {

    func testDecodeValidJWTReturnsCorrectUserId() {
        // JWT with payload: { "user_id": "test-user-id" }
        let token = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9." +
                    "eyJ1c2VyX2lkIjoidGVzdC11c2VyLWlkIiwiZW1haWwiOiJ0ZXN0QGVtYWlsLmNvbSIsImV4cCI6MTk5OTk5OTk5OX0." +
                    "X3fQQv_kdS5Aow0qAHJtk6Mrw9r0Beq19drz9PjOWLY"

        let result = AuthTokenDecoder.standard.decodeJWT(token: token)

        XCTAssertNotNil(result)
        XCTAssertEqual(result?.userId, "test-user-id")
    }

    func testDecodeInvalidJWTReturnsNil() {
        let invalidToken = "not.a.valid.token"
        let result = AuthTokenDecoder.standard.decodeJWT(token: invalidToken)
        XCTAssertNil(result)
    }

    func testDecodeMalformedPayloadReturnsNil() {
        let badPayload = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.bad_payload.signature"
        let result = AuthTokenDecoder.standard.decodeJWT(token: badPayload)
        XCTAssertNil(result)
    }
}
