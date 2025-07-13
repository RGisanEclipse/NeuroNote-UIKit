//
//  GradientButton.swift
//  NeuroNote-UIKit
//
//  Created by Eclipse on 13/07/25.
//

import UIKit

class GradientButton: UIButton {
    private let gradient = CAGradientLayer()
    var leadingColor: CGColor = UIColor.systemBlue.cgColor
    var trailingColor: CGColor = UIColor.systemPurple.cgColor
    init(title: String, leadingColor: CGColor, trailingColor: CGColor) {
        super.init(frame: .zero)
        self.leadingColor  = leadingColor
        self.trailingColor = trailingColor
        setTitle(title, for: .normal)
        setTitleColor(.white, for: .normal)
        titleLabel?.font = UIFont(name: Fonts.BeachDay, size: 25) ?? .systemFont(ofSize: 17, weight: .semibold)
        layer.cornerRadius = 20
        clipsToBounds = true
        gradient.colors = [self.leadingColor, self.trailingColor]
        gradient.startPoint = CGPoint(x: 0, y: 0.5)
        gradient.endPoint   = CGPoint(x: 1, y: 0.5)
        layer.insertSublayer(gradient, at: 0)
    }
    
    required init?(coder: NSCoder) { fatalError() }
    override func layoutSubviews() { super.layoutSubviews(); gradient.frame = bounds }
}
