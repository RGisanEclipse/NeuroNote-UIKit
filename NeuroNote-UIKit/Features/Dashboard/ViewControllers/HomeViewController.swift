import UIKit
import Lottie

class HomeViewController: UIViewController {
    
    // MARK: - UI
    
    private lazy var logMoodButton: UIView = {
        let buttonSize: CGFloat = 56
        
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.layer.cornerRadius = buttonSize / 2
        container.clipsToBounds = true
        
        let blurEffect = UIBlurEffect(style: .systemThinMaterial)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.translatesAutoresizingMaskIntoConstraints = false
        blurView.isUserInteractionEnabled = false
        container.addSubview(blurView)
        
        container.layer.borderWidth = 1
        container.layer.borderColor = UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor.white.withAlphaComponent(0.25)
                : UIColor.black.withAlphaComponent(0.15)
        }.cgColor
        
        let iconConfig = UIImage.SymbolConfiguration(pointSize: 24, weight: .semibold)
        let plusIcon = UIImage(systemName: "plus", withConfiguration: iconConfig)
        let iconView = UIImageView(image: plusIcon)
        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconView.tintColor = UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor.white.withAlphaComponent(0.9)
                : UIColor(red: 0.18, green: 0.15, blue: 0.25, alpha: 1.0) 
        }
        iconView.contentMode = .scaleAspectFit
        container.addSubview(iconView)
        
        NSLayoutConstraint.activate([
            blurView.topAnchor.constraint(equalTo: container.topAnchor),
            blurView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            blurView.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            blurView.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            
            iconView.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            iconView.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            
            container.widthAnchor.constraint(equalToConstant: buttonSize),
            container.heightAnchor.constraint(equalToConstant: buttonSize)
        ])
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(logMoodButtonTapped))
        container.addGestureRecognizer(tapGesture)
        container.isUserInteractionEnabled = true
        
        return container
    }()
    
    private lazy var backgroundAnimationView: LottieAnimationView = {
        let animation = LottieAnimation.named("stars")
        let view = LottieAnimationView(animation: animation)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.contentMode = .scaleAspectFill
        view.loopMode = .playOnce
        view.backgroundBehavior = .pauseAndRestore
        view.isUserInteractionEnabled = false
        view.shouldRasterizeWhenIdle = true
        return view
    }()
    
    // Mood Animation
    private lazy var moodAnimationView: LottieAnimationView = {
        let animation = LottieAnimation.named(getCurrentMoodAnimationName())
        let view = LottieAnimationView(animation: animation)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.contentMode = .scaleAspectFit
        view.loopMode = .loop
        view.backgroundBehavior = .pauseAndRestore
        view.isUserInteractionEnabled = false
        view.shouldRasterizeWhenIdle = true
        return view
    }()
    
    // Labels
    private lazy var greetingLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "How was your day?"
        label.font = UIFont(name: Fonts.MontserratBold, size: 25) ?? .systemFont(ofSize: 25, weight: .medium)
        label.textColor = UIColor(red: 0.97, green: 0.97, blue: 0.95, alpha: 1.0)
        label.textAlignment = .center
        label.alpha = 0
        return label
    }()
    
    private lazy var prefixLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Lately, I feel"
        label.font = UIFont(name: Fonts.MontserratMedium, size: 18) ?? .systemFont(ofSize: 18, weight: .light)
        label.textColor = .systemGray
        label.textAlignment = .center
        label.alpha = 0
        return label
    }()
    
    private lazy var moodCasinoLabel: CasinoTextLabel = {
        let label = CasinoTextLabel(
            text: "HAPPY",
            font: UIFont(name: Fonts.BeachDay, size: 36) ?? .boldSystemFont(ofSize: 36),
            textColor: getMoodColor(),
            letterSpacing: 0,
            rollDuration: 1,
            staggerDelay: 0.2
        )
        return label
    }()
    
    // Vertical stack for mood text
    private lazy var moodFeelingStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [prefixLabel, moodCasinoLabel])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 8
        return stack
    }()
    
    private lazy var moodAnimationFeelingStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [moodAnimationView, moodFeelingStack])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.spacing = 0
        stack.alignment = .center
        stack.distribution = .fill
        return stack
    }()
    
    // MARK: - Content Card Container
    
    /// Large card container with rounded top corners for the remaining screen space
    private lazy var contentCardView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor(red: 0.18, green: 0.15, blue: 0.25, alpha: 1.0) // Dark purple
                : UIColor(red: 0.922, green: 0.910, blue: 0.988, alpha: 1.0) // Purplish-white
        }
        view.layer.cornerRadius = 28
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner] // Only top corners rounded
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.12
        view.layer.shadowOffset = CGSize(width: 0, height: -4)
        view.layer.shadowRadius = 16
        return view
    }()
    
    /// Scroll view inside the content card for scrollable content
    private lazy var contentScrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.alwaysBounceVertical = true
        scrollView.contentInsetAdjustmentBehavior = .automatic
        return scrollView
    }()
    
    /// Content stack inside scroll view
    private lazy var scrollContentStack: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 16
        stack.alignment = .fill
        stack.layoutMargins = UIEdgeInsets(top: 24, left: 20, bottom: 40, right: 20)
        stack.isLayoutMarginsRelativeArrangement = true
        return stack
    }()
    
    // MARK: - Container Items
    
    private lazy var insightsChartView: InsightsChartView = {
        let chart = InsightsChartView(skeletonCount: 3)
        chart.translatesAutoresizingMaskIntoConstraints = false
        chart.onRefreshTapped = { [weak self] in
            self?.fetchInsightsData()
        }
        return chart
    }()
    
    private lazy var weeklyMoodStrip: WeeklyMoodStrip = {
        let strip = WeeklyMoodStrip()
        strip.translatesAutoresizingMaskIntoConstraints = false
        strip.onSeeMoreTapped = { [weak self] in
            self?.handleWeeklyMoodSeeMore()
        }
        return strip
    }()
    
    private lazy var tilesStack: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.spacing = 16
        stack.distribution = .fillEqually
        stack.alignment = .top
        return stack
    }()
    
    private lazy var breatheCard: LottieCard = {
        let card = LottieCard()
        card.translatesAutoresizingMaskIntoConstraints = false
        card.configure(
            topText: "Breathe",
            bottomText: "Try out a 30 minute guided breathing exercise",
            animationName: "meditating-brain"
        ) { [weak self] in
            self?.handleBreatheCardTapped()
        }
        return card
    }()
    
    /// Invisible spacer to maintain grid layout when odd number of cards
    private lazy var tilesSpacer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        view.isUserInteractionEnabled = false
        return view
    }()
    
    private lazy var streakInsightCard: InsightCard = {
        let card = InsightCard()
        card.translatesAutoresizingMaskIntoConstraints = false
        card.configure(
            text: "You've checked in 3 days this week!",
            backgroundColor: UIColor(red: 0.45, green: 0.36, blue: 0.65, alpha: 1.0)
        ) { [weak self] in
            self?.handleInsightCardTapped()
        }
        return card
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        buildHierarchy()
        setupConstraints()
        registerForTraitChanges()
        fetchWeeklyMoodData()
        fetchInsightsData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        animateContentIn()
    }
    
    private func registerForTraitChanges() {
        registerForTraitChanges([UITraitUserInterfaceStyle.self]) { [weak self] (traitEnvironment: Self, previousTraitCollection: UITraitCollection) in
            self?.updateLogMoodButtonAppearance()
        }
    }
    
    private func updateLogMoodButtonAppearance() {
        logMoodButton.layer.borderColor = traitCollection.userInterfaceStyle == .dark
            ? UIColor.white.withAlphaComponent(0.25).cgColor
            : UIColor.black.withAlphaComponent(0.15).cgColor
    }
    
    // MARK: - UI Builders
    
    private func buildHierarchy() {
        view.addSubview(backgroundAnimationView)
        view.addSubview(contentCardView)
        view.addSubview(greetingLabel)
        view.addSubview(moodAnimationFeelingStack)
        view.addSubview(logMoodButton)
        
        contentCardView.addSubview(contentScrollView)
        contentScrollView.addSubview(scrollContentStack)
        
        scrollContentStack.addArrangedSubview(insightsChartView)
        scrollContentStack.addArrangedSubview(weeklyMoodStrip)
        
        tilesStack.addArrangedSubview(breatheCard)
        tilesStack.addArrangedSubview(streakInsightCard)
        scrollContentStack.addArrangedSubview(tilesStack)
        
        backgroundAnimationView.play()
        moodAnimationView.play()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            backgroundAnimationView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundAnimationView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundAnimationView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundAnimationView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.36),
            
            logMoodButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            logMoodButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            greetingLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            greetingLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            greetingLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            moodAnimationFeelingStack.topAnchor.constraint(equalTo: greetingLabel.bottomAnchor, constant: 20),
            moodAnimationFeelingStack.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            moodAnimationFeelingStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            
            moodAnimationView.widthAnchor.constraint(equalTo: moodAnimationFeelingStack.widthAnchor, multiplier: 0.28),
            moodAnimationView.heightAnchor.constraint(equalTo: moodAnimationView.widthAnchor),
            moodFeelingStack.widthAnchor.constraint(equalTo: moodAnimationFeelingStack.widthAnchor, multiplier: 0.72),
            
            contentCardView.topAnchor.constraint(equalTo: backgroundAnimationView.bottomAnchor, constant: -40),
            contentCardView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            contentCardView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            contentCardView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentScrollView.topAnchor.constraint(equalTo: contentCardView.topAnchor),
            contentScrollView.leadingAnchor.constraint(equalTo: contentCardView.leadingAnchor),
            contentScrollView.trailingAnchor.constraint(equalTo: contentCardView.trailingAnchor),
            contentScrollView.bottomAnchor.constraint(equalTo: contentCardView.bottomAnchor),
            
            scrollContentStack.topAnchor.constraint(equalTo: contentScrollView.topAnchor),
            scrollContentStack.leadingAnchor.constraint(equalTo: contentScrollView.leadingAnchor),
            scrollContentStack.trailingAnchor.constraint(equalTo: contentScrollView.trailingAnchor),
            scrollContentStack.bottomAnchor.constraint(equalTo: contentScrollView.bottomAnchor),
            scrollContentStack.widthAnchor.constraint(equalTo: contentScrollView.widthAnchor),
        ])
    }
    // MARK: - Animation
    
    private func animateContentIn() {
        UIView.animate(withDuration: 0.5, delay: 0.3, options: .curveEaseOut) { [weak self] in
            self?.greetingLabel.alpha = 1
            self?.greetingLabel.transform = CGAffineTransform(translationX: 0, y: -4)
        } completion: { _ in
            UIView.animate(withDuration: 0.2) { [weak self] in
                self?.greetingLabel.transform = .identity
            }
        }
        
        UIView.animate(withDuration: 0.4, delay: 0.6, options: .curveEaseOut) { [weak self] in
            self?.prefixLabel.alpha = 1
        } completion: { [weak self] _ in
            self?.moodCasinoLabel.startAnimation()
        }
    }
    
    // MARK: - Actions
    
    @objc private func logMoodButtonTapped() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        
        UIView.animate(withDuration: 0.1, animations: { [weak self] in
            self?.logMoodButton.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        }) { [weak self] _ in
            UIView.animate(withDuration: 0.1) { [weak self] in
                self?.logMoodButton.transform = .identity
            }
            self?.presentMoodLogSheet()
        }
    }
    
    private func presentMoodLogSheet() {
        MoodLogSheet.present(from: self) { [weak self] mood, reason in
            self?.handleMoodLogged(mood: mood, reason: reason)
        }
    }
    
    private func handleMoodLogged(mood: Mood, reason: MoodReason?) {
        // TODO: Save mood entry to backend/local storage
        print("Mood logged: \(mood.label)" + (reason.map { ", reason: \($0.label)" } ?? ""))
    }
    
    // MARK: - Helpers
    
    private func getCurrentMoodAnimationName() -> String {
        return "alien-in-rocket"
    }
    
    private func getMoodColor() -> UIColor {
        return UIColor(red: 1.0, green: 0.6, blue: 0.0, alpha: 1.0)
    }
    
    // MARK: - Data Fetching
    
    private func fetchInsightsData() {
        insightsChartView.setState(.loading)
        
        // TODO: Replace with actual API call
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
            // Simulated success with sample data
            let sampleData: [MoodInsightsChartViewData] = [
                .init(
                    label: "Happy",
                    icon: UIImage(named: "happyFace"),
                    color: UIColor(
                        red: 0.95,
                        green: 0.80,
                        blue: 0.38,
                        alpha: 1.0
                    ),
                    percentage: 0.7
                ),
                .init(
                    label: "Discomfort",
                    icon: UIImage(named: "disgustedFace"),
                    color: UIColor(red: 0.55, green: 0.80, blue: 0.62, alpha: 1.0),
                    percentage: 0.35
                ),
                .init(
                    label: "Drained",
                    icon: UIImage(named: "fearedFace"),
                    color: UIColor(
                        red: 0.63,
                        green: 0.56,
                        blue: 0.86,
                        alpha: 1.0
                    ),
                    percentage: 0.5
                ),
            ]
            
            self?.insightsChartView.setState(.loaded(sampleData))
        }
    }
    
    private func fetchWeeklyMoodData() {
        weeklyMoodStrip.setState(.loading)
        
        // TODO: Replace with actual API call
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
            // Get current date info for "today" highlighting
            let calendar = Calendar.current
            let today = Date()
            
            // Generate last 7 days
            var configs: [DailyMoodCircleData] = []
            
            // Sample mood colors (replace with actual data)
            let sampleColors: [UIColor?] = [
                UIColor(red: 0.55, green: 0.85, blue: 0.9, alpha: 1.0),  // Calm
                UIColor(red: 0.7, green: 0.9, blue: 0.6, alpha: 1.0),    // Happy
                UIColor(red: 0.95, green: 0.9, blue: 0.4, alpha: 1.0),   // Joy
                UIColor(red: 0.95, green: 0.9, blue: 0.4, alpha: 1.0),   // Joy
                UIColor(red: 0.75, green: 0.7, blue: 0.9, alpha: 1.0),   // Neutral
                UIColor(red: 0.95, green: 0.9, blue: 0.4, alpha: 1.0),   // Today
                nil                                                       // Tomorrow
            ]
            
            for i in 0..<7 {
                let dayOffset = i - 5  // -5 to +1 from today
                let date = calendar.date(byAdding: .day, value: dayOffset, to: today) ?? today
                let day = calendar.component(.day, from: date)
                
                let isToday = dayOffset == 0
                let isFuture = dayOffset > 0
                
                configs.append(.init(
                    date: "\(day)",
                    moodColor: sampleColors[i],
                    circleSize: 20,
                    isToday: isToday,
                    isFuture: isFuture
                ))
            }
            
            self?.weeklyMoodStrip.setState(.loaded(configs))
        }
    }
    
    private func handleWeeklyMoodSeeMore() {
        // TODO: Navigate to mood history/calendar view
        print("See More tapped - navigate to mood history")
    }
    
    private func handleBreatheCardTapped() {
        print("Breathe card tapped")
    }
    
    private func handleInsightCardTapped() {
        print("Insight card tapped")
    }
}

#Preview {
    HomeViewController()
}
