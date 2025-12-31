//
//  CasinoTextLabel.swift
//  NeuroNote-UIKit
//
//  Created by Eclipse on 30/12/25.
//

import UIKit

/// A label that displays text with a casino/slot machine reveal effect.
/// Each letter appears to "roll" through random characters before settling on the final letter.
class CasinoTextLabel: UIView {
    
    // MARK: - Configuration
    private let targetText: String
    private var font: UIFont
    private let baseFont: UIFont
    private let textColor: UIColor
    private var letterSpacing: CGFloat
    private let baseLetterSpacing: CGFloat
    private let rollDuration: TimeInterval
    private let staggerDelay: TimeInterval
    private let minFontScale: CGFloat
    
    // MARK: - State
    private var letterLabels: [UILabel] = []
    private var displayLinks: [CADisplayLink] = []
    private var letterStartTimes: [CFTimeInterval] = []
    private var hasAnimated = false
    private var stackView: UIStackView?
    
    private let randomCharacters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%&*"
    
    // MARK: - Init
    
    /// Creates a casino text label with the specified configuration.
    /// - Parameters:
    ///   - text: The final text to display after the animation.
    ///   - font: The font to use for the text.
    ///   - textColor: The color of the text.
    ///   - letterSpacing: Space between each letter (default: 4).
    ///   - rollDuration: How long each letter "rolls" before settling (default: 0.8 seconds).
    ///   - staggerDelay: Delay between each letter starting its animation (default: 0.1 seconds).
    ///   - minFontScale: Minimum scale factor for auto-sizing (default: 0.5 = 50% of original size).
    init(
        text: String,
        font: UIFont,
        textColor: UIColor,
        letterSpacing: CGFloat = 4,
        rollDuration: TimeInterval = 0.8,
        staggerDelay: TimeInterval = 0.1,
        minFontScale: CGFloat = 0.5
    ) {
        self.targetText = text.uppercased()
        self.font = font
        self.baseFont = font
        self.textColor = textColor
        self.letterSpacing = letterSpacing
        self.baseLetterSpacing = letterSpacing
        self.rollDuration = rollDuration
        self.staggerDelay = staggerDelay
        self.minFontScale = minFontScale
        super.init(frame: .zero)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        stopAllAnimations()
    }
    
    // MARK: - Setup
    
    private func setupView() {
        translatesAutoresizingMaskIntoConstraints = false
        clipsToBounds = false
        
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.alignment = .center
        stack.distribution = .fill
        stack.spacing = letterSpacing
        
        addSubview(stack)
        self.stackView = stack
        
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor),
            stack.centerXAnchor.constraint(equalTo: centerXAnchor),
            stack.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor),
            stack.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor)
        ])
        
        // Create a label for each letter
        for char in targetText {
            let label = createLetterLabel(String(char))
            letterLabels.append(label)
            stack.addArrangedSubview(label)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        adjustFontToFit()
    }
    
    private func adjustFontToFit() {
        guard bounds.width > 0 else { return }
        
        let availableWidth = bounds.width
        var currentScale: CGFloat = 1.0
        
        // Calculate width needed at current scale
        func calculateNeededWidth(scale: CGFloat) -> CGFloat {
            let scaledFont = baseFont.withSize(baseFont.pointSize * scale)
            let scaledSpacing = baseLetterSpacing * scale
            
            var totalWidth: CGFloat = 0
            let sampleText = "W"
            let charSize = (sampleText as NSString).size(withAttributes: [.font: scaledFont])
            
            totalWidth = charSize.width * CGFloat(targetText.count)
            totalWidth += scaledSpacing * CGFloat(max(0, targetText.count - 1))
            
            return totalWidth
        }
        
        // Binary search for the right scale
        var minScale = minFontScale
        var maxScale: CGFloat = 1.0
        
        while maxScale - minScale > 0.01 {
            let midScale = (minScale + maxScale) / 2
            let neededWidth = calculateNeededWidth(scale: midScale)
            
            if neededWidth <= availableWidth {
                minScale = midScale
            } else {
                maxScale = midScale
            }
        }
        
        currentScale = minScale
        
        // Apply the scaled font and spacing
        let newFontSize = baseFont.pointSize * currentScale
        font = baseFont.withSize(newFontSize)
        letterSpacing = baseLetterSpacing * currentScale
        
        // Update labels
        for label in letterLabels {
            label.font = font
            
            // Update width constraint
            let sampleText = "W"
            let size = (sampleText as NSString).size(withAttributes: [.font: font])
            
            for constraint in label.constraints {
                if constraint.firstAttribute == .width {
                    constraint.constant = size.width
                }
            }
        }
        
        // Update stack spacing
        stackView?.spacing = letterSpacing
    }
    
    private func createLetterLabel(_ character: String) -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = font
        label.textColor = textColor
        label.textAlignment = .center
        label.text = " "
        label.alpha = 0
        label.numberOfLines = 0
        
        // Set a minimum width based on the widest character
        let sampleText = "W"
        let size = (sampleText as NSString).size(withAttributes: [.font: font])
        label.widthAnchor.constraint(greaterThanOrEqualToConstant: size.width).isActive = true
        
        return label
    }
    
    // MARK: - Animation
    
    /// Starts the casino roll animation. Call this when the view appears.
    func startAnimation() {
        guard !hasAnimated else { return }
        hasAnimated = true
        
        stopAllAnimations()
        
        let baseTime = CACurrentMediaTime()
        
        for (index, _) in targetText.enumerated() {
            let startTime = baseTime + (Double(index) * staggerDelay)
            letterStartTimes.append(startTime)
            
            let displayLink = CADisplayLink(target: self, selector: #selector(updateLetter(_:)))
            displayLink.preferredFrameRateRange = CAFrameRateRange(minimum: 30, maximum: 60)
            
            // Store the index in the display link
            objc_setAssociatedObject(displayLink, &AssociatedKeys.letterIndex, index, .OBJC_ASSOCIATION_RETAIN)
            
            displayLinks.append(displayLink)
            displayLink.add(to: .main, forMode: .common)
        }
    }
    
    /// Resets the animation so it can be played again.
    func resetAnimation() {
        stopAllAnimations()
        hasAnimated = false
        letterStartTimes.removeAll()
        
        for label in letterLabels {
            label.text = " "
            label.alpha = 0
            label.transform = .identity
        }
    }
    
    @objc private func updateLetter(_ displayLink: CADisplayLink) {
        guard let index = objc_getAssociatedObject(displayLink, &AssociatedKeys.letterIndex) as? Int,
              index < letterLabels.count,
              index < letterStartTimes.count else {
            displayLink.invalidate()
            return
        }
        
        let label = letterLabels[index]
        let startTime = letterStartTimes[index]
        let currentTime = CACurrentMediaTime()
        let elapsed = currentTime - startTime
        
        // If we haven't started yet, skip
        guard elapsed >= 0 else { return }
        
        let progress = min(elapsed / rollDuration, 1.0)
        
        // Fade in quickly at the start
        if label.alpha < 1 {
            label.alpha = min(CGFloat(elapsed / 0.1), 1.0)
        }
        
        if progress < 1.0 {
            // Still rolling - show random characters
            // Slow down the randomization as we approach the end
            let shouldChange = Double.random(in: 0...1) > (progress * 0.8)
            if shouldChange {
                let randomIndex = randomCharacters.index(
                    randomCharacters.startIndex,
                    offsetBy: Int.random(in: 0..<randomCharacters.count)
                )
                label.text = String(randomCharacters[randomIndex])
            }
            
            // Add slight vertical jitter during roll
            let jitter = CGFloat.random(in: -2...2) * CGFloat(1 - progress)
            label.transform = CGAffineTransform(translationX: 0, y: jitter)
            
        } else {
            // Animation complete - show final letter
            let targetIndex = targetText.index(targetText.startIndex, offsetBy: index)
            label.text = String(targetText[targetIndex])
            label.transform = .identity
            
            // Add a subtle scale pop when settling
            UIView.animate(withDuration: 0.15, delay: 0, options: .curveEaseOut) {
                label.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
            } completion: { _ in
                UIView.animate(withDuration: 0.1) {
                    label.transform = .identity
                }
            }
            
            // Stop this display link
            displayLink.invalidate()
            if let linkIndex = displayLinks.firstIndex(of: displayLink) {
                displayLinks.remove(at: linkIndex)
            }
        }
    }
    
    private func stopAllAnimations() {
        for displayLink in displayLinks {
            displayLink.invalidate()
        }
        displayLinks.removeAll()
    }
}

// MARK: - Associated Keys

private enum AssociatedKeys {
    static var letterIndex: UInt8 = 0
}

#Preview {
    let container = UIView()
    container.backgroundColor = .systemBackground
    
    let casinoLabel = CasinoTextLabel(
        text: "CASINO",
        font: UIFont(name: Fonts.MontserratBold, size: 32) ?? .boldSystemFont(ofSize: 32),
        textColor: .systemOrange,
        letterSpacing: 6,
        rollDuration: 0.8,
        staggerDelay: 0.12
    )
    
    container.addSubview(casinoLabel)
    
    NSLayoutConstraint.activate([
        casinoLabel.centerXAnchor.constraint(equalTo: container.centerXAnchor),
        casinoLabel.centerYAnchor.constraint(equalTo: container.centerYAnchor)
    ])
    
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
        casinoLabel.startAnimation()
    }
    
    return container
}

