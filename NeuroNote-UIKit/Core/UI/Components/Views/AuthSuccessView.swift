//
//  AuthSuccessView.swift
//  NeuroNote-UIKit
//
//  Created by Eclipse on 19/07/25.
//

import UIKit
import Lottie

class AuthSuccessView: UIView {
    var onAnimationCompletion: (() -> Void)?
    // MARK: - Subviews
    private let animationView: LottieAnimationView = {
        let view = LottieAnimationView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.contentMode = .scaleAspectFit
        view.loopMode = .playOnce
        view.backgroundBehavior = .pauseAndRestore
        view.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        return view
    }()
    
    private let messageLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Entry Granted"
        label.numberOfLines = 0
        label.font = UIFont(
            name: Fonts.BeachDay,
            size: 30
        ) ?? UIFont.systemFont(ofSize: 30, weight: .medium)
        label.textColor = .white
        label.alpha = 0
        label.textAlignment = .center
        return label
    }()
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        animateInAndPlay()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
        animateInAndPlay()
    }

    // MARK: - Setup View
    private func setupView() {
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .clear

        // Blur Effect
        let blurEffect = UIBlurEffect(style: .systemThinMaterialDark)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.translatesAutoresizingMaskIntoConstraints = false
        insertSubview(blurView, at: 0)

        NSLayoutConstraint.activate([
            blurView.leadingAnchor.constraint(equalTo: leadingAnchor),
            blurView.trailingAnchor.constraint(equalTo: trailingAnchor),
            blurView.topAnchor.constraint(equalTo: topAnchor),
            blurView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])

        addSubview(animationView)
        addSubview(messageLabel)
        setupConstraints()
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            animationView.centerXAnchor.constraint(equalTo: centerXAnchor),
            animationView.centerYAnchor.constraint(equalTo: centerYAnchor),
            animationView.widthAnchor.constraint(equalToConstant: 200),
            animationView.heightAnchor.constraint(equalToConstant: 200),
            
            messageLabel.topAnchor.constraint(
                equalTo: animationView.bottomAnchor,
                constant: 24
            ),
            messageLabel.centerXAnchor.constraint(equalTo: centerXAnchor)
        ])
    }

    // MARK: - Animate In and Play
    private func animateInAndPlay() {
        self.transform = CGAffineTransform(translationX: UIScreen.main.bounds.width, y: 0)
        self.alpha = 0

        UIView.animate(
            withDuration: 0.4,
            delay: 0,
            options: [.curveEaseOut],
            animations: { [weak self] in
                self?.transform = .identity
                self?.alpha = 1
            },
            completion: { [weak self] _ in
                self?.loadAndPlayAnimation()
            }
        )
    }

    // MARK: - AnimationView Logic
    private func loadAndPlayAnimation() {
        let animationName = "lock-success"
        
        guard
            let animationURL = Bundle.main.url(forResource: animationName, withExtension: "json"),
            let animation = LottieAnimation.filepath(animationURL.path)
        else {
            assertionFailure("Could not load animation '\(animationName).json'")
            return
        }
        
        animationView.animation = animation
        
        let frameToChangeColor = 77.0
        let durationToFrame = TimeInterval(frameToChangeColor / 30)
        
        animationView.play { [weak self] _ in
            self?.onAnimationCompletion?()
            self?.dismiss()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + durationToFrame) { [weak self] in
            guard let self = self else { return }
            UIView.animate(withDuration: 0.3) {
                self.backgroundColor = UIColor(red: 0.0, green: 0.52, blue: 0.31, alpha: 1.0)
            }
            UIView.animate(
                    withDuration: 0.6,
                    delay: 0.15,
                    options: [.curveEaseOut],
                    animations: {
                        self.messageLabel.alpha = 1
                        self.messageLabel.transform = CGAffineTransform(translationX: 0, y: -8)
                    },
                    completion: nil
                )
        }
    }

    // MARK: - Dismiss Logic
    func dismiss() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            UIView.animate(
                withDuration: 0.8,
                delay: 0,
                usingSpringWithDamping: 1,
                initialSpringVelocity: 0.5,
                options: [.curveEaseIn],
                animations: {
                    self.transform = CGAffineTransform(translationX: 0, y: -self.frame.height)
                    self.alpha = 0
                },
                completion: { _ in
                    self.removeFromSuperview()
                }
            )
        }
    }
}

#Preview{
    AuthSuccessView()
}
