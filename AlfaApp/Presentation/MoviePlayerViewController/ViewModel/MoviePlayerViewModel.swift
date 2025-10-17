//
//  MoviePlayerViewModel.swift
//  AlfaApp
//
//  Created by Onur Yilmaz on 17.10.2025.
//  Copyright (c) 2025 AlfaApp IOS Development Team. All rights reserved.
//

import Foundation

protocol IMoviePlayerViewModel: AnyObject {
    var viewState: ScreenStateSubject<MoviePlayerViewState> { get }
    var errorState: ErrorStateSubject { get }
    
    init(repository: IMoviePlayerRepository,
         coordinator: IMoviePlayerCoordinator,
         vmLogic: IMoviePlayerVMLogic)
    
    // Service
    func fetchVideoURL()
    
    // Coordinator Actions
    func closeButtonTapped()
    
    // Player Lifecycle
    func playerIsReady(totalDuration: Double)
    func playerDidFail()
    func timeProgressed(to seconds: Double)
    
    // Playback Controls
    func playButtonTapped()
    func pauseButtonTapped()
    func skip(by seconds: Double)
    
    // Seeking
    func beginSeeking()
    func seek(toProgress progress: Float)
    func endSeeking(wasPlaying: Bool)
}

final class MoviePlayerViewModel: BaseViewModel, IMoviePlayerViewModel {
    private let repository: IMoviePlayerRepository
    private let coordinator: IMoviePlayerCoordinator
    private let vmLogic: IMoviePlayerVMLogic
    
    var viewState = ScreenStateSubject<MoviePlayerViewState>(nil)
    var errorState = ErrorStateSubject(nil)
    
    private var totalDuration: Double = 0
    private var currentTime: Double = 0
    
    required init(repository: IMoviePlayerRepository,
                  coordinator: IMoviePlayerCoordinator,
                  vmLogic: IMoviePlayerVMLogic) {
        self.repository = repository; self.coordinator = coordinator; self.vmLogic = vmLogic; super.init()
    }
}


// MARK: Service
extension MoviePlayerViewModel {
    
    func fetchVideoURL() {
        viewState.send(.loading(true))
        Task { @MainActor in
            do {
                let url: URL = try await repository.fetchMovieURL()
                viewState.send(.videoLoaded(url: url, title: vmLogic.videoTitle))
            } catch {
                errorState.send("Failed to fetch video URL.")
                viewState.send(.loading(false))
            }
        }
    }
}


// MARK: Coordinator Actions
extension MoviePlayerViewModel {
    
    func closeButtonTapped() {
        coordinator.dismiss(animated: true, completion: nil)
    }
}


// MARK: Player Lifecycle
extension MoviePlayerViewModel {
    
    // ViewController, oynatıcının hazır olduğunu bildirdiğinde çağrılır.
    func playerIsReady(totalDuration: Double) {
        self.totalDuration = totalDuration
        viewState.send(.updateDurationText(vmLogic.formatTime(from: totalDuration)))
        viewState.send(.play) // Otomatik oynat komutunu gönder.
    }
    
    func playerDidFail() {
        errorState.send("Video could not be loaded.")
        viewState.send(.loading(false))
    }
    
    func timeProgressed(to seconds: Double) {
        self.currentTime = seconds
        guard totalDuration > 0 else { return }
        let progress: Float = Float(seconds / totalDuration)
        let timeText: String = vmLogic.formatTime(from: seconds)
        viewState.send(.updateProgress(progress: progress, time: timeText))
    }
}


// MARK: Playback Controls
extension MoviePlayerViewModel {
    
    func playButtonTapped() {
        viewState.send(.play)
    }
    
    func pauseButtonTapped() {
        viewState.send(.pause)
    }
    
    func skip(by seconds: Double) {
        let newTime: Double = self.currentTime + seconds
        viewState.send(.seek(toSeconds: max(0, newTime))) // Negatif zamana gitmeyi engelle.
    }
}


// MARK: Seeking
extension MoviePlayerViewModel {
    
    func beginSeeking() {
        viewState.send(.pause)
    }
    
    func seek(toProgress progress: Float) {
        guard totalDuration > 0 else { return }
        let newTime: Double = totalDuration * Double(progress)
        viewState.send(.seek(toSeconds: newTime))
    }
    
    func endSeeking(wasPlaying: Bool) {
        // Eğer kullanıcı ileri/geri sarmadan önce video oynuyorsa,
        // bittiğinde tekrar oynat komutunu gönder.
        if wasPlaying {
            viewState.send(.play)
        }
    }
}


enum MoviePlayerViewState {
    case loading(Bool)
    case videoLoaded(url: URL, title: String)
    case play
    case pause
    case seek(toSeconds: Double)
    case updateProgress(progress: Float, time: String)
    case updateDurationText(String)
}
