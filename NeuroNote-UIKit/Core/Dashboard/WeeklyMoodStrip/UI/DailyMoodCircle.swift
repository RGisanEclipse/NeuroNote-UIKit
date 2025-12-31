//
//  DailyMoodCircle.swift
//  NeuroNote-UIKit
//
//  Created by Eclipse on 31/12/25.
//

import UIKit

class DailyMoodCircle: UIView {
    
    // MARK: - UI Elements
    
    private let highlightRing: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        view.layer.borderColor = UIColor(red: 0.95, green: 0.9, blue: 0.4, alpha: 1.0).cgColor
        view.layer.borderWidth = 2
        view.isHidden = true
        return view
    }()
    
    private let circleView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.clipsToBounds = true
        return view
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 10, weight: .regular)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        return label
    }()
    
    // MARK: - Properties
    
    private var circleSize: CGFloat = 32
    
    // MARK: - Init
    
    convenience init(configuration: DailyMoodCircleData) {
        self.init(frame: .zero)
        self.circleSize = configuration.circleSize
        setupViews()
        applyConfiguration(configuration)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    // MARK: - Setup
    
    private func setupViews() {
        let ringSize = circleSize + 6
        
        addSubview(highlightRing)
        addSubview(circleView)
        addSubview(dateLabel)
        
        NSLayoutConstraint.activate([
            highlightRing.topAnchor.constraint(equalTo: topAnchor),
            highlightRing.centerXAnchor.constraint(equalTo: centerXAnchor),
            highlightRing.widthAnchor.constraint(equalToConstant: ringSize),
            highlightRing.heightAnchor.constraint(equalToConstant: ringSize),
            
            circleView.centerXAnchor.constraint(equalTo: highlightRing.centerXAnchor),
            circleView.centerYAnchor.constraint(equalTo: highlightRing.centerYAnchor),
            circleView.widthAnchor.constraint(equalToConstant: circleSize),
            circleView.heightAnchor.constraint(equalToConstant: circleSize),
            
            dateLabel.topAnchor.constraint(equalTo: highlightRing.bottomAnchor, constant: 4),
            dateLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            dateLabel.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        circleView.layer.cornerRadius = circleSize / 2
        highlightRing.layer.cornerRadius = ringSize / 2
    }
    
    // MARK: - Configuration
    
    private func applyConfiguration(_ configuration: DailyMoodCircleData) {
        dateLabel.text = configuration.date
        highlightRing.isHidden = !configuration.isToday
        
        if configuration.isFuture {
            circleView.backgroundColor = .systemGray4
            dateLabel.textColor = .systemGray3
        } else {
            circleView.backgroundColor = configuration.moodColor ?? .systemGray5
            dateLabel.textColor = .secondaryLabel
        }
    }
}

// MARK: - Preview

#Preview {
    let container = UIView()
    container.backgroundColor = .systemBackground
    
    let stack = UIStackView()
    stack.axis = .horizontal
    stack.spacing = 0
    stack.alignment = .center
    stack.distribution = .fillEqually
    stack.translatesAutoresizingMaskIntoConstraints = false
    
    let days = ["8", "9", "10", "11", "12", "13", "14"]
    let colors: [UIColor?] = [
        UIColor(red: 0.55, green: 0.85, blue: 0.9, alpha: 1.0),
        UIColor(red: 0.7, green: 0.9, blue: 0.6, alpha: 1.0),
        UIColor(red: 0.95, green: 0.9, blue: 0.4, alpha: 1.0),
        UIColor(red: 0.95, green: 0.9, blue: 0.4, alpha: 1.0),
        UIColor(red: 0.75, green: 0.7, blue: 0.9, alpha: 1.0),
        UIColor(red: 0.95, green: 0.9, blue: 0.4, alpha: 1.0),
        nil
    ]
    let todayIndex = 5
    
    for (index, day) in days.enumerated() {
        let circle = DailyMoodCircle(configuration: DailyMoodCircleData(
            date: day,
            moodColor: colors[index],
            circleSize: 20,
            isToday: index == todayIndex,
            isFuture: index > todayIndex
        ))
        circle.translatesAutoresizingMaskIntoConstraints = false
        stack.addArrangedSubview(circle)
    }
    
    container.addSubview(stack)
    NSLayoutConstraint.activate([
        stack.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 20),
        stack.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -20),
        stack.centerYAnchor.constraint(equalTo: container.centerYAnchor)
    ])
    
    return container
}
