//
//  JetpackOverlayView.swift
//  NeuroNote
//
//  Created by Eclipse on 16/07/25.
//

import UIKit
import Lottie

class LoadingOverlayView: UIView {
    
    // MARK: - Subviews
    private let animationView: LottieAnimationView = {
        let view = LottieAnimationView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.contentMode = .scaleAspectFit
        view.loopMode = .loop
        view.backgroundBehavior = .pauseAndRestore
        view.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        return view
    }()
    
    private let backgroundAnimationView: LottieAnimationView = {
        let view = LottieAnimationView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.contentMode = .scaleAspectFill
        view.loopMode = .loop
        view.backgroundBehavior = .pauseAndRestore
        return view
    }()
    
    private let messageLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.font =
        UIFont(
            name: Fonts.MontserratBoldItalic,
            size: 25
        ) ?? UIFont.systemFont(ofSize: 25, weight: .medium)
        label.textColor = .white
        label.numberOfLines = 2
        label.alpha = 0
        return label
    }()
    
    // MARK: - Properties
    private var messageTimer: Timer?
    private let messages: [String] = [
        "Vibing with the server",
        "Cooking up your request",
        "Lowkey doing backend stuff",
        "Talking to the cloud, brb",
        "Manifesting data like a pro",
        "Loading... but aesthetic",
        "Fetching stuff fr fr",
        "No cap, this might take a sec",
        "Doing the digital hustle",
        "Coding on beast mode",
        "Backend’s in its feels rn",
        "Serving hot data, hold up",
        "Just backend things",
        "Being so real with this request",
        "Trying not to crash (same)"
    ]
    private var currentMessageIndex = 0
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        loadAnimation()
        registerTraitChangeHandler()
        animateIn()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
        loadAnimation()
        registerTraitChangeHandler()
        animateIn()
    }
    
    // MARK: - Setup
    private func setupView() {
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = UIColor.black.withAlphaComponent(0.1)

        addSubview(backgroundAnimationView)
        addSubview(animationView)
        addSubview(messageLabel)
        
        NSLayoutConstraint.activate([
            backgroundAnimationView.topAnchor.constraint(equalTo: topAnchor),
            backgroundAnimationView.bottomAnchor.constraint(equalTo: bottomAnchor),
            backgroundAnimationView.leadingAnchor.constraint(equalTo: leadingAnchor),
            backgroundAnimationView.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            animationView.centerXAnchor.constraint(equalTo: centerXAnchor),
            animationView.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -110),
            animationView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.9),
            animationView.heightAnchor.constraint(equalTo: animationView.widthAnchor),
            
            messageLabel.topAnchor.constraint(equalTo: bottomAnchor, constant: -250),
            messageLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            messageLabel.widthAnchor.constraint(lessThanOrEqualTo: widthAnchor, multiplier: 0.8)
        ])
    }
    
    private func loadAnimation() {
        let animationName: String = traitCollection.userInterfaceStyle == .dark
        ? Constants.animations.plane
        : Constants.animations.jetPack
        
        guard
            let animationURL = Bundle.main.url(forResource: animationName, withExtension: "json"),
            let animation = LottieAnimation.filepath(animationURL.path)
        else {
            assertionFailure("Could not load animation '\(animationName).json'")
            return
        }
        animationView.animation = animation
        animationView.play()
        loadBackgroundAnimation()
    }
    
    private func loadBackgroundAnimation() {
        let backgroundName: String = traitCollection.userInterfaceStyle == .dark
            ? Constants.animations.nightSky
            : Constants.animations.clouds
        
        guard
            let bgURL = Bundle.main.url(forResource: backgroundName, withExtension: "json"),
            let bgAnimation = LottieAnimation.filepath(bgURL.path)
        else {
            assertionFailure("Could not load background animation '\(backgroundName).json'")
            return
        }
        backgroundAnimationView.animation = bgAnimation
        backgroundAnimationView.play()
    }
    
    func animateIn() {
        self.transform = CGAffineTransform(translationX: UIScreen.main.bounds.width, y: 0)
        self.alpha = 0

        UIView.animate(
            withDuration: 0.6,
            delay: 0,
            usingSpringWithDamping: 0.85,
            initialSpringVelocity: 0.5,
            options: [.curveEaseOut]
        ) { [weak self] in
            self?.transform = .identity
            self?.alpha = 1
            self?.backgroundAnimationView.play()
            self?.animationView.play()
            self?.startMessageCycle()
            
            UIView.animate(withDuration: 0.5,
                           delay: 0.1,
                           usingSpringWithDamping: 0.8,
                           initialSpringVelocity: 0.5) {
                self?.animationView.alpha = 1
                self?.animationView.transform = .identity
            }
        }
    }
    
    // MARK: - Message Cycle
    private func startMessageCycle() {
        updateMessage()

        messageTimer = Timer.scheduledTimer(withTimeInterval: 2.2, repeats: true) { [weak self] _ in
            self?.updateMessage()
        }
    }

    private func updateMessage() {
        UIView.animate(withDuration: 0.3, animations: {
            self.messageLabel.transform = CGAffineTransform(translationX: 0, y: -10)
            self.messageLabel.alpha = 0
        }) { _ in
            self.messageLabel.text = self.messages[self.currentMessageIndex]
            self.currentMessageIndex = (self.currentMessageIndex + 1) % self.messages.count
            
            self.messageLabel.transform = CGAffineTransform(translationX: 0, y: 10)
            
            UIView.animate(withDuration: 0.3) {
                self.messageLabel.transform = .identity
                self.messageLabel.alpha = 1
            }
        }
    }
    
    // MARK: - Dismiss
    func dismiss() {
        messageTimer?.invalidate()
        messageTimer = nil

        animationView.stop()
        backgroundAnimationView.stop()

        UIView.animate(
            withDuration: 1,
            delay: 0,
            usingSpringWithDamping: 1,
            initialSpringVelocity: 0.5,
            options: [.curveEaseIn],
            animations: {
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                self.transform = CGAffineTransform(translationX: 0, y: -self.frame.height)
                self.alpha = 0
            },
            completion: { _ in
                self.removeFromSuperview()
            }
        )
    }
}

// MARK: - Dark Mode Support
extension LoadingOverlayView {
    func registerTraitChangeHandler() {
        registerForTraitChanges([UITraitUserInterfaceStyle.self], action: #selector(onUserInterfaceStyleChanged))
    }

    @objc private func onUserInterfaceStyleChanged() {
        loadAnimation()
    }
}

#Preview {
    LoadingOverlayView()
}
