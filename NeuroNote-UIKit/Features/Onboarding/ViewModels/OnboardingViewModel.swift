//
//  OnboardingViewModel.swift
//  NeuroNote-UIKit
//
//  Created by Eclipse on 11/12/25.
//

import Foundation

@MainActor
class OnboardingViewModel {
    
    // MARK: - Callbacks
    var onMessage: ((AlertContent) -> Void)?
    var onOnboardingSuccess: (() -> Void)?
    var onAsyncStart: (() -> Void)?
    var onAsyncEnd: (() -> Void)?
    
    // MARK: - Dependencies
    private let onboardingManager: OnboardingManagerProtocol
    
    // MARK: - Init
    init(onboardingManager: OnboardingManagerProtocol = OnboardingManager()) {
        self.onboardingManager = onboardingManager
    }
    
    // MARK: - Actions
    func submitButtonTapped(onboardingData: OnboardingData) {
        guard !onboardingData.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            onMessage?(OnboardingAlert.nameTooShort)
            return
        }
        
        guard onboardingData.age >= 13 && onboardingData.age <= 100 else {
            onMessage?(OnboardingAlert.ageOutOfRange)
            return
        }
        
        guard onboardingData.gender == 0 || onboardingData.gender == 1 else {
            onMessage?(SignupAlerts.emptyGender)
            return
        }
        
        Task { [weak self] in
            guard let self = self else { return }
            
            onAsyncStart?()
            defer { onAsyncEnd?() }
            
            do {
                try await onboardingManager.onboardUser(onboardingData: onboardingData)
                onOnboardingSuccess?()
                
            } catch let apiError as APIError {
                let alertContent = apiError.serverCode.presentation
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    self.onMessage?(alertContent)
                }
                
            } catch let networkError as NetworkError {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    self.onMessage?(networkError.presentation)
                }
                
            } catch {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    self.onMessage?(AuthAlert.unknown)
                }
            }
        }
    }
}
