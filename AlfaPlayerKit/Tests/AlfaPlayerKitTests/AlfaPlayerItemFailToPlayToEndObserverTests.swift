//
//  File.swift
//  AlfaPlayerKit
//
//  Created by Onur Yilmaz on 18.10.2025.
//

import Testing
import AVFoundation
@testable import AlfaPlayerKit

struct AlfaPlayerItemFailToPlayToEndObserverTests {
    
    // 'swift-testing' her testi izole çalıştırdığı için 'setUp/tearDown'a gerek yok.
    // Her test kendi nesnelerini oluşturur.

    @Test @MainActor
    func test_notificationPost_firesOnFailCallback() async {
        // [GIVEN]
        let mockError = NSError(domain: "TestError", code: 123, userInfo: nil)
        let sut = AlfaPlayerItemFailToPlayToEndObserver()
        let testItem = AVPlayerItem(url: URL(string: "file:///dev/null")!)
            
        // 'onFail' callback'ini 'await' etmek için 'withCheckedContinuation' kullan
        let receivedError = await withCheckedContinuation { (continuation: CheckedContinuation<Error?, Never>) in
            
            sut.onFail = { error in
                continuation.resume(returning: error)
            }
            
            sut.playerItem = testItem // Gözlemciyi başlat
            
            // [WHEN] Manuel olarak 'FailedToPlayToEndTime' notification'ı yayınla
            let userInfo = [AVPlayerItemFailedToPlayToEndTimeErrorKey: mockError]
            NotificationCenter.default.post(
                name: .AVPlayerItemFailedToPlayToEndTime,
                object: testItem,
                userInfo: userInfo
            )
        }
            
        // [THEN]
        #expect((receivedError as NSError?) == mockError, "Callback doğru hatayı almadı.")
    }
    
    @Test @MainActor
    func test_replacePlayerItem_removesOldObserver() async {
        // [GIVEN]
        let sut = AlfaPlayerItemFailToPlayToEndObserver()
        let item1 = AVPlayerItem(url: URL(string: "file:///dev/null-1")!)
        let item2 = AVPlayerItem(url: URL(string: "file:///dev/null-2")!)
        
        var didFailCallbackFire = false
        
        sut.onFail = { _ in
            didFailCallbackFire = true // Eğer tetiklenirse, test fail olur
        }
            
        sut.playerItem = item1 // Önce item1'i dinle
        sut.playerItem = item2 // Sonra item2'yi dinle (eski gözlemci kalkmalı)
            
        // [WHEN] Eski item (item1) için bir notification yayınla
        NotificationCenter.default.post(name: .AVPlayerItemFailedToPlayToEndTime, object: item1)
        
        // 'Notification' asenkron olabileceğinden, 'run loop'un
        // bir sonraki döngüsüne kadar kısa bir süre bekle.
        try? await Task.sleep(nanoseconds: 10_000_000) // 0.01 saniye
            
        // [THEN]
        #expect(didFailCallbackFire == false, "Callback eski item için tetiklenmemeliydi.")
    }
}
