//
//  EmailAlerts.swift
//  NeuroNote
//
//  Created by Eclipse on 09/07/25.
//

import Foundation

enum EmailAlerts{
    static let invalidEmailFormat = AlertContent(
        title: "Email be like 🤡",
        message: "Bruh, that’s not even an email 😭. We can’t slide into your inbox if your email’s broken.",
        shouldBeRed: true,
        imageName: Constants.moodImages.angry
    )
    static let commonEmailError = AlertContent(
        title: "Fake Vibes 🚩",
        message: "That email looks faker than influencer drama. Try a real one.",
        shouldBeRed: true,
        imageName: Constants.moodImages.angry
    )
}
