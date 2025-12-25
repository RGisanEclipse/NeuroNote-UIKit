//
//  OnboardingViewModel.swift
//  NeuroNote-UIKit
//
//  Created by Eclipse on 11/12/25.
//

import Foundation

@MainActor
class OnboardingViewModel{
    
    var onMessage: ((AlertContent)->Void)?
    var onOnboardingSuccess: (()->Void)?
    var onAsyncStart: (() -> Void)?
    
    func submitButtonTapped(onboardingData: OnboardingData){
        guard !onboardingData.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            onMessage?(AuthAlert.fieldsMissing)
            return
        }
        
        guard onboardingData.age >= 13 || onboardingData.age <= 100 else{
            onMessage?(AuthAlert.fieldsMissing)
            return
        }
        
        guard onboardingData.gender == 0 || onboardingData.gender == 1 else {
            onMessage?(SignupAlerts.emptyGender)
            return
        }
        
        // Call OnboardingManager to make a call to backend and await response
    }
    
}
