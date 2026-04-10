import UIKit
import Lottie

class HomeViewController: UIViewController {
    
    // MARK: - ViewModel
    
    private let viewModel = HomeViewModel(
        moodManager: MoodManager(),
        dashboardManager: DashboardManager()
    )
    
    // MARK: - State
    
    private var hasShownStreakConfetti = false
    
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
        let plusIcon = UIImage(systemName: Constants.HomeViewControllerConstants.plusIconImageName, withConfiguration: iconConfig)
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
        let animation = LottieAnimation.named(Constants.animations.stars)
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
        label.text = Constants.HomeViewControllerConstants.greetingLabelText
        label.font = UIFont(name: Fonts.MontserratBold, size: 25) ?? .systemFont(ofSize: 25, weight: .medium)
        label.textColor = UIColor(red: 0.97, green: 0.97, blue: 0.95, alpha: 1.0)
        label.textAlignment = .center
        label.alpha = 0
        return label
    }()
    
    private lazy var prefixLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = Constants.HomeViewControllerConstants.prefixLabelText
        label.font = UIFont(name: Fonts.MontserratMedium, size: 18) ?? .systemFont(ofSize: 18, weight: .light)
        label.textColor = .systemGray
        label.textAlignment = .center
        label.alpha = 0
        label.numberOfLines = 0
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
                ? Constants.Colors.dashboardDarkPurple
                :  Constants.Colors.dashboardLightPurple
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
            self?.refreshInsightsChart()
        }
        return chart
    }()
    
    private lazy var weeklyMoodStrip: WeeklyMoodStrip = {
        let strip = WeeklyMoodStrip()
        strip.translatesAutoresizingMaskIntoConstraints = false
        strip.onSeeMoreTapped = { [weak self] in
            self?.handleWeeklyMoodSeeMore()
        }
        strip.onRefreshTapped = { [weak self] in
            self?.refreshWeeklyMoodStrip()
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
            topText: Constants.HomeViewControllerConstants.breatheCardTitle,
            bottomText: Constants.HomeViewControllerConstants.breatheCardBottomText,
            animationName: Constants.animations.meditatingBrain
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
            text: Constants.empty,
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
        bindViewModel()
        fetchDashboardData()
    }
    
    // MARK: - ViewModel Binding
    
    private func bindViewModel() {
        
//        viewModel.onAsyncStart = { [weak self] in
//             Could show a loading indicator on the log button if needed
//        }
//        
//        viewModel.onAsyncEnd = { [weak self] in
//             Hide loading indicator
//        }
        
        viewModel.onLoggingSuccess = { [weak self] in
            guard let self else { return }
            if ConnectivityMonitor.shared.isConnected {
                presentInAppNotificationBanner(withText: Constants.HomeViewControllerConstants.moodLoggingSuccessText)
                fetchDashboardData()
            } else {
                presentInAppNotificationBanner(withText: "Mood saved — will sync when you're back online.")
            }
        }

        viewModel.onStreakVisibilityChange = { [weak self] isVisible in
            self?.streakInsightCard.isHidden = !isVisible
            self?.tilesSpacer.isHidden = isVisible
        }
        
        viewModel.onMessage = { [weak self] message in
            self?.presentInAppNotificationBanner(withText: message)
        }
        
        viewModel.onInsightsState = { [weak self] state in
            self?.insightsChartView.setState(state)
        }
        
        viewModel.onWeeklyMoodState = { [weak self] state in
            self?.weeklyMoodStrip.setState(state)
        }
        
        viewModel.onDominantMoodState = { [weak self] state in
            self?.applyDominantMoodState(state)
        }

        viewModel.onStreakUpdate = { [weak self] streak in
            self?.updateStreakCard(streak: streak)
        }
    }
    
    private func applyDominantMoodState(_ state: DominantMoodState) {
        switch state {
        case .loaded(let label, let color):
            prefixLabel.text = Constants.HomeViewControllerConstants.prefixLabelText
            moodCasinoLabel.updateText(label, color: color)
            moodCasinoLabel.resetAnimation()
            moodCasinoLabel.startAnimation()
            if let animation = LottieAnimation.named(animationName(for: label)) {
                moodAnimationView.animation = animation
                moodAnimationView.play()
            }
        case .unavailableNoData:
            prefixLabel.text = Constants.HomeViewControllerConstants.dominantMoodEmptyPrefix
            moodCasinoLabel.updateText(Constants.HomeViewControllerConstants.dominantMoodPlaceholder, color: .secondaryLabel)
            moodCasinoLabel.resetAnimation()
            moodCasinoLabel.startAnimation()
            if let animation = LottieAnimation.named(Constants.animations.alienInRocket) {
                moodAnimationView.animation = animation
                moodAnimationView.play()
            }
        case .unavailableNetworkError:
            prefixLabel.text = Constants.HomeViewControllerConstants.dominantMoodUnavailablePrefix
            moodCasinoLabel.updateText(Constants.HomeViewControllerConstants.dominantMoodPlaceholder, color: .secondaryLabel)
            moodCasinoLabel.resetAnimation()
            moodCasinoLabel.startAnimation()
            if let animation = LottieAnimation.named(Constants.animations.noInternet) {
                moodAnimationView.animation = animation
                moodAnimationView.play()
            }
        }
    }
    
    private func animationName(for moodLabel: String) -> String {
        let normalized = moodLabel.lowercased()
        switch normalized {
        case "happy": return Constants.animations.alienInRocket
        case "down": return Constants.animations.sadAlien
        case "frustrated": return Constants.animations.angryAlien
        case "surprised", "uncomfortable", "worried": return Constants.animations.confusedAlien
        default: return Constants.animations.alienInRocket
        }
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
        tilesStack.addArrangedSubview(tilesSpacer)
        tilesSpacer.isHidden = true
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
        
        // Play overlay animation on streak insight card once
        if !hasShownStreakConfetti {
            hasShownStreakConfetti = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) { [weak self] in
                self?.streakInsightCard.playOverlayAnimation(named: Constants.animations.confetti)
            }
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
        let requestData = MoodLogData(
            mood: mood.rawValue,
            reason: reason?.rawValue
        )
        viewModel.handleMoodLog(with: requestData)
    }
    
    func presentInAppNotificationBanner(withText text: String) {
        let blurEffect = UIBlurEffect(style: .systemUltraThinMaterialDark)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.clipsToBounds = true
        blurView.layer.cornerRadius = 14
        blurView.layer.borderColor = UIColor.white.withAlphaComponent(0.2).cgColor
        blurView.layer.borderWidth = 0.5

        let label = UILabel()
        label.text = text
        label.textColor = .white
        label.font = UIFont(name: Fonts.MontserratMedium, size: 14) ??
            .systemFont(ofSize: 14, weight: .semibold)
        label.textAlignment = .center
        label.numberOfLines = 0

        blurView.contentView.addSubview(label)
        let bannerHeight: CGFloat = 60
        blurView.frame = CGRect(x: 16, y: -bannerHeight, width: view.frame.width - 32, height: bannerHeight)
        label.frame = CGRect(x: 12, y: 0, width: blurView.frame.width - 24, height: bannerHeight)

        view.addSubview(blurView)
        UIView.animate(withDuration: 0.4,
                       delay: 0,
                       usingSpringWithDamping: 0.7,
                       initialSpringVelocity: 0.8,
                       options: .curveEaseOut) {
            blurView.frame.origin.y = 60
        }
        
        UIView.animate(withDuration: 0.3,
                       delay: 3,
                       options: .curveEaseIn,
                       animations: {
            blurView.frame.origin.y = -bannerHeight
            blurView.alpha = 0
        }) { _ in
            blurView.removeFromSuperview()
        }
    }
    
    // MARK: - Helpers

    private func updateStreakCard(streak: Int) {
        let text = streak <= 1
            ? "Every streak starts with day one. You've got this!"
            : "You've checked in \(streak) days in a row. Keep it up!"
        streakInsightCard.configure(
            text: text,
            backgroundColor: UIColor(red: 0.45, green: 0.36, blue: 0.65, alpha: 1.0)
        ) { [weak self] in
            self?.handleInsightCardTapped()
        }
    }

    private func getCurrentMoodAnimationName() -> String {
        return Constants.animations.alienInRocket
    }
    
    private func getMoodColor() -> UIColor {
        return UIColor(red: 1.0, green: 0.6, blue: 0.0, alpha: 1.0)
    }
    
    // MARK: - Data Fetching
    
    private func fetchDashboardData() {
        viewModel.fetchDashboardData()
    }

    private func refreshInsightsChart() {
        viewModel.refreshMonthlyMoodInsights()
    }

    private func refreshWeeklyMoodStrip() {
        viewModel.refreshWeeklyMoodStrip()
    }
    
    private func handleWeeklyMoodSeeMore() {
        // TODO: Navigate to mood history/calendar view
        print("See More tapped - navigate to mood history")
    }
    
    private func handleBreatheCardTapped() {
        let vc = BreathingActivityViewController()
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }
    
    private func handleInsightCardTapped() {
        // Since this is the streak/infographic card, no action for this for now
        return
    }
}

#Preview {
    HomeViewController()
}
