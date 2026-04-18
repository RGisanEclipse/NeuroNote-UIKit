//
//  MoodLogSheet.swift
//  AVYO
//

import UIKit

final class MoodLogSheet: UIViewController {
    
    // MARK: - Callback
    
    var onMoodLogged: ((Mood, MoodReason?) -> Void)?
    
    // MARK: - State
    
    private var selectedMood: Mood?
    
    // MARK: - Detent Identifiers
    
    private static let compactDetentId = UISheetPresentationController.Detent.Identifier("compact")
    private static let expandedDetentId = UISheetPresentationController.Detent.Identifier("expanded")
    
    // MARK: - UI Components
    
    private lazy var grabberView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.label.withAlphaComponent(0.3)
        view.layer.cornerRadius = 2.5
        return view
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "How are you feeling?"
        label.font = UIFont(name: Fonts.MontserratBold, size: 20) ?? .boldSystemFont(ofSize: 20)
        label.textColor = .label
        label.textAlignment = .center
        return label
    }()
    
    private lazy var moodGridStack: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 16
        stack.alignment = .fill
        return stack
    }()
    
    private lazy var reasonsContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.alpha = 0
        return view
    }()
    
    private lazy var reasonsStack: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 10
        stack.alignment = .fill
        return stack
    }()
    
    private lazy var skipButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Skip", for: .normal)
        button.titleLabel?.font = UIFont(name: Fonts.MontserratMedium, size: 14) ?? .systemFont(ofSize: 14)
        button.setTitleColor(.secondaryLabel, for: .normal)
        button.alpha = 0
        button.addTarget(self, action: #selector(skipTapped), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupMoodButtons()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        view.backgroundColor = UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor(red: 0.12, green: 0.10, blue: 0.18, alpha: 1.0)
                : UIColor(red: 0.96, green: 0.95, blue: 0.99, alpha: 1.0)
        }
        
        view.addSubview(grabberView)
        view.addSubview(titleLabel)
        view.addSubview(moodGridStack)
        view.addSubview(reasonsContainer)
        view.addSubview(skipButton)
        
        reasonsContainer.addSubview(reasonsStack)
        
        NSLayoutConstraint.activate([
            grabberView.topAnchor.constraint(equalTo: view.topAnchor, constant: 12),
            grabberView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            grabberView.widthAnchor.constraint(equalToConstant: 36),
            grabberView.heightAnchor.constraint(equalToConstant: 5),
            
            titleLabel.topAnchor.constraint(equalTo: grabberView.bottomAnchor, constant: 28),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            
            moodGridStack.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 32),
            moodGridStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            moodGridStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            
            reasonsContainer.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 24),
            reasonsContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            reasonsContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            reasonsStack.topAnchor.constraint(equalTo: reasonsContainer.topAnchor),
            reasonsStack.leadingAnchor.constraint(equalTo: reasonsContainer.leadingAnchor),
            reasonsStack.trailingAnchor.constraint(equalTo: reasonsContainer.trailingAnchor),
            reasonsStack.bottomAnchor.constraint(equalTo: reasonsContainer.bottomAnchor),
            
            skipButton.topAnchor.constraint(equalTo: reasonsContainer.bottomAnchor, constant: 16),
            skipButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        ])
    }
    
    private func setupMoodButtons() {
        let moods = Mood.allCases
        let moodsPerRow = 3
        
        for rowIndex in stride(from: 0, to: moods.count, by: moodsPerRow) {
            let rowStack = UIStackView()
            rowStack.axis = .horizontal
            rowStack.spacing = 32
            rowStack.alignment = .center
            rowStack.distribution = .fill
            
            let endIndex = min(rowIndex + moodsPerRow, moods.count)
            for moodIndex in rowIndex..<endIndex {
                let button = createMoodButton(for: moods[moodIndex])
                rowStack.addArrangedSubview(button)
            }
            
            let containerView = UIView()
            containerView.addSubview(rowStack)
            rowStack.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                rowStack.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
                rowStack.topAnchor.constraint(equalTo: containerView.topAnchor),
                rowStack.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            ])
            
            moodGridStack.addArrangedSubview(containerView)
        }
    }
    
    private func createMoodButton(for mood: Mood) -> UIButton {
        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tag = Mood.allCases.firstIndex(of: mood) ?? 0
        
        let imageView = UIImageView()
        imageView.image = mood.image
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.isUserInteractionEnabled = false
        
        button.addSubview(imageView)
        
        NSLayoutConstraint.activate([
            button.widthAnchor.constraint(equalToConstant: 72),
            button.heightAnchor.constraint(equalToConstant: 72),
            imageView.centerXAnchor.constraint(equalTo: button.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: button.centerYAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 64),
            imageView.heightAnchor.constraint(equalToConstant: 64),
        ])
        
        button.addTarget(self, action: #selector(moodButtonTapped(_:)), for: .touchUpInside)
        
        return button
    }
    
    private func createReasonButton(for reason: MoodReason) -> UIButton {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.contentHorizontalAlignment = .leading
        
        var config = UIButton.Configuration.filled()
        config.title = reason.label
        config.baseForegroundColor = .label
        config.baseBackgroundColor = UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor.white.withAlphaComponent(0.08)
                : UIColor.black.withAlphaComponent(0.05)
        }
        config.cornerStyle = .medium
        config.contentInsets = NSDirectionalEdgeInsets(top: 14, leading: 16, bottom: 14, trailing: 16)
        
        button.configuration = config
        button.tag = MoodReason.allCases.firstIndex(of: reason) ?? 0
        button.addTarget(self, action: #selector(reasonButtonTapped(_:)), for: .touchUpInside)
        
        return button
    }
    
    // MARK: - Actions
    
    @objc private func moodButtonTapped(_ sender: UIButton) {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        
        let mood = Mood.allCases[sender.tag]
        selectedMood = mood
        
        UIView.animate(withDuration: 0.1, animations: {
            sender.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                sender.transform = .identity
            } completion: { _ in
                self.showReasons(for: mood)
            }
        }
    }
    
    @objc private func reasonButtonTapped(_ sender: UIButton) {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        
        let reason = MoodReason.allCases[sender.tag]
        
        UIView.animate(withDuration: 0.1, animations: {
            sender.transform = CGAffineTransform(scaleX: 0.97, y: 0.97)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                sender.transform = .identity
            } completion: { _ in
                self.completeMoodLog(reason: reason)
            }
        }
    }
    
    @objc private func skipTapped() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        completeMoodLog(reason: nil)
    }
    
    // MARK: - Transitions
    
    private func showReasons(for mood: Mood) {
        // Clear existing reasons
        reasonsStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        // Add new reason buttons
        for reason in mood.reasons {
            let button = createReasonButton(for: reason)
            reasonsStack.addArrangedSubview(button)
        }
        
        // Expand sheet to show all content
        expandSheet()
        
        // Animate transition
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut) {
            self.titleLabel.text = mood.followUpQuestion
            self.moodGridStack.alpha = 0
            self.moodGridStack.transform = CGAffineTransform(translationX: -30, y: 0)
        }
        
        UIView.animate(withDuration: 0.3, delay: 0.15, options: .curveEaseOut) {
            self.reasonsContainer.alpha = 1
            self.skipButton.alpha = 1
        }
        
        // Animate reason buttons in with stagger
        for (index, button) in reasonsStack.arrangedSubviews.enumerated() {
            button.alpha = 0
            button.transform = CGAffineTransform(translationX: 0, y: 20)
            
            UIView.animate(
                withDuration: 0.3,
                delay: 0.1 + Double(index) * 0.05,
                options: .curveEaseOut
            ) {
                button.alpha = 1
                button.transform = .identity
            }
        }
    }
    
    private func completeMoodLog(reason: MoodReason?) {
        guard let mood = selectedMood else { return }
        
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        
        onMoodLogged?(mood, reason)
        
        dismiss(animated: true)
    }
    
    // MARK: - Sheet Size Management
    
    private func expandSheet() {
        guard let sheetController = sheetPresentationController else { return }
        
        sheetController.animateChanges {
            sheetController.selectedDetentIdentifier = Self.expandedDetentId
        }
    }
}

// MARK: - Presentation Helper

extension MoodLogSheet {
    
    static func present(from viewController: UIViewController, onMoodLogged: @escaping (Mood, MoodReason?) -> Void) {
        let sheet = MoodLogSheet()
        sheet.onMoodLogged = onMoodLogged
        
        if let sheetController = sheet.sheetPresentationController {
            let compactDetent = UISheetPresentationController.Detent.custom(identifier: compactDetentId) { _ in
                return 300
            }
            let expandedDetent = UISheetPresentationController.Detent.custom(identifier: expandedDetentId) { _ in
                return 420
            }
            
            sheetController.detents = [compactDetent, expandedDetent]
            sheetController.selectedDetentIdentifier = compactDetentId
            sheetController.preferredCornerRadius = 28
            sheetController.prefersScrollingExpandsWhenScrolledToEdge = false
        }
        
        viewController.present(sheet, animated: true)
    }
}
