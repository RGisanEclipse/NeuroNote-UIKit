//
//  BreathingActivityViewController.swift
//  NeuroNote-UIKit
//
//  Created by Eclipse on 09/04/26.
//

import UIKit
import Lottie

class BreathingActivityViewController: UIViewController {

    // MARK: - Breathing Phases

    private enum BreathingPhase: Int, CaseIterable {
        case inhale, exhale, holdOut

        var duration: TimeInterval {
            switch self {
            case .inhale:  return 6.006006
            case .exhale:  return 5.338672
            case .holdOut: return 2.669336
            }
        }

        var title: String {
            switch self {
            case .inhale:  return "Inhale"
            case .exhale:  return "Exhale"
            case .holdOut: return "Rest"
            }
        }

        var instruction: String {
            switch self {
            case .inhale:  return "Breathe in through your nose"
            case .exhale:  return "Release through your mouth"
            case .holdOut: return "Relax"
            }
        }

        var accentColor: UIColor {
            switch self {
            case .inhale:  return UIColor(red: 0.45, green: 0.82, blue: 1.00, alpha: 1.0)
            case .exhale:  return UIColor(red: 0.45, green: 0.95, blue: 0.80, alpha: 1.0)
            case .holdOut: return UIColor(red: 0.80, green: 0.75, blue: 1.00, alpha: 0.80)
            }
        }
    }

    // MARK: - State

    private let totalDuration: TimeInterval = 210.110102
    private var elapsed:        TimeInterval = 0
    private var phaseElapsed:   TimeInterval = 0
    private var currentPhaseIndex: Int = 0
    private var sessionTimer:    Timer?
    private var isRunning:       Bool = false

    private var currentPhase: BreathingPhase {
        BreathingPhase.allCases[currentPhaseIndex % BreathingPhase.allCases.count]
    }

    // MARK: - CALayers

    private let bgGradientLayer = CAGradientLayer()
    private let ringTrackLayer  = CAShapeLayer()
    private let ringGlowLayer   = CAShapeLayer()
    private let ringFillLayer   = CAShapeLayer()

    // MARK: - UI

    private lazy var lottieView: LottieAnimationView = {
        let anim = LottieAnimation.named(Constants.animations.breathing)
        let v = LottieAnimationView(animation: anim)
        v.translatesAutoresizingMaskIntoConstraints = false
        v.contentMode              = .scaleAspectFill
        v.loopMode                 = .loop
        v.backgroundBehavior       = .pauseAndRestore
        v.isUserInteractionEnabled = false
        v.shouldRasterizeWhenIdle  = true
        return v
    }()

    private lazy var lottieContainer: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.clipsToBounds = true
        return v
    }()

    private lazy var ringCanvas: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.isUserInteractionEnabled = false
        return v
    }()

    private lazy var closeButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.translatesAutoresizingMaskIntoConstraints = false
        let cfg = UIImage.SymbolConfiguration(pointSize: 15, weight: .medium)
        btn.setImage(UIImage(systemName: "xmark", withConfiguration: cfg), for: .normal)
        btn.tintColor = UIColor.white.withAlphaComponent(0.55)
        btn.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        return btn
    }()

    private lazy var roundLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.attributedText = Self.trackedString("ROUND 1", font: Fonts.MontserratSemiBold, size: 12, kern: 2.0, alpha: 0.40)
        l.textAlignment  = .center
        l.alpha = 0
        return l
    }()

    private lazy var timerLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.font      = UIFont(name: Fonts.BeachDay, size: 60)
        l.textColor = .white
        l.textAlignment = .center
        l.text          = "3:30"
        return l
    }()

    private lazy var timerTagLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.attributedText = Self.trackedString("REMAINING", font: Fonts.MontserratMedium, size: 11, kern: 2.5, alpha: 0.38)
        l.textAlignment  = .center
        l.alpha = 0
        return l
    }()

    private lazy var phaseLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.font      = UIFont(name: Fonts.BeachDay, size: 38)
        l.textColor = .white
        l.textAlignment = .center
        l.text          = "Settle in"
        return l
    }()

    private lazy var instructionLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.font          = UIFont(name: Fonts.MontserratMedium, size: 15)
        l.textColor = UIColor.white.withAlphaComponent(0.60)
        l.textAlignment = .center
        l.numberOfLines = 1
        l.text          = "Tap Begin to start your session"
        return l
    }()


    private lazy var progressTrack: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = UIColor.white.withAlphaComponent(0.11)
        v.layer.cornerRadius = 4
        v.clipsToBounds = true
        return v
    }()

    private lazy var progressFill: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor   = UIColor(red: 0.58, green: 0.48, blue: 1.0, alpha: 1.0)
        v.layer.cornerRadius = 4
        return v
    }()

    private var progressFillWidth: NSLayoutConstraint?

    private lazy var actionButton: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.layer.cornerRadius = 30
        v.clipsToBounds = true

        let blur = UIVisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterialDark))
        blur.translatesAutoresizingMaskIntoConstraints = false
        v.addSubview(blur)

        v.layer.borderWidth = 1.5
        v.layer.borderColor = UIColor.white.withAlphaComponent(0.26).cgColor

        NSLayoutConstraint.activate([
            blur.topAnchor.constraint(equalTo: v.topAnchor),
            blur.leadingAnchor.constraint(equalTo: v.leadingAnchor),
            blur.trailingAnchor.constraint(equalTo: v.trailingAnchor),
            blur.bottomAnchor.constraint(equalTo: v.bottomAnchor),
        ])

        v.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(actionTapped)))
        v.isUserInteractionEnabled = true
        return v
    }()

    private lazy var actionLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.font      = UIFont(name: Fonts.MontserratBold, size: 17)
        l.textColor = .white
        l.textAlignment = .center
        l.text          = "Begin"
        return l
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupBackground()
        setupLayout()
        setupRing()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        lottieView.currentProgress = 0
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        endSession()
        lottieView.stop()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        bgGradientLayer.frame = view.bounds
        refreshRingPath()
        lottieContainer.layer.cornerRadius = lottieContainer.bounds.width / 2
    }

    // MARK: - Background

    private func setupBackground() {
        bgGradientLayer.colors = [
            UIColor(red: 0.06, green: 0.05, blue: 0.14, alpha: 1.0).cgColor,
            UIColor(red: 0.10, green: 0.07, blue: 0.22, alpha: 1.0).cgColor,
            UIColor(red: 0.14, green: 0.08, blue: 0.28, alpha: 1.0).cgColor,
        ]
        bgGradientLayer.locations  = [0, 0.5, 1]
        bgGradientLayer.startPoint = CGPoint(x: 0.25, y: 0)
        bgGradientLayer.endPoint   = CGPoint(x: 0.75, y: 1)
        view.layer.insertSublayer(bgGradientLayer, at: 0)
    }

    // MARK: - Layout

    private func setupLayout() {
        view.addSubview(closeButton)
        view.addSubview(roundLabel)
        view.addSubview(timerLabel)
        view.addSubview(timerTagLabel)
        view.addSubview(ringCanvas)
        view.addSubview(lottieContainer)
        lottieContainer.addSubview(lottieView)
        view.addSubview(phaseLabel)
        view.addSubview(instructionLabel)
        view.addSubview(progressTrack)
        progressTrack.addSubview(progressFill)
        view.addSubview(actionButton)
        actionButton.addSubview(actionLabel)

        progressFillWidth = progressFill.widthAnchor.constraint(equalToConstant: 0)

        NSLayoutConstraint.activate([
            // Top bar
            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            closeButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            closeButton.widthAnchor.constraint(equalToConstant: 40),
            closeButton.heightAnchor.constraint(equalToConstant: 40),

            roundLabel.centerYAnchor.constraint(equalTo: closeButton.centerYAnchor),
            roundLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            // Timer
            timerLabel.topAnchor.constraint(equalTo: closeButton.bottomAnchor, constant: 0),
            timerLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            timerTagLabel.topAnchor.constraint(equalTo: timerLabel.bottomAnchor, constant: 2),
            timerTagLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            // Ring canvas (ring wraps lottie)
            ringCanvas.topAnchor.constraint(equalTo: timerTagLabel.bottomAnchor, constant: 16),
            ringCanvas.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            ringCanvas.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.76),
            ringCanvas.heightAnchor.constraint(equalTo: ringCanvas.widthAnchor),

            // Circular lottie container centered inside ring canvas
            lottieContainer.centerXAnchor.constraint(equalTo: ringCanvas.centerXAnchor),
            lottieContainer.centerYAnchor.constraint(equalTo: ringCanvas.centerYAnchor),
            lottieContainer.widthAnchor.constraint(equalTo: ringCanvas.widthAnchor, multiplier: 0.94),
            lottieContainer.heightAnchor.constraint(equalTo: lottieContainer.widthAnchor),

            // Lottie fills container
            lottieView.centerXAnchor.constraint(equalTo: lottieContainer.centerXAnchor),
            lottieView.centerYAnchor.constraint(equalTo: lottieContainer.centerYAnchor, constant: 0),
            lottieView.widthAnchor.constraint(equalTo: lottieContainer.widthAnchor),
            lottieView.heightAnchor.constraint(equalTo: lottieContainer.heightAnchor),

            // Phase info
            phaseLabel.topAnchor.constraint(equalTo: ringCanvas.bottomAnchor, constant: 18),
            phaseLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            instructionLabel.topAnchor.constraint(equalTo: phaseLabel.bottomAnchor, constant: 6),
            instructionLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            instructionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 28),
            instructionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -28),

            // Action button (anchored to bottom)
            actionButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            actionButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -28),
            actionButton.widthAnchor.constraint(equalToConstant: 168),
            actionButton.heightAnchor.constraint(equalToConstant: 60),

            actionLabel.centerXAnchor.constraint(equalTo: actionButton.centerXAnchor),
            actionLabel.centerYAnchor.constraint(equalTo: actionButton.centerYAnchor),

            // Progress bar
            progressTrack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 28),
            progressTrack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -28),
            progressTrack.heightAnchor.constraint(equalToConstant: 6),
            progressTrack.bottomAnchor.constraint(equalTo: actionButton.topAnchor, constant: -24),

            progressFill.leadingAnchor.constraint(equalTo: progressTrack.leadingAnchor),
            progressFill.topAnchor.constraint(equalTo: progressTrack.topAnchor),
            progressFill.bottomAnchor.constraint(equalTo: progressTrack.bottomAnchor),
            progressFillWidth!,

            // Milestone (floats above progress track)
        ])
    }

    // MARK: - Ring Setup

    private func setupRing() {
        ringTrackLayer.fillColor   = UIColor.clear.cgColor
        ringTrackLayer.strokeColor = UIColor.white.withAlphaComponent(0.06).cgColor
        ringTrackLayer.lineWidth   = 4
        ringTrackLayer.lineCap     = .round
        ringCanvas.layer.addSublayer(ringTrackLayer)

        ringGlowLayer.fillColor    = UIColor.clear.cgColor
        ringGlowLayer.strokeColor  = UIColor(red: 0.60, green: 0.50, blue: 1.0, alpha: 0.28).cgColor
        ringGlowLayer.lineWidth    = 12
        ringGlowLayer.lineCap      = .round
        ringGlowLayer.shadowColor  = UIColor(red: 0.60, green: 0.50, blue: 1.0, alpha: 1.0).cgColor
        ringGlowLayer.shadowOffset = .zero
        ringGlowLayer.shadowRadius = 16
        ringGlowLayer.shadowOpacity = 0.85
        ringGlowLayer.strokeEnd    = 0
        ringCanvas.layer.addSublayer(ringGlowLayer)

        ringFillLayer.fillColor    = UIColor.clear.cgColor
        ringFillLayer.strokeColor  = UIColor(red: 0.65, green: 0.56, blue: 1.0, alpha: 1.0).cgColor
        ringFillLayer.lineWidth    = 4
        ringFillLayer.lineCap      = .round
        ringFillLayer.strokeEnd    = 0
        ringCanvas.layer.addSublayer(ringFillLayer)
    }

    private func refreshRingPath() {
        let b = ringCanvas.bounds
        guard b.width > 0 else { return }
        let path = UIBezierPath(
            arcCenter: CGPoint(x: b.midX, y: b.midY),
            radius:    min(b.width, b.height) / 2 - 6,
            startAngle: -.pi / 2,
            endAngle:   .pi * 1.5,
            clockwise:  true
        ).cgPath
        ringTrackLayer.path = path
        ringGlowLayer.path  = path
        ringFillLayer.path  = path
    }

    // MARK: - Session Control

    private func startSession() {
        guard !isRunning else { return }
        isRunning = true
        actionLabel.text = "Pause"
        lottieView.play()

        UIView.animate(withDuration: 0.25) {
            self.roundLabel.alpha    = 1
            self.timerTagLabel.alpha = 1
        }

        sessionTimer = Timer.scheduledTimer(
            withTimeInterval: 0.1, repeats: true
        ) { [weak self] _ in self?.tick() }

        transitionPhase(to: currentPhaseIndex)
    }

    private func pauseSession() {
        guard isRunning else { return }
        isRunning = false
        sessionTimer?.invalidate()
        sessionTimer = nil
        actionLabel.text = "Resume"
        lottieView.pause()

        UIView.transition(with: phaseLabel, duration: 0.3, options: .transitionCrossDissolve) {
            self.phaseLabel.text = "Paused"
        }
        UIView.transition(with: instructionLabel, duration: 0.3, options: .transitionCrossDissolve) {
            self.instructionLabel.text = "Tap Resume to continue"
        }
    }

    private func endSession() {
        isRunning = false
        sessionTimer?.invalidate()
        sessionTimer = nil
    }

    private func finishSession() {
        endSession()
        lottieView.stop()
        actionLabel.text = "Done"
        actionButton.isUserInteractionEnabled = true

        UIView.animate(withDuration: 0.3) {
            self.closeButton.alpha = 0
        }

        CATransaction.begin()
        CATransaction.setDisableActions(true)
        ringFillLayer.strokeEnd = 0
        ringGlowLayer.strokeEnd = 0
        CATransaction.commit()

        UIView.transition(with: phaseLabel, duration: 0.5, options: .transitionCrossDissolve) {
            self.phaseLabel.text = "Well done!"
        }
        UIView.transition(with: instructionLabel, duration: 0.5, options: .transitionCrossDissolve) {
            self.instructionLabel.text = "Stay with yourself for a moment"
        }

        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }

    // MARK: - Tick

    private func tick() {
        elapsed      += 0.1
        phaseElapsed += 0.1

        let remaining = totalDuration - elapsed
        guard remaining > 0 else { finishSession(); return }

        // Timer display
        let mins = Int(remaining) / 60
        let secs = Int(remaining) % 60
        timerLabel.text = String(format: "%d:%02d", mins, secs)

        // Session progress bar
        let trackWidth = progressTrack.bounds.width
        progressFillWidth?.constant = trackWidth * CGFloat(elapsed / totalDuration)

        // Phase ring fill
        let phaseProgress = CGFloat(min(phaseElapsed / currentPhase.duration, 1.0))
        setRingProgress(phaseProgress)

        // Phase advance
        if phaseElapsed >= currentPhase.duration {
            phaseElapsed -= currentPhase.duration
            currentPhaseIndex += 1
            transitionPhase(to: currentPhaseIndex)
        }

    }

    // MARK: - Phase Transition

    private func transitionPhase(to index: Int) {
        let phase = BreathingPhase.allCases[index % BreathingPhase.allCases.count]
        let round = (index / BreathingPhase.allCases.count) + 1

        UIImpactFeedbackGenerator(style: .light).impactOccurred()

        UIView.transition(with: phaseLabel,       duration: 0.35, options: .transitionCrossDissolve) { self.phaseLabel.text       = phase.title }
        UIView.transition(with: instructionLabel, duration: 0.35, options: .transitionCrossDissolve) { self.instructionLabel.text = phase.instruction }
        UIView.transition(with: roundLabel,       duration: 0.25, options: .transitionCrossDissolve) {
            self.roundLabel.attributedText = Self.trackedString("ROUND \(round)", font: Fonts.MontserratSemiBold, size: 12, kern: 2.0, alpha: 0.40)
        }

        // Ring color shift
        CATransaction.begin()
        CATransaction.setAnimationDuration(0.4)
        ringFillLayer.strokeColor  = phase.accentColor.cgColor
        ringGlowLayer.strokeColor  = phase.accentColor.withAlphaComponent(0.22).cgColor
        ringGlowLayer.shadowColor  = phase.accentColor.cgColor
        CATransaction.commit()

        // Reset ring progress
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        ringFillLayer.strokeEnd = 0
        ringGlowLayer.strokeEnd = 0
        CATransaction.commit()
    }

    // MARK: - Ring Progress

    private func setRingProgress(_ progress: CGFloat) {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        ringFillLayer.strokeEnd = progress
        ringGlowLayer.strokeEnd = progress
        CATransaction.commit()
    }


    // MARK: - Actions

    @objc private func actionTapped() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()

        UIView.animate(withDuration: 0.10) {
            self.actionButton.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        } completion: { _ in
            UIView.animate(withDuration: 0.15) {
                self.actionButton.transform = .identity
            }
        }

        if actionLabel.text == "Done" {
            dismiss(animated: true)
        } else {
            isRunning ? pauseSession() : startSession()
        }
    }

    @objc private func closeTapped() {
        dismiss(animated: true)
    }

    // MARK: - Helpers

    private static func trackedString(
        _ text: String,
        font: String,
        size: CGFloat,
        kern: CGFloat,
        alpha: CGFloat
    ) -> NSAttributedString {
        NSAttributedString(string: text, attributes: [
            .font:            UIFont(name: font, size: size) ?? .systemFont(ofSize: size),
            .foregroundColor: UIColor.white.withAlphaComponent(alpha),
            .kern:            kern,
        ])
    }
}

#Preview { BreathingActivityViewController() }

