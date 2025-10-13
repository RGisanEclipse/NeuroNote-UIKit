//
//  PasswordStrengthView.swift
//  NeuroNote-UIKit
//
//  Created by Eclipse on 11/10/25.
//

import UIKit

class PasswordStrengthView: UIView {
    
    private let strengthLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.textColor = .white
        label.text = "Password Strength: Weak"
        return label
    }()
    
    private let strengthBarBackground: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        view.layer.cornerRadius = 4
        return view
    }()
    
    private let strengthBarFill: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = PasswordStrength.weak.color
        view.layer.cornerRadius = 4
        return view
    }()
    
    private var fillWidthConstraint: NSLayoutConstraint!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
        setupUI()
        DispatchQueue.main.async {
            self.setInitialWeakState()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        addSubview(strengthLabel)
        addSubview(strengthBarBackground)
        strengthBarBackground.addSubview(strengthBarFill)
        
        fillWidthConstraint = strengthBarFill.widthAnchor.constraint(equalToConstant: 0)
        
        NSLayoutConstraint.activate([
            strengthLabel.topAnchor.constraint(equalTo: topAnchor),
            strengthLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            strengthLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            strengthBarBackground.topAnchor.constraint(equalTo: strengthLabel.bottomAnchor, constant: 6),
            strengthBarBackground.leadingAnchor.constraint(equalTo: leadingAnchor),
            strengthBarBackground.trailingAnchor.constraint(equalTo: trailingAnchor),
            strengthBarBackground.heightAnchor.constraint(equalToConstant: 8),
            strengthBarBackground.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            strengthBarFill.leadingAnchor.constraint(equalTo: strengthBarBackground.leadingAnchor),
            strengthBarFill.topAnchor.constraint(equalTo: strengthBarBackground.topAnchor),
            strengthBarFill.bottomAnchor.constraint(equalTo: strengthBarBackground.bottomAnchor),
            fillWidthConstraint
        ])
    }
    
    private func setInitialWeakState() {
        let totalWidth = strengthBarBackground.bounds.width
        fillWidthConstraint.constant = totalWidth * PasswordStrength.weak.fillPercentage
        layoutIfNeeded()
    }
    
    func updateStrength(for password: String) {
        let strength = PasswordStrength.evaluate(password)
        strengthLabel.text = "Password Strength: \(strength.text)"
        strengthBarFill.backgroundColor = strength.color
        
        let totalWidth = strengthBarBackground.bounds.width
        let targetWidth = totalWidth * strength.fillPercentage
        
        UIView.animate(withDuration: 0.3) {
            self.fillWidthConstraint.constant = targetWidth
            self.layoutIfNeeded()
        }
    }
}

enum PasswordStrength {
    case weak, medium, strong
    
    var text: String {
        switch self {
        case .weak: return "Weak"
        case .medium: return "Medium"
        case .strong: return "Strong"
        }
    }
    
    var color: UIColor {
        switch self {
        case .weak: return .systemRed
        case .medium: return .systemYellow
        case .strong: return .systemGreen
        }
    }
    
    var fillPercentage: CGFloat {
        switch self {
        case .weak: return 0.33
        case .medium: return 0.66
        case .strong: return 1.0
        }
    }
    
    static func evaluate(_ password: String) -> PasswordStrength {
        let length = password.count
        let hasUpper = NSPredicate(format: "SELF MATCHES %@", ".*[A-Z]+.*").evaluate(with: password)
        let hasNumber = NSPredicate(format: "SELF MATCHES %@", ".*[0-9]+.*").evaluate(with: password)
        let hasSymbol = NSPredicate(format: "SELF MATCHES %@", ".*[!@#$%^&*(),.?\":{}|<>]+.*").evaluate(with: password)
        
        var score = 0
        if length > 6 { score += 1 }
        if hasUpper { score += 1 }
        if hasNumber || hasSymbol { score += 1 }
        
        switch score {
        case 0...1: return .weak
        case 2: return .medium
        default: return .strong
        }
    }
}
