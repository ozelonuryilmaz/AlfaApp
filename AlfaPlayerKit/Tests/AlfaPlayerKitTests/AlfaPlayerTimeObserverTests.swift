//
//  File.swift
//  AlfaPlayerKit
//
//  Created by Onur Yilmaz on 18.10.2025.
//

import Testing
import AVFoundation
@testable import AlfaPlayerKit

struct AlfaPlayerTimeObserverTests {

    @Test @MainActor
    func test_addObserver_invokesPlayerMethod() {
        // [GIVEN]
        let mockPlayer = MockPlayer()
        let sut = AlfaPlayerTimeObserver(mockPlayer)
        
        // [WHEN] Gözlemci eklendiğinde
        sut.addObserver(interval: CMTime(seconds: 1, preferredTimescale: 600))
        
        // [THEN] 'MockPlayer'ın ilgili fonksiyonu çağrılmalı
        // 'XCTAssertTrue' yerine '#expect' makrosunu kullan
        #expect(mockPlayer.invokedAddPeriodicTimeObserver)
    }
    
    @Test @MainActor
    func test_addObserver_whenAlreadyAdded_doesNotAddAgain() {
        // [GIVEN]
        let mockPlayer = MockPlayer()
        let sut = AlfaPlayerTimeObserver(mockPlayer)

        // [WHEN] Gözlemci iki kez eklendiğinde
        sut.addObserver(interval: CMTime(seconds: 1, preferredTimescale: 600))
        sut.addObserver(interval: CMTime(seconds: 1, preferredTimescale: 600))

        // [THEN] 'MockPlayer'ın fonksiyonu sadece bir kez çağrılmalı
        #expect(mockPlayer.addPeriodicTimeObserverCallCount == 1)
    }
    
    @Test @MainActor
    func test_removeObserver_invokesPlayerMethod() {
        // [GIVEN]
        let mockPlayer = MockPlayer()
        let sut = AlfaPlayerTimeObserver(mockPlayer)
        sut.addObserver(interval: CMTime(seconds: 1, preferredTimescale: 600))
            
        // [WHEN] Gözlemci kaldırıldığında
        sut.removeObserver()
            
        // [THEN] 'MockPlayer'ın ilgili fonksiyonu çağrılmalı
        #expect(mockPlayer.invokedRemoveTimeObserver)
    }
    
    @Test @MainActor
    func test_deinit_removesObserver() {
        // [GIVEN]
        let mockPlayer = MockPlayer()
        
        // 'sut'u bu scope içinde oluştur
        var localSut: AlfaPlayerTimeObserver? = AlfaPlayerTimeObserver(mockPlayer)
        localSut?.addObserver(interval: CMTime(seconds: 1, preferredTimescale: 600))
        
        #expect(mockPlayer.invokedRemoveTimeObserver == false)

        // [WHEN] 'localSut' scope dışına çıktığında deinit tetiklenir
        localSut = nil
        
        // [THEN]
        #expect(mockPlayer.invokedRemoveTimeObserver, "deinit, gözlemciyi temizlemeli.")
    }
}
