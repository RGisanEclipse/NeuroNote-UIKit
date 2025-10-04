//
//  OTPAlerts.swift
//  NeuroNote-UIKit
//
//  Created by Eclipse on 20/07/25.
//

enum OTPAlert{
    static let invalidEmail = AlertContent(
        title: "Oops 😬",
        message: "That email's not giving valid. Double-check and try again.",
        shouldBeRed: true,
        animationName: Constants.animations.angryStar
    )
    
    static let deliveryFailed = AlertContent(
        title: "Vibe Check Failed 🚫",
        message: "Couldn't send the OTP. Servers are having a moment. Try again soon!",
        shouldBeRed: true,
        animationName: Constants.animations.noWifi
    )
    
    static let unknown = AlertContent(
        title: "What just happened? 🤔",
        message: "Something went wrong, but we’re not sure what. Try again or manifest it into existence.",
        shouldBeRed: true,
        animationName: Constants.animations.unsureStar
    )
}
