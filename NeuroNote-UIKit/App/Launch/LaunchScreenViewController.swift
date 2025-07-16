//
//  LaunchScreenViewController.swift
//  NeuroNote
//
//  Created by Eclipse on 28/06/25.
//

import UIKit

class LaunchScreenViewController: UIViewController {

    // MARK: - Subviews
    private let containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .black
        return view
    }()

    private let logoImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: Constants.LaunchScreenConstants.logoImageName))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.alpha = 0
        return imageView
    }()
    

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        buildHierarchy()
        setupConstraints()
        animateLaunch()
    }

    // MARK: - Private helpers
    private func buildHierarchy() {
        view.addSubview(containerView)
        containerView.addSubview(logoImageView)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // ContainerView Constraints
            containerView.topAnchor.constraint(equalTo: view.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            // LogoImage Constraints
            logoImageView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            logoImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            logoImageView.widthAnchor.constraint(equalToConstant: view.bounds.width/4),
            logoImageView.heightAnchor.constraint(equalTo: logoImageView.widthAnchor)
        ])
    }

    private func animateLaunch() {
        UIView.animate(withDuration: 0.8,
                       delay: 0,
                       options: [.curveEaseOut],
                       animations: {
            self.logoImageView.alpha = 1
            self.logoImageView.transform = CGAffineTransform(
                scaleX: 1.5,
                y: 1.5
            )
        },
            completion: { _ in
            UIView.animate(withDuration: 0.3,
                           animations: {
                self.logoImageView.transform = .identity
            }, completion: { _ in
                self.transitionToApp()
            })
        })
    }

    private func transitionToApp() {
        let loginVC      = LoginViewController()
        let navController = UINavigationController(rootViewController: loginVC)
        navController.modalPresentationStyle = .fullScreen
        navController.modalTransitionStyle   = .coverVertical
        present(navController, animated: true)
    }
}

#Preview { LaunchScreenViewController() }
