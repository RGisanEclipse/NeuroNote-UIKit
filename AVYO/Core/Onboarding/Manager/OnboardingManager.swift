//
//  OnboardingManager.swift
//  AVYO
//
//  Created by Eclipse on 11/12/25.
//

import Foundation

final class OnboardingManager: OnboardingManagerProtocol {
    
    private let apiClient: APIClientProtocol
    
    init(apiClient: APIClientProtocol = APIClient.shared) {
        self.apiClient = apiClient
    }
    
    func onboardUser(onboardingData: OnboardingData) async throws {
        try await apiClient.requestSuccess(
            route: Routes.onboardUser,
            body: onboardingData
        )
    }
}
