//
//  Mood.swift
//  NeuroNote-UIKit
//

import UIKit

enum Mood: String, CaseIterable {
    case happy
    case surprised
    case uncomfortable
    case down
    case worried
    case frustrated
    
    var imageName: String {
        switch self {
        case .happy: return "happyFace"
        case .surprised: return "surprisedFace"
        case .uncomfortable: return "disgustedFace"
        case .down: return "sadFace"
        case .worried: return "fearedFace"
        case .frustrated: return "angryFace"
        }
    }
    
    var image: UIImage? {
        return UIImage(named: imageName)
    }
    
    var label: String {
        switch self {
        case .happy: return "Happy"
        case .surprised: return "Surprised"
        case .uncomfortable: return "Uncomfortable"
        case .down: return "Down"
        case .worried: return "Worried"
        case .frustrated: return "Frustrated"
        }
    }
    
    var color: UIColor {
        switch self {
        case .happy:
            return UIColor(red: 0.95, green: 0.80, blue: 0.38, alpha: 1.0)
        case .surprised:
            return UIColor(red: 0.95, green: 0.75, blue: 0.50, alpha: 1.0)
        case .uncomfortable:
            return UIColor(red: 0.70, green: 0.80, blue: 0.55, alpha: 1.0)
        case .down:
            return UIColor(red: 0.55, green: 0.70, blue: 0.90, alpha: 1.0)
        case .worried:
            return UIColor(red: 0.75, green: 0.55, blue: 0.85, alpha: 1.0)
        case .frustrated:
            return UIColor(red: 0.90, green: 0.55, blue: 0.55, alpha: 1.0)
        }
    }
    
    var followUpQuestion: String {
        switch self {
        case .happy: return "What's bringing you joy?"
        case .surprised: return "What caught you off guard?"
        case .uncomfortable: return "What's making you uneasy?"
        case .down: return "What's weighing on you?"
        case .worried: return "What's on your mind?"
        case .frustrated: return "What's been bothering you?"
        }
    }
    
    var reasons: [MoodReason] {
        switch self {
        case .happy:
            return [.achievement, .socialConnection, .selfCare, .goodNews, .noReason]
        case .surprised:
            return [.unexpectedNews, .somethingNew, .socialConnection, .achievement, .noReason]
        case .uncomfortable:
            return [.socialPressure, .uncertainty, .overwhelmed, .someoneBothered, .noReason]
        case .down:
            return [.loneliness, .disappointment, .loss, .exhaustion, .noReason]
        case .worried:
            return [.workDeadlines, .uncertainty, .healthWorries, .socialPressure, .noReason]
        case .frustrated:
            return [.frustration, .someoneBothered, .thingsWentWrong, .injustice, .noReason]
        }
    }
}
