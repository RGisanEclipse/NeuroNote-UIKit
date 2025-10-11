//
//  ClearButton.swift
//  NeuroNote-UIKit
//
//  Created by Eclipse on 11/10/25.
//

import UIKit

final class ClearButton: UIButton {
    
    // MARK: - Initializers
    init(title: String,
         titleColor: UIColor = .white,
         font: UIFont = UIFont(name: Fonts.MontserratMedium, size: 16) ?? .systemFont(ofSize: 16, weight: .semibold),
         backgroundColor: UIColor = UIColor.white.withAlphaComponent(0.1),
         borderColor: UIColor = UIColor.white.withAlphaComponent(0.25)) {
        
        super.init(frame: .zero)
        
        setTitle(title, for: .normal)
        setTitleColor(titleColor, for: .normal)
        titleLabel?.font = font
        self.backgroundColor = backgroundColor
        layer.cornerRadius = 10
        clipsToBounds = true
        
        layer.borderWidth = 1
        layer.borderColor = borderColor.cgColor
        
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
