//
//  NetworkAlerts.swift
//  NeuroNote-UIKit
//
//  Created by Eclipse on 14/07/25.
//

// MARK: - Network-side Alerts
enum NetworkAlert {
    
    static let noInternet = AlertContent(
        title: "Wi-Fi Ghosted 📡💨",
        message: "You’re totally offline, fam. Flip that switch and slide back.",
        shouldBeRed: true,
        animationName: Constants.animations.noWifi
    )

    static let timeout = AlertContent(
        title: "Too Slow, Bro 🐌",
        message: "The request took an eternal nap. Smash that button again.",
        shouldBeRed: true,
        animationName: Constants.animations.angryStar
    )
    
    static let cannotReachServer = AlertContent(
        title: "Server’s in Stealth Mode 👻",
        message: "We knocked. No answer. Server’s on a vibe break. Try again later.",
        shouldBeRed: true,
        animationName: Constants.animations.unsureStar
    )

    static func generic(_ msg: String) -> AlertContent {
        AlertContent(
            title: "Network Glitchin’ 🌐✨",
            message: msg.isEmpty ? "The tubes got tangled. Try again?" : msg,
            shouldBeRed: false,
            animationName: Constants.animations.unsureStar
        )
    }
    static let tooManyRequests = AlertContent(
        title: "Chill 😮‍💨",
        message: "You're going too fast. Slow down a bit.",
        shouldBeRed: true,
        animationName: Constants.animations.angryStar
    )
}
