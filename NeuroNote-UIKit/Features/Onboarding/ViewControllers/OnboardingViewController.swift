//
//  OnboardingViewController.swift
//  NeuroNote-UIKit
//
//  Created by Eclipse on 19/07/25.
//

import UIKit
import Lottie

class OnboardingViewController: UIViewController {
    
    // MARK: - ViewModel
    private let viewModel = OnboardingViewModel()
    
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
    
    // MARK: - Name Field
    private lazy var nameTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.font = UIFont(name: Fonts.MontserratRegular, size: 18)
        textField.textColor = .white
        textField.attributedPlaceholder = NSAttributedString(
            string: "What's your name?",
            attributes: [
                .foregroundColor: UIColor.white.withAlphaComponent(0.7),
                .font: UIFont(name: Fonts.MontserratSemiBold, size: 18) ?? .systemFont(ofSize: 18)
            ]
        )
        textField.textAlignment = .center
        textField.borderStyle = .none
        textField.autocapitalizationType = .words
        textField.autocorrectionType = .no
        textField.returnKeyType = .done
        textField.alpha = 0.5
        textField.transform = CGAffineTransform(translationX: 0, y: 30)
        return textField
    }()
    
    private lazy var nameFieldContainer: UIView = {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        container.layer.cornerRadius = 20
        container.layer.borderWidth = 1
        container.layer.borderColor = UIColor.white.withAlphaComponent(0.2).cgColor
        container.layer.shadowColor = UIColor.black.cgColor
        container.layer.shadowOffset = CGSize(width: 0, height: 4)
        container.layer.shadowRadius = 12
        container.layer.shadowOpacity = 0.15
        container.alpha = 0
        container.transform = CGAffineTransform(translationX: 0, y: 30)
        return container
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Let's get started!"
        label.font = UIFont(name: Fonts.BeachDay, size: 32)
        label.textColor = .white
        label.textAlignment = .center
        label.alpha = 0
        label.transform = CGAffineTransform(translationX: 0, y: -20)
        return label
    }()
    
    // MARK: - Age Slider
    private lazy var ageSliderContainer: UIView = {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        container.layer.cornerRadius = 20
        container.layer.borderWidth = 1
        container.layer.borderColor = UIColor.white.withAlphaComponent(0.2).cgColor
        container.layer.shadowColor = UIColor.black.cgColor
        container.layer.shadowOffset = CGSize(width: 0, height: 4)
        container.layer.shadowRadius = 12
        container.layer.shadowOpacity = 0.15
        container.alpha = 0
        container.transform = CGAffineTransform(translationX: 0, y: 30)
        container.layoutMargins = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        container.preservesSuperviewLayoutMargins = false
        
        return container
    }()
    
    private var hasConfirmedDefaultAge = false
    
    private lazy var ageSlider: UISlider = {
        let slider = UISlider()
        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.minimumValue = 13
        slider.maximumValue = 100
        slider.value = 21
        slider.tintColor = .white
        slider.thumbTintColor = .white
        slider.minimumTrackTintColor = UIColor.white.withAlphaComponent(0.8)
        slider.maximumTrackTintColor = UIColor.white.withAlphaComponent(0.3)
        slider.addTarget(self, action: #selector(ageSliderChanged), for: .valueChanged)
        return slider
    }()
    
    private lazy var ageLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Age: 21"
        label.font = UIFont(name: Fonts.MontserratRegular, size: 16)
        label.textColor = .white
        label.textAlignment = .center
        label.alpha = 0
        return label
    }()
    
    private lazy var ageSliderTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "How old are you?"
        label.font = UIFont(name: Fonts.MontserratSemiBold, size: 18)
        label.textColor = UIColor.white.withAlphaComponent(0.8)
        label.textAlignment = .center
        label.alpha = 0
        label.transform = CGAffineTransform(translationX: 0, y: 30)
        return label
    }()
    
    private lazy var continueButton: GradientButton = {
        let button = GradientButton(
            title: "Continue",
            leadingColor: UIColor.systemYellow.cgColor,
            trailingColor: UIColor.systemOrange.cgColor
        )
        button.translatesAutoresizingMaskIntoConstraints = false
        button.alpha = 0
        button.transform = CGAffineTransform(translationX: 0, y: 30)
        button.addTarget(self, action: #selector(continueButtonTapped), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Back and Submit Buttons
    private lazy var backButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Back", for: .normal)
        button.titleLabel?.font = UIFont(name: Fonts.MontserratSemiBold, size: 18)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        button.layer.cornerRadius = 30
        button.layer.borderWidth = 2
        button.layer.borderColor = UIColor.white.withAlphaComponent(0.3).cgColor
        button.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        button.alpha = 0
        button.transform = CGAffineTransform(translationX: 0, y: 30)
        button.isHidden = true
        return button
    }()
    
    private lazy var submitButton: GradientButton = {
        let button = GradientButton(
            title: "Submit",
            leadingColor: UIColor.systemYellow.cgColor,
            trailingColor: UIColor.systemOrange.cgColor
        )
        button.translatesAutoresizingMaskIntoConstraints = false
        button.alpha = 0
        button.transform = CGAffineTransform(translationX: 0, y: 30)
        button.addTarget(self, action: #selector(submitButtonTapped), for: .touchUpInside)
        button.isHidden = true
        return button
    }()
    
    // MARK: - Gender Selection
    private lazy var genderContainer: UIView = {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        container.layer.cornerRadius = 20
        container.layer.borderWidth = 1
        container.layer.borderColor = UIColor.white.withAlphaComponent(0.2).cgColor
        container.layer.shadowColor = UIColor.black.cgColor
        container.layer.shadowOffset = CGSize(width: 0, height: 4)
        container.layer.shadowRadius = 12
        container.layer.shadowOpacity = 0.15
        container.alpha = 0
        container.transform = CGAffineTransform(translationX: view.bounds.width, y: 0)
        container.layoutMargins = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        container.preservesSuperviewLayoutMargins = false
        container.isHidden = true
        return container
    }()
    
    private lazy var genderTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "How do you identify?"
        label.font = UIFont(name: Fonts.MontserratSemiBold, size: 20)
        label.textColor = UIColor.white.withAlphaComponent(0.8)
        label.textAlignment = .center
        label.alpha = 0
        label.transform = CGAffineTransform(translationX: view.bounds.width, y: 0)
        label.isHidden = true
        return label
    }()
    
    private lazy var maleButton: LottieAnimationView = {
        let animationView = LottieAnimationView(name: Constants.animations.maleAvatar)
        animationView.translatesAutoresizingMaskIntoConstraints = false
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .loop
        animationView.play()
        animationView.isHidden = true
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(genderButtonTapped(_:)))
        animationView.addGestureRecognizer(tapGesture)
        animationView.tag = 0
        animationView.isUserInteractionEnabled = true
        
        return animationView
    }()
    
    private lazy var femaleButton: LottieAnimationView = {
        let animationView = LottieAnimationView(name: Constants.animations.femaleAvatar)
        animationView.translatesAutoresizingMaskIntoConstraints = false
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .loop
        animationView.play()
        animationView.isHidden = true
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(genderButtonTapped(_:)))
        animationView.addGestureRecognizer(tapGesture)
        animationView.tag = 1
        animationView.isUserInteractionEnabled = true
        
        return animationView
    }()
    
    private var selectedGender: Int? = nil
    
    private func getCurrentBackgroundAnimationName() -> String {
        return traitCollection.userInterfaceStyle == .dark
        ? Constants.animations.nightSky
        : Constants.animations.clouds
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupConstraints()
        setupViewModelBindings()
        registerTraitChanges()
    }
    
    // MARK: - ViewModel Bindings
    private func setupViewModelBindings() {
        viewModel.onAsyncStart = { [weak self] in
            guard let self = self else { return }
            self.submitButton.setLoading(true)
        }
        
        viewModel.onAsyncEnd = { [weak self] in
            guard let self = self else { return }
            self.submitButton.setLoading(false)
        }
        
        viewModel.onOnboardingSuccess = { [weak self] in
            guard let self = self else { return }
            // TODO: Navigate to dashboard/home
            self.dismiss(animated: true)
        }
        
        viewModel.onMessage = { [weak self] alert in
            guard let self = self else { return }
            let banner = OkAlertView(
                title: alert.title,
                message: alert.message,
                isError: alert.shouldBeRed,
                icon: alert.animationName
            )
            self.displayOkAlertView(banner: banner)
        }
    }
    
    func setupView(){
        view.addSubview(backgroundAnimationView)
        view.addSubview(titleLabel)
        view.addSubview(nameFieldContainer)
        view.addSubview(nameTextField)
        view.addSubview(ageSliderContainer)
        view.addSubview(ageSliderTitleLabel)
        view.addSubview(ageSlider)
        view.addSubview(ageLabel)
        view.addSubview(continueButton)
        view.addSubview(backButton)
        view.addSubview(submitButton)
        view.addSubview(genderTitleLabel)
        view.addSubview(maleButton)
        view.addSubview(femaleButton)
        backgroundAnimationView.play()
        setupTextFieldBehavior()
    }
    
    func setupConstraints(){
        NSLayoutConstraint.activate([
            backgroundAnimationView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundAnimationView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundAnimationView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundAnimationView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // Title Label - centered vertically
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -120),
            
            // Name Field Container
            nameFieldContainer.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            nameFieldContainer.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 40),
            nameFieldContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 50),
            nameFieldContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -50),
            nameFieldContainer.heightAnchor.constraint(equalToConstant: 60),
            
            // Name Text Field
            nameTextField.centerXAnchor.constraint(equalTo: nameFieldContainer.centerXAnchor),
            nameTextField.centerYAnchor.constraint(equalTo: nameFieldContainer.centerYAnchor),
            nameTextField.leadingAnchor.constraint(equalTo: nameFieldContainer.leadingAnchor, constant: 20),
            nameTextField.trailingAnchor.constraint(equalTo: nameFieldContainer.trailingAnchor, constant: -20),
            
            // Age Slider Title
            ageSliderTitleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            ageSliderTitleLabel.topAnchor.constraint(equalTo: nameFieldContainer.bottomAnchor, constant: 30),
            
            // Age Slider Container
            ageSliderContainer.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            ageSliderContainer.topAnchor.constraint(equalTo: ageSliderTitleLabel.bottomAnchor, constant: 15),
            ageSliderContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 50),
            ageSliderContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -50),
            ageSliderContainer.heightAnchor.constraint(equalToConstant: 100),
            
            // Age Slider
            ageSlider.centerXAnchor.constraint(equalTo: ageSliderContainer.centerXAnchor),
            ageSlider.topAnchor.constraint(equalTo: ageSliderContainer.layoutMarginsGuide.topAnchor),
            ageSlider.leadingAnchor.constraint(equalTo: ageSliderContainer.layoutMarginsGuide.leadingAnchor),
            ageSlider.trailingAnchor.constraint(equalTo: ageSliderContainer.layoutMarginsGuide.trailingAnchor),
            
            // Age Label
            ageLabel.centerXAnchor.constraint(equalTo: ageSliderContainer.centerXAnchor),
            ageLabel.topAnchor.constraint(equalTo: ageSlider.bottomAnchor, constant: 15),
            ageLabel.bottomAnchor.constraint(equalTo: ageSliderContainer.layoutMarginsGuide.bottomAnchor),
            
            // Continue button
            continueButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            continueButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            continueButton.heightAnchor.constraint(equalToConstant: 60),
            continueButton.widthAnchor.constraint(equalToConstant: 220),
            
            // Back button
            backButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 50),
            backButton.heightAnchor.constraint(equalToConstant: 60),
            backButton.widthAnchor.constraint(equalToConstant: 100),
            
            // Submit button
            submitButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            submitButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -50),
            submitButton.heightAnchor.constraint(equalToConstant: 60),
            submitButton.widthAnchor.constraint(equalToConstant: 100),
            
            // Gender Title Label
            genderTitleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            genderTitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 50),
            
            // Lottie Gender Buttons
            maleButton.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: -100),
            maleButton.topAnchor.constraint(equalTo: genderTitleLabel.bottomAnchor, constant: 0),
            maleButton.widthAnchor.constraint(equalToConstant: 200),
            maleButton.heightAnchor.constraint(equalToConstant: 200),
            
            femaleButton.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 100),
            femaleButton.topAnchor.constraint(equalTo: genderTitleLabel.bottomAnchor, constant: 0),
            femaleButton.widthAnchor.constraint(equalToConstant: 200),
            femaleButton.heightAnchor.constraint(equalToConstant: 200)
            
        ])
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.hidesBackButton = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        animateNameField()
        setupCircularButtons()
    }
    
    private func setupCircularButtons() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.maleButton.layer.cornerRadius = self.maleButton.frame.width / 2
            self.femaleButton.layer.cornerRadius = self.femaleButton.frame.width / 2
        }
    }
    
    // MARK: - Animation & Behavior
    private func animateNameField() {
        UIView.animate(
            withDuration: 0.8,
            delay: 0.0,
            usingSpringWithDamping: 0.7,
            initialSpringVelocity: 0.5,
            options: [.curveEaseOut],
            animations: { [weak self] in
                guard let self = self else { return }
                // Title label
                self.titleLabel.alpha = 1.0
                self.titleLabel.transform = .identity
                
                // Name field
                self.nameFieldContainer.alpha = 1.0
                self.nameFieldContainer.transform = .identity
                self.nameTextField.alpha = 1.0
                self.nameTextField.transform = .identity
                
                // Age slider
                self.ageSliderTitleLabel.alpha = 1.0
                self.ageSliderTitleLabel.transform = .identity
                self.ageSliderContainer.alpha = 1.0
                self.ageSliderContainer.transform = .identity
                self.ageSlider.alpha = 1.0
                self.ageLabel.alpha = 1.0
                
                // Continue button
                self.continueButton.alpha = 1.0
                self.continueButton.transform = .identity
            }
        )
    }
    
    private func setupTextFieldBehavior() {
        nameTextField.delegate = self
    }
    
    @objc private func ageSliderChanged() {
        let age = Int(ageSlider.value)
        ageLabel.text = "Age: \(age)"
        UIView.animate(withDuration: 0.2, animations: { [weak self] in
            guard let self = self else { return }
            self.ageLabel.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
        }) { [weak self] _ in
            guard let self = self else { return }
            UIView.animate(withDuration: 0.2) {
                self.ageLabel.transform = .identity
            }
        }
    }
    
    @objc private func continueButtonTapped() {
        guard let name = nameTextField.text, !name.isEmpty else {
            showEmptyFieldsAlert()
            return
        }
        let age = Int(ageSlider.value)
        if age == 21 && !hasConfirmedDefaultAge {
            showAgeConfirmationAlert()
            return
        }
        showGenderSelection()
    }
    
    @objc private func genderButtonTapped(_ sender: UITapGestureRecognizer) {
        guard let animationView = sender.view as? LottieAnimationView else { return }
        selectedGender = animationView.tag
        
        UIView.animate(withDuration: 0.1, animations: {
            animationView.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        }) { _ in
            UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.8, options: [.curveEaseInOut], animations: {
                animationView.transform = .identity
            })
        }
        
        maleButton.stop()
        femaleButton.stop()
        
        if animationView.tag == 0 {
            maleButton.alpha = 1
            femaleButton.alpha = 0.65
            DispatchQueue.main.async{ [weak self] in
                self?.maleButton.play()
            }
        } else {
            femaleButton.play()
            femaleButton.alpha = 1
            maleButton.alpha = 0.65
        }
    }
    
    @objc private func backButtonTapped() {
        self.nameFieldContainer.isHidden = false
        
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5, options: [.curveEaseInOut], animations: { [weak self] in
            guard let self = self else { return }
            self.maleButton.alpha = 0
            self.maleButton.transform = CGAffineTransform(translationX: self.view.bounds.width, y: 0)
            self.femaleButton.alpha = 0
            self.femaleButton.transform = CGAffineTransform(translationX: self.view.bounds.width, y: 0)
            self.genderTitleLabel.alpha = 0
            self.genderTitleLabel.transform = CGAffineTransform(translationX: self.view.bounds.width, y: 0)
            self.backButton.alpha = 0
            self.backButton.transform = CGAffineTransform(translationX: self.view.bounds.width, y: 0)
            self.submitButton.alpha = 0
            self.submitButton.transform = CGAffineTransform(translationX: self.view.bounds.width, y: 0)
            
            // Slide name/age content back to center
            self.titleLabel.transform = .identity
            self.nameFieldContainer.transform = .identity
            self.nameTextField.transform = .identity
            self.ageSliderTitleLabel.transform = .identity
            self.ageSliderContainer.transform = .identity
            self.ageSlider.transform = .identity
            self.ageLabel.transform = .identity
            
            self.titleLabel.text = "Let's get started!"
            self.continueButton.isHidden = false
            
        }) { [weak self] _ in
            guard let self = self else { return }
            self.genderTitleLabel.isHidden = true
            self.femaleButton.isHidden = true
            self.maleButton.isHidden = true
            self.backButton.isHidden = true
            self.submitButton.isHidden = true
        }
    }
    
    @objc private func submitButtonTapped() {
        guard let gender = selectedGender else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                let banner = OkAlertView(
                    title: SignupAlerts.emptyGender.title,
                    message: SignupAlerts.emptyGender.message,
                    isError: SignupAlerts.emptyGender.shouldBeRed,
                    icon: SignupAlerts.emptyGender.animationName
                )
                self?.displayOkAlertView(banner: banner)
            }
            return
        }
        
        let onboardingData = OnboardingData(
            name: nameTextField.text ?? "",
            age: Int(ageSlider.value),
            gender: gender
        )
        
        viewModel.submitButtonTapped(onboardingData: onboardingData)
    }
    
    private func showGenderSelection(){
        self.genderTitleLabel.isHidden = false
        self.femaleButton.isHidden = false
        self.maleButton.isHidden = false
        self.backButton.isHidden = false
        self.submitButton.isHidden = false
        
        self.titleLabel.text = "One last question"
        
        UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5, options: [.curveEaseInOut], animations: { [weak self] in
            guard let self = self else { return }
            self.nameFieldContainer.transform = CGAffineTransform(translationX: -self.view.bounds.width, y: 0)
            self.nameTextField.transform = CGAffineTransform(translationX: -self.view.bounds.width, y: 0)
            self.ageSliderTitleLabel.transform = CGAffineTransform(translationX: -self.view.bounds.width, y: 0)
            self.ageSliderContainer.transform = CGAffineTransform(translationX: -self.view.bounds.width, y: 0)
            self.ageSlider.transform = CGAffineTransform(translationX: -self.view.bounds.width, y: 0)
            self.ageLabel.transform = CGAffineTransform(translationX: -self.view.bounds.width, y: 0)
            
            self.titleLabel.transform = .identity
            self.genderTitleLabel.alpha = 1.0
            self.genderTitleLabel.transform = .identity
            self.backButton.alpha = 1.0
            self.backButton.transform = .identity
            self.submitButton.alpha = 1.0
            self.submitButton.transform = .identity
            
            if let selectedGender = self.selectedGender {
                if selectedGender == 0 {
                    self.maleButton.alpha = 1.0
                    self.femaleButton.alpha = 0.65
                } else {
                    self.femaleButton.alpha = 1.0
                    self.maleButton.alpha = 0.65
                }
            } else {
                self.maleButton.alpha = 0.5
                self.femaleButton.alpha = 0.5
            }
            
            self.maleButton.transform = .identity
            self.femaleButton.transform = .identity
            
            self.continueButton.isHidden = true
            self.nameFieldContainer.isHidden = true
            
        }) { [weak self] _ in
            guard let self = self else { return }
            if let selectedGender = self.selectedGender {
                self.maleButton.stop()
                self.femaleButton.stop()
                if selectedGender == 0 {
                    self.maleButton.play()
                } else {
                    self.femaleButton.play()
                }
            } else {
                self.maleButton.stop()
                self.femaleButton.stop()
            }
        }
    }
    private func showEmptyFieldsAlert(){
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            guard let self = self else { return }
            let banner = OkAlertView(
                title: AuthAlert.fieldsMissing.title,
                message: AuthAlert.fieldsMissing.message,
                isError: AuthAlert.fieldsMissing.shouldBeRed,
                icon: AuthAlert.fieldsMissing.animationName
            )
            self.displayOkAlertView(banner: banner)
        }
    }
    
    private func showAgeConfirmationAlert(){
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5){ [weak self] in
            guard let self = self else { return }
            let banner = OkAlertView(
                title: SignupAlerts.confirmAge.title,
                message: SignupAlerts.confirmAge.message,
                isError: SignupAlerts.confirmAge.shouldBeRed,
                icon: SignupAlerts.confirmAge.animationName
            )
            self.displayOkAlertView(banner: banner)
            self.hasConfirmedDefaultAge = true
        }
    }
    
    private func displayOkAlertView(banner: OkAlertView){
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

extension OnboardingViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        UIView.animate(withDuration: 0.3) { [weak self] in
            guard let self = self else { return }
            self.nameFieldContainer.layer.borderColor = UIColor.white.withAlphaComponent(0.6).cgColor
            self.nameFieldContainer.transform = CGAffineTransform(scaleX: 1.02, y: 1.02)
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        UIView.animate(withDuration: 0.3) { [weak self] in
            guard let self = self else { return }
            self.nameFieldContainer.layer.borderColor = UIColor.white.withAlphaComponent(0.2).cgColor
            self.nameFieldContainer.transform = .identity
        }
    }
}

extension OnboardingViewController {
    func registerTraitChanges() {
        registerForTraitChanges([UITraitUserInterfaceStyle.self]) { [weak self] (viewController: UIViewController, previousTraitCollection: UITraitCollection) in
            self?.updateBackgroundAnimation()
        }
    }
    private func updateBackgroundAnimation() {
        guard let animation = LottieAnimation.named(getCurrentBackgroundAnimationName()) else { return }
        backgroundAnimationView.animation = animation
        backgroundAnimationView.play()
    }
}

#Preview{
    OnboardingViewController()
}
