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
    
    init(viewModel: IMoviePlayerViewModel,
         didDismissCallback: DefaultDismissCallback? = nil) {
        self.viewModel = viewModel
        super.init()
        self.didDismissCallback = didDismissCallback
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        playerObservers.forEach { $0.cancel() }
    }
    
    override func setupView() {
        rootView.delegate = self
    }
    
    override func initialComponents() {
        observeViewModel()
        viewModel.fetchVideoURL()
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
    
    // Immersive experience için status bar ve home indicator gizlendi
    override var prefersHomeIndicatorAutoHidden: Bool { true }
    override var prefersStatusBarHidden: Bool { true }
}


// MARK: ViewModel State Handling
private extension MoviePlayerViewController {
    
    func observeViewModel() {
        viewModel.viewState
            .compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?.handle(state: state)
            }
            .store(in: &cancelBag)
    }
    
    func handle(state: MoviePlayerViewState) {
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
}


// MARK: AVPlayer Observers
private extension MoviePlayerViewController {
    
    func setupPlayerObservers() {
        observePlayerStatus()
        observeTimeControlStatus()
        observePeriodicTimeUpdates()
    }
    
    func observePlayerStatus() {
        let playerItem = rootView.playerView.player.currentItem
        
        playerItem?.publisher(for: \.status)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] status in
                switch status {
                case .readyToPlay:
                    self?.viewModel.playerIsReady(totalDuration: playerItem?.duration.seconds ?? 0)
                case .failed:
                    self?.viewModel.playerDidFail()
                default:
                    break
                }
            }
            .store(in: &playerObservers)
    }
    
    func observeTimeControlStatus() {
        let player = rootView.playerView.player
        
        player.publisher(for: \.timeControlStatus)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] status in
                let isPlaying = status == .playing
                let isWaiting = status == .waitingToPlayAtSpecifiedRate
                
                self?.rootView.showLoading(isWaiting)
                self?.rootView.setPlayback(isPlaying: isPlaying)
                
                let session = AVAudioSession.sharedInstance()
                isPlaying ? session.activatePlaybackSession() : session.deactivatePlaybackSession()
            }
            .store(in: &playerObservers)
    }
    
    func observePeriodicTimeUpdates() {
        rootView.playerView.timeObserver.onTimeChange = { [weak self] seconds in
            self?.viewModel.timeProgressed(to: seconds)
        }
    }
}



// MARK: MoviePlayerRootViewDelegate
extension MoviePlayerViewController: MoviePlayerRootViewDelegate {
    
    func rootViewDidTogglePlayback(isPlaying: Bool) {
        isPlaying ? viewModel.playButtonTapped() : viewModel.pauseButtonTapped()
    }
    
    func rootViewDidTapSkip(seconds: Double) {
        viewModel.skip(by: seconds)
    }
    
    func rootViewDidBeginSeeking() {
        wasPlayingBeforeSeek = rootView.playerView.player.rate > 0
        viewModel.beginSeeking()
    }
    
    func rootViewDidSeek(toProgress progress: Float) {
        viewModel.seek(toProgress: progress)
    }
    
    func rootViewDidEndSeeking() {
        viewModel.endSeeking(wasPlaying: wasPlayingBeforeSeek)
    }
    
    func rootViewDidTapClose() {
        viewModel.closeButtonTapped()
    }
}
