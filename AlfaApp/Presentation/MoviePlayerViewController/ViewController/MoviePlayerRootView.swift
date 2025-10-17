//
//  MoviePlayerRootView.swift
//  AlfaApp
//
//  Created by Onur Yilmaz on 17.10.2025.
//  Copyright (c) 2025 AlfaApp IOS Development Team. All rights reserved.
//

import UIKit
import AlfaPlayerKit

/// RootView'dan dışarıya (ViewController'a) bildirilecek kullanıcı etkileşimlerini tanımlar.
/// ControlsView'dan gelen eylemleri doğrudan yukarıya iletir.
protocol MoviePlayerRootViewDelegate: AnyObject {
    func rootViewDidTogglePlayback(isPlaying: Bool)
    func rootViewDidTapSkip(seconds: Double)
    func rootViewDidBeginSeeking()
    func rootViewDidSeek(toProgress progress: Float)
    func rootViewDidEndSeeking()
    func rootViewDidTapClose()
}

final class MoviePlayerRootView: BaseRootView {
    
    // MARK: Properties
    weak var delegate: MoviePlayerRootViewDelegate?
    private var controlsHideTimer: Timer?
    private var isSeeking = false
    
    // MARK: UI Components
    let playerView = AlfaPlayerView()
    private let controlsView = MoviePlayerControlsView()
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.color = .white
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    // MARK: Initialization
    init() {
        super.init(frame: .zero)
        backgroundColor = .black
        setupUI()
        setupInteractions()
    }
    
    // MARK: Public Configuration Methods
    func configurePlayer(with url: URL, title: String) {
        playerView.setVideo(with: url)
        controlsView.setTitle(title)
    }
    
    func showLoading(_ isLoading: Bool) {
        if isLoading {
            activityIndicator.startAnimating()
        } else {
            activityIndicator.stopAnimating()
        }
    }
    
    func setPlayback(isPlaying: Bool) {
        controlsView.setPlaying(isPlaying)
    }
    
    func updateProgress(progress: Float, currentTime: String) {
        // Daha akıcı kullanıcı deneyim için kullanıcı slider'ı sürüklerken, zamanlayıcıdan gelen güncellemeyi engelle
        if !isSeeking {
            controlsView.updateProgress(progress, currentTime: currentTime)
        }
    }
    
    func setTotalDuration(_ duration: String) {
        controlsView.setDuration(duration)
    }
    
    // MARK: UI Setup
    private func setupUI() {
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
            
            // Yükleme göstergesi merkezde
            activityIndicator.centerXAnchor.constraint(equalTo: centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
    
    // MARK: Interaction Logic
    private func setupInteractions() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        addGestureRecognizer(tapGesture)
        
        controlsView.delegate = self
        
        // Başlangıçta kontrolleri göster ve zamanlayıcıyı başlat.
        showControls(true, animated: false)
    }
    
    /// Ekrana dokunulduğunda kontrollerin görünürlüğünü değiştirir.
    @objc private func handleTap() {
        showControls(controlsView.alpha == 0)
    }
    
    /// Kontrolleri gösterir veya gizler.
    private func showControls(_ shouldShow: Bool, animated: Bool = true) {
        // Gösterilecekse, otomatik gizleme zamanlayıcısını sıfırla.
        if shouldShow {
            resetControlsTimer()
        } else {
            // Gizlenecekse, zamanlayıcıyı iptal et.
            controlsHideTimer?.invalidate()
        }
        
        UIView.animate(withDuration: animated ? 0.3 : 0.0) {
            self.controlsView.alpha = shouldShow ? 1.0 : 0.0
        }
    }
    
    /// Kontrolleri 5 saniye sonra otomatik gizlemek için zamanlayıcıyı başlatır/sıfırlar.
    private func resetControlsTimer() {
        controlsHideTimer?.invalidate()
        controlsHideTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: false) { [weak self] _ in
            self?.showControls(false)
        }
    }
}

// MARK: MoviePlayerControlsViewDelegate Conformance
extension MoviePlayerRootView: MoviePlayerControlsViewDelegate {
    
    // ControlsView'dan gelen tüm eylemleri doğrudan kendi delegesine (ViewController'a) iletir.
    // Ayrıca zamanlayıcıyı ve isSeeking durumunu yönetir.
    
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
