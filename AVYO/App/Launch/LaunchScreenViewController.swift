//
//  LaunchScreenViewController.swift
//  AVYO
//
//  Created by Eclipse on 28/06/25.
//

import UIKit
import Lottie

class LaunchScreenViewController: UIViewController {

    // MARK: - State
    private var animationDidFinish = false
    private var minimumTimeElapsed = false
    private var starsAdded = false

    // MARK: - Layers
    private let glowLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.type = .radial
        layer.colors = [
            UIColor(red: 0.50, green: 0.25, blue: 0.90, alpha: 0.30).cgColor,
            UIColor(red: 0.50, green: 0.25, blue: 0.90, alpha: 0.0).cgColor
        ]
        layer.startPoint = CGPoint(x: 0.5, y: 0.5)
        layer.endPoint   = CGPoint(x: 1.0, y: 1.0)
        return layer
    }()

    // MARK: - Subviews
    private let alienView: LottieAnimationView = {
        let view = LottieAnimationView(name: Constants.animations.happyAlien)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.contentMode = .scaleAspectFit
        view.loopMode = .playOnce
        view.backgroundBehavior = .pauseAndRestore
        view.isUserInteractionEnabled = false
        view.alpha = 0
        view.animationSpeed = 1.5
        return view
    }()

    private let appNameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "AVYO"
        label.textColor = .white
        label.font = UIFont(name: Fonts.MontserratBlack, size: 46) ?? .systemFont(ofSize: 46, weight: .black)
        label.textAlignment = .center
        label.alpha = 0
        return label
    }()

    private let taglineLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "A Vibe You Own"
        label.textColor = UIColor(white: 1.0, alpha: 0.55)
        label.font = UIFont(name: Fonts.MontserratRegular, size: 15) ?? .systemFont(ofSize: 15)
        label.textAlignment = .center
        label.alpha = 0
        return label
    }()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 0.173, green: 0.122, blue: 0.271, alpha: 1.0)
        view.layer.addSublayer(glowLayer)
        buildHierarchy()
        setupConstraints()
        prepareInitialState()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let glowSize = view.bounds.width * 0.85
        glowLayer.frame = CGRect(
            x: (view.bounds.width - glowSize) / 2,
            y: view.bounds.midY - 44 - glowSize / 2,
            width: glowSize,
            height: glowSize
        )
        guard !starsAdded else { return }
        starsAdded = true
        addStars()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        animateLaunch()
    }

    // MARK: - Private helpers
    private func addStars() {
        for _ in 0..<140 {
            let star = CALayer()
            let size = CGFloat.random(in: 0.8...2.2)
            star.frame = CGRect(
                x: CGFloat.random(in: 0...view.bounds.width),
                y: CGFloat.random(in: 0...view.bounds.height),
                width: size,
                height: size
            )
            star.cornerRadius = size / 2
            star.backgroundColor = UIColor.white.withAlphaComponent(
                CGFloat.random(in: 0.15...0.6)
            ).cgColor
            view.layer.insertSublayer(star, below: glowLayer)
        }
    }

    private func buildHierarchy() {
        view.addSubview(alienView)
        view.addSubview(appNameLabel)
        view.addSubview(taglineLabel)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            alienView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            alienView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -44),
            alienView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.6),
            alienView.heightAnchor.constraint(equalTo: alienView.widthAnchor),

            appNameLabel.topAnchor.constraint(equalTo: alienView.bottomAnchor, constant: 12),
            appNameLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            taglineLabel.topAnchor.constraint(equalTo: appNameLabel.bottomAnchor, constant: 6),
            taglineLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        ])
    }

    private func prepareInitialState() {
        let slideOffset = CGAffineTransform(translationX: 0, y: 20)
        appNameLabel.transform = slideOffset
        taglineLabel.transform = slideOffset
    }

    private func animateLaunch() {
        UIView.animate(withDuration: 0.4, delay: 0.1, options: [.curveEaseOut]) { [weak self] in
            self?.alienView.alpha = 1
        }

        UIView.animate(
            withDuration: 0.55, delay: 0.35,
            usingSpringWithDamping: 0.78, initialSpringVelocity: 0.3, options: []
        ) { [weak self] in
            self?.appNameLabel.alpha = 1
            self?.appNameLabel.transform = .identity
        }

        UIView.animate(
            withDuration: 0.55, delay: 0.52,
            usingSpringWithDamping: 0.78, initialSpringVelocity: 0.3, options: []
        ) { [weak self] in
            self?.taglineLabel.alpha = 1
            self?.taglineLabel.transform = .identity
        }

        alienView.play { [weak self] _ in
            self?.animationDidFinish = true
            if self?.minimumTimeElapsed == true { self?.transitionToApp() }
        }

        DispatchQueue.main.async { [weak self] in
            self?.minimumTimeElapsed = true
            if self?.animationDidFinish == true { self?.transitionToApp() }
        }
    }

    private func transitionToApp() {
        let rootVC: UIViewController
        if KeychainHelper.standard.getRefreshToken() != nil {
            rootVC = DashboardTabBarController()
        } else {
            let loginVC = LoginViewController()
            rootVC = UINavigationController(rootViewController: loginVC)
        }
        rootVC.modalPresentationStyle = .fullScreen
        rootVC.modalTransitionStyle = .coverVertical
        present(rootVC, animated: true)
    }
}

#Preview { LaunchScreenViewController() }
