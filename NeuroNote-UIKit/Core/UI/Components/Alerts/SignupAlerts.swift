//
//  SignupAlerts.swift
//  NeuroNote-UIKit
//
//  Created by Eclipse on 02/11/25.
//

import Foundation

enum SignupAlerts {
    
    static let confirmAge = AlertContent(
        title: "Still 21? 😏",
        message: "Slider didn’t move an inch. Just making sure you're 21. 👀",
        shouldBeRed: false,
        animationName: Constants.animations.unsureStar
    )
    
    static let emptyGender = AlertContent(
            title: "Pick a vibe 🔮",
            message: "Can’t skip this one, bestie. We gotta know your vibe before moving on 💅",
            shouldBeRed: true,
            animationName: Constants.animations.angryStar
        )
}
