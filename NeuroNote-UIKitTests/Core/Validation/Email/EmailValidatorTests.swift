//
//  EmailValidatorTests.swift
//  NeuroNote
//
//  Created by Eclipse on 09/07/25.
//

import XCTest
@testable import NeuroNote_UIKit

final class EmailValidatorTests: XCTestCase{
    func testInvalidEmailFormat() {
        let result = EmailValidator.validate(email: "invalid-email")
        XCTAssertEqual(result?.title, EmailAlerts.invalidEmailFormat.title)
    }

    func testCommonEmail() {
        let result = EmailValidator.validate(email: "123456789@gmail.com")
        XCTAssertEqual(result?.title, EmailAlerts.commonEmailError.title)
    }

    func testValidEmailPasses() {
        let result = EmailValidator.validate(email: "neuronote@gmail.com")
        XCTAssertNil(result)
    }
}
