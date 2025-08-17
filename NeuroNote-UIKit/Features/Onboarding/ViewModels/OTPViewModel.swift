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
    func verify(otp: String, purpose: OTPPurpose) {
        onAsyncStart?()
        Task {
            defer { onAsyncEnd?() }
            
            do {
                let verified = try await otpManager.verifyOTP(otp, purpose: purpose)
                if verified.success{
                    onOTPVerified?()
                } else{
                    onOTPFailed?()
                }
                
            } catch let error as OTPError {
                switch error {
                case .serverError(let message):
                    if message == .otpVerificationFailed {
                        onOTPFailed?()
                    } else if message == .tooManyRequests{
                        onNetworkError?(NetworkAlert.tooManyRequests.title + "\n Please try again later")
                    } else {
                        onServerError?()
                    }
                default:
                    onServerError?()
                }
            } catch let error as NetworkError{
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
            } catch {
                onServerError?()
            }
        }
    }
    
    // MARK: - Resend OTP
    @MainActor
    func resendOTP(purpose: OTPPurpose) {
        onAsyncStart?()
        
        Task {
            defer { onAsyncEnd?() }
            
            do {
                _ = try await otpManager.requestOTP(purpose: purpose)
                startResendTimer()
            } catch let error as OTPError {
                switch error {
                case .serverError:
                    onServerError?()
                default:
                    onServerError?()
                }
            } catch let error as NetworkError {
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
            } catch {
                onServerError?()
            }
        }
    }
}
