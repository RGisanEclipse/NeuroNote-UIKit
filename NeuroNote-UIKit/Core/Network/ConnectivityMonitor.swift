//
//  ConnectivityMonitor.swift
//  NeuroNote-UIKit
//

import Network
import Foundation

extension Notification.Name {
    static let connectivityChanged = Notification.Name("NeuroNote.connectivityChanged")
    static let syncDidComplete = Notification.Name("NeuroNote.syncDidComplete")
}

final class ConnectivityMonitor {
    static let shared = ConnectivityMonitor()

    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "com.neuronote.connectivity", qos: .utility)

    private(set) var isConnected: Bool = true

    private init() {
        monitor.pathUpdateHandler = { [weak self] path in
            let connected = path.status == .satisfied
            DispatchQueue.main.async {
                self?.isConnected = connected
                NotificationCenter.default.post(
                    name: .connectivityChanged,
                    object: nil,
                    userInfo: ["isConnected": connected]
                )
            }
        }
        monitor.start(queue: queue)
    }

    deinit { monitor.cancel() }
}
