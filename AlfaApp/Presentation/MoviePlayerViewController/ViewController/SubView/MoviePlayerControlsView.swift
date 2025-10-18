//
//  MoviePlayerControlsView.swift
//  AlfaApp
//
//  Created by Onur Yilmaz on 17.10.2025.
//

import UIKit

protocol MoviePlayerControlsViewDelegate: AnyObject {
    
    func controlsViewDidTogglePlayback(isPlaying: Bool)
    func controlsViewDidTapSkip(seconds: Double)
    func controlsViewDidBeginSeeking()
    func controlsViewDidSeek(toProgress progress: Float)
    func controlsViewDidEndSeeking()
    func controlsViewDidTapClose()
}

final class MoviePlayerControlsView: UIView {
    
    weak var delegate: MoviePlayerControlsViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // Ekran boyutu değiştiğinde gradient'i de güncelle.
        (layer.sublayers?.first as? CAGradientLayer)?.frame = bounds
    }
    
    // MARK: Definitions
    private let titleLabel = UILabel()
    private let currentTimeLabel = UILabel()
    private let durationLabel = UILabel()
    private let progressSlider = UISlider()
    private let playPauseButton = UIButton(type: .system)
    private let skipBackwardButton = UIButton(type: .system)
    private let skipForwardButton = UIButton(type: .system)
    private let closeButton = UIButton(type: .system)
}


// MARK: Configuration
extension MoviePlayerControlsView {
    func setTitle(_ title: String) {
        titleLabel.text = title
    }

    func setPlaying(_ isPlaying: Bool) {
        let imageName = isPlaying ? "pause.fill" : "play.fill"
        let config = UIImage.SymbolConfiguration(pointSize: 40, weight: .bold)
        playPauseButton.setImage(UIImage(systemName: imageName, withConfiguration: config), for: .normal)
        playPauseButton.isSelected = !isPlaying
    }

    func updateProgress(_ progress: Float, currentTime: String) {
        progressSlider.value = progress
        currentTimeLabel.text = currentTime
    }

    func setDuration(_ text: String) {
        durationLabel.text = text
    }
}


// MARK: SetupUI
private extension MoviePlayerControlsView {
    
    func setupViews() {
        setupGradient()
        setupTopBar()
        setupBottomBar()
        setupCenterControls()
        setupLayout()
    }

    func setupGradient() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [
            UIColor.black.withAlphaComponent(0.6).cgColor,
            UIColor.clear.cgColor,
            UIColor.clear.cgColor,
            UIColor.black.withAlphaComponent(0.6).cgColor
        ]
        gradientLayer.locations = [0.0, 0.25, 0.75, 1.0]
        layer.insertSublayer(gradientLayer, at: 0)
    }

    func setupTopBar() {
        titleLabel.textColor = .white
        titleLabel.font = .systemFont(ofSize: 18, weight: .bold)

        closeButton.setImage(UIImage(systemName: "xmark", withConfiguration: UIImage.SymbolConfiguration(pointSize: 18, weight: .bold)), for: .normal)
        closeButton.tintColor = .white
        closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
    }

    func setupBottomBar() {
        [currentTimeLabel, durationLabel].forEach {
            $0.textColor = .white
            $0.font = .monospacedSystemFont(ofSize: 14, weight: .regular)
            $0.text = "00:00"
        }

        progressSlider.addTarget(self, action: #selector(sliderDidBeginSeeking), for: .touchDown)
        progressSlider.addTarget(self, action: #selector(sliderValueChanged), for: .valueChanged)
        progressSlider.addTarget(self, action: #selector(sliderDidEndSeeking), for: [.touchUpInside, .touchUpOutside, .touchCancel])
    }

    func setupCenterControls() {
        var buttonConfig = UIButton.Configuration.plain()
        buttonConfig.baseForegroundColor = .white.withAlphaComponent(0.84)
        buttonConfig.background.backgroundColor = .clear

        buttonConfig.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(pointSize: 30, weight: .regular)
        skipBackwardButton.configuration = buttonConfig
        skipBackwardButton.setImage(UIImage(systemName: "gobackward.10"), for: .normal)
        skipBackwardButton.addTarget(self, action: #selector(skipBackwardTapped), for: .touchUpInside)

        skipForwardButton.configuration = buttonConfig
        skipForwardButton.setImage(UIImage(systemName: "goforward.10"), for: .normal)
        skipForwardButton.addTarget(self, action: #selector(skipForwardTapped), for: .touchUpInside)

        buttonConfig.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(pointSize: 40, weight: .bold)
        playPauseButton.configuration = buttonConfig
        playPauseButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
        playPauseButton.setImage(UIImage(systemName: "play.fill"), for: .selected)
        playPauseButton.addTarget(self, action: #selector(playbackButtonTapped), for: .touchUpInside)

        setPlaying(false)
    }

    func setupLayout() {
        let topStack = UIStackView(arrangedSubviews: [titleLabel, closeButton])
        topStack.alignment = .center

        let progressStack = UIStackView(arrangedSubviews: [currentTimeLabel, progressSlider, durationLabel])
        progressStack.spacing = 12
        progressStack.alignment = .center

        let playbackControlsStack = UIStackView(arrangedSubviews: [skipBackwardButton, playPauseButton, skipForwardButton])
        playbackControlsStack.distribution = .equalSpacing

        [topStack, playbackControlsStack, progressStack].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            addSubview($0)
        }

        NSLayoutConstraint.activate([
            topStack.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 12),
            topStack.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 20),
            topStack.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -20),

            playbackControlsStack.centerXAnchor.constraint(equalTo: centerXAnchor),
            playbackControlsStack.centerYAnchor.constraint(equalTo: centerYAnchor),
            playbackControlsStack.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.6),

            progressStack.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -12),
            progressStack.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 20),
            progressStack.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -20),
        ])
    }
}


// MARK: User Actions
@objc private  extension MoviePlayerControlsView {

    func playbackButtonTapped() {
        let userWantsToPlay = playPauseButton.isSelected
        delegate?.controlsViewDidTogglePlayback(isPlaying: userWantsToPlay)
    }

    func skipBackwardTapped() {
        delegate?.controlsViewDidTapSkip(seconds: -10)
    }

    func skipForwardTapped() {
        delegate?.controlsViewDidTapSkip(seconds: 10)
    }

    func sliderDidBeginSeeking() {
        delegate?.controlsViewDidBeginSeeking()
    }

    func sliderValueChanged() {
        delegate?.controlsViewDidSeek(toProgress: progressSlider.value)
    }

    func sliderDidEndSeeking() {
        delegate?.controlsViewDidEndSeeking()
    }

    func closeTapped() {
        delegate?.controlsViewDidTapClose()
    }
}
