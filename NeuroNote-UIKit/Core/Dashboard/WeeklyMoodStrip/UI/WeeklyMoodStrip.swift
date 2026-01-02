//
//  WeeklyMoodStrip.swift
//  NeuroNote-UIKit
//
//  Created by Eclipse on 31/12/25.
//

import UIKit

// MARK: - View State

enum WeeklyMoodStripState {
    case loading
    case loaded([DailyMoodCircleData])
    case error(String)
}

// MARK: - WeeklyMoodStrip

class WeeklyMoodStrip: UIView {
    
    // MARK: - Callbacks
    
    var onSeeMoreTapped: (() -> Void)?
    
    // MARK: - UI Elements
    
    private let cardView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor(red: 0.14, green: 0.13, blue: 0.20, alpha: 1.0)
                : .white
        }
        view.layer.cornerRadius = 20
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.08
        view.layer.shadowOffset = CGSize(width: 0, height: 4)
        view.layer.shadowRadius = 12
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "This Week's Mood"
        label.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        label.textColor = .label
        return label
    }()
    
    private lazy var seeMoreButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("See More", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        button.setTitleColor(.systemGray, for: .normal)
        button.addTarget(self, action: #selector(seeMoreTapped), for: .touchUpInside)
        return button
    }()
    
    private let moodCirclesStack: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.spacing = 0
        stack.alignment = .center
        stack.distribution = .fillEqually
        return stack
    }()
    
    // Skeleton views for loading state
    private let skeletonContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        return view
    }()
    
    private let skeletonStack: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.spacing = 0
        stack.alignment = .center
        stack.distribution = .fillEqually
        return stack
    }()
    
    // Content container
    private let contentContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // MARK: - Properties
    
    private var moodCircles: [DailyMoodCircle] = []
    private var skeletonViews: [UIView] = []
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupSkeletons()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
        setupSkeletons()
    }
    
    // MARK: - Setup
    
    private func setupViews() {
        addSubview(cardView)
        cardView.addSubview(titleLabel)
        cardView.addSubview(seeMoreButton)
        cardView.addSubview(contentContainer)
        contentContainer.addSubview(moodCirclesStack)
        cardView.addSubview(skeletonContainer)
        skeletonContainer.addSubview(skeletonStack)
        
        NSLayoutConstraint.activate([
            // Card fills parent
            cardView.topAnchor.constraint(equalTo: topAnchor),
            cardView.leadingAnchor.constraint(equalTo: leadingAnchor),
            cardView.trailingAnchor.constraint(equalTo: trailingAnchor),
            cardView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            // Title
            titleLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 20),
            
            // See More button
            seeMoreButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            seeMoreButton.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -20),
            
            // Content container
            contentContainer.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            contentContainer.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 20),
            contentContainer.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -20),
            contentContainer.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -20),
            
            // Mood circles stack
            moodCirclesStack.topAnchor.constraint(equalTo: contentContainer.topAnchor),
            moodCirclesStack.leadingAnchor.constraint(equalTo: contentContainer.leadingAnchor),
            moodCirclesStack.trailingAnchor.constraint(equalTo: contentContainer.trailingAnchor),
            moodCirclesStack.bottomAnchor.constraint(equalTo: contentContainer.bottomAnchor),
            
            // Skeleton container (same position as content)
            skeletonContainer.topAnchor.constraint(equalTo: contentContainer.topAnchor),
            skeletonContainer.leadingAnchor.constraint(equalTo: contentContainer.leadingAnchor),
            skeletonContainer.trailingAnchor.constraint(equalTo: contentContainer.trailingAnchor),
            skeletonContainer.bottomAnchor.constraint(equalTo: contentContainer.bottomAnchor),
            
            // Skeleton stack
            skeletonStack.topAnchor.constraint(equalTo: skeletonContainer.topAnchor),
            skeletonStack.leadingAnchor.constraint(equalTo: skeletonContainer.leadingAnchor),
            skeletonStack.trailingAnchor.constraint(equalTo: skeletonContainer.trailingAnchor),
            skeletonStack.bottomAnchor.constraint(equalTo: skeletonContainer.bottomAnchor)
        ])
    }
    
    private func setupSkeletons() {
        // Create 7 skeleton circles
        for _ in 0..<7 {
            let skeleton = createSkeletonCircle()
            skeletonStack.addArrangedSubview(skeleton)
            skeletonViews.append(skeleton)
        }
    }
    
    private func createSkeletonCircle() -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        
        let circle = UIView()
        circle.translatesAutoresizingMaskIntoConstraints = false
        circle.backgroundColor = .systemGray5
        circle.layer.cornerRadius = 10
        
        let label = UIView()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = .systemGray5
        label.layer.cornerRadius = 3
        
        container.addSubview(circle)
        container.addSubview(label)
        
        NSLayoutConstraint.activate([
            circle.topAnchor.constraint(equalTo: container.topAnchor),
            circle.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            circle.widthAnchor.constraint(equalToConstant: 20),
            circle.heightAnchor.constraint(equalToConstant: 20),
            
            label.topAnchor.constraint(equalTo: circle.bottomAnchor, constant: 4),
            label.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            label.widthAnchor.constraint(equalToConstant: 14),
            label.heightAnchor.constraint(equalToConstant: 8),
            label.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])
        
        return container
    }
    
    // MARK: - Actions
    
    @objc private func seeMoreTapped() {
        UIView.animate(withDuration: 0.1, animations: {
            self.seeMoreButton.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                self.seeMoreButton.transform = .identity
            }
        }
        onSeeMoreTapped?()
    }
    
    // MARK: - State Management
    
    func setState(_ state: WeeklyMoodStripState) {
        switch state {
        case .loading:
            showLoading()
        case .loaded(let configurations):
            showContent(with: configurations)
        case .error:
            // For now, just show empty state
            showContent(with: [])
        }
    }
    
    private func showLoading() {
        contentContainer.alpha = 0
        skeletonContainer.isHidden = false
        startSkeletonAnimation()
    }
    
    private func showContent(with configurations: [DailyMoodCircleData]) {
        stopSkeletonAnimation()
        
        // Clear existing circles
        moodCircles.forEach { $0.removeFromSuperview() }
        moodCircles.removeAll()
        
        // Create new circles
        for config in configurations {
            let circle = DailyMoodCircle(configuration: config)
            circle.translatesAutoresizingMaskIntoConstraints = false
            moodCirclesStack.addArrangedSubview(circle)
            moodCircles.append(circle)
        }
        
        // Animate transition
        UIView.animate(withDuration: 0.3) {
            self.skeletonContainer.isHidden = true
            self.contentContainer.alpha = 1
        }
    }
    
    // MARK: - Skeleton Animation
    
    private func startSkeletonAnimation() {
        for (index, skeleton) in skeletonViews.enumerated() {
            let delay = Double(index) * 0.1
            animateSkeleton(skeleton, delay: delay)
        }
    }
    
    private func animateSkeleton(_ view: UIView, delay: TimeInterval) {
        view.alpha = 0.5
        UIView.animate(
            withDuration: 0.8,
            delay: delay,
            options: [.repeat, .autoreverse, .curveEaseInOut]
        ) {
            view.alpha = 1.0
        }
    }
    
    private func stopSkeletonAnimation() {
        skeletonViews.forEach { $0.layer.removeAllAnimations() }
    }
}

// MARK: - Preview

#Preview {
    let container = UIView()
    container.backgroundColor = UIColor.systemGroupedBackground
    
    let strip = WeeklyMoodStrip()
    strip.translatesAutoresizingMaskIntoConstraints = false
    
    container.addSubview(strip)
    NSLayoutConstraint.activate([
        strip.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
        strip.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
        strip.centerYAnchor.constraint(equalTo: container.centerYAnchor)
    ])
    
    let configs: [DailyMoodCircleData] = [
        .init(date: "8", moodColor: UIColor(red: 0.55, green: 0.85, blue: 0.9, alpha: 1.0), circleSize: 20),
        .init(date: "9", moodColor: UIColor(red: 0.7, green: 0.9, blue: 0.6, alpha: 1.0), circleSize: 20),
        .init(date: "10", moodColor: UIColor(red: 0.95, green: 0.9, blue: 0.4, alpha: 1.0), circleSize: 20),
        .init(date: "11", moodColor: UIColor(red: 0.95, green: 0.9, blue: 0.4, alpha: 1.0), circleSize: 20),
        .init(date: "12", moodColor: UIColor(red: 0.75, green: 0.7, blue: 0.9, alpha: 1.0), circleSize: 20),
        .init(date: "13", moodColor: UIColor(red: 0.95, green: 0.9, blue: 0.4, alpha: 1.0), circleSize: 20, isToday: true),
        .init(date: "14", circleSize: 20, isFuture: true)
    ]
    
    strip.setState(.loaded(configs))
    
    return container
}
