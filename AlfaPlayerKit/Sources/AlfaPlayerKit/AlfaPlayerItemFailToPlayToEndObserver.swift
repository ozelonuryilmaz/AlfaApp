//
//  File.swift
//  AlfaPlayerKit
//
//  Created by Onur Yilmaz on 17.10.2025.
//

import AVFoundation

/// Observes when an AVPlayerItem fails to play to its end time.
public final class AlfaPlayerItemFailToPlayToEndObserver: NSObject {
    
    public var onFail: ((Error?) -> Void)?
    
    weak var playerItem: AVPlayerItem? {
        willSet {
            if let oldItem = playerItem {
                NotificationCenter.default.removeObserver(self, name: .AVPlayerItemFailedToPlayToEndTime, object: oldItem)
            }
        }
        didSet {
            if let newItem = playerItem {
                NotificationCenter.default.addObserver(self, selector: #selector(handleDidFailToPlayToEnd), name: .AVPlayerItemFailedToPlayToEndTime, object: newItem)
            }
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc private func handleDidFailToPlayToEnd(_ notification: Notification) {
        let error = notification.userInfo?[AVPlayerItemFailedToPlayToEndTimeErrorKey] as? Error
        onFail?(error)
    }
}
