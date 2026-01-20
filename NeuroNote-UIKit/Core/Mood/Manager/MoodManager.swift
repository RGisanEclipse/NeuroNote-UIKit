//
//  MoodManager.swift
//  NeuroNote-UIKit
//
//  Created by Eclipse on 04/01/26.
//

import Foundation

final class MoodManager: MoodManagerProtocol {
    
    private let apiClient: APIClientProtocol
    
    init(apiClient: APIClientProtocol = APIClient.shared) {
        self.apiClient = apiClient
    }
    
    func logMood(with data: MoodLogData) async throws {
        try await apiClient.requestSuccess(
            route: Routes.logMood,
            body: data
        )
    }
}
