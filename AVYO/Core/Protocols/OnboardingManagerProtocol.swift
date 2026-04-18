//
//  OnboardingManagerProtocol.swift
//  AVYO
//
//  Created by Eclipse on 17/12/25.
//

protocol OnboardingManagerProtocol {
    func onboardUser(
        onboardingData: OnboardingData
    ) async throws
    
}
