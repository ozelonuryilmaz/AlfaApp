//
//  File.swift
//  AlfaPlayerKit
//
//  Created by Onur Yilmaz on 17.10.2025.
//

import UIKit
import AVFoundation
import Combine

/// A view that handles the AVPlayerLayer and basic player setup.
public final class AlfaPlayerView: UIView {
    
    // MARK: - Observers
    public private(set) lazy var timeObserver = AlfaPlayerTimeObserver(player)
    public private(set) lazy var itemStatusObserver = AlfaPlayerItemStatusObserver()
    public private(set) lazy var itemFailToPlayToEndObserver = AlfaPlayerItemFailToPlayToEndObserver()
    
    // MARK: - AVPlayer Properties
    public override class var layerClass: AnyClass {
        return AVPlayerLayer.self
    }
    
    public var playerLayer: AVPlayerLayer {
        guard let layer = layer as? AVPlayerLayer else {
            fatalError("Layer is not of type AVPlayerLayer. This should not happen.")
        }
        return layer
    }
    
    public var player: AVPlayer {
        guard let player = playerLayer.player else {
            fatalError("AVPlayer instance not found. Initialization issue.")
        }
        return player
    }
    
    public var playerItem: AVPlayerItem? {
        get { player.currentItem }
        set {
            if playerItem != nil {
                timeObserver.removeObserver()
            }
            
            player.replaceCurrentItem(with: newValue)
            itemStatusObserver.playerItem = newValue
            itemFailToPlayToEndObserver.playerItem = newValue
            
            if newValue != nil {
                // Observe time changes every 0.5 seconds for smoother progress updates
                timeObserver.addObserver(interval: CMTime(seconds: 0.5, preferredTimescale: 600))
            }
        }
    }
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        playerLayer.player = AVPlayer()
        playerLayer.videoGravity = .resizeAspect
    }
    
    // MARK: - Public Methods
    @discardableResult
    public func setVideo(with url: URL) -> Bool {
        self.playerItem = AVPlayerItem(url: url)
        return true
    }
}
