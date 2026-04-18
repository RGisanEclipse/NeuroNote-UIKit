//
//  LottieCard.swift
//  AVYO
//

import UIKit
import Lottie

final class LottieCard: UIView {
    
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
    
    private lazy var topLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: Fonts.MontserratSemiBold, size: 14) ?? .systemFont(ofSize: 14, weight: .semibold)
        label.textColor = .label
        label.textAlignment = .center
        label.numberOfLines = 2
        return label
    }()
    
    private lazy var lottieView: LottieAnimationView = {
        let view = LottieAnimationView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.contentMode = .scaleAspectFit
        view.loopMode = .loop
        view.backgroundBehavior = .pauseAndRestore
        view.isUserInteractionEnabled = false
        return view
    }()
    
    private lazy var bottomLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: Fonts.MontserratMedium, size: 12) ?? .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.setContentCompressionResistancePriority(.required, for: .vertical)
        return label
    }()
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupGesture()
        registerForTraitChanges()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
        setupGesture()
        registerForTraitChanges()
    }
    
    private func registerForTraitChanges() {
        registerForTraitChanges([UITraitUserInterfaceStyle.self]) { [weak self] (traitEnvironment: Self, previousTraitCollection: UITraitCollection) in
            self?.updateAppearance()
        }
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        addSubview(containerView)
        containerView.addSubview(topLabel)
        containerView.addSubview(lottieView)
        containerView.addSubview(bottomLabel)
        
        updateAppearance()
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            topLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            topLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            topLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            
            lottieView.topAnchor.constraint(equalTo: topLabel.bottomAnchor, constant: 8),
            lottieView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            lottieView.widthAnchor.constraint(equalToConstant: 70),
            lottieView.heightAnchor.constraint(equalToConstant: 70),
            
            bottomLabel.topAnchor.constraint(equalTo: lottieView.bottomAnchor, constant: 8),
            bottomLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            bottomLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            bottomLabel.bottomAnchor.constraint(lessThanOrEqualTo: containerView.bottomAnchor, constant: -12),
        ])
    }
    
    private func setupGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        containerView.addGestureRecognizer(tapGesture)
        containerView.isUserInteractionEnabled = true
    }
    
    private func updateAppearance() {
        containerView.backgroundColor = traitCollection.userInterfaceStyle == .dark
            ? Constants.HomeViewControllerConstants.tileDarkModeColor
            : .white
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
        topText: String,
        bottomText: String,
        animationName: String,
        onTap: (() -> Void)? = nil
    ) {
        topLabel.text = topText
        bottomLabel.text = bottomText
        self.onTap = onTap
        
        if let animation = LottieAnimation.named(animationName) {
            lottieView.animation = animation
            lottieView.play()
        }
    }
    
    // MARK: - Animation Control
    
    func playAnimation() {
        lottieView.play()
    }
    
    func stopAnimation() {
        lottieView.stop()
    }
}

