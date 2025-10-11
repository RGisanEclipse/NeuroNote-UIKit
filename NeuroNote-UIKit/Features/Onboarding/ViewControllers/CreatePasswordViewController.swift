//
//  CreatePasswordViewController.swift
//  NeuroNote-UIKit
//
//  Created by Eclipse on 10/10/25.
//

import UIKit
import Lottie
class CreatePasswordViewController: UIViewController {

    private let backgroundImage: UIImageView = {
        let bgImage = UIImageView(image: UIImage(named: Constants.OTPViewControllerConstants.backgroundImageName))
        bgImage.contentMode = .scaleAspectFill
        bgImage.translatesAutoresizingMaskIntoConstraints = false
        return bgImage
    }()
    // Animation
    private let passwordAnimationView: LottieAnimationView = {
        let animation = LottieAnimation.named(Constants.animations.phonePassword)
        let animationView = LottieAnimationView(animation: animation)
        animationView.translatesAutoresizingMaskIntoConstraints = false
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .playOnce
        return animationView
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
    
    // Title
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        label.numberOfLines = 0
        label.font = UIFont(name: Fonts.MontserratMedium, size: 28) ?? .systemFont(ofSize: 28, weight: .bold)
        label.textAlignment = .center
        label.text = Constants.CreatePasswordViewControllerConstants.titleLabel
        return label
    }()
    
    private let passwordView = LabeledTextField(
        placeholder: "Set Password",
        trailingImage: UIImage(systemName: "eye")
    )
    private let confirmPasswordView = LabeledTextField(
        placeholder: "Verify Password",
        trailingImage: UIImage(systemName: "eye")
    )
    
    private let passwordStrengthView = PasswordStrengthView()
    
    private let submitButton = ClearButton(title: "Reset Password")
    
    // Handle Button
    @objc private func handleSubmitButtonTapped(){
        // Call to viewmodel to submit the password
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupHeirarchy()
        setupConstraints()
        
        passwordAnimationView.play()
        passwordView.delegate = self
        submitButton.addTarget(self, action: #selector(handleSubmitButtonTapped), for: .touchUpInside)
    }
    
    func setupHeirarchy(){
        view.addSubview(backgroundImage)
        view.sendSubviewToBack(backgroundImage)
        view.addSubview(passwordAnimationView)
        view.addSubview(scrollView)
        scrollView.addSubview(scrollContentView)
        [titleLabel, passwordView, confirmPasswordView, passwordStrengthView].forEach{
            scrollView.addSubview($0)
        }
        view.addSubview(submitButton)
    }
    
    func setupConstraints(){
        NSLayoutConstraint.activate([
            backgroundImage.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImage.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            backgroundImage.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImage.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            passwordAnimationView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: -20),
            passwordAnimationView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            passwordAnimationView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            passwordAnimationView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.25),
            
            
            scrollView.topAnchor.constraint(equalTo: passwordAnimationView.bottomAnchor, constant: -8),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            scrollContentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            scrollContentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            scrollContentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            scrollContentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            titleLabel.topAnchor.constraint(equalTo: scrollContentView.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            
            passwordView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            passwordView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            passwordView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            
            confirmPasswordView.topAnchor.constraint(equalTo: passwordView.bottomAnchor, constant: 20),
            confirmPasswordView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            confirmPasswordView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            
            passwordStrengthView.topAnchor.constraint(equalTo: confirmPasswordView.bottomAnchor,constant: 30),
            passwordStrengthView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            passwordStrengthView.widthAnchor.constraint(equalToConstant: 200),
            
            submitButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            submitButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            submitButton.heightAnchor.constraint(equalToConstant: 60),
            submitButton.widthAnchor.constraint(equalToConstant: 220)
        ])
    }
}

// MARK: - LabeledTextFieldDelegate
extension CreatePasswordViewController: LabeledTextFieldDelegate {
    func labeledTextField(_ textField: LabeledTextField, didChangeText text: String) {
        if textField === passwordView {
            passwordStrengthView.updateStrength(for: text)
        }
    }
}

#Preview{CreatePasswordViewController()}
