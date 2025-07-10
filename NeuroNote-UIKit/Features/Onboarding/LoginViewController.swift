//
//  LoginViewController.swift
//  NeuroNote
//
//  Created by Eclipse on 28/06/25.
//

import UIKit

// MARK: - Authentication Mode
enum AuthMode {
    case login
    case signup
}

class LoginViewController: UIViewController {

    // MARK: - View-Model
    private let viewModel = LoginViewModel()

    // MARK: - UI Elements
    private let backgroundImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: Constants.LoginViewControllerConstants.loginBGImageName))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode   = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()

    private let helloLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor     = .white
        label.numberOfLines = 0
        label.font          = UIFont(name: Fonts.MontserratRegular, size: 30) ?? .systemFont(ofSize: 30)
        return label
    }()

    private let cardView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor      = .white
        view.layer.cornerRadius   = 50
        view.layer.maskedCorners  = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        view.clipsToBounds        = true
        return view
    }()

    private let emailView  = LabeledTextField(title: "Email",
                                              placeholder: "Enter your email",
                                              trailingImage: nil)

    private let passwordView = LabeledTextField(title: "Password",
                                                placeholder: "Enter your password",
                                                trailingImage: UIImage(systemName: "eye"))

    private let confirmPasswordView = LabeledTextField(title: "Confirm Password",
                                                       placeholder: "Re-enter your password",
                                                       trailingImage: UIImage(systemName: "eye"))

    private let forgotPasswordButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Forgot Password?", for: .normal)
        button.setTitleColor(.systemPurple, for: .normal)
        button.titleLabel?.font = UIFont(name: Fonts.MontserratRegular, size: 15) ?? .systemFont(ofSize: 15)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let signInButton: UIButton = {
        let button = UIButton()
        button.setTitle("SIGN IN", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .medium)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor(red: 49/255, green: 53/255, blue: 126/255, alpha: 1.0)
        button.layer.cornerRadius = 20
        button.translatesAutoresizingMaskIntoConstraints = false
        button.clipsToBounds = true
        return button
    }()

    private let toggleModeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Don't have an account? Sign up", for: .normal)
        button.setTitleColor(.systemPurple, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 15)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    // MARK: - States and Dynamic Constraints
    private var mode: AuthMode = .login {
        didSet { updateUIForMode(animated: false) }
    }

    private var confirmConstraints: [NSLayoutConstraint] = []
    private var forgotPasswordTopConstraint: NSLayoutConstraint?
    private var signButtonTopToForgotPassword: NSLayoutConstraint?
    private var signButtonTopToConfirm: NSLayoutConstraint?
    private var cardHeightConstraint: NSLayoutConstraint!

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        buildHierarchy()
        setupConstraints()
        setupViewModelBindings()
        setupButtonTargets()
        updateUIForMode(animated: false)
    }

    // MARK: - Hierarchy + Constraints
    private func buildHierarchy() {
        view.addSubview(backgroundImageView)
        view.addSubview(cardView)
        view.addSubview(helloLabel)

        [emailView, passwordView, forgotPasswordButton, signInButton, toggleModeButton]
            .forEach { cardView.addSubview($0) }
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            
            // Background Constraints
            backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // Greeting Label Constraints
            helloLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            helloLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),

            // Card View Constraints
            cardView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            cardView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            cardView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // Email LabeledTextField Constraints
            emailView.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 50),
            emailView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 20),
            emailView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -20),
            
            // Password LabeledTextField Constraints
            passwordView.topAnchor.constraint(equalTo: emailView.bottomAnchor, constant: 40),
            passwordView.leadingAnchor.constraint(equalTo: emailView.leadingAnchor),
            passwordView.trailingAnchor.constraint(equalTo: emailView.trailingAnchor),
            
            // Forgot Password Button Constraints
            forgotPasswordButton.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -30),
            
            // Toggle Button and Sign Button Constraints
            toggleModeButton.topAnchor.constraint(equalTo: signInButton.bottomAnchor, constant: 10),
            toggleModeButton.centerXAnchor.constraint(equalTo: cardView.centerXAnchor),
            signInButton.centerXAnchor.constraint(equalTo: cardView.centerXAnchor),
            signInButton.widthAnchor.constraint(equalTo: cardView.widthAnchor, multiplier: 0.8),
            signInButton.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        // Dynamic card height constraint
        cardHeightConstraint = cardView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.6)
        cardHeightConstraint.isActive = true
        
        //Forgot Password Button Constraints
        forgotPasswordTopConstraint = forgotPasswordButton.topAnchor.constraint(equalTo: passwordView.bottomAnchor, constant: 30)
        forgotPasswordTopConstraint?.isActive = true
        
        // Sign Button Constraints
        signButtonTopToForgotPassword = signInButton.topAnchor.constraint(equalTo: forgotPasswordButton.bottomAnchor, constant: 20)
        signButtonTopToConfirm   = signInButton.topAnchor.constraint(equalTo: confirmPasswordView.bottomAnchor, constant: 20)
        signButtonTopToForgotPassword?.isActive = true
    }

    // MARK: - UI Update
    private func updateUIForMode(animated: Bool) {
        let newMultiplier: CGFloat = (mode == .login) ? 0.63 : 0.7

        let updates = {
            self.view.removeConstraint(self.cardHeightConstraint)
            self.cardHeightConstraint = self.cardView.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: newMultiplier)
            self.cardHeightConstraint.isActive = true

            self.toggleModeButton.titleLabel?.font = UIFont(name: Fonts.MontserratRegular, size: 15) ?? .systemFont(ofSize: 15)
            switch self.mode {
            case .login:
                self.helloLabel.text = Constants.LoginViewControllerConstants.helloLabelSignInText
                self.signInButton.setTitle("SIGN IN", for: .normal)
                self.toggleModeButton.setTitle(Constants.LoginViewControllerConstants.toggleButtonToSignUpText, for: .normal)

                self.confirmPasswordView.removeFromSuperview()
                NSLayoutConstraint.deactivate(self.confirmConstraints)
                self.confirmConstraints = []

                self.forgotPasswordButton.isHidden = false

                self.forgotPasswordTopConstraint?.isActive = false
                self.forgotPasswordTopConstraint = self.forgotPasswordButton.topAnchor.constraint(equalTo: self.passwordView.bottomAnchor, constant: 30)
                self.forgotPasswordTopConstraint?.isActive = true

                self.signButtonTopToConfirm?.isActive = false
                self.signButtonTopToForgotPassword?.isActive = true

            case .signup:
                self.helloLabel.text = Constants.LoginViewControllerConstants.helloLabelSignUpText
                self.signInButton.setTitle("SIGN UP", for: .normal)
                self.toggleModeButton.setTitle(Constants.LoginViewControllerConstants.toggleButtonToSignInText, for: .normal)

                if self.confirmPasswordView.superview == nil {
                    self.cardView.addSubview(self.confirmPasswordView)
                    self.confirmPasswordView.translatesAutoresizingMaskIntoConstraints = false
                    self.confirmConstraints = [
                        self.confirmPasswordView.topAnchor.constraint(equalTo: self.passwordView.bottomAnchor, constant: 40),
                        self.confirmPasswordView.leadingAnchor.constraint(equalTo: self.passwordView.leadingAnchor),
                        self.confirmPasswordView.trailingAnchor.constraint(equalTo: self.passwordView.trailingAnchor)
                    ]
                    NSLayoutConstraint.activate(self.confirmConstraints)
                }

                self.forgotPasswordTopConstraint?.isActive = false
                self.forgotPasswordButton.isHidden = true

                self.signButtonTopToForgotPassword?.isActive = false
                self.signButtonTopToConfirm?.isActive = true
            }

            self.view.layoutIfNeeded()
        }

        if animated {
            UIView.transition(with: cardView,
                              duration: 0.25,
                              options: [.transitionCrossDissolve],
                              animations: updates)
        } else {
            updates()
        }
    }

    // MARK: - Button Targets
    private func setupButtonTargets() {
        forgotPasswordButton.addTarget(self, action: #selector(forgotPasswordButtonTapped), for: .touchUpInside)
        signInButton.addTarget(self, action: #selector(signInButtonTapped), for: .touchUpInside)
        toggleModeButton.addTarget(self, action: #selector(toggleModeTapped), for: .touchUpInside)
    }

    // MARK: - Button actions
    @objc private func forgotPasswordButtonTapped() {
        let email = emailView.getText() ?? Constants.empty
        viewModel.forgotPasswordButtonTapped(email: email)
    }

    @objc private func signInButtonTapped() {
        let email = emailView.getText() ?? Constants.empty
        let password = passwordView.getText() ?? Constants.empty
        let confirm = (mode == .signup) ? (confirmPasswordView.getText() ?? Constants.empty) : nil
        viewModel.signInButtonTapped(email: email, password: password, confirmPassword: confirm, mode: mode)
    }

    // MARK: - Toggle Mode Logic and Animation
    @objc private func toggleModeTapped() {
        view.endEditing(true)
        toggleModeButton.isUserInteractionEnabled = false

        UIView.animate(withDuration: 0.25,
                       animations: {
            self.cardView.transform = CGAffineTransform(translationX: 0, y: self.view.bounds.height)
            self.cardView.alpha = 0.3
        }) { _ in
            self.mode = (self.mode == .login) ? .signup : .login

            self.emailView.reset()
            self.passwordView.reset()
            self.confirmPasswordView.reset()

            self.cardView.layoutIfNeeded()

            UIView.animate(withDuration: 0.45,
                           delay: 0.05,
                           usingSpringWithDamping: 0.8,
                           initialSpringVelocity: 0.4) {
                self.cardView.transform = .identity
                self.cardView.alpha = 1.0
            } completion: { _ in
                self.toggleModeButton.isUserInteractionEnabled = true
            }
        }
    }

    // MARK: - ViewModel Bindings
    private func setupViewModelBindings() {
        viewModel.onMessage = { [weak self] alertContent in
            guard let self = self else { return }
            let alert = OkAlertView(title: alertContent.title,
                                    message: alertContent.message,
                                    isError: alertContent.shouldBeRed,
                                    icon: UIImage(named: alertContent.imageName))
            alert.translatesAutoresizingMaskIntoConstraints = false
            self.view.addSubview(alert)
            NSLayoutConstraint.activate([
                alert.topAnchor.constraint(equalTo: self.view.topAnchor),
                alert.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
                alert.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
                alert.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
            ])
        }
    }
}

#Preview { LoginViewController() }
