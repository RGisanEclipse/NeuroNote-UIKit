//
//  OkAlertView.swift
//  NeuroNote
//
//  Created by Eclipse on 29/06/25.
//

import UIKit
import Lottie

class OkAlertView: UIView {
    
    // MARK: - Subviews
    
    private let dimBackground: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.black.withAlphaComponent(0.2)
        return view
    }()
    
    private let alertBox: UIVisualEffectView = {
        let blur = UIBlurEffect(style: .systemUltraThinMaterialLight)
        let view = UIVisualEffectView(effect: blur)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 20
        view.clipsToBounds = true
        view.alpha = 0
        view.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.white.withAlphaComponent(0.20).cgColor
        return view
    }()
    
    private let badgeAnimationView: LottieAnimationView = {
        let view = LottieAnimationView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.contentMode = .scaleAspectFit
        view.loopMode = .loop
        view.backgroundBehavior = .pauseAndRestore
        view.alpha = 0
        view.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: Fonts.MontserratSemiBold, size: 18) ?? .boldSystemFont(ofSize: 18)
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    private let messageLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: Fonts.MontserratRegular, size: 16) ?? .systemFont(ofSize: 16)
        label.numberOfLines = 0
        label.textAlignment = .center
        label.textColor = .black
        return label
    }()
    
    private var okButton: GradientButton!

    // MARK: - Init
    
    init(title: String,
         message: String,
         isError: Bool,
         icon: String) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        
        titleLabel.text = title
        titleLabel.textColor = isError ? .systemRed : .systemPurple
        messageLabel.text = message
        
        configureAnimation(named: icon)
        configureButton(isError: isError)
        
        buildHierarchy()
        setupLayout()
        animateIn()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Configuration
    
    private func configureAnimation(named icon: String) {
        guard
            let url = Bundle.main.url(forResource: icon, withExtension: "json"),
            let animation = LottieAnimation.filepath(url.path)
        else {
            assertionFailure("Could not load resource: \(icon)")
            return
        }
        badgeAnimationView.animation = animation
    }
    
    private func configureButton(isError: Bool) {
        okButton = GradientButton(
            title: "OK",
            leadingColor: isError ?
                UIColor(red: 0.93, green: 0.32, blue: 0.29, alpha: 1.0).cgColor :
                UIColor(red: 0.67, green: 0.51, blue: 0.96, alpha: 1.0).cgColor,
            trailingColor: isError ?
                UIColor(red: 0.73, green: 0.11, blue: 0.14, alpha: 1.0).cgColor :
                UIColor(red: 0.44, green: 0.16, blue: 0.94, alpha: 1.0).cgColor   
        )
        okButton.translatesAutoresizingMaskIntoConstraints = false
        okButton.layer.cornerRadius = 10
        okButton.titleLabel?.font = UIFont(name: Fonts.BeachDay, size: 20) ?? .systemFont(ofSize: 20, weight: .medium)
        okButton.addTarget(self, action: #selector(dismissSelf), for: .touchUpInside)
    }

    // MARK: - Build View

    private func buildHierarchy() {
        addSubview(dimBackground)
        addSubview(alertBox)
        addSubview(badgeAnimationView)
        
        [titleLabel, messageLabel, okButton].forEach {
            alertBox.contentView.addSubview($0)
        }
    }
    
    private func setupLayout() {
        NSLayoutConstraint.activate([
            dimBackground.topAnchor.constraint(equalTo: topAnchor),
            dimBackground.bottomAnchor.constraint(equalTo: bottomAnchor),
            dimBackground.leadingAnchor.constraint(equalTo: leadingAnchor),
            dimBackground.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            alertBox.centerYAnchor.constraint(equalTo: centerYAnchor),
            alertBox.centerXAnchor.constraint(equalTo: centerXAnchor),
            alertBox.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.8),
            
            badgeAnimationView.widthAnchor.constraint(equalToConstant: 60),
            badgeAnimationView.heightAnchor.constraint(equalTo: badgeAnimationView.widthAnchor),
            badgeAnimationView.leadingAnchor.constraint(equalTo: alertBox.leadingAnchor, constant: -15),
            badgeAnimationView.topAnchor.constraint(equalTo: alertBox.topAnchor, constant: -28),
            
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
