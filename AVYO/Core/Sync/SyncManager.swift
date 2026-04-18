//
//  SyncManager.swift
//  AVYO
//

import Foundation

final class SyncManager {
    static let shared = SyncManager()

    private let apiClient: APIClientProtocol
    private let pendingMoodLogService: PendingMoodLogService
    private var isSyncing = false
    private var wasConnected: Bool? = nil

    private init(
        apiClient: APIClientProtocol = APIClient.shared,
        pendingMoodLogService: PendingMoodLogService = PendingMoodLogService()
    ) {
        self.apiClient = apiClient
        self.pendingMoodLogService = pendingMoodLogService

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleConnectivityChange(_:)),
            name: .connectivityChanged,
            object: nil
        )
    }

    @objc private func handleConnectivityChange(_ notification: Notification) {
        guard let isConnected = notification.userInfo?["isConnected"] as? Bool else { return }
        let cameBackOnline = wasConnected == false && isConnected
        wasConnected = isConnected
        guard cameBackOnline else { return }
        syncPendingMoodLogs()
    }

    func syncPendingMoodLogs() {
        guard !isSyncing else { return }
        isSyncing = true
        Task {
            defer { isSyncing = false }
            let pending = pendingMoodLogService.fetchAll()
            guard !pending.isEmpty else { return }

            let operations = pending.map { entry in
                SyncOperation(
                    type: "mood",
                    payload: SyncMoodPayload(
                        mood: entry.mood,
                        reason: entry.reason,
                        timestamp: Int64(entry.loggedAt.timeIntervalSince1970)
                    )
                )
            }

            do {
                let apiResponse: SyncAPIResponse = try await apiClient.request(
                    route: Routes.syncDashboard,
                    body: SyncRequest(operations: operations),
                    requiresAuth: true
                )

                await MainActor.run {
                    for result in apiResponse.response.results {
                        guard result.index < pending.count else { continue }
                        if !result.success {
                            Logger.shared.error("SyncManager: server rejected operation", fields: [
                                "index": result.index,
                                "mood": pending[result.index].mood,
                                "error": result.error ?? "unknown"
                            ])
                        }
                        pendingMoodLogService.delete(objectID: pending[result.index].objectID)
                    }
                    NotificationCenter.default.post(name: .syncDidComplete, object: nil)
                }

            } catch {
                Logger.shared.error("SyncManager: batch sync failed, will retry on reconnect", fields: [
                    "error": error.localizedDescription,
                    "pendingCount": pending.count
                ])
            }
        }
    }
}
