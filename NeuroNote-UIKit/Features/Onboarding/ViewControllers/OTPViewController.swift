//
//  OTPViewController.swift
//  NeuroNote-UIKit
//
//  Created by Eclipse on 17/07/25.
//

import UIKit
import Lottie

class OTPViewController: UIViewController {
    
    private var viewModel = OTPViewModel()
    
    // MARK: - Lottie Animation
    private let otpAnimationView: LottieAnimationView = {
        let animation = LottieAnimation.named(Constants.animations.otpChair)
        let animationView = LottieAnimationView(animation: animation)
        animationView.translatesAutoresizingMaskIntoConstraints = false
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .loop
        return animationView
    }()
    
    private let backgroundImage: UIImageView = {
        let bgImage = UIImageView(image: UIImage(named: Constants.OTPViewControllerConstants.backgroundImageName))
        bgImage.contentMode = .scaleAspectFill
        bgImage.translatesAutoresizingMaskIntoConstraints = false
        return bgImage
    }()
    
    // Scroll View
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        return scrollView
    }()
    
    private let scrollContentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // OTP Fields
    private var otpTextFields: [OTPTextField] = []
    private let otpStackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.spacing = 12
        sv.distribution = .fillEqually
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()
    
    // Timer
    private var resendTimerLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.textAlignment = .center
        label.font = UIFont.monospacedDigitSystemFont(ofSize: 14, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // Go Back Button
    private let goBackButton: GradientButton = {
        let button = GradientButton(
            title: "Back to Login",
            leadingColor: UIColor.systemIndigo.cgColor,
            trailingColor: UIColor.systemIndigo.cgColor
        )
        button.setTitleColor(.white, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 16
        return button
    }()
    
    // Title
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        label.numberOfLines = 0
        label.font = UIFont(name: Fonts.MontserratMedium, size: 32) ?? .systemFont(ofSize: 32, weight: .bold)
        label.textAlignment = .center
        label.text = Constants.OTPViewControllerConstants.titleLabel
        return label
    }()
    
    // Message
    private let messageLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        label.numberOfLines = 0
        label.font = UIFont(name: Fonts.MontserratRegular, size: 18) ?? .monospacedSystemFont(ofSize: 18, weight: .medium)
        label.textAlignment = .center
        label.text = Constants.OTPViewControllerConstants.messageLabel
        return label
    }()
    
    // Resend OTP
    private let resendOTPButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Resend OTP", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.monospacedDigitSystemFont(ofSize: 15, weight: .bold)
        button.alpha = 1.0
        button.isEnabled = true
        button.isHidden = true
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupHierarchy()
        setupConstraints()
        setupOTPFields()
        setupBindings()
        otpAnimationView.play()
        setupButtonTargets()
        viewModel.startResendTimer()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.hidesBackButton = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }
    
    // MARK: - ViewModel Bindings
    private func setupBindings() {
        viewModel.onTimerUpdate = { [weak self] remaining in
            guard let self = self else { return }
            
            if remaining > 0 {
                self.resendTimerLabel.text = "You can re-send OTP in \(remaining)s"
                self.resendTimerLabel.isHidden = false
                self.resendOTPButton.isHidden = true
            } else {
                self.resendTimerLabel.isHidden = true
                self.resendOTPButton.isHidden = false
            }
        }
        
        viewModel.onOTPFailed = { [weak self] in
            guard let self = self else { return }
            print("OTP Failed")
            self.shakeOTPFields()
        }
        
        viewModel.onOTPVerified = { [weak self] in
            guard let self = self else { return }
            self.clearOTPFields(otpCase: OTPCases.correctOTP)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                guard let self = self else { return }
                let successView = AuthSuccessView()
                self.view.addSubview(successView)
                NSLayoutConstraint.activate([
                    successView.topAnchor.constraint(equalTo: self.view.topAnchor),
                    successView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
                    successView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
                    successView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor)
                ])
                successView.onAnimationCompletion = {
                    let signupVC = SignupViewController()
                    signupVC.modalPresentationStyle = .fullScreen
                    signupVC.modalTransitionStyle = .coverVertical
                    self.present(signupVC, animated: true, completion: nil)
                }
            }
        }
        viewModel.onServerError = { [weak self] in
            guard let self = self else { return }
            clearOTPFields(otpCase: OTPCases.incorrectOTP)
            self.showServerErrorBanner()
        }
        viewModel.onNetworkError = { [weak self] message in
            guard let self = self else { return }
            clearOTPFields(otpCase: OTPCases.incorrectOTP)
            self.showNetworkErrorBanner(with: message)
        }
    }
    
    private func setupOTPFields() {
        for i in 0..<4 {
            let textField = OTPTextField()
            textField.backgroundColor = UIColor.white.withAlphaComponent(0.1)
            textField.textColor = .white
            textField.font = UIFont(name: Fonts.MontserratBold, size: 24) ?? UIFont.monospacedDigitSystemFont(ofSize: 24, weight: .bold)
            textField.textAlignment = .center
            textField.keyboardType = .numberPad
            textField.layer.cornerRadius = 10
            textField.tag = i
            textField.delegate = self
            textField.backspaceDelegate = self
            textField.translatesAutoresizingMaskIntoConstraints = false
            textField.heightAnchor.constraint(equalToConstant: 48).isActive = true
            textField.tintColor = .clear
            otpStackView.addArrangedSubview(textField)
            otpTextFields.append(textField)
        }
        otpTextFields.first?.becomeFirstResponder()
    }
    
    private func setupButtonTargets(){
        resendOTPButton.addTarget(self, action: #selector(handleResendOTP), for: .touchUpInside)
        goBackButton.addTarget(self, action: #selector(handleGoBack), for: .touchUpInside)
    }
    
    private func shakeOTPFields() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.error)
        
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: .linear)
        animation.duration = 0.4
        animation.values = [-10, 10, -8, 8, -5, 5, 0]
        otpStackView.layer.add(animation, forKey: "shake")
        clearOTPFields(otpCase: OTPCases.incorrectOTP)
    }
    
    private func clearOTPFields(otpCase: OTPCases) {
        switch otpCase{
        case .correctOTP:
            otpTextFields.forEach {
                $0.resignFirstResponder()
            }
        case .incorrectOTP:
            otpTextFields.forEach {
                $0.text = Constants.empty
                $0.resignFirstResponder()
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { [weak self] in
            guard let self = self else { return }
            self.otpTextFields.forEach {
                $0.layer.borderColor = UIColor.clear.cgColor
            }
            self.view.endEditing(true)
        }
    }
    
    @objc private func handleGoBack() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func handleResendOTP() {
        viewModel.resendOTP()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            backgroundImage.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImage.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            backgroundImage.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImage.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            otpAnimationView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: -20),
            otpAnimationView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            otpAnimationView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            otpAnimationView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.25),
            
            scrollView.topAnchor.constraint(equalTo: otpAnimationView.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: goBackButton.topAnchor, constant: -12),
            
            scrollContentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            scrollContentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            scrollContentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            scrollContentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            titleLabel.topAnchor.constraint(equalTo: scrollContentView.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            
            messageLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            messageLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            messageLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            
            otpStackView.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 30),
            otpStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            otpStackView.widthAnchor.constraint(equalToConstant: 220),
            
            resendTimerLabel.topAnchor.constraint(equalTo: otpStackView.bottomAnchor, constant: 30),
            resendTimerLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            resendOTPButton.topAnchor.constraint(equalTo: otpStackView.bottomAnchor, constant: 30),
            resendOTPButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            scrollContentView.bottomAnchor.constraint(equalTo: resendOTPButton.bottomAnchor, constant: 20),
            
            goBackButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            goBackButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            goBackButton.heightAnchor.constraint(equalToConstant: 60),
            goBackButton.widthAnchor.constraint(equalToConstant: 220)
        ])
    }
    
    private func setupHierarchy() {
        view.addSubview(backgroundImage)
        view.sendSubviewToBack(backgroundImage)
        view.addSubview(otpAnimationView)
        view.addSubview(scrollView)
        scrollView.addSubview(scrollContentView)
        [titleLabel, messageLabel, otpStackView, resendTimerLabel, resendOTPButton].forEach {
            scrollContentView.addSubview($0)
        }
        view.addSubview(goBackButton)
    }
    func showServerErrorBanner() {
        let blurEffect = UIBlurEffect(style: .systemUltraThinMaterialDark)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.clipsToBounds = true
        blurView.layer.cornerRadius = 14
        blurView.layer.borderColor = UIColor.white.withAlphaComponent(0.2).cgColor
        blurView.layer.borderWidth = 0.5

        let label = UILabel()
        label.text = Constants.OTPViewControllerConstants.serverError
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        label.textAlignment = .center
        label.numberOfLines = 0

        blurView.contentView.addSubview(label)
        let bannerHeight: CGFloat = 60
        blurView.frame = CGRect(x: 16, y: -bannerHeight, width: view.frame.width - 32, height: bannerHeight)
        label.frame = CGRect(x: 12, y: 0, width: blurView.frame.width - 24, height: bannerHeight)

        view.addSubview(blurView)
        UIView.animate(withDuration: 0.4,
                       delay: 0,
                       usingSpringWithDamping: 0.7,
                       initialSpringVelocity: 0.8,
                       options: .curveEaseOut) {
            blurView.frame.origin.y = 60
        }
        
        UIView.animate(withDuration: 0.3,
                       delay: 3,
                       options: .curveEaseIn,
                       animations: {
            blurView.frame.origin.y = -bannerHeight
            blurView.alpha = 0
        }) { _ in
            blurView.removeFromSuperview()
        }
    }
    func showNetworkErrorBanner(with message: String){
        let blurEffect = UIBlurEffect(style: .systemUltraThinMaterialDark)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.clipsToBounds = true
        blurView.layer.cornerRadius = 14
        blurView.layer.borderColor = UIColor.white.withAlphaComponent(0.2).cgColor
        blurView.layer.borderWidth = 0.5

        let label = UILabel()
        label.text = message
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        label.textAlignment = .center
        label.numberOfLines = 0

        blurView.contentView.addSubview(label)
        let bannerHeight: CGFloat = 60
        blurView.frame = CGRect(x: 16, y: -bannerHeight, width: view.frame.width - 32, height: bannerHeight)
        label.frame = CGRect(x: 12, y: 0, width: blurView.frame.width - 24, height: bannerHeight)

        view.addSubview(blurView)
        UIView.animate(withDuration: 0.4,
                       delay: 0,
                       usingSpringWithDamping: 0.7,
                       initialSpringVelocity: 0.8,
                       options: .curveEaseOut) {
            blurView.frame.origin.y = 60
        }
        
        UIView.animate(withDuration: 0.3,
                       delay: 3,
                       options: .curveEaseIn,
                       animations: {
            blurView.frame.origin.y = -bannerHeight
            blurView.alpha = 0
        }) { _ in
            blurView.removeFromSuperview()
        }
    }
}

extension OTPViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let index = otpTextFields.firstIndex(of: textField as! OTPTextField) else {
            return false
        }
        
        if string.isEmpty {
            textField.text = Constants.empty
            if index > 0 {
                let previousField = otpTextFields[index - 1]
                enableField(previousField)
                disableField(textField)
            }
        } else if let _ = Int(string) {
            textField.text = string
            if index < otpTextFields.count - 1 {
                let nextField = otpTextFields[index + 1]
                enableField(nextField)
                disableField(textField)
            } else {
                textField.resignFirstResponder()
            }
            let otp = otpTextFields.compactMap { $0.text }.joined()
            if otp.count == otpTextFields.count {
                viewModel.verify(otp: otp)
                for (i, field) in otpTextFields.enumerated() {
                    if i == 0 {
                        enableField(field)
                        field.layer.borderWidth = 0
                    } else {
                        disableField(field)
                    }
                }
            }
        }
        return false
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.layer.borderColor = UIColor.white.cgColor
        textField.layer.borderWidth = 2
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.layer.borderWidth = 0
    }
    
    func enableField(_ field: UITextField) {
        field.isUserInteractionEnabled = true
        field.becomeFirstResponder()
    }
    
    func disableField(_ field: UITextField) {
        field.isUserInteractionEnabled = false
        field.resignFirstResponder()
    }
}

protocol OTPTextFieldDelegate: AnyObject {
    func didPressBackspace(on textField: OTPTextField)
}

class OTPTextField: UITextField {
    
    weak var backspaceDelegate: OTPTextFieldDelegate?
    
    override func deleteBackward() {
        if text?.isEmpty ?? true {
            backspaceDelegate?.didPressBackspace(on: self)
        }
        super.deleteBackward()
    }
}

extension OTPViewController: OTPTextFieldDelegate {
    func didPressBackspace(on textField: OTPTextField) {
        guard let index = otpTextFields.firstIndex(of: textField), index > 0 else { return }
        
        let previousField = otpTextFields[index - 1]
        previousField.text = Constants.empty
        previousField.becomeFirstResponder()
        enableField(previousField)
        disableField(textField)
    }
}

enum OTPCases{
    case incorrectOTP
    case correctOTP
}

#Preview{
    OTPViewController()
}
