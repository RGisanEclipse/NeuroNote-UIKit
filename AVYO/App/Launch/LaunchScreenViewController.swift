//
//  LaunchScreenViewController.swift
//  AVYO
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
                       animations: { [weak self] in
            guard let self = self else { return }
            self.logoImageView.alpha = 1
            self.logoImageView.transform = CGAffineTransform(
                scaleX: 1.5,
                y: 1.5
            )
        },
            completion: { _ in
            UIView.animate(withDuration: 0.3,
                           animations: { [weak self] in
                guard let self = self else { return }
                self.logoImageView.transform = .identity
            }, completion: { [weak self] _ in
                guard let self = self else { return }
                self.transitionToApp()
            })
        })
    }

    private func transitionToApp() {
        let rootVC: UIViewController
        
        // Check if user has a valid session (refresh token exists)
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
