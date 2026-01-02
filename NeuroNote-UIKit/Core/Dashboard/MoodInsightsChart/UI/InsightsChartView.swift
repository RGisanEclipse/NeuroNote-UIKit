//
//  InsightsChartView.swift
//  NeuroNote-UIKit
//
//  Created by Eclipse on 31/12/25.
//

import UIKit

class InsightsChartView: UIView {
    
    // MARK: - Callbacks
    
    var onRefreshTapped: (() -> Void)?
    
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
    
    // Content container (bars + legend)
    private let contentContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let barsStackView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 8
        stack.alignment = .fill
        stack.distribution = .fillEqually
        return stack
    }()
    
    private let legendStackView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.spacing = 24
        stack.alignment = .center
        stack.distribution = .fillEqually
        return stack
    }()
    
    
    // Skeleton container
    private let skeletonContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let skeletonStackView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 8
        stack.alignment = .fill
        stack.distribution = .fillEqually
        return stack
    }()
    
    private let skeletonLegendView: SkeletonView = {
        let view = SkeletonView(cornerRadius: 8)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // Error container
    private let errorContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.alpha = 0
        return view
    }()
    
    private let errorIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(systemName: "wifi.exclamationmark")?
            .withConfiguration(UIImage.SymbolConfiguration(pointSize: 36, weight: .medium))
        imageView.tintColor = .tertiaryLabel
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let errorLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Couldn't load insights"
        label.font = UIFont(name: Fonts.MontserratMedium, size: 15) ?? .systemFont(ofSize: 15, weight: .medium)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        return label
    }()
    
    private lazy var refreshButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        var config = UIButton.Configuration.filled()
        config.title = "Refresh"
        config.image = UIImage(systemName: "arrow.clockwise")
        config.imagePadding = 8
        config.cornerStyle = .capsule
        config.baseBackgroundColor = .systemCyan
        config.baseForegroundColor = .white
        config.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 24, bottom: 12, trailing: 24)
        
        button.configuration = config
        button.addTarget(self, action: #selector(refreshTapped), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Properties
    
    private var barViews: [InsightsBarView] = []
    private var skeletonBarViews: [SkeletonBarView] = []
    private var moodData: [MoodInsightsChartViewData] = []
    private(set) var currentState: InsightsChartViewState = .loading
    private var skeletonCount: Int = 3
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupSkeletonViews()
        setupErrorViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
        setupSkeletonViews()
        setupErrorViews()
    }
    
    convenience init(data: [MoodInsightsChartViewData]) {
        self.init(frame: .zero)
        setState(.loaded(data))
    }
    
    convenience init(skeletonCount: Int = 3) {
        self.init(frame: .zero)
        self.skeletonCount = skeletonCount
        setupSkeletonViews()
        setState(.loading)
    }
    
    // MARK: - Setup
    
    private func setupViews() {
        addSubview(cardView)
        cardView.addSubview(contentContainer)
        cardView.addSubview(skeletonContainer)
        cardView.addSubview(errorContainer)
        
        contentContainer.addSubview(barsStackView)
        contentContainer.addSubview(legendStackView)
        
        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: topAnchor),
            cardView.leadingAnchor.constraint(equalTo: leadingAnchor),
            cardView.trailingAnchor.constraint(equalTo: trailingAnchor),
            cardView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            // Content container
            contentContainer.topAnchor.constraint(equalTo: cardView.topAnchor),
            contentContainer.leadingAnchor.constraint(equalTo: cardView.leadingAnchor),
            contentContainer.trailingAnchor.constraint(equalTo: cardView.trailingAnchor),
            contentContainer.bottomAnchor.constraint(equalTo: cardView.bottomAnchor),
            
            barsStackView.topAnchor.constraint(equalTo: contentContainer.topAnchor, constant: 16),
            barsStackView.leadingAnchor.constraint(equalTo: contentContainer.leadingAnchor, constant: 16),
            barsStackView.trailingAnchor.constraint(equalTo: contentContainer.trailingAnchor, constant: -16),
            
            legendStackView.topAnchor.constraint(equalTo: barsStackView.bottomAnchor, constant: 12),
            legendStackView.leadingAnchor.constraint(equalTo: contentContainer.leadingAnchor, constant: 16),
            legendStackView.trailingAnchor.constraint(equalTo: contentContainer.trailingAnchor, constant: -16),
            legendStackView.bottomAnchor.constraint(equalTo: contentContainer.bottomAnchor, constant: -14),
            
            // Skeleton container
            skeletonContainer.topAnchor.constraint(equalTo: cardView.topAnchor),
            skeletonContainer.leadingAnchor.constraint(equalTo: cardView.leadingAnchor),
            skeletonContainer.trailingAnchor.constraint(equalTo: cardView.trailingAnchor),
            skeletonContainer.bottomAnchor.constraint(equalTo: cardView.bottomAnchor),
            
            // Error container
            errorContainer.topAnchor.constraint(equalTo: cardView.topAnchor),
            errorContainer.leadingAnchor.constraint(equalTo: cardView.leadingAnchor),
            errorContainer.trailingAnchor.constraint(equalTo: cardView.trailingAnchor),
            errorContainer.bottomAnchor.constraint(equalTo: cardView.bottomAnchor)
        ])
    }
    
    private func setupSkeletonViews() {
        skeletonBarViews.forEach { $0.removeFromSuperview() }
        skeletonBarViews.removeAll()
        skeletonStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        skeletonContainer.addSubview(skeletonStackView)
        skeletonContainer.addSubview(skeletonLegendView)
        
        for _ in 0..<skeletonCount {
            let skeletonBar = SkeletonBarView()
            skeletonBar.translatesAutoresizingMaskIntoConstraints = false
            skeletonBar.heightAnchor.constraint(equalToConstant: 36).isActive = true
            skeletonStackView.addArrangedSubview(skeletonBar)
            skeletonBarViews.append(skeletonBar)
        }
        
        NSLayoutConstraint.activate([
            skeletonStackView.topAnchor.constraint(equalTo: skeletonContainer.topAnchor, constant: 16),
            skeletonStackView.leadingAnchor.constraint(equalTo: skeletonContainer.leadingAnchor, constant: 16),
            skeletonStackView.trailingAnchor.constraint(equalTo: skeletonContainer.trailingAnchor, constant: -16),
            
            skeletonLegendView.topAnchor.constraint(equalTo: skeletonStackView.bottomAnchor, constant: 22),
            skeletonLegendView.leadingAnchor.constraint(equalTo: skeletonContainer.leadingAnchor, constant: 16),
            skeletonLegendView.trailingAnchor.constraint(equalTo: skeletonContainer.trailingAnchor, constant: -16),
            skeletonLegendView.heightAnchor.constraint(equalToConstant: 18),
            skeletonLegendView.bottomAnchor.constraint(equalTo: skeletonContainer.bottomAnchor, constant: -14)
        ])
    }
    
    private func setupErrorViews() {
        let errorStack = UIStackView(arrangedSubviews: [errorIcon, errorLabel, refreshButton])
        errorStack.translatesAutoresizingMaskIntoConstraints = false
        errorStack.axis = .vertical
        errorStack.spacing = 16
        errorStack.alignment = .center
        
        errorContainer.addSubview(errorStack)
        
        NSLayoutConstraint.activate([
            errorStack.centerXAnchor.constraint(equalTo: errorContainer.centerXAnchor),
            errorStack.centerYAnchor.constraint(equalTo: errorContainer.centerYAnchor),
            errorStack.leadingAnchor.constraint(greaterThanOrEqualTo: errorContainer.leadingAnchor, constant: 20),
            errorStack.trailingAnchor.constraint(lessThanOrEqualTo: errorContainer.trailingAnchor, constant: -20)
        ])
    }
    
    // MARK: - State Management
    
    func setState(_ state: InsightsChartViewState, animated: Bool = true) {
        currentState = state
        
        let duration: TimeInterval = animated ? 0.3 : 0
        
        switch state {
        case .loading:
            showLoading(animated: animated, duration: duration)
            
        case .loaded(let data):
            showLoaded(data: data, animated: animated, duration: duration)
            
        case .error(let message):
            showError(message: message, animated: animated, duration: duration)
        }
    }
    
    private func showLoading(animated: Bool, duration: TimeInterval) {
        skeletonBarViews.forEach { $0.startShimmer() }
        skeletonLegendView.startShimmer()
        
        UIView.animate(withDuration: duration) {
            self.skeletonContainer.alpha = 1
            self.contentContainer.alpha = 0
            self.errorContainer.alpha = 0
        }
    }
    
    private func showLoaded(data: [MoodInsightsChartViewData], animated: Bool, duration: TimeInterval) {
        skeletonBarViews.forEach { $0.stopShimmer() }
        skeletonLegendView.stopShimmer()
        
        configure(with: data)
        
        UIView.animate(withDuration: duration) {
            self.skeletonContainer.alpha = 0
            self.contentContainer.alpha = 1
            self.errorContainer.alpha = 0
        } completion: { _ in
            self.animateChart()
        }
    }
    
    private func showError(message: String, animated: Bool, duration: TimeInterval) {
        skeletonBarViews.forEach { $0.stopShimmer() }
        skeletonLegendView.stopShimmer()
        
        errorLabel.text = message
        
        UIView.animate(withDuration: duration) {
            self.skeletonContainer.alpha = 0
            self.contentContainer.alpha = 0
            self.errorContainer.alpha = 1
        }
    }
    
    // MARK: - Actions
    
    @objc private func refreshTapped() {
        // Animate button
        UIView.animate(withDuration: 0.1, animations: {
            self.refreshButton.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                self.refreshButton.transform = .identity
            }
        }
        
        // Rotate the icon
        if let imageView = refreshButton.imageView {
            UIView.animate(withDuration: 0.5) {
                imageView.transform = imageView.transform.rotated(by: .pi)
            }
        }
        
        onRefreshTapped?()
    }
    
    // MARK: - Configuration
    
    private func configure(with data: [MoodInsightsChartViewData]) {
        self.moodData = data
        
        // Clear existing bars and legend items
        barViews.forEach { $0.removeFromSuperview() }
        barViews.removeAll()
        legendStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        // Create bars
        for mood in data {
            let barView = InsightsBarView(configuration: .init(
                icon: mood.icon,
                fillColor: mood.color,
                percentage: mood.percentage
            ))
            barView.translatesAutoresizingMaskIntoConstraints = false
            barView.heightAnchor.constraint(equalToConstant: 36).isActive = true
            
            barsStackView.addArrangedSubview(barView)
            barViews.append(barView)
        }
        
        // Create legend items
        for mood in data {
            let legendItem = createLegendItem(color: mood.color, label: mood.label)
            legendStackView.addArrangedSubview(legendItem)
        }
    }
    
    private func createLegendItem(color: UIColor, label: String) -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        
        let dot = UIView()
        dot.translatesAutoresizingMaskIntoConstraints = false
        dot.backgroundColor = color
        dot.layer.cornerRadius = 6
        
        let labelView = UILabel()
        labelView.translatesAutoresizingMaskIntoConstraints = false
        labelView.text = label
        labelView.font = UIFont(name: Fonts.MontserratMedium, size: 13) ?? .systemFont(ofSize: 13, weight: .medium)
        labelView.textColor = .secondaryLabel
        
        container.addSubview(dot)
        container.addSubview(labelView)
        
        NSLayoutConstraint.activate([
            dot.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            dot.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            dot.widthAnchor.constraint(equalToConstant: 12),
            dot.heightAnchor.constraint(equalToConstant: 12),
            
            labelView.leadingAnchor.constraint(equalTo: dot.trailingAnchor, constant: 8),
            labelView.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            labelView.trailingAnchor.constraint(lessThanOrEqualTo: container.trailingAnchor),
            
            container.heightAnchor.constraint(equalToConstant: 20)
        ])
        
        return container
    }
    
    // MARK: - Animation
    
    /// Animate all bars with overshoot effect (staggered)
    func animateChart() {
        for (index, barView) in barViews.enumerated() {
            let delay = TimeInterval(index) * 0.15
            barView.animateWithOvershoot(delay: delay)
        }
    }
    
    /// Reset bars to zero (for re-animation)
    func resetBars() {
        for barView in barViews {
            barView.layoutIfNeeded()
        }
    }
}

// MARK: - Preview (Loading State)

#Preview("Loading") {
    let container = UIView()
    container.backgroundColor = UIColor.systemGroupedBackground
    
    let chartView = InsightsChartView(skeletonCount: 3)
    chartView.translatesAutoresizingMaskIntoConstraints = false
    chartView.setState(.loading)
    
    container.addSubview(chartView)
    NSLayoutConstraint.activate([
        chartView.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 20),
        chartView.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -20),
        chartView.centerYAnchor.constraint(equalTo: container.centerYAnchor)
    ])
    
    return container
}

// MARK: - Preview (Loaded State)

#Preview("Loaded") {
    let container = UIView()
    container.backgroundColor = UIColor.systemGroupedBackground
    
    let sampleData: [MoodInsightsChartViewData] = [
        .init(
            label: "Happy",
            icon: UIImage(systemName: "face.smiling.fill")?.withTintColor(
                UIColor(red: 0.95, green: 0.85, blue: 0.35, alpha: 1.0),
                renderingMode: .alwaysOriginal
            ),
            color: UIColor(red: 0.95, green: 0.9, blue: 0.5, alpha: 1.0),
            percentage: 0.7
        ),
        .init(
            label: "Disgust",
            icon: UIImage(systemName: "face.smiling.fill")?.withTintColor(
                UIColor(red: 0.6, green: 0.75, blue: 0.55, alpha: 1.0),
                renderingMode: .alwaysOriginal
            ),
            color: UIColor(red: 0.7, green: 0.85, blue: 0.65, alpha: 1.0),
            percentage: 0.35
        ),
        .init(
            label: "Sad",
            icon: UIImage(systemName: "face.smiling.fill")?.withTintColor(
                UIColor(red: 0.45, green: 0.7, blue: 0.75, alpha: 1.0),
                renderingMode: .alwaysOriginal
            ),
            color: UIColor(red: 0.55, green: 0.8, blue: 0.85, alpha: 1.0),
            percentage: 0.5
        ),
    ]
    
    let chartView = InsightsChartView()
    chartView.translatesAutoresizingMaskIntoConstraints = false
    
    container.addSubview(chartView)
    NSLayoutConstraint.activate([
        chartView.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 20),
        chartView.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -20),
        chartView.centerYAnchor.constraint(equalTo: container.centerYAnchor)
    ])
    
    // Simulate loading then data arrives
    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
        chartView.setState(.loaded(sampleData))
    }
    
    return container
}

// MARK: - Preview (Error State)

#Preview("Error") {
    let container = UIView()
    container.backgroundColor = UIColor.systemGroupedBackground
    
    let chartView = InsightsChartView(skeletonCount: 3)
    chartView.translatesAutoresizingMaskIntoConstraints = false
    chartView.setState(.error("Couldn't load insights"))
    
    chartView.onRefreshTapped = {
        print("Refresh tapped!")
        chartView.setState(.loading)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            chartView.setState(.error("Still couldn't connect"))
        }
    }
    
    container.addSubview(chartView)
    NSLayoutConstraint.activate([
        chartView.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 20),
        chartView.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -20),
        chartView.centerYAnchor.constraint(equalTo: container.centerYAnchor)
    ])
    
    return container
}

