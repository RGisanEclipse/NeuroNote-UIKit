//
//  DashboardManagerProtocol.swift
//  NeuroNote-UIKit
//
//  Created by Eclipse on 20/01/26.
//

protocol DashboardManagerProtocol {
    func fetchDashboard() async throws -> DashboardPayload
    func fetchMonthlyTopMoods() async throws -> [MonthlyMood]
    func fetchWeeklyMoodStrip() async throws -> [String: String?]
}
