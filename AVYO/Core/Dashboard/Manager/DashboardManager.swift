//
//  DashboardManager.swift
//  AVYO
//
//  Created by Eclipse on 20/01/26.
//

import Foundation

final class DashboardManager: DashboardManagerProtocol {
    
    private let apiClient: APIClientProtocol
    
    init(apiClient: APIClientProtocol = APIClient.shared) {
        self.apiClient = apiClient
    }
    
    func fetchDashboard() async throws -> DashboardPayload {
        let apiResponse: DashboardAPIResponse = try await apiClient.request(
            route: Routes.dashboard,
            requiresAuth: true
        )
        return apiResponse.response
    }
    
    func fetchMonthlyTopMoods() async throws -> [MonthlyMood] {
        let apiResponse: MonthlyTopMoodsAPIResponse = try await apiClient.request(
            route: Routes.monthlyTopMoods,
            requiresAuth: true
        )
        return apiResponse.response.monthlyTopMoods
    }

    func fetchWeeklyMoodStrip() async throws -> [String: String?] {
        let apiResponse: WeeklyMoodStripAPIResponse = try await apiClient.request(
            route: Routes.weeklyMoodStrip,
            requiresAuth: true
        )
        return apiResponse.response.weeklyMoodStrip
    }
}
