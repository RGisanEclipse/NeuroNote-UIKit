//
//  LoginViewController.swift
//  NeuroNote
//
//  Created by Eclipse on 28/06/25.
//

import UIKit
import Lottie

// MARK: - Authentication Mode
enum AuthMode {
    case login
    case signup
}

class LoginViewController: UIViewController {
    
    // MARK: - View-Model & Overlay
    private let viewModel = LoginViewModel()
    private var loadingOverlay: LoadingOverlayView?
    
    // MARK: - Lottie
    private lazy var backgroundAnimationView: LottieAnimationView = {
        let animation = LottieAnimation.named(getCurrentBackgroundAnimationName())
        let view = LottieAnimationView(animation: animation)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.contentMode = .scaleAspectFill
        view.loopMode = .loop
        view.backgroundBehavior = .pauseAndRestore
        return view
    }()
    private let celestialAnimationView: LottieAnimationView = {
        let animation = LottieAnimation.named(Constants.animations.happySun)
        let animationView = LottieAnimationView(animation: animation)
        animationView.translatesAutoresizingMaskIntoConstraints = false
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .playOnce
        return animationView
    }()
    
    // MARK: - Greeting
    private let helloLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        label.numberOfLines = 0
        label.font = UIFont(
            name: Fonts.BeachDay,
            size: 32
        ) ?? .systemFont(ofSize: 32, weight: .bold)
        label.textAlignment = .center
        return label
    }()
    
    // MARK: - Glass Card (container)
    private let glassCard: UIVisualEffectView = {
        let blur = UIBlurEffect(style: .systemUltraThinMaterialLight)
        let v = UIVisualEffectView(effect: blur)
        v.translatesAutoresizingMaskIntoConstraints = false
        v.layer.cornerRadius = 60
        v.clipsToBounds = true
        v.layer.borderWidth  = 1
        v.layer.borderColor  = UIColor.white.withAlphaComponent(0.10).cgColor
        return v
    }()
    
    // MARK: - Scroll View for content inside glass card
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        return scrollView
    }()
    
    // MARK: - Content View inside Scroll View
    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // MARK: - Text Fields (unchanged component)
    private let emailView  = LabeledTextField(
        placeholder: "Email",
        trailingImage: nil
    )
    private let passwordView = LabeledTextField(
        placeholder: "Password",
        trailingImage: UIImage(systemName: "eye")
    )
    private let confirmPasswordView = LabeledTextField(
        placeholder: "Re-enter password",
        trailingImage: UIImage(systemName: "eye")
    )
    
    // MARK: - Forgot Password
    private let forgotPasswordButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(
            "Forgot Password?",
            for: .normal
        )
        button.setTitleColor(
            .label,
            for: .normal
        )
        button.titleLabel?.font = UIFont(
            name: Fonts.MontserratRegular,
            size: 15
        ) ?? .systemFont(ofSize: 15)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Gradient Sign Button
    private let signInButton = GradientButton(
        title: "SIGN IN",
        leadingColor: UIColor.systemYellow.cgColor,
        trailingColor: UIColor.systemOrange.cgColor
    )
    
    // MARK: - Toggle Mode
    private let toggleModeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(Constants.LoginViewControllerConstants.toggleButtonToSignUpText, for: .normal)
        button.setTitleColor(
            .label,
            for: .normal
        )
        button.titleLabel?.font = UIFont(
            name: Fonts.MontserratRegular,
            size: 15
        ) ?? .systemFont(ofSize: 15)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - State & Constraints
    private var mode: AuthMode = .login { didSet { updateUIForMode(animated: false) } }
    private var confirmConstraints: [NSLayoutConstraint] = []
    private var forgotPasswordTopConstraint: NSLayoutConstraint?
    private var signButtonTopToForgot: NSLayoutConstraint?
    private var signButtonTopToConfirm: NSLayoutConstraint?
    private var cardHeightConstraint: NSLayoutConstraint!
    
    // MARK: - Helpers
    private func getCurrentBackgroundAnimationName() -> String {
        return traitCollection.userInterfaceStyle == .dark
        ? Constants.animations.nightSky
        : Constants.animations.clouds
    }
    
    private func getCurrentCelestialAnimationName() -> String {
        return traitCollection.userInterfaceStyle == .dark
        ? Constants.animations.rotatingMoon
        : Constants.animations.happySun
    }
    
    private func updateCelestialAnimation() {
        guard let newAnimation = LottieAnimation.named(getCurrentCelestialAnimationName()) else { return }
        
        celestialAnimationView.animation = newAnimation
        celestialAnimationView.play()
    }
    
    private func resetForm() {
        emailView.reset()
        passwordView.reset()
        confirmPasswordView.reset()

        if mode != .login {
            mode = .login
        }
        
        scrollView.setContentOffset(.zero, animated: false)
    }
    
    private func updateSignInButtonTitle() {
        let title = mode == .login ? "SIGN IN" : "SIGN UP"
        signInButton.setTitle(title, for: .normal)
    }
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        buildHierarchy()
        setupConstraints()
        setupButtonTargets()
        setupViewModelBindings()
        updateUIForMode(animated: false)
        registerTraitChanges()
        updateCelestialAnimation()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        backgroundAnimationView.play()
        celestialAnimationView.play()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        resetForm()
    }
    
    // MARK: - Build UI
    private func buildHierarchy() {
        view.addSubview(backgroundAnimationView)
        view.addSubview(celestialAnimationView)
        view.addSubview(glassCard)
        
        // Add scroll view to glassCard's content view
        glassCard.contentView.addSubview(scrollView)
        scrollView.addSubview(contentView) // Add content view to scroll view
        
        // Add all interactive elements to the content view
        [helloLabel, passwordView, emailView, passwordView, forgotPasswordButton, signInButton, toggleModeButton]
            .forEach { contentView.addSubview($0) }
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Background
            backgroundAnimationView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundAnimationView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundAnimationView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundAnimationView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // Glass Card
            glassCard.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: 16
            ),
            glassCard.trailingAnchor.constraint(
                equalTo: view.trailingAnchor,
                constant: -16
            ),
            glassCard.centerYAnchor.constraint(
                equalTo: view.centerYAnchor,
                constant: 50
            ),
            
            // Scroll View constraints (to fill glassCard's content view)
            scrollView.topAnchor.constraint(equalTo: glassCard.contentView.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: glassCard.contentView.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: glassCard.contentView.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: glassCard.contentView.bottomAnchor),
            
            // Content View constraints (to fill scrollView and define scrollable area)
            contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor), // Essential for vertical scrolling
        ])
        
        cardHeightConstraint = glassCard.heightAnchor.constraint(equalToConstant: 370)
        cardHeightConstraint.isActive = true
        
        // Fields & buttons inside content view
        emailView.translatesAutoresizingMaskIntoConstraints = false
        passwordView.translatesAutoresizingMaskIntoConstraints = false
        signInButton.translatesAutoresizingMaskIntoConstraints = false
        forgotPasswordButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            // Sun AnimationView
            celestialAnimationView.widthAnchor.constraint(equalToConstant: 150),
            celestialAnimationView.heightAnchor.constraint(
                equalTo: glassCard.widthAnchor
            ),
            celestialAnimationView.leadingAnchor.constraint(
                equalTo: glassCard.leadingAnchor,
                constant: view.frame.width/3 - 30
            ),
            celestialAnimationView.bottomAnchor.constraint(
                equalTo: glassCard.topAnchor,
                constant: 100
            ),
            
            helloLabel.topAnchor.constraint(
                equalTo: contentView.topAnchor,
                constant: 15
            ),
            helloLabel.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor,
                constant: 0
            ),
            helloLabel.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor,
                constant: 0
            ),
            
            emailView.topAnchor.constraint(
                equalTo: helloLabel.bottomAnchor,
                constant: 10
            ),
            emailView.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor,
                constant: 24
            ),
            emailView.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor,
                constant: -24
            ),
            
            passwordView.topAnchor.constraint(
                equalTo: emailView.bottomAnchor,
                constant: 10
            ),
            passwordView.leadingAnchor.constraint(equalTo: emailView.leadingAnchor),
            passwordView.trailingAnchor.constraint(equalTo: emailView.trailingAnchor),
            
            forgotPasswordButton.trailingAnchor.constraint(
                equalTo: emailView.trailingAnchor,
                constant: -4
            )
        ])
        
        forgotPasswordTopConstraint = forgotPasswordButton.topAnchor.constraint(
            equalTo: passwordView.bottomAnchor,
            constant: 20
        )
        forgotPasswordTopConstraint?.isActive = true
        
        // Sign button
        NSLayoutConstraint.activate([
            signInButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            signInButton.widthAnchor.constraint(
                equalTo: contentView.widthAnchor,
                multiplier: 0.7
            ),
            signInButton.heightAnchor.constraint(equalToConstant: 52)
        ])
        signButtonTopToForgot = signInButton.topAnchor.constraint(
            equalTo: forgotPasswordButton.bottomAnchor,
            constant: 20
        )
        signButtonTopToForgot?.isActive = true
        
        // Toggle
        NSLayoutConstraint.activate([
            toggleModeButton.topAnchor.constraint(
                equalTo: signInButton.bottomAnchor,
                constant: 12
            ),
            toggleModeButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            toggleModeButton.bottomAnchor.constraint(
                equalTo: contentView.bottomAnchor,
                constant: -20
            )
        ])
    }
    
    // MARK: - UI Mode Switch
    private func updateUIForMode(animated: Bool) {
        let newConstant: CGFloat = (mode == .login) ? 370 : 420
        let updates = {
            self.view.removeConstraint(self.cardHeightConstraint)
            self.cardHeightConstraint.constant = newConstant
            self.cardHeightConstraint.isActive = true
            
            switch self.mode {
            case .login:
                self.helloLabel.text = Constants.LoginViewControllerConstants.helloLabelSignInText
                self.toggleModeButton.setTitle(
                    Constants.LoginViewControllerConstants.toggleButtonToSignUpText,
                    for: .normal
                )
                
                self.confirmPasswordView.removeFromSuperview()
                NSLayoutConstraint.deactivate(self.confirmConstraints)
                self.confirmConstraints.removeAll()
                self.forgotPasswordButton.isHidden = false
                
                self.signButtonTopToConfirm?.isActive = false
                self.signButtonTopToForgot?.isActive = true
                
            case .signup:
                self.helloLabel.text = Constants.LoginViewControllerConstants.helloLabelSignUpText
                self.toggleModeButton.setTitle(
                    Constants.LoginViewControllerConstants.toggleButtonToSignInText,
                    for: .normal
                )
                
                if self.confirmPasswordView.superview == nil {
                    self.confirmPasswordView.translatesAutoresizingMaskIntoConstraints = false
                    self.contentView.addSubview(self.confirmPasswordView) // Add to content view
                    self.confirmConstraints = [
                        self.confirmPasswordView.topAnchor.constraint(
                            equalTo: self.passwordView.bottomAnchor, constant: 10),
                        self.confirmPasswordView.leadingAnchor.constraint(
                            equalTo: self.passwordView.leadingAnchor),
                        self.confirmPasswordView.trailingAnchor.constraint(
                            equalTo: self.passwordView.trailingAnchor)
                    ]
                    NSLayoutConstraint.activate(self.confirmConstraints)
                }
                self.forgotPasswordButton.isHidden = true
                self.signButtonTopToForgot?.isActive = false
                if self.signButtonTopToConfirm == nil {
                    self.signButtonTopToConfirm = self.signInButton.topAnchor.constraint(
                        equalTo: self.confirmPasswordView.bottomAnchor,
                        constant: 26
                    )
                }
                self.signButtonTopToConfirm?.isActive = true
            }
            self.view.layoutIfNeeded()
            // Important: Update scrollView's contentSize after layout changes
            self.scrollView.layoutIfNeeded()
            self.updateSignInButtonTitle()
        }
        
        animated ? UIView.transition(
            with: glassCard,
            duration: 0.25,
            options: .transitionCrossDissolve,
            animations: updates
        ) : updates()
    }
    
    // MARK: - Button Targets
    private func setupButtonTargets() {
        forgotPasswordButton.addTarget(
            self,
            action: #selector(forgotPasswordTapped),
            for: .touchUpInside
        )
        signInButton.addTarget(
            self,
            action: #selector(authTapped),
            for: .touchUpInside
        )
        toggleModeButton.addTarget(
            self,
            action: #selector(toggleModeTapped),
            for: .touchUpInside
        )
    }
    
    // MARK: - Actions
    @objc private func forgotPasswordTapped() {
        signInButton.setLoading(true)
        viewModel.forgotPasswordButtonTapped(email: emailView.getText() ?? Constants.empty)
    }
    
    @objc private func authTapped() {
        let email = emailView.getText() ?? Constants.empty
        let pw    = passwordView.getText() ?? Constants.empty
        let confirm = mode == .signup ? (confirmPasswordView.getText() ?? Constants.empty) : nil

        signInButton.setLoading(true)

        viewModel.signInButtonTapped(
            email: email,
            password: pw,
            confirmPassword: confirm,
            mode: mode
        )
    }
    
    @objc private func toggleModeTapped() {
        view.endEditing(true)
        toggleModeButton.isUserInteractionEnabled = false
        UIView.animate(withDuration: 0.25, animations: {
            self.glassCard.transform = CGAffineTransform(translationX: 0, y: self.view.bounds.height)
            self.celestialAnimationView.transform = CGAffineTransform(translationX: 0, y: self.view.bounds.height)
            self.glassCard.alpha = 0.3
        }) { _ in
            self.mode = self.mode == .login ? .signup : .login
            [self.emailView,
             self.passwordView,
             self.confirmPasswordView
            ].forEach { $0.reset() }
            self.glassCard.layoutIfNeeded()
            UIView.animate(withDuration: 0.45,
                           delay: 0.05,
                           usingSpringWithDamping: 0.8,
                           initialSpringVelocity: 0.4) {
                self.glassCard.transform = .identity
                self.glassCard.alpha = 1
                self.celestialAnimationView.transform = .identity
            } completion: { [weak self] _ in
                guard let self = self else { return }
                self.toggleModeButton.isUserInteractionEnabled = true
                self.updateSignInButtonTitle()
            }
        }
    }
    
    func showLoadingOverlay() {
        let overlay = LoadingOverlayView()
        view.addSubview(overlay)
        NSLayoutConstraint.activate([
            overlay.topAnchor.constraint(equalTo: view.topAnchor),
            overlay.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            overlay.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            overlay.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        overlay.animateIn()
        self.loadingOverlay = overlay
    }
    
    private func hideLoadingOverlay() {
        loadingOverlay?.dismiss()
        loadingOverlay = nil
    }
    
    // MARK: - ViewModel Bindings
    private func setupViewModelBindings() {
        viewModel.onAsyncStart = { [weak self] in
            guard let self = self else { return }
            if self.mode == .signup {
                self.showLoadingOverlay()
                self.signInButton.setLoading(false)
                self.updateSignInButtonTitle()
            }
        }

        viewModel.onSigninSuccess = { [weak self] in
            guard let self = self else { return }
            self.signInButton.setLoading(false)
            self.updateSignInButtonTitle()

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                let banner = OkAlertView(
                    title: AuthAlert.signinSuccess.title,
                    message: AuthAlert.signinSuccess.message,
                    isError: AuthAlert.signinSuccess.shouldBeRed,
                    icon: AuthAlert.signinSuccess.animationName
                )
                banner.translatesAutoresizingMaskIntoConstraints = false
                self.view.addSubview(banner)
                NSLayoutConstraint.activate([
                    banner.topAnchor.constraint(equalTo: self.view.topAnchor),
                    banner.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
                    banner.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
                    banner.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
                ])
            }

            self.hideLoadingOverlay()
        }
        
        viewModel.onForgotPasswordOTPSuccess = { [weak self] in
            guard let self = self else { return }
            self.signInButton.setLoading(false)
            let otpVC = OTPViewController(purpose: OTPPurpose.ForgotPassword, requestData: ForgotPasswordOTPRequest(email: emailView.getText() ?? Constants.empty))
            otpVC.modalPresentationStyle = .fullScreen
            otpVC.modalTransitionStyle = .coverVertical
            self.present(otpVC, animated: true)
        }
        
        viewModel.onOTPRequired = { [weak self] in
            guard let self = self else { return }
            self.hideLoadingOverlay()
            self.signInButton.setLoading(false)
            guard let userId = KeychainHelper.standard.getUserID() else { return }
            let otpVC = OTPViewController(purpose: OTPPurpose.Signup, requestData: SignupOTPRequest(userId: userId),)
            otpVC.modalPresentationStyle = .fullScreen
            otpVC.modalTransitionStyle = .coverVertical
            self.present(otpVC, animated: true)
        }

        viewModel.onMessage = { [weak self] alert in
            guard let self = self else { return }

            self.signInButton.setLoading(false)
            self.updateSignInButtonTitle()
            self.hideLoadingOverlay()

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                let banner = OkAlertView(
                    title: alert.title,
                    message: alert.message,
                    isError: alert.shouldBeRed,
                    icon: alert.animationName
                )
                banner.translatesAutoresizingMaskIntoConstraints = false
                self.view.addSubview(banner)
                NSLayoutConstraint.activate([
                    banner.topAnchor.constraint(equalTo: self.view.topAnchor),
                    banner.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
                    banner.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
                    banner.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
                ])
            }
        }
    }
}

extension LoginViewController {
    func registerTraitChanges() {
        registerForTraitChanges([UITraitUserInterfaceStyle.self]) { [weak self] (viewController: UIViewController, previousTraitCollection: UITraitCollection) in
            self?.updateBackgroundAnimation()
        }
    }
    private func updateBackgroundAnimation() {
        guard let animation = LottieAnimation.named(getCurrentBackgroundAnimationName()) else { return }
        backgroundAnimationView.animation = animation
        backgroundAnimationView.play()
        updateCelestialAnimation()
    }
}

#Preview { LoginViewController() }
