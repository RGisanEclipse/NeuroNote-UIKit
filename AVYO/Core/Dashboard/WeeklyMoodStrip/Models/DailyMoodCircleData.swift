//
//  DailyMoodCircle.swift
//  AVYO
//
//  Created by Eclipse on 31/12/25.
//

import UIKit

struct DailyMoodCircleData {
    let date: String
    let moodColor: UIColor?
    let circleSize: CGFloat
    let isToday: Bool
    let isFuture: Bool
    
    init(
        date: String,
        moodColor: UIColor? = nil,
        circleSize: CGFloat = 32,
        isToday: Bool = false,
        isFuture: Bool = false
    ) {
        self.date = date
        self.moodColor = moodColor
        self.circleSize = circleSize
        self.isToday = isToday
        self.isFuture = isFuture
    }
}
