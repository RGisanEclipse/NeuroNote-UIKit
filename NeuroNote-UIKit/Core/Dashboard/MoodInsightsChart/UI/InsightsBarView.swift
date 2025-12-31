//
//  InsightsBarView.swift
//  NeuroNote-UIKit
//
//  Created by Eclipse on 31/12/25.
//

import UIKit

class InsightsBarView: UIView {
    
    // MARK: - Configuration
    
    struct Configuration {
        let icon: UIImage?
        let fillColor: UIColor
        let percentage: CGFloat // 0.0 to 1.0
        let trackColor: UIColor
        let barHeight: CGFloat
        let iconSize: CGFloat
        
        init(
            icon: UIImage?,
            fillColor: UIColor,
            percentage: CGFloat,
            trackColor: UIColor = UIColor.systemGray5,
            barHeight: CGFloat = 20,
            iconSize: CGFloat = 32
        ) {
            self.icon = icon
            self.fillColor = fillColor
            self.percentage = min(max(percentage, 0), 1) // Clamp between 0 and 1
            self.trackColor = trackColor
            self.barHeight = barHeight
            self.iconSize = iconSize
        }
    }
    
    // MARK: - UI Elements
    
    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let trackView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.clipsToBounds = true
        return view
    }()
    
    private let fillView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // MARK: - Properties
    
    private var fillWidthConstraint: NSLayoutConstraint?
    private var configuration: Configuration?
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }
    
    convenience init(configuration: Configuration) {
        self.init(frame: .zero)
        configure(with: configuration)
    }
    
    // MARK: - Setup
    
    private func setupViews() {
        addSubview(iconImageView)
        addSubview(trackView)
        trackView.addSubview(fillView)
        
        NSLayoutConstraint.activate([
            iconImageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            iconImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 32),
            iconImageView.heightAnchor.constraint(equalToConstant: 32),
            
            trackView.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 10),
            trackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            trackView.centerYAnchor.constraint(equalTo: centerYAnchor),
            trackView.heightAnchor.constraint(equalToConstant: 20),
            
            fillView.leadingAnchor.constraint(equalTo: trackView.leadingAnchor),
            fillView.topAnchor.constraint(equalTo: trackView.topAnchor),
            fillView.bottomAnchor.constraint(equalTo: trackView.bottomAnchor)
        ])
        
        fillWidthConstraint = fillView.widthAnchor.constraint(equalToConstant: 0)
        fillWidthConstraint?.isActive = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let barHeight = configuration?.barHeight ?? 20
        trackView.layer.cornerRadius = barHeight / 2
        fillView.layer.cornerRadius = barHeight / 2
        
        updateFillWidth()
    }
    
    // MARK: - Configuration
    
    func configure(with configuration: Configuration) {
        self.configuration = configuration
        
        iconImageView.image = configuration.icon
        trackView.backgroundColor = configuration.trackColor
        fillView.backgroundColor = configuration.fillColor
        
        // Update size constraints
        iconImageView.constraints.forEach { constraint in
            if constraint.firstAttribute == .width || constraint.firstAttribute == .height {
                constraint.constant = configuration.iconSize
            }
        }
        
        trackView.constraints.forEach { constraint in
            if constraint.firstAttribute == .height {
                constraint.constant = configuration.barHeight
            }
        }
        
        setNeedsLayout()
    }
    
    private func updateFillWidth() {
        guard let configuration = configuration else { return }
        let availableWidth = trackView.bounds.width
        let fillWidth = availableWidth * configuration.percentage
        fillWidthConstraint?.constant = fillWidth
    }
    
    // MARK: - Animation
    
    /// Simple fill animation with spring
    func animateFill(duration: TimeInterval = 0.6, delay: TimeInterval = 0) {
        fillWidthConstraint?.constant = 0
        layoutIfNeeded()
        
        UIView.animate(
            withDuration: duration,
            delay: delay,
            usingSpringWithDamping: 0.8,
            initialSpringVelocity: 0.5,
            options: .curveEaseOut
        ) { [weak self] in
            self?.updateFillWidth()
            self?.layoutIfNeeded()
        }
    }
    
    /// Overshoot animation: fills to 100%, then bounces back to actual value
    func animateWithOvershoot(delay: TimeInterval = 0) {
        guard let configuration = configuration else { return }
        
        let availableWidth = trackView.bounds.width
        let targetWidth = availableWidth * configuration.percentage
        
        // Start from zero
        fillWidthConstraint?.constant = 0
        layoutIfNeeded()
        
        // Phase 1: Fill to 100%
        UIView.animate(
            withDuration: 0.5,
            delay: delay,
            options: .curveEaseOut
        ) { [weak self] in
            self?.fillWidthConstraint?.constant = availableWidth
            self?.layoutIfNeeded()
        } completion: { [weak self] _ in
            // Phase 2: Bounce back to actual value
            UIView.animate(
                withDuration: 0.6,
                delay: 0.05,
                usingSpringWithDamping: 0.5,
                initialSpringVelocity: 0.8,
                options: .curveEaseInOut
            ) {
                self?.fillWidthConstraint?.constant = targetWidth
                self?.layoutIfNeeded()
            }
        }
    }
    
    // MARK: - Update
    
    func updatePercentage(_ percentage: CGFloat, animated: Bool = true) {
        guard var config = configuration else { return }
        config = Configuration(
            icon: config.icon,
            fillColor: config.fillColor,
            percentage: percentage,
            trackColor: config.trackColor,
            barHeight: config.barHeight,
            iconSize: config.iconSize
        )
        self.configuration = config
        
        if animated {
            animateFill(duration: 0.4)
        } else {
            updateFillWidth()
        }
    }
}

// MARK: - Preview

#Preview {
    let container = UIView()
    container.backgroundColor = .white
    
    let stack = UIStackView()
    stack.axis = .vertical
    stack.spacing = 16
    stack.translatesAutoresizingMaskIntoConstraints = false
    
    let happyBar = InsightsBarView(configuration: .init(
        icon: UIImage(systemName: "face.smiling.fill"),
        fillColor: UIColor(red: 0.95, green: 0.9, blue: 0.4, alpha: 1.0),
        percentage: 0.7
    ))
    happyBar.translatesAutoresizingMaskIntoConstraints = false
    happyBar.heightAnchor.constraint(equalToConstant: 36).isActive = true
    
    let disgustBar = InsightsBarView(configuration: .init(
        icon: UIImage(systemName: "face.smiling.fill"),
        fillColor: UIColor(red: 0.7, green: 0.85, blue: 0.65, alpha: 1.0),
        percentage: 0.35
    ))
    disgustBar.translatesAutoresizingMaskIntoConstraints = false
    disgustBar.heightAnchor.constraint(equalToConstant: 36).isActive = true
    
    let sadBar = InsightsBarView(configuration: .init(
        icon: UIImage(systemName: "face.smiling.fill"),
        fillColor: UIColor(red: 0.55, green: 0.8, blue: 0.85, alpha: 1.0),
        percentage: 0.5
    ))
    sadBar.translatesAutoresizingMaskIntoConstraints = false
    sadBar.heightAnchor.constraint(equalToConstant: 36).isActive = true
    
    stack.addArrangedSubview(happyBar)
    stack.addArrangedSubview(disgustBar)
    stack.addArrangedSubview(sadBar)
    
    container.addSubview(stack)
    NSLayoutConstraint.activate([
        stack.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 20),
        stack.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -20),
        stack.centerYAnchor.constraint(equalTo: container.centerYAnchor)
    ])
    
    return container
}
