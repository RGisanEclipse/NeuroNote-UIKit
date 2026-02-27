//
//  MoodInsightsChartViewData.swift
//  NeuroNote-UIKit
//
//  Created by Eclipse on 31/12/25.
//

import UIKit

enum InsightsChartViewState {
    case loading
    case loaded([MoodInsightsChartViewData])
    case empty
    case error(String)
}

struct MoodInsightsChartViewData {
    let label: String
    let icon: UIImage?
    let color: UIColor
    let percentage: CGFloat
    
    init(label: String, icon: UIImage?, color: UIColor, percentage: CGFloat) {
        self.label = label
        self.icon = icon
        self.color = color
        self.percentage = min(max(percentage, 0), 1)
    }
}
