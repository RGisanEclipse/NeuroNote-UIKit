//
//  EmailValidator.swift
//  NeuroNote
//
//  Created by Eclipse on 09/07/25.
//

import Foundation

struct EmailValidator {
    static func validate(email: String) -> AlertContent? {
        let emailRegex = #"^[^@\s]+@[^@\s]+\.[^@\s]+$"#
        let predicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)

        if !predicate.evaluate(with: email) {
            return EmailAlerts.invalidEmailFormat
        }

        if EmailManager.isCommonEmail(email) {
            return EmailAlerts.commonEmailError
        }
        
        return nil
    }
}
