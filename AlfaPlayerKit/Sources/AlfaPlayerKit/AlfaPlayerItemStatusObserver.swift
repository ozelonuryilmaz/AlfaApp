//
//  File.swift
//  AlfaPlayerKit
//
//  Created by Onur Yilmaz on 17.10.2025.
//

import AVFoundation
import Combine

/// Observes the status of an AVPlayerItem.
public final class AlfaPlayerItemStatusObserver: NSObject {
    
    public var onStatusChange: ((AVPlayerItem.Status) -> Void)?
    
    private var statusObservation: NSKeyValueObservation?
    
    weak var playerItem: AVPlayerItem? {
        didSet {
            statusObservation?.invalidate()
            guard let playerItem = playerItem else { return }
            
            statusObservation = playerItem.observe(\.status, options: [.initial, .new]) { [weak self] _, change in
                guard let newStatus = change.newValue else { return }
                self?.onStatusChange?(newStatus)
            }
        }
    }
    
    deinit {
        statusObservation?.invalidate()
    }
}
