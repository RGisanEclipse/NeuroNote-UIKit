//
//  PasswordValidator.swift
//  NeuroNote
//
//  Created by Eclipse on 09/07/25.
//

//  PasswordValidator.swift
//  NeuroNote
//
//  Created by Eclipse on 09/07/25.
//

import Foundation

struct PasswordValidator {
    static func validate(_ password: String) -> AlertContent? {
        let uppercaseRegex = ".*[A-Z]+.*"
        let lowercaseRegex = ".*[a-z]+.*"
        let digitRegex = ".*[0-9]+.*"
        let specialCharacterRegex = ".*[!@#$%^&*(),.?\":{}|<>]+.*"
        let repeatedRegex = ".*(.)\\1{2,}.*"
        let whitespaceRegex = ".*\\s+.*"
        let commonPasswords = PasswordManager.getCommonPasswords()

        if password.count < 8 {
            return PasswordAlerts.passwordTooShort
        } else if password.count > 32 {
            return PasswordAlerts.passwordTooLong
        } else if !NSPredicate(format: "SELF MATCHES %@", uppercaseRegex).evaluate(with: password) {
            return PasswordAlerts.noUppercase
        } else if !NSPredicate(format: "SELF MATCHES %@", lowercaseRegex).evaluate(with: password) {
            return PasswordAlerts.noLowercase
        } else if !NSPredicate(format: "SELF MATCHES %@", digitRegex).evaluate(with: password) {
            return PasswordAlerts.noNumber
        } else if !NSPredicate(format: "SELF MATCHES %@", specialCharacterRegex).evaluate(with: password) {
            return PasswordAlerts.noSpecialCharacter
        } else if NSPredicate(format: "SELF MATCHES %@", repeatedRegex).evaluate(with: password) {
            return PasswordAlerts.repeatedCharacters
        } else if NSPredicate(format: "SELF MATCHES %@", whitespaceRegex).evaluate(with: password) {
            return PasswordAlerts.whitespaceInPassword
        } else if commonPasswords.contains(password) {
            return PasswordAlerts.commonPassword
        }

        return nil
    }
}
