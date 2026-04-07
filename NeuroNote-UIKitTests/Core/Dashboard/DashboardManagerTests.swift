//
//  DashboardManagerTests.swift
//  NeuroNote-UIKitTests
//
//  Created by Eclipse on 20/01/26.
//

import XCTest
@testable import NeuroNote_UIKit

final class DashboardManagerTests: XCTestCase {

    private var mockAPIClient: MockAPIClient!
    private var dashboardManager: DashboardManager!

    override func setUp() {
        super.setUp()
        mockAPIClient = MockAPIClient()
        dashboardManager = DashboardManager(apiClient: mockAPIClient)
    }

    override func tearDown() {
        super.tearDown()
        mockAPIClient.reset()
        mockAPIClient = nil
        dashboardManager = nil
    }

    private func decode<T: Decodable>(_ json: String) throws -> T {
        let data = Data(json.utf8)
        return try JSONDecoder().decode(T.self, from: data)
    }

    func testFetchDashboardUsesDashboardRoute() async throws {
        let payload: DashboardPayload = try decode("""
        {
          "monthlyTopMoods": [{"mood":"happy","percentage":50}],
          "weeklyMoodStrip": {"2026-01-18":"happy"},
          "streakWidget": {"currentStreak":3,"longestStreak":5,"lastActiveDate":1775520000}
        }
        """)
        mockAPIClient.mockResponseData = DashboardAPIResponse(
            success: true,
            status: 200,
            response: payload
        )

        _ = try await dashboardManager.fetchDashboard()

        XCTAssertEqual(mockAPIClient.lastEndpoint, Routes.dashboard.path)
        XCTAssertEqual(mockAPIClient.lastMethod, Routes.dashboard.method)
    }

    func testFetchDashboardDecodesStreakWidget() async throws {
        let payload: DashboardPayload = try decode("""
        {
          "monthlyTopMoods": [{"mood":"happy","percentage":66.67}],
          "weeklyMoodStrip": {"2026-04-07":"happy"},
          "streakWidget": {"currentStreak":1,"longestStreak":1,"lastActiveDate":1775520000}
        }
        """)
        mockAPIClient.mockResponseData = DashboardAPIResponse(
            success: true,
            status: 200,
            response: payload
        )

        let result = try await dashboardManager.fetchDashboard()

        XCTAssertEqual(result.streakWidget.currentStreak, 1)
        XCTAssertEqual(result.streakWidget.longestStreak, 1)
        XCTAssertEqual(result.streakWidget.lastActiveDate, 1775520000)
    }

    func testFetchMonthlyTopMoodsUsesRoute() async throws {
        let payload: MonthlyTopMoodsPayload = try decode("""
        {
          "data": [{"mood":"happy","percentage":53.125}]
        }
        """)
        mockAPIClient.mockResponseData = MonthlyTopMoodsAPIResponse(
            success: true,
            status: 200,
            response: payload
        )

        _ = try await dashboardManager.fetchMonthlyTopMoods()

        XCTAssertEqual(mockAPIClient.lastEndpoint, Routes.monthlyTopMoods.path)
        XCTAssertEqual(mockAPIClient.lastMethod, Routes.monthlyTopMoods.method)
    }

    func testFetchWeeklyMoodStripUsesRoute() async throws {
        let payload: WeeklyMoodStripPayload = try decode("""
        {
          "data": {
            "2026-01-18": "happy",
            "2026-01-19": null
          }
        }
        """)
        mockAPIClient.mockResponseData = WeeklyMoodStripAPIResponse(
            success: true,
            status: 200,
            response: payload
        )

        _ = try await dashboardManager.fetchWeeklyMoodStrip()

        XCTAssertEqual(mockAPIClient.lastEndpoint, Routes.weeklyMoodStrip.path)
        XCTAssertEqual(mockAPIClient.lastMethod, Routes.weeklyMoodStrip.method)
    }
}
