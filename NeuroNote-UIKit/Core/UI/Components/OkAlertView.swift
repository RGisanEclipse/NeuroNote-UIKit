//
//  LoginAlertView.swift
//  NeuroNote
//
//  Created by Eclipse on 29/06/25.
//

import UIKit
import Lottie

class OkAlertView: UIView {
    
    // MARK: - Subviews
    private let dimBackground = UIView()
    private let alertBox = UIView()
    private let badgeAnimationView = LottieAnimationView()
    private let titleLabel = UILabel()
    private let messageLabel = UILabel()
    private let okButton = UIButton(type: .system)
    
    // MARK: - Init
    init(title: String,
         message: String,
         isError: Bool,
         icon: String) {
        
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        
        setupDimBackground()
        setupAlertBox()
        setupBadge(with: icon)
        setupTitle(title, isError)
        setupMessage(message)
        setupButton(isError)
        setupLayout()
        animateIn()
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    // MARK: - Component builders
    private func setupDimBackground() {
        dimBackground.backgroundColor = UIColor.black.withAlphaComponent(0.2)
        dimBackground.translatesAutoresizingMaskIntoConstraints = false
        addSubview(dimBackground)
        NSLayoutConstraint.activate([
            dimBackground.topAnchor.constraint(equalTo: topAnchor),
            dimBackground.bottomAnchor.constraint(equalTo: bottomAnchor),
            dimBackground.leadingAnchor.constraint(equalTo: leadingAnchor),
            dimBackground.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }
    
    private func setupAlertBox() {
        alertBox.translatesAutoresizingMaskIntoConstraints = false
        alertBox.backgroundColor = .white
        alertBox.layer.cornerRadius = 20
        alertBox.alpha = 0
        alertBox.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        addSubview(alertBox)
    }
    
    private func setupBadge(with icon: String) {
        guard
            let url = Bundle.main.url(forResource: icon, withExtension: "json"),
            let animation = LottieAnimation.filepath(url.path)
        else {
            assertionFailure("Could not load resource")
            return
        }

        badgeAnimationView.animation          = animation
        badgeAnimationView.translatesAutoresizingMaskIntoConstraints = false
        badgeAnimationView.contentMode        = .scaleAspectFit
        badgeAnimationView.loopMode           = .loop
        badgeAnimationView.backgroundBehavior = .pauseAndRestore
        badgeAnimationView.alpha              = 0
        badgeAnimationView.transform          = CGAffineTransform(scaleX: 0.8, y: 0.8)

        addSubview(badgeAnimationView)
    }
    
    private func setupTitle(_ text: String, _ isError: Bool) {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = text
        titleLabel.font = UIFont(name: Fonts.MontserratSemiBold, size: 18) ?? .boldSystemFont(ofSize: 18)
        titleLabel.textColor = isError ? .systemRed : .systemPurple
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0
        alertBox.addSubview(titleLabel)
    }
    
    private func setupMessage(_ text: String) {
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.text = text
        messageLabel.font = UIFont(name: Fonts.MontserratRegular, size: 16) ?? .systemFont(ofSize: 16)
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .center
        messageLabel.textColor = .black
        alertBox.addSubview(messageLabel)
    }
    
    private func setupButton(_ isError: Bool) {
        okButton.translatesAutoresizingMaskIntoConstraints = false
        okButton.setTitle("OK", for: .normal)
        okButton.setTitleColor(.white, for: .normal)
        okButton.backgroundColor = isError ? .systemRed : .systemPurple
        okButton.layer.cornerRadius = 10
        okButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        okButton.addTarget(self, action: #selector(dismissSelf), for: .touchUpInside)
        alertBox.addSubview(okButton)
    }
    
    // MARK: - Layout
    private func setupLayout() {
        NSLayoutConstraint.activate([
            alertBox.centerYAnchor.constraint(equalTo: centerYAnchor),
            alertBox.centerXAnchor.constraint(equalTo: centerXAnchor),
            alertBox.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.8),
            
            // Badge overlaps top-left
            badgeAnimationView.widthAnchor.constraint(equalToConstant: 60),
            badgeAnimationView.heightAnchor.constraint(equalTo: badgeAnimationView.widthAnchor),
            badgeAnimationView.leadingAnchor.constraint(equalTo: alertBox.leadingAnchor, constant: -15),
            badgeAnimationView.topAnchor.constraint(equalTo: alertBox.topAnchor, constant: -28),
            
            // Title / message / button
            titleLabel.topAnchor.constraint(equalTo: alertBox.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: alertBox.leadingAnchor, constant: 40),
            titleLabel.trailingAnchor.constraint(equalTo: alertBox.trailingAnchor, constant: -40),
            
            messageLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            messageLabel.leadingAnchor.constraint(equalTo: alertBox.leadingAnchor, constant: 20),
            messageLabel.trailingAnchor.constraint(equalTo: alertBox.trailingAnchor, constant: -20),
            
            okButton.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 20),
            okButton.bottomAnchor.constraint(equalTo: alertBox.bottomAnchor, constant: -20),
            okButton.centerXAnchor.constraint(equalTo: alertBox.centerXAnchor),
            okButton.widthAnchor.constraint(equalToConstant: 80),
            okButton.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    // MARK: - Animations
    private func animateIn() {
        UIView.animate(withDuration: 0.5,
                       delay: 0,
                       usingSpringWithDamping: 0.8,
                       initialSpringVelocity: 0.6,
                       options: .curveEaseInOut) {
            self.alertBox.alpha = 1
            self.alertBox.transform = .identity
            self.badgeAnimationView.alpha = 1
            self.badgeAnimationView.transform = .identity
        } completion: { _ in
            self.badgeAnimationView.play()
        }
    }
    
    @objc private func dismissSelf() {
        UIView.animate(withDuration: 0.2, animations: {
            self.alertBox.alpha = 0
            self.alpha = 0
        }) { _ in
            self.removeFromSuperview()
        }
    }
}
#Preview{
    OkAlertView(title: "Alert",
                message: "Message",
                isError: false,
                icon: "birdie-success"
    )
}
