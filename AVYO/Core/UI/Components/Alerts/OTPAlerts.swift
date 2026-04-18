//
//  OTPAlerts.swift
//  AVYO
//
//  Created by Eclipse on 20/07/25.
//

enum OTPAlert {
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
        message: "Something went wrong, but we're not sure what. Try again or manifest it into existence.",
        shouldBeRed: true,
        animationName: Constants.animations.unsureStar
    )
    
    static let expired = AlertContent(
        title: "OTP's Gone 💨",
        message: "That OTP expired like old milk. Request a fresh one!",
        shouldBeRed: true,
        animationName: Constants.animations.angryStar
    )
    
    static let invalid = AlertContent(
        title: "Wrong Code 🔢",
        message: "That OTP ain't it. Check your inbox and try again.",
        shouldBeRed: true,
        animationName: Constants.animations.angryStar
    )
    
    static let required = AlertContent(
        title: "OTP Missing 📭",
        message: "We need the code! Check your email and enter it here.",
        shouldBeRed: true,
        animationName: Constants.animations.angryStar
    )
    
    static let notVerified = AlertContent(
        title: "Hold Up ✋",
        message: "You need to verify the OTP first before resetting your password.",
        shouldBeRed: true,
        animationName: Constants.animations.angryStar
    )
}
