//
//  SkeletonView.swift
//  AVYO
//
//  Created by Eclipse on 31/12/25.
//

import UIKit

class SkeletonView: UIView {
    
    // MARK: - Properties
    
    private let gradientLayer = CAGradientLayer()
    private var isAnimating = false
    
    var skeletonColor: UIColor = UIColor.systemGray5 {
        didSet { updateColors() }
    }
    
    var shimmerColor: UIColor = UIColor.systemGray4 {
        didSet { updateColors() }
    }
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    convenience init(cornerRadius: CGFloat = 8) {
        self.init(frame: .zero)
        layer.cornerRadius = cornerRadius
    }
    
    // MARK: - Setup
    
    private func setup() {
        clipsToBounds = true
        backgroundColor = skeletonColor
        
        gradientLayer.colors = [
            skeletonColor.cgColor,
            shimmerColor.cgColor,
            skeletonColor.cgColor
        ]
        gradientLayer.locations = [0, 0.5, 1]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        
        layer.addSublayer(gradientLayer)
    }
    
    private func updateColors() {
        backgroundColor = skeletonColor
        gradientLayer.colors = [
            skeletonColor.cgColor,
            shimmerColor.cgColor,
            skeletonColor.cgColor
        ]
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = CGRect(
            x: -bounds.width,
            y: 0,
            width: bounds.width * 3,
            height: bounds.height
        )
    }
    
    // MARK: - Animation
    
    func startShimmer() {
        guard !isAnimating else { return }
        isAnimating = true
        
        let animation = CABasicAnimation(keyPath: "transform.translation.x")
        animation.fromValue = -bounds.width * 2
        animation.toValue = bounds.width * 2
        animation.duration = 1.5
        animation.repeatCount = .infinity
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        
        gradientLayer.add(animation, forKey: "shimmer")
    }
    
    func stopShimmer() {
        isAnimating = false
        gradientLayer.removeAnimation(forKey: "shimmer")
    }
}

// MARK: - Skeleton Bar View (for InsightsChartView)

class SkeletonBarView: UIView {
    
    private let iconSkeleton: SkeletonView = {
        let view = SkeletonView(cornerRadius: 16)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let barSkeleton: SkeletonView = {
        let view = SkeletonView(cornerRadius: 10)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        addSubview(iconSkeleton)
        addSubview(barSkeleton)
        
        NSLayoutConstraint.activate([
            iconSkeleton.leadingAnchor.constraint(equalTo: leadingAnchor),
            iconSkeleton.centerYAnchor.constraint(equalTo: centerYAnchor),
            iconSkeleton.widthAnchor.constraint(equalToConstant: 32),
            iconSkeleton.heightAnchor.constraint(equalToConstant: 32),
            
            barSkeleton.leadingAnchor.constraint(equalTo: iconSkeleton.trailingAnchor, constant: 10),
            barSkeleton.trailingAnchor.constraint(equalTo: trailingAnchor),
            barSkeleton.centerYAnchor.constraint(equalTo: centerYAnchor),
            barSkeleton.heightAnchor.constraint(equalToConstant: 20)
        ])
    }
    
    func startShimmer() {
        iconSkeleton.startShimmer()
        barSkeleton.startShimmer()
    }
    
    func stopShimmer() {
        iconSkeleton.stopShimmer()
        barSkeleton.stopShimmer()
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
    
    for _ in 0..<3 {
        let bar = SkeletonBarView()
        bar.translatesAutoresizingMaskIntoConstraints = false
        bar.heightAnchor.constraint(equalToConstant: 36).isActive = true
        stack.addArrangedSubview(bar)
        bar.startShimmer()
    }
    
    container.addSubview(stack)
    NSLayoutConstraint.activate([
        stack.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 20),
        stack.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -20),
        stack.centerYAnchor.constraint(equalTo: container.centerYAnchor)
    ])
    
    return container
}

