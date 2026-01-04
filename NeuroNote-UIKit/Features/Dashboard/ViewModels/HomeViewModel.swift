//
//  HomeViewModel.swift
//  NeuroNote-UIKit
//
//  Created by Eclipse on 04/01/26.
//

import Foundation

@MainActor
class HomeViewModel{
    // MARK: - CallBacks
    var onMessage: ((String) -> Void)?
    var onLoggingSuccess: (() -> Void)?
    var onAsyncStart: (() -> Void)?
    var onAsyncEnd: (() -> Void)?
    
    // MARK: - Dependencies
    private let moodManager: MoodManagerProtocol
    
    // MARK: - init
    init(moodManager: MoodManagerProtocol) {
        self.moodManager = moodManager
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
}
