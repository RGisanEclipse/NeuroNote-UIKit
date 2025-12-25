//
//  OnboardingManagerProtocol.swift
//  NeuroNote-UIKit
//
//  Created by Eclipse on 17/12/25.
//

protocol OnboardingManagerProtocol {
    func onboardUser(
        onboardingData: OnboardingData
    ) async throws
    
}
