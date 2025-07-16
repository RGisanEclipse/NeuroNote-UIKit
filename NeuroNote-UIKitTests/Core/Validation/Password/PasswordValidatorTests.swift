//
//  PasswordValidatorTests.swift
//  NeuroNote
//
//  Created by Eclipse on 09/07/25.
//

import XCTest
@testable import NeuroNote_UIKit

final class PasswordValidatorTests: XCTestCase{
    
    func testPasswordTooShort() {
        let result = PasswordValidator.validate("Ab1@", email: Constants.Tests.validEmail)
        XCTAssertEqual(result?.title, PasswordAlerts.passwordTooShort.title)
    }
    
    func testPasswordTooLong(){
        let result = PasswordValidator.validate("ThisIsAVeryLongPassw0rd@123456789!", email: Constants.Tests.validEmail)
        XCTAssertEqual(result?.title, PasswordAlerts.passwordTooLong.title)
    }
    
    func testPasswordMissingUppercase() {
        let result = PasswordValidator.validate("password1@", email: Constants.Tests.validEmail)
        XCTAssertEqual(result?.title, PasswordAlerts.noUppercase.title)
    }
    
    func testPasswordMissingLowercase() {
        let result = PasswordValidator.validate("PASSWORD1@", email: Constants.Tests.validEmail)
        XCTAssertEqual(result?.title, PasswordAlerts.noLowercase.title)
    }

    func testPasswordMissingNumber() {
        let result = PasswordValidator.validate("Password!@", email: Constants.Tests.validEmail)
        XCTAssertEqual(result?.title, PasswordAlerts.noNumber.title)
    }
    
    func testPasswordMissingSpecialCharacter() {
        let result = PasswordValidator.validate("Password12", email: Constants.Tests.validEmail)
        XCTAssertEqual(result?.title, PasswordAlerts.noSpecialCharacter.title)
    }
    
    func testPasswordRepeatedCharacters() {
        let result = PasswordValidator.validate("Paaaassword1@", email: Constants.Tests.validEmail)
        XCTAssertEqual(result?.title, PasswordAlerts.repeatedCharacters.title)
    }
    
    func testPasswordWithWhiteSpace() {
        let result = PasswordValidator.validate("Pass word1@", email: Constants.Tests.validEmail)
        XCTAssertEqual(result?.title, PasswordAlerts.whitespaceInPassword.title)
    }
    
    func testCommonPassword(){
        let result = PasswordValidator.validate("asdfghjkl1A1@", email: Constants.Tests.validEmail)
        XCTAssertEqual(result?.title, PasswordAlerts.commonPassword.title)
    }
    
    func testPasswordPassesAllChecks() {
        let result = PasswordValidator.validate("CoolPass1@", email: Constants.Tests.validEmail)
        XCTAssertNil(result)
    }
}
