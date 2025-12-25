//
//  EmailAlerts.swift
//  NeuroNote
//
//  Created by Eclipse on 09/07/25.
//

import Foundation

enum EmailAlerts {
    static let invalidEmailFormat = AlertContent(
        title: "Email be like 🤡",
        message: "Bruh, that's not even an email 😭. We can't slide into your inbox if your email's broken.",
        shouldBeRed: true,
        animationName: Constants.animations.angryStar
    )
    static let commonEmailError = AlertContent(
        title: "Fake Vibes 🚩",
        message: "That email looks faker than influencer drama. Try a real one.",
        shouldBeRed: true,
        animationName: Constants.animations.angryStar
    )
}
// MARK: - Aliases for ServerErrorCode compatibility
enum EmailAlert {
    static let required = AlertContent(
        title: "Email Required 📧",
        message: "We need your email to continue. Don't leave us hanging!",
        shouldBeRed: true,
        animationName: Constants.animations.angryStar
    )
    
    static let invalid = EmailAlerts.invalidEmailFormat
}

enum PasswordAlert {
    static let required = AlertContent(
        title: "Password Needed 🔐",
        message: "Can't log in without a password. That's the whole point!",
        shouldBeRed: true,
        animationName: Constants.animations.angryStar
    )
    
    static let tooShort = PasswordAlerts.passwordTooShort
    static let tooLong = PasswordAlerts.passwordTooLong
    static let noUppercase = PasswordAlerts.noUppercase
    static let noLowercase = PasswordAlerts.noLowercase
    static let noDigit = PasswordAlerts.noNumber
    static let noSpecialChar = PasswordAlerts.noSpecialCharacter
    static let hasWhitespace = PasswordAlerts.whitespaceInPassword
}

enum OnboardingAlert {
    static let nameTooLong = AlertContent(
        title: "Name's Too Long 📏",
        message: "Keep your name under 50 characters. We're not writing a biography!",
        shouldBeRed: true,
        animationName: Constants.animations.angryStar
    )
    
    static let nameTooShort = AlertContent(
        title: "Name's Missing 🤷",
        message: "We need to call you something! Enter your name.",
        shouldBeRed: true,
        animationName: Constants.animations.angryStar
    )
    
    static let ageOutOfRange = AlertContent(
        title: "Age Check Failed 🎂",
        message: "Age must be between 13 and 100. Time travelers not allowed!",
        shouldBeRed: true,
        animationName: Constants.animations.angryStar
    )
    
    static let invalidGender = AlertContent(
        title: "Invalid Selection 🚫",
        message: "Please select a valid gender option.",
        shouldBeRed: true,
        animationName: Constants.animations.angryStar
    )
    
    static let alreadyOnboarded = AlertContent(
        title: "Already Done ✅",
        message: "You've already completed onboarding. Let's get you to the app!",
        shouldBeRed: false,
        animationName: Constants.animations.thumbsUp
    )
}

enum ServerAlert {
    static let tooManyRequests = NetworkAlert.tooManyRequests
}

