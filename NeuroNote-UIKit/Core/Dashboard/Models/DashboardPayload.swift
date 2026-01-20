//
//  DashboardPayload.swift
//  NeuroNote-UIKit
//
//  Created by Eclipse on 20/01/26.
//

import Foundation

struct DashboardPayload: Decodable {
    let monthlyTopMoods: [MonthlyMood]
    let weeklyMoodStrip: [String: String?]
}

struct MonthlyMood: Decodable {
    let mood: String
    let percentage: Double
}

struct MonthlyTopMoodsPayload: Decodable {
    let monthlyTopMoods: [MonthlyMood]

    init(from decoder: Decoder) throws {
        let singleValue = try decoder.singleValueContainer()
        if let moods = try? singleValue.decode([MonthlyMood].self) {
            self.monthlyTopMoods = moods
            return
        }

        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let moods = try? container.decode([MonthlyMood].self, forKey: .monthlyTopMoods) {
            self.monthlyTopMoods = moods
            return
        }

        self.monthlyTopMoods = try container.decode([MonthlyMood].self, forKey: .data)
    }

    private enum CodingKeys: String, CodingKey {
        case monthlyTopMoods
        case data
    }
}

struct WeeklyMoodStripPayload: Decodable {
    let weeklyMoodStrip: [String: String?]

    init(from decoder: Decoder) throws {
        let singleValue = try decoder.singleValueContainer()
        if let strip = try? singleValue.decode([String: String?].self) {
            self.weeklyMoodStrip = strip
            return
        }

        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let strip = try? container.decode([String: String?].self, forKey: .weeklyMoodStrip) {
            self.weeklyMoodStrip = strip
            return
        }

        self.weeklyMoodStrip = try container.decode([String: String?].self, forKey: .data)
    }

    private enum CodingKeys: String, CodingKey {
        case weeklyMoodStrip
        case data
    }
}
