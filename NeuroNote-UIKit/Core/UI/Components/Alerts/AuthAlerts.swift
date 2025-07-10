//
//  AuthAlerts.swift
//  NeuroNote
//
//  Created by Eclipse on 05/07/25.
//

// Alerts.swift

// AuthAlert contains client side Alert Content
enum AuthAlert {
    static let fieldsMissing = AlertContent(
        title: "Hold Up 🛑",
        message: "You really thought you could skip fields? Nah.",
        shouldBeRed: true,
        imageName: Constants.moodImages.angry
    )
    
    static let passwordMismatch = AlertContent(
        title: "Password Beef Detected 🔍",
        message: "Those passwords are on different planets. Make ’em match.",
        shouldBeRed: true,
        imageName: Constants.moodImages.angry
    )
    
    static let signupSuccess = AlertContent(
        title: "New Vibes Unlocked 🎉",
        message: "You’re in! Let’s cause some chaos ✨",
        shouldBeRed: false,
        imageName: Constants.moodImages.happy
    )
    
    static let signinSuccess = AlertContent(
        title: "Back Like You Never Left 😎",
        message: "Login successful. Let the shenanigans resume.",
        shouldBeRed: false,
        imageName: Constants.moodImages.happy
    )
    
    static let emailDoesNotExist = AlertContent(
        title: "Umm… Who Dis?",
        message: "We couldn't find an account with this email.",
        shouldBeRed: true,
        imageName: Constants.moodImages.angry
    )
    
    static let emailAlreadyExists = AlertContent(
        title: "Slow Down, It's Taken 😬",
        message: "An account with this email already exists.",
        shouldBeRed: true,
        imageName: Constants.moodImages.angry
    )
    
    static let incorrectPassword = AlertContent(
        title: "That's Not It, Chief",
        message: "Double-check your password and try again.",
        shouldBeRed: true,
        imageName: Constants.moodImages.angry
    )
    
    static let tokenInvalid = AlertContent(
        title: "Session’s Toasted 🔥",
        message: "Please log in again to refresh things.",
        shouldBeRed: false,
        imageName: Constants.moodImages.feared
    )
    
    static let internalServerError = AlertContent(
        title: "Our Bad 😓",
        message: "Something broke on our end. We're on it.",
        shouldBeRed: false,
        imageName: Constants.moodImages.feared
    )
    
    static let unauthorized = AlertContent(
        title: "Nope, Not Allowed 🚫",
        message: "Looks like you don’t have access.",
        shouldBeRed: true,
        imageName: Constants.moodImages.angry
    )
    
    static let invalidRequestBody = AlertContent(
        title: "This Ain’t It 😵‍💫",
        message: "That form didn’t make sense. Try again?",
        shouldBeRed: false,
        imageName: Constants.moodImages.feared
    )
    
    static let tooManyRequests = AlertContent(
        title: "Chill 😮‍💨",
        message: "You're going too fast. Slow down a bit.",
        shouldBeRed: true,
        imageName: Constants.moodImages.angry
    )
    
    static let unknown = AlertContent(
        title: "We Dunno Either 🤷‍♂️",
        message: "Seems like we've hit a new error. We'll check it out.",
        shouldBeRed: false,
        imageName: Constants.moodImages.feared
    )
}
