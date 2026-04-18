//
//  ClearButton.swift
//  AVYO
//
//  Created by Eclipse on 11/10/25.
//

import UIKit

final class ClearButton: UIButton {

    private var originalTitle: String?
    private var activityIndicator: UIActivityIndicatorView?

    // MARK: - Initializers
    init(
        title: String,
        titleColor: UIColor = .white,
        font: UIFont = UIFont(name: Fonts.MontserratMedium, size: 16)
            ?? .systemFont(ofSize: 16, weight: .semibold),
        backgroundColor: UIColor = UIColor.white.withAlphaComponent(0.1),
        borderColor: UIColor = UIColor.white.withAlphaComponent(0.25)
    ) {

        super.init(frame: .zero)

        setTitle(title, for: .normal)
        originalTitle = title
        setTitleColor(titleColor, for: .normal)
        titleLabel?.font = font
        self.backgroundColor = backgroundColor
        layer.cornerRadius = 10
        clipsToBounds = true

        layer.borderWidth = 1
        layer.borderColor = borderColor.cgColor

        translatesAutoresizingMaskIntoConstraints = false
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setLoading(_ isLoading: Bool) {
        if isLoading {
            guard activityIndicator == nil else { return }

            isEnabled = false
            setTitle(Constants.empty, for: .normal)

            let spinner = UIActivityIndicatorView(style: .medium)
            spinner.color = .white
            spinner.translatesAutoresizingMaskIntoConstraints = false
            addSubview(spinner)

            NSLayoutConstraint.activate([
                spinner.centerXAnchor.constraint(equalTo: centerXAnchor),
                spinner.centerYAnchor.constraint(equalTo: centerYAnchor),
            ])

            spinner.startAnimating()
            activityIndicator = spinner
        } else {
            isEnabled = true
            setTitle(originalTitle, for: .normal)

            activityIndicator?.stopAnimating()
            activityIndicator?.removeFromSuperview()
            activityIndicator = nil
        }
    }
}
