//
//  MoviePlayerViewController.swift
//  AlfaApp
//
//  Created by Onur Yilmaz on 17.10.2025.
//  Copyright (c) 2025 AlfaApp IOS Development Team. All rights reserved.
//

import UIKit
import AVFoundation
import Combine

final class MoviePlayerViewController: AlfaLandscapeViewController<MoviePlayerRootView> {
    private let viewModel: IMoviePlayerViewModel
    private var playerObservers: Set<AnyCancellable> = []
    private var wasPlayingBeforeSeek = false

    init(viewModel: IMoviePlayerViewModel) {
        self.viewModel = viewModel
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        playerObservers.forEach { $0.cancel() }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        observeViewModel()
        viewModel.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
        AVAudioSession.sharedInstance().deactivatePlaybackSession()
    }
    
    // Immersive experience için status bar ve home indicator'ı gizle.
    override var prefersHomeIndicatorAutoHidden: Bool { true }
    override var prefersStatusBarHidden: Bool { true }
    
    private func setupUI() {
        rootView.delegate = self
    }
    
    private func observeViewModel() {
        viewModel.viewState.compactMap { $0 }.receive(on: DispatchQueue.main)
            .sink { [weak self] state in self?.handle(state: state) }
            .store(in: &cancelBag)
    }
    
    /// ViewModel'den gelen komutları AVPlayer'a tercüme eden merkezi metot.
    private func handle(state: MoviePlayerViewState) {
        switch state {
        case .loading(let isLoading):
            rootView.showLoading(isLoading)
        case .videoLoaded(let url, let title):
            rootView.configurePlayer(with: url, title: title)
            setupPlayerObservers()
        case .play:
            rootView.playerView.player.play()
        case .pause:
            rootView.playerView.player.pause()
        case .seek(let seconds):
            let time = CMTime(seconds: seconds, preferredTimescale: 600)
            rootView.playerView.player.seek(to: time, toleranceBefore: .zero, toleranceAfter: .zero)
        case .updateProgress(let progress, let time):
            rootView.updateProgress(progress: progress, currentTime: time)
        case .updateDurationText(let text):
            rootView.setTotalDuration(text)
        }
    }
    
    /// AVPlayer'dan gelen olayları dinleyip ViewModel'e bildiren metot.
    private func setupPlayerObservers() {
        let player = rootView.playerView.player
        let playerItem = player.currentItem
        
        // Combine ile Status Observer
        playerItem?.publisher(for: \.status).receive(on: DispatchQueue.main)
            .sink { [weak self] status in
                switch status {
                case .readyToPlay:
                    self?.viewModel.playerIsReady(totalDuration: playerItem?.duration.seconds ?? 0)
                case .failed:
                    self?.viewModel.playerDidFail()
                default: break
                }
            }.store(in: &playerObservers)

        // Combine ile Time Control Observer (Play/Pause/Waiting)
        player.publisher(for: \.timeControlStatus).receive(on: DispatchQueue.main)
            .sink { [weak self] status in
                let isPlaying = status == .playing
                self?.rootView.showLoading(status == .waitingToPlayAtSpecifiedRate)
                self?.rootView.setPlayback(isPlaying: isPlaying)
                if isPlaying { AVAudioSession.sharedInstance().activatePlaybackSession() } else { AVAudioSession.sharedInstance().deactivatePlaybackSession() }
            }.store(in: &playerObservers)

        // Periyodik Zaman Observer
        rootView.playerView.timeObserver.onTimeChange = { [weak self] seconds in
            self?.viewModel.timeProgressed(to: seconds)
        }
    }
}

// UI etkileşimlerini ViewModel'e yönlendiren delege metodları.
extension MoviePlayerViewController: MoviePlayerRootViewDelegate {
    func rootViewDidTogglePlayback(isPlaying: Bool) {
        if isPlaying { viewModel.playButtonTapped() } else { viewModel.pauseButtonTapped() }
    }
    func rootViewDidTapSkip(seconds: Double) { viewModel.skip(by: seconds) }
    func rootViewDidBeginSeeking() { wasPlayingBeforeSeek = rootView.playerView.player.rate > 0; viewModel.beginSeeking() }
    func rootViewDidSeek(toProgress progress: Float) { viewModel.seek(toProgress: progress) }
    func rootViewDidEndSeeking() { viewModel.endSeeking(wasPlaying: wasPlayingBeforeSeek) }
    func rootViewDidTapClose() { viewModel.closeButtonTapped() }
}
