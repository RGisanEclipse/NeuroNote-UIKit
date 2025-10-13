import Foundation
import UIKit

class OTPViewModel {
    
    // MARK: - Properties
    var timeRemaining: Int = 60
    var resendTimer: Timer?
    var onTimerUpdate: ((Int) -> Void)?
    var onTimerFinished: (() -> Void)?
    var onOTPVerified: (() -> Void)?
    var onOTPFailed: (() -> Void)?
    var onAsyncStart: (() -> Void)?
    var onAsyncEnd: (() -> Void)?
    var onServerError: (() -> Void)?
    var onNetworkError: ((String) -> Void)?
    
    private let otpManager: OTPManagerProtocol
    private let userIdStore: UserIDStore
    
    // MARK: - Init
    init(
        manager: OTPManagerProtocol = OTPManager(),
        userIdStore: UserIDStore = KeychainHelper.standard) {
            self.otpManager = manager
            self.userIdStore = userIdStore
        }
    
    // MARK: - Public Methods
    func startResendTimer() {
        timeRemaining = 60
        resendTimer?.invalidate()
        
        resendTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
            guard let self = self else { return }
            self.timeRemaining -= 1
            self.onTimerUpdate?(self.timeRemaining)
            
            if self.timeRemaining <= 0 {
                timer.invalidate()
                self.onTimerFinished?()
            }
        }
    }
    
    func invalidateTimer() {
        resendTimer?.invalidate()
    }
    
    // MARK: - OTP Verification
    @MainActor
    func verify(otp: String, userId: String, purpose: OTPPurpose) {
        onAsyncStart?()
        Task {
            defer { onAsyncEnd?() }
            
            do {
                let response = try await otpManager.verifyOTP(otp, userId: userId, purpose: purpose)
                if response.success {
                    onOTPVerified?()
                } else {
                    handleAPIErrorCode(code: response.errorCode)
                }
                
            } catch let apiError as APIError {
                handleAPIErrorCode(code: apiError.code)
            } catch let networkError as NetworkError {
                handleNetworkError(networkError)
            } catch {
                onServerError?()
            }
        }
    }
    
    // MARK: - Resend OTP
    @MainActor
    func resendOTP(requestData: OTPRequestData, purpose: OTPPurpose) {
        onAsyncStart?()
        
        Task {
            defer { onAsyncEnd?() }
            
            do {
                _ = try await otpManager.requestOTP(requestData: requestData, purpose: purpose)
                startResendTimer()
            } catch _ as APIError {
                onServerError?()
            } catch let networkError as NetworkError {
                handleNetworkError(networkError)
            } catch {
                onServerError?()
            }
        }
    }
    
    // MARK: - Private Helpers
    private func handleAPIErrorCode(code: String?) {
        guard let code = code else {
            onServerError?()
            return
        }
        switch code {
        case "OTP_003":
            onOTPFailed?()
        case "OTP_004":
            onOTPFailed?()
        default:
            onServerError?()
        }
    }
    
    private func handleNetworkError(_ error: NetworkError) {
        switch error {
        case .noInternet:
            onNetworkError?(NetworkAlert.noInternet.title + "\n Please check your internet connection")
        case .timeout:
            onNetworkError?(NetworkAlert.timeout.title + "\n Please try again")
        case .cannotReachServer:
            onNetworkError?(NetworkAlert.cannotReachServer.title + "\n Please try again")
        case .generic(let msg):
            onNetworkError?(NetworkAlert.generic(msg).title)
        }
    }
}
