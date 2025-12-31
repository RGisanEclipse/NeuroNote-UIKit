//
//  DailyMoodCircle.swift
//  NeuroNote-UIKit
//
//  Created by Eclipse on 31/12/25.
//

import UIKit

class DailyMoodCircle: UIView{
    
    // MARK: - Configuration
    
    struct Configuration {
        let date: String
        let moodColor: UIColor?
        let circleSize: CGFloat
        let isToday: Bool
        let isFuture: Bool
        
        init(
            date: String,
            moodColor: UIColor? = nil,
            circleSize: CGFloat = 32,
            isToday: Bool = false,
            isFuture: Bool = false
        ) {
            self.date = date
            self.moodColor = moodColor
            self.circleSize = circleSize
            self.isToday = isToday
            self.isFuture = isFuture
        }
    }
    
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
    
    // MARK: - UI Elements
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
    
    private func setupViews() {
        addSubview(highlightRing)
        addSubview(circleView)
        addSubview(dateLabel)
        
        NSLayoutConstraint.activate([
            highlightRing.topAnchor.constraint(equalTo: topAnchor),
            highlightRing.centerXAnchor.constraint(equalTo: centerXAnchor),
            
            circleView.centerXAnchor.constraint(equalTo: highlightRing.centerXAnchor),
            circleView.centerYAnchor.constraint(equalTo: highlightRing.centerYAnchor),
            
            dateLabel.topAnchor.constraint(equalTo: highlightRing.bottomAnchor, constant: 4),
            dateLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            dateLabel.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    private var configuration: Configuration?
    private var circleSizeConstraints: [NSLayoutConstraint] = []
    private var highlightRingSizeConstraints: [NSLayoutConstraint] = []
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }
    
    convenience init(configuration: Configuration) {
        self.init(frame: .zero)
        configure(with: configuration)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let size = configuration?.circleSize ?? 32
        let ringSize = size + 6
        circleView.layer.cornerRadius = size / 2
        highlightRing.layer.cornerRadius = ringSize / 2
    }
    
    // MARK: - Configuration
    
    func configure(with configuration: Configuration) {
        self.configuration = configuration
        
        let ringSize = configuration.circleSize + 6
        
        // Handle future days (grayed out)
        if configuration.isFuture {
            circleView.backgroundColor = .systemGray4
            dateLabel.textColor = .systemGray3
        } else {
            circleView.backgroundColor = configuration.moodColor ?? .systemGray5
            dateLabel.textColor = .secondaryLabel
        }
        
        dateLabel.text = configuration.date
        
        // Show highlight ring for today
        highlightRing.isHidden = !configuration.isToday
        
        // Update highlight ring size constraints
        NSLayoutConstraint.deactivate(highlightRingSizeConstraints)
        highlightRingSizeConstraints = [
            highlightRing.widthAnchor.constraint(equalToConstant: ringSize),
            highlightRing.heightAnchor.constraint(equalToConstant: ringSize)
        ]
        NSLayoutConstraint.activate(highlightRingSizeConstraints)
        
        // Update circle size constraints
        NSLayoutConstraint.deactivate(circleSizeConstraints)
        circleSizeConstraints = [
            circleView.widthAnchor.constraint(equalToConstant: configuration.circleSize),
            circleView.heightAnchor.constraint(equalToConstant: configuration.circleSize)
        ]
        NSLayoutConstraint.activate(circleSizeConstraints)
        
        setNeedsLayout()
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
        UIColor(red: 0.55, green: 0.85, blue: 0.9, alpha: 1.0),  // Calm - cyan
        UIColor(red: 0.7, green: 0.9, blue: 0.6, alpha: 1.0),    // Happy - green
        UIColor(red: 0.95, green: 0.9, blue: 0.4, alpha: 1.0),   // Joy - yellow
        UIColor(red: 0.95, green: 0.9, blue: 0.4, alpha: 1.0),   // Joy - yellow
        UIColor(red: 0.75, green: 0.7, blue: 0.9, alpha: 1.0),   // Meh - purple
        UIColor(red: 0.95, green: 0.9, blue: 0.4, alpha: 1.0),   // Today - yellow
        nil                                                       // Future - no mood
    ]
    let todayIndex = 5  // "13" is today
    
    for (index, day) in days.enumerated() {
        let circle = DailyMoodCircle(configuration: .init(
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
