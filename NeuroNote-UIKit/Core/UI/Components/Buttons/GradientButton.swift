//
//  GradientButton.swift
//  NeuroNote-UIKit
//
//  Created by Eclipse on 13/07/25.
//

import UIKit
import Lottie

class GradientButton: UIButton {
    
    private let gradientLayer = CAGradientLayer()
    private var cachedTitle: String?
    private let originalColors: [CGColor]
    private let grayColors: [CGColor] = [
        UIColor(red: 0.90, green: 0.90, blue: 0.92, alpha: 1.0).cgColor,
        UIColor(red: 0.90, green: 0.90, blue: 0.92, alpha: 1.0).cgColor
    ]
    
    private let lottieView: LottieAnimationView = {
        let anim = LottieAnimationView(name: Constants.animations.loadingDots)
        anim.loopMode = .loop
        anim.contentMode = .scaleAspectFit
        anim.translatesAutoresizingMaskIntoConstraints = false
        anim.isHidden = true
        return anim
    }()
    
    init(title: String, leadingColor: CGColor, trailingColor: CGColor) {
        self.originalColors = [leadingColor, trailingColor]
        super.init(frame: .zero)
        
        layer.insertSublayer(gradientLayer, at: 0)
        setTitle(title, for: .normal)
        setTitleColor(.white, for: .normal)
        titleLabel?.font = UIFont(
            name: Fonts.BeachDay,
            size: 20
        ) ?? UIFont.boldSystemFont(ofSize: 16)
        layer.cornerRadius = 20
        clipsToBounds = true
        
        gradientLayer.colors = originalColors
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        
        addSubview(lottieView)
        NSLayoutConstraint.activate([
            lottieView.centerXAnchor.constraint(equalTo: centerXAnchor),
            lottieView.centerYAnchor.constraint(equalTo: centerYAnchor),
            lottieView.heightAnchor.constraint(
                equalTo: heightAnchor,
                multiplier: 0.5
            ),
            lottieView.widthAnchor.constraint(equalTo: lottieView.heightAnchor)
        ])
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
    }
    
    func setLoading(_ isLoading: Bool) {
        isEnabled = !isLoading
        
        if isLoading {
            cachedTitle = title(for: .normal)
            setTitle(Constants.empty, for: .normal)
            lottieView.transform = CGAffineTransform(scaleX: 3.0, y: 3.0)
            lottieView.isHidden = false
            lottieView.play()
            gradientLayer.colors = grayColors
        } else {
            lottieView.stop()
            lottieView.isHidden = true
            lottieView.transform = .identity
            gradientLayer.colors = originalColors
            if let cachedTitle = cachedTitle {
                setTitle(cachedTitle, for: .normal)
            }
        }
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
