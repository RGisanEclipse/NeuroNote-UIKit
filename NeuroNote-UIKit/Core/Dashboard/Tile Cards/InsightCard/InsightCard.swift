//
//  InsightCard.swift
//  NeuroNote-UIKit
//

import UIKit
import Lottie

final class InsightCard: UIView {
    
    // MARK: - Callback
    
    var onTap: (() -> Void)?
    
    // MARK: - UI Components
    
    private lazy var containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 16
        view.clipsToBounds = true
        return view
    }()
    
    private lazy var overlayAnimationView: LottieAnimationView = {
        let view = LottieAnimationView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.contentMode = .scaleAspectFill
        view.loopMode = .playOnce
        view.backgroundBehavior = .pauseAndRestore
        view.isUserInteractionEnabled = false
        view.alpha = 0
        // Prevent animation from affecting card layout
        view.setContentHuggingPriority(.defaultLow, for: .horizontal)
        view.setContentHuggingPriority(.defaultLow, for: .vertical)
        view.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        view.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        return view
    }()
    
    private lazy var mainTextLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: Fonts.MontserratBold, size: 20) ?? .boldSystemFont(ofSize: 20)
        label.textColor = .white
        label.textAlignment = .left
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        return label
    }()
    
    private lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: Fonts.MontserratMedium, size: 13) ?? .systemFont(ofSize: 13, weight: .medium)
        label.textColor = UIColor.white.withAlphaComponent(0.75)
        label.textAlignment = .left
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var contentStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [mainTextLabel, subtitleLabel])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 8
        stack.alignment = .fill
        return stack
    }()
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupGesture()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
        setupGesture()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        addSubview(containerView)
        containerView.addSubview(contentStack)
        containerView.addSubview(overlayAnimationView)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            contentStack.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            contentStack.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            contentStack.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            contentStack.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -16),
            
            overlayAnimationView.topAnchor.constraint(equalTo: containerView.topAnchor),
            overlayAnimationView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            overlayAnimationView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            overlayAnimationView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
        ])
    }
    
    private func setupGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        containerView.addGestureRecognizer(tapGesture)
        containerView.isUserInteractionEnabled = true
    }
    
    // MARK: - Actions
    
    @objc private func handleTap() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        
        UIView.animate(withDuration: 0.1, animations: {
            self.containerView.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                self.containerView.transform = .identity
            } completion: { _ in
                self.onTap?()
            }
        }
    }
    
    // MARK: - Public Configuration
    
    func configure(
        text: String,
        subtitle: String? = nil,
        backgroundColor: UIColor,
        onTap: (() -> Void)? = nil
    ) {
        mainTextLabel.text = text
        subtitleLabel.text = subtitle
        subtitleLabel.isHidden = subtitle == nil
        containerView.backgroundColor = backgroundColor
        self.onTap = onTap
    }
    
    // MARK: - Overlay Animation
    
    /// Plays a one-time Lottie animation overlay on the card
    /// - Parameter animationName: The name of the Lottie JSON file (without extension)
    func playOverlayAnimation(named animationName: String) {
        guard let animation = LottieAnimation.named(animationName) else { return }
        
        overlayAnimationView.animation = animation
        overlayAnimationView.alpha = 1
        overlayAnimationView.play { [weak self] _ in
            self?.overlayAnimationView.alpha = 0
        }
    }
}
