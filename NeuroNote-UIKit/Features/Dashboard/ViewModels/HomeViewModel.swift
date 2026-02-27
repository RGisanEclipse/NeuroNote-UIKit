//
//  HomeViewModel.swift
//  NeuroNote-UIKit
//
//  Created by Eclipse on 04/01/26.
//

import UIKit

@MainActor
class HomeViewModel{
    // MARK: - CallBacks
    var onMessage: ((String) -> Void)?
    var onLoggingSuccess: (() -> Void)?
    var onAsyncStart: (() -> Void)?
    var onAsyncEnd: (() -> Void)?
    var onInsightsState: ((InsightsChartViewState) -> Void)?
    var onWeeklyMoodState: ((WeeklyMoodStripState) -> Void)?
    
    // MARK: - Dependencies
    private let moodManager: MoodManagerProtocol
    private let dashboardManager: DashboardManagerProtocol
    
    // MARK: - init
    init(
        moodManager: MoodManagerProtocol,
        dashboardManager: DashboardManagerProtocol
    ) {
        self.moodManager = moodManager
        self.dashboardManager = dashboardManager
    }
    
    // MARK: - Actions
    
    func handleMoodLog(with requestData: MoodLogData){
        Task { [weak self] in
            guard let self = self else { return }
            
            onAsyncStart?()
            defer { onAsyncEnd?() }
            
            do {
                try await moodManager.logMood(with: requestData)
                onLoggingSuccess?()
                
            } catch let apiError as APIError {
                Logger.shared.error("APIError in HomeViewModel", fields: [
                    "code": apiError.code,
                    "message": apiError.message
                ])
                let alertContent = apiError.presentation
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    self.onMessage?(alertContent.message)
                }
                
            } catch let networkError as NetworkError {
                Logger.shared.error("NetworkError in HomeViewModel", fields: [
                    "error": String(describing: networkError)
                ])
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    self.onMessage?(networkError.presentation.message)
                }
                
            } catch let clientError as APIClientError {
                Logger.shared.error("APIClientError in HomeViewModel", fields: [
                    "error": String(describing: clientError)
                ])
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    self.onMessage?(clientError.presentation.message)
                }
                
            } catch {
                Logger.shared.error("Unknown error in HomeViewModel", fields: [
                    "errorType": String(describing: type(of: error)),
                    "description": error.localizedDescription
                ])
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    self.onMessage?(AuthAlert.unknown.message)
                }
            }
        }
    }
    
    func fetchDashboardData() {
        Task { [weak self] in
            guard let self = self else { return }
            
            onInsightsState?(.loading)
            onWeeklyMoodState?(.loading)
            
            do {
                let payload = try await dashboardManager.fetchDashboard()
                let insightsData = makeInsightsViewData(from: payload.monthlyTopMoods)
                let weeklyData = makeWeeklyMoodData(from: payload.weeklyMoodStrip)

                if insightsData.isEmpty {
                    onInsightsState?(.empty)
                } else {
                    onInsightsState?(.loaded(insightsData))
                }
                onWeeklyMoodState?(.loaded(weeklyData))
            } catch {
                let errorMessage = message(for: error)
                onWeeklyMoodState?(.error)
                onInsightsState?(.error(errorMessage))
            }
        }
    }

    func refreshMonthlyMoodInsights() {
        Task { [weak self] in
            guard let self = self else { return }

            onInsightsState?(.loading)

            do {
                let monthlyMoods = try await dashboardManager.fetchMonthlyTopMoods()
                let insightsData = makeInsightsViewData(from: monthlyMoods)
                if insightsData.isEmpty {
                    onInsightsState?(.empty)
                } else {
                    onInsightsState?(.loaded(insightsData))
                }
            } catch {
                let errorMessage = message(for: error)
                onMessage?(errorMessage)
                onInsightsState?(.error(errorMessage))
            }
        }
    }

    func refreshWeeklyMoodStrip() {
        Task { [weak self] in
            guard let self = self else { return }

            onWeeklyMoodState?(.loading)

            do {
                let weeklyStrip = try await dashboardManager.fetchWeeklyMoodStrip()
                let weeklyData = makeWeeklyMoodData(from: weeklyStrip)
                onWeeklyMoodState?(.loaded(weeklyData))
            } catch {
                onWeeklyMoodState?(.error)
            }
        }
    }
    
    // MARK: - Mapping Helpers
    
    private func makeInsightsViewData(from moods: [MonthlyMood]) -> [MoodInsightsChartViewData] {
        moods.map { moodData in
            let normalized = normalizePercentage(moodData.percentage)
            let mood = Mood(rawValue: moodData.mood.lowercased())
            return MoodInsightsChartViewData(
                label: mood?.label ?? moodData.mood.capitalized,
                icon: mood?.image,
                color: mood?.color ?? UIColor.systemGray,
                percentage: normalized
            )
        }
    }
    
    private func makeWeeklyMoodData(from strip: [String: String?]) -> [DailyMoodCircleData] {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone.current
        
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        let sortedDays = strip.compactMap { dateString, moodString -> (Date, String?)? in
            guard let date = formatter.date(from: dateString) else { return nil }
            return (date, moodString)
        }
        .sorted { $0.0 < $1.0 }
        
        return sortedDays.map { date, moodString in
            let day = calendar.component(.day, from: date)
            let isToday = calendar.isDate(date, inSameDayAs: today)
            let isFuture = date > today
            let mood = moodString.flatMap { Mood(rawValue: $0.lowercased()) }
            
            return DailyMoodCircleData(
                date: "\(day)",
                moodColor: mood?.color,
                circleSize: 20,
                isToday: isToday,
                isFuture: isFuture
            )
        }
    }
    
    private func normalizePercentage(_ value: Double) -> CGFloat {
        let normalized = value > 1 ? value / 100 : value
        return CGFloat(normalized)
    }
    
    private func message(for error: Error) -> String {
        if let apiError = error as? APIError {
            return apiError.presentation.message
        }
        if let networkError = error as? NetworkError {
            return networkError.presentation.message
        }
        if let clientError = error as? APIClientError {
            return clientError.presentation.message
        }
        return AuthAlert.unknown.message
    }
}
