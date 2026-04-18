//
//  MoodReason.swift
//  AVYO
//

import Foundation

enum MoodReason: String, CaseIterable {
    // Happy reasons
    case achievement
    case socialConnection
    case selfCare
    case goodNews
    
    // Surprised reasons
    case unexpectedNews
    case somethingNew
    
    // Sad reasons
    case loneliness
    case disappointment
    case loss
    case exhaustion
    
    // Angry reasons
    case frustration
    case someoneBothered
    case injustice
    case thingsWentWrong
    
    // Anxious reasons
    case workDeadlines
    case uncertainty
    case healthWorries
    case socialPressure
    
    // Calm reasons
    case restRelaxation
    case nature
    case meditation
    case resolution
    
    // Confused reasons
    case decisions
    case overwhelmed
    case mixedSignals
    case lifeDirection
    
    // Universal
    case noReason
    
    var label: String {
        switch self {
        case .achievement: return "I achieved something"
        case .socialConnection: return "Good time with people"
        case .selfCare: return "Self-care / Rest"
        case .goodNews: return "Good news"
        case .unexpectedNews: return "Unexpected news"
        case .somethingNew: return "Something new happened"
        case .loneliness: return "Feeling lonely"
        case .disappointment: return "Disappointment"
        case .loss: return "Loss or grief"
        case .exhaustion: return "Exhaustion"
        case .frustration: return "Frustration"
        case .someoneBothered: return "Someone bothered me"
        case .injustice: return "Injustice"
        case .thingsWentWrong: return "Things went wrong"
        case .workDeadlines: return "Work / Deadlines"
        case .uncertainty: return "Uncertainty"
        case .healthWorries: return "Health worries"
        case .socialPressure: return "Social pressure"
        case .restRelaxation: return "Rest & relaxation"
        case .nature: return "Nature / Outdoors"
        case .meditation: return "Meditation / Mindfulness"
        case .resolution: return "Resolved something"
        case .decisions: return "Tough decisions"
        case .overwhelmed: return "Feeling overwhelmed"
        case .mixedSignals: return "Mixed signals"
        case .lifeDirection: return "Life direction"
        case .noReason: return "Just feeling it"
        }
    }
}

