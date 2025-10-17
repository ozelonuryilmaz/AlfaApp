//
//  File.swift
//  AlfaPlayerKit
//
//  Created by Onur Yilmaz on 17.10.2025.
//

import AVFoundation

/// Observes the periodic time changes of an AVPlayer.
public final class AlfaPlayerTimeObserver: NSObject {
    
    public var onTimeChange: ((Double) -> Void)?
    
    private weak var player: AVPlayer?
    private var playerTimeObserver: Any?
    
    init(_ player: AVPlayer) {
        self.player = player
        super.init()
    }
    
    deinit {
        removeObserver()
    }
    
    public func addObserver(interval: CMTime) {
        guard playerTimeObserver == nil else { return }
        
        playerTimeObserver = player?.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            self?.onTimeChange?(time.seconds)
        }
    }
    
    public func removeObserver() {
        guard let observer = playerTimeObserver else { return }
        player?.removeTimeObserver(observer)
        playerTimeObserver = nil
    }
}
