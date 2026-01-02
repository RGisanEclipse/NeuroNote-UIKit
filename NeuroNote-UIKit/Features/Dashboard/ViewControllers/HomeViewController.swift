import UIKit
import Lottie

class HomeViewController: UIViewController {
    
    // MARK: - UI
    
    // Background Animation
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
        scrollView.contentInsetAdjustmentBehavior = .never
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
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        buildHierarchy()
        setupConstraints()
        fetchWeeklyMoodData()
        fetchInsightsData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        animateContentIn()
    }
    
    // MARK: - UI Builders
    
    private func buildHierarchy() {
        view.addSubview(backgroundAnimationView)
        view.addSubview(contentCardView)
        view.addSubview(greetingLabel)
        view.addSubview(moodAnimationFeelingStack)
        
        // Setup scroll view inside card
        contentCardView.addSubview(contentScrollView)
        contentScrollView.addSubview(scrollContentStack)
        
        // Add content to scroll stack
        scrollContentStack.addArrangedSubview(insightsChartView)
        scrollContentStack.addArrangedSubview(weeklyMoodStrip)
        backgroundAnimationView.play()
        moodAnimationView.play()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Background
            backgroundAnimationView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundAnimationView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundAnimationView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundAnimationView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.36),
            
            // Greeting
            greetingLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            greetingLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            greetingLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            // Mood section
            moodAnimationFeelingStack.topAnchor.constraint(equalTo: greetingLabel.bottomAnchor, constant: 20),
            moodAnimationFeelingStack.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            moodAnimationFeelingStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            
            // Animation: 28%, Text: 72% of stack width (respects padding)
            moodAnimationView.widthAnchor.constraint(equalTo: moodAnimationFeelingStack.widthAnchor, multiplier: 0.28),
            moodAnimationView.heightAnchor.constraint(equalTo: moodAnimationView.widthAnchor),
            moodFeelingStack.widthAnchor.constraint(equalTo: moodAnimationFeelingStack.widthAnchor, multiplier: 0.72),
            
            // Content card
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
            scrollContentStack.widthAnchor.constraint(equalTo: contentScrollView.widthAnchor)
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
}

#Preview {
    HomeViewController()
}
