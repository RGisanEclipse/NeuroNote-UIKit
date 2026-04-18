//
//  PasswordAlerts.swift
//  AVYO
//
//  Created by Eclipse on 09/07/25.
//


import Foundation

enum PasswordAlerts {
    
    static let passwordTooShort = AlertContent(
        title: "Short King? 👶",
        message: "Nah fam, 8+ chars only. Go grow that password up. 🧢",
        shouldBeRed: true,
        animationName: Constants.animations.angryStar
    )

    static let passwordTooLong = AlertContent(
        title: "Calm Down, Hacker 💻",
        message: "Keep it under 32 characters, bro. You ain't writing a novel.",
        shouldBeRed: true,
        animationName: Constants.animations.angryStar
    )
    
    static let noUppercase = AlertContent(
        title: "Where’s the Caps? 🧢",
        message: "Throw in a capital letter. Don’t be lazy. 😤",
        shouldBeRed: true,
        animationName: Constants.animations.angryStar
    )

    static let noLowercase = AlertContent(
        title: "Too LOUD 🔊",
        message: "Mix in some lowercase letters, we ain’t shouting all day.",
        shouldBeRed: true,
        animationName: Constants.animations.angryStar
    )

    static let noNumber = AlertContent(
        title: "Digits Please 🔢",
        message: "No numbers? Add some sauce with digits. 🔥",
        shouldBeRed: true,
        animationName: Constants.animations.angryStar
    )

    static let noSpecialCharacter = AlertContent(
        title: "Where’s the ✨ Spice? ✨",
        message: "You need at least one special character. Don't be plain toast.",
        shouldBeRed: true,
        animationName: Constants.animations.angryStar
    )

    static let repeatedCharacters = AlertContent(
        title: "Chill with the spam 🔁",
        message: "Don't repeat characters like you're stuck on a keyboard loop.",
        shouldBeRed: true,
        animationName: Constants.animations.angryStar
    )

    static let whitespaceInPassword = AlertContent(
        title: "Whitespace? Seriously? 🚫",
        message: "Passwords don't need spaces. This ain’t poetry class.",
        shouldBeRed: true,
        animationName: Constants.animations.angryStar
    )

    static let commonPassword = AlertContent(
        title: "Cliché much? 🙄",
        message: "That password's too basic. Even hackers are bored of it.",
        shouldBeRed: true,
        animationName: Constants.animations.angryStar
    )
}
