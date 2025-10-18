//
//  File.swift
//  AlfaPlayerKit
//
//  Created by Onur Yilmaz on 18.10.2025.
//

import AVFoundation
@testable import AlfaPlayerKit

// MARK: MockPlayer (Spy)
/// 'AVPlayer', MainActor'a bağlı bir sınıftır.
/// Bu nedenle, ondan miras alan mock sınıfımız da @MainActor olmalıdır.
@MainActor
final class MockPlayer: AVPlayer {
    
    private let lock = NSLock()

    nonisolated(unsafe) private var _invokedReplaceCurrentItem = false
    nonisolated var invokedReplaceCurrentItem: Bool {
        get { lock.withLock { _invokedReplaceCurrentItem } }
    }
    
    nonisolated(unsafe) private var _receivedItem: AVPlayerItem?
    nonisolated var receivedItem: AVPlayerItem? {
        get { lock.withLock { _receivedItem } }
    }
    
    nonisolated(unsafe) private var _invokedAddPeriodicTimeObserver = false
    nonisolated var invokedAddPeriodicTimeObserver: Bool {
        get { lock.withLock { _invokedAddPeriodicTimeObserver } }
    }
    
    nonisolated(unsafe) private var _addPeriodicTimeObserverCallCount = 0
    nonisolated var addPeriodicTimeObserverCallCount: Int {
        get { lock.withLock { _addPeriodicTimeObserverCallCount } }
    }
    
    nonisolated(unsafe) private var _invokedRemoveTimeObserver = false
    nonisolated var invokedRemoveTimeObserver: Bool {
        get { lock.withLock { _invokedRemoveTimeObserver } }
    }
    
    private let dummyObserverToken = "DummyToken"
    
    override func replaceCurrentItem(with item: AVPlayerItem?) {
        // 'nonisolated' bir fonksiyon 'nonisolated(unsafe)' bir özelliği
        // (lock aracılığıyla) güvenle değiştirebilir.
        lock.withLock {
            _invokedReplaceCurrentItem = true
            _receivedItem = item
        }
        super.replaceCurrentItem(with: item)
    }
    
    override func addPeriodicTimeObserver(forInterval interval: CMTime, queue: DispatchQueue?, using block: @escaping (CMTime) -> Void) -> Any {
        lock.withLock {
            _invokedAddPeriodicTimeObserver = true
            _addPeriodicTimeObserverCallCount += 1
        }
        return dummyObserverToken
    }
    
    override func removeTimeObserver(_ observer: Any) {
        if let token = observer as? String, token == dummyObserverToken {
            lock.withLock {
                _invokedRemoveTimeObserver = true
            }
        }
    }
}
