//
//  HomeViewModel.swift
//  AVYO
//
//  Created by Eclipse on 04/01/26.
//

import UIKit

// MARK: - Dominant Mood State

enum DominantMoodState {
    case loaded(label: String, color: UIColor)
    case unavailableNoData
    case unavailableNetworkError
}

@MainActor
class HomeViewModel {
    // MARK: - Callbacks
    var onMessage: ((String) -> Void)?
    var onLoggingSuccess: (() -> Void)?
    var onAsyncStart: (() -> Void)?
    var onAsyncEnd: (() -> Void)?
    var onInsightsState: ((InsightsChartViewState) -> Void)?
    var onWeeklyMoodState: ((WeeklyMoodStripState) -> Void)?
    var onDominantMoodState: ((DominantMoodState) -> Void)?
    var onStreakUpdate: ((Int) -> Void)?
    var onStreakVisibilityChange: ((Bool) -> Void)?

    // MARK: - Dependencies
    private let moodManager: MoodManagerProtocol
    private let dashboardManager: DashboardManagerProtocol
    private let dashboardCache: DashboardCacheService
    private let pendingMoodLogService: PendingMoodLogService

    // MARK: - Init
    init(
        moodManager: MoodManagerProtocol,
        dashboardManager: DashboardManagerProtocol,
        dashboardCache: DashboardCacheService = DashboardCacheService(),
        pendingMoodLogService: PendingMoodLogService = PendingMoodLogService()
    ) {
        self.moodManager = moodManager
        self.dashboardManager = dashboardManager
        self.dashboardCache = dashboardCache
        self.pendingMoodLogService = pendingMoodLogService

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleSyncDidComplete),
            name: .syncDidComplete,
            object: nil
        )
    }

    @objc private func handleSyncDidComplete() {
        fetchDashboardData()
    }

    // MARK: - Actions

    func handleMoodLog(with requestData: MoodLogData) {
        guard ConnectivityMonitor.shared.isConnected else {
            pendingMoodLogService.enqueue(requestData)
            onLoggingSuccess?()
            return
        }

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

            // 1. Show cache instantly if available, skeletons only if nothing cached
            if let cached = dashboardCache.load() {
                applyPayload(cached)
                onStreakVisibilityChange?(false)
            } else {
                onInsightsState?(.loading)
                onWeeklyMoodState?(.loading)
            }

            // 2. Bail early if offline — cache was already shown above
            guard ConnectivityMonitor.shared.isConnected else {
                if dashboardCache.load() == nil {
                    onWeeklyMoodState?(.error)
                    onInsightsState?(.error("No cached data available"))
                    onDominantMoodState?(.unavailableNetworkError)
                }
                return
            }

            // 3. Fetch fresh data in background, update UI when it arrives
            do {
                let payload = try await dashboardManager.fetchDashboard()
                dashboardCache.save(payload)
                applyPayload(payload)
                onStreakVisibilityChange?(true)
            } catch {
                // Fresh fetch failed — if cache was already shown, stay silent
                // Only show error if there was nothing to show at all
                if dashboardCache.load() == nil {
                    let errorMessage = message(for: error)
                    onWeeklyMoodState?(.error)
                    onInsightsState?(.error(errorMessage))
                    onDominantMoodState?(.unavailableNetworkError)
                }
                onStreakVisibilityChange?(false)
            }
        }
    }

    func refreshMonthlyMoodInsights() {
        Task { [weak self] in
            guard let self = self else { return }

            guard ConnectivityMonitor.shared.isConnected else {
                onInsightsState?(.error("No internet connection"))
                onDominantMoodState?(.unavailableNetworkError)
                return
            }

            onInsightsState?(.loading)

            do {
                let monthlyMoods = try await dashboardManager.fetchMonthlyTopMoods()
                let insightsData = makeInsightsViewData(from: monthlyMoods)
                if insightsData.isEmpty {
                    onInsightsState?(.empty)
                    onDominantMoodState?(.unavailableNoData)
                } else {
                    onInsightsState?(.loaded(insightsData))
                    let sorted = insightsData.sorted { $0.percentage > $1.percentage }
                    if let dominant = sorted.first {
                        onDominantMoodState?(.loaded(label: dominant.label, color: dominant.color))
                    } else {
                        onDominantMoodState?(.unavailableNoData)
                    }
                }
            } catch {
                let errorMessage = message(for: error)
                onMessage?(errorMessage)
                onInsightsState?(.error(errorMessage))
                onDominantMoodState?(.unavailableNetworkError)
            }
        }
    }

    func refreshWeeklyMoodStrip() {
        Task { [weak self] in
            guard let self = self else { return }

            guard ConnectivityMonitor.shared.isConnected else {
                onWeeklyMoodState?(.error)
                return
            }

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

    // MARK: - Private Helpers

    private func applyPayload(_ payload: DashboardPayload) {
        let insightsData = makeInsightsViewData(from: payload.monthlyTopMoods)
        let weeklyData = makeWeeklyMoodData(from: payload.weeklyMoodStrip)

        if insightsData.isEmpty {
            onInsightsState?(.empty)
            onDominantMoodState?(.unavailableNoData)
        } else {
            onInsightsState?(.loaded(insightsData))
            let sorted = insightsData.sorted { $0.percentage > $1.percentage }
            if let dominant = sorted.first {
                onDominantMoodState?(.loaded(label: dominant.label, color: dominant.color))
            } else {
                onDominantMoodState?(.unavailableNoData)
            }
        }
        onWeeklyMoodState?(.loaded(weeklyData))
        onStreakUpdate?(payload.streakWidget.currentStreak)
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
