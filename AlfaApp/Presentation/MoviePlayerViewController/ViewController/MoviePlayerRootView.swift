//
//  MoviePlayerRootView.swift
//  AlfaApp
//
//  Created by Onur Yilmaz on 17.10.2025.
//  Copyright (c) 2025 AlfaApp IOS Development Team. All rights reserved.
//

import UIKit
import AlfaPlayerKit

protocol MoviePlayerRootViewDelegate: AnyObject {
    
    func rootViewDidTogglePlayback(isPlaying: Bool)
    func rootViewDidTapSkip(seconds: Double)
    func rootViewDidBeginSeeking()
    func rootViewDidSeek(toProgress progress: Float)
    func rootViewDidEndSeeking()
    func rootViewDidTapClose()
}

final class MoviePlayerRootView: BaseRootView {
    
    weak var delegate: MoviePlayerRootViewDelegate?
    private var controlsHideTimer: Timer?
    private var isSeeking = false
    
    // MARK: Initialization
    init() {
        super.init(frame: .zero)
        backgroundColor = .black
        setupUI()
        setupInteractions()
    }
    
    // MARK: Definitions
    let playerView = AlfaPlayerView() // TODO: playerView'ı private yap. Dışarıdan playerView.player.currentItem "." gibi kullanılmasın
    private let controlsView = MoviePlayerControlsView()
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.color = .white
        indicator.hidesWhenStopped = true
        return indicator
    }()
}


// MARK: SetupUI
private extension MoviePlayerRootView {
    
    func setupUI() {
        [playerView, controlsView, activityIndicator].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            // Video katmanı her zaman en altta ve tam ekran
            playerView.topAnchor.constraint(equalTo: topAnchor),
            playerView.bottomAnchor.constraint(equalTo: bottomAnchor),
            playerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            playerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            // Kontrol katmanı video katmanının üstünde
            controlsView.topAnchor.constraint(equalTo: topAnchor),
            controlsView.bottomAnchor.constraint(equalTo: bottomAnchor),
            controlsView.leadingAnchor.constraint(equalTo: leadingAnchor),
            controlsView.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            activityIndicator.centerXAnchor.constraint(equalTo: centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
}


// MARK: Configuration
extension MoviePlayerRootView {
    
    func configurePlayer(with url: URL, title: String) {
        playerView.setVideo(with: url)
        controlsView.setTitle(title)
    }

    func showLoading(_ isLoading: Bool) {
        isLoading ? activityIndicator.startAnimating() : activityIndicator.stopAnimating()
    }

    func setPlayback(isPlaying: Bool) {
        controlsView.setPlaying(isPlaying)
    }

    func updateProgress(progress: Float, currentTime: String) {
        if !isSeeking {
            controlsView.updateProgress(progress, currentTime: currentTime)
        }
    }

    func setTotalDuration(_ duration: String) {
        controlsView.setDuration(duration)
    }
}


// MARK: Interaction Logic
private extension MoviePlayerRootView {
    
    func setupInteractions() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        addGestureRecognizer(tapGesture)
        controlsView.delegate = self
        showControls(true, animated: false)
    }

    @objc func handleTap() {
        showControls(controlsView.alpha == 0)
    }

    func showControls(_ shouldShow: Bool, animated: Bool = true) {
        if shouldShow {
            resetControlsTimer()
        } else {
            controlsHideTimer?.invalidate()
        }

        UIView.animate(withDuration: animated ? 0.3 : 0.0) {
            self.controlsView.alpha = shouldShow ? 1.0 : 0.0
        }
    }

    func resetControlsTimer() {
        controlsHideTimer?.invalidate()
        controlsHideTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: false) { [weak self] _ in
            self?.showControls(false)
        }
    }
}


// MARK: MoviePlayerControlsViewDelegate
extension MoviePlayerRootView: MoviePlayerControlsViewDelegate {

    func controlsViewDidTogglePlayback(isPlaying: Bool) {
        delegate?.rootViewDidTogglePlayback(isPlaying: isPlaying)
        resetControlsTimer()
    }
    
    func controlsViewDidTapSkip(seconds: Double) {
        delegate?.rootViewDidTapSkip(seconds: seconds)
        resetControlsTimer()
    }
    
    func controlsViewDidBeginSeeking() {
        isSeeking = true
        controlsHideTimer?.invalidate() // Slider sürüklenirken zamanlayıcıyı durdur.
        delegate?.rootViewDidBeginSeeking()
    }
    
    func controlsViewDidSeek(toProgress progress: Float) {
        delegate?.rootViewDidSeek(toProgress: progress)
    }
    
    func controlsViewDidEndSeeking() {
        isSeeking = false
        resetControlsTimer() // Slider bırakıldığında zamanlayıcıyı yeniden başlat.
        delegate?.rootViewDidEndSeeking()
    }
    
    func controlsViewDidTapClose() {
        delegate?.rootViewDidTapClose()
    }
}
