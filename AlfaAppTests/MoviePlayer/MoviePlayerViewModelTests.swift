//
//  MoviePlayerViewModelTests.swift
//  AlfaAppTests
//
//  Created by Onur Yilmaz on 18.10.2025.
//

import XCTest
import Combine
@testable import AlfaApp

// MARK: MoviePlayerViewModelTests
final class MoviePlayerViewModelTests: XCTestCase {

    var sut: MoviePlayerViewModel! // SUT (System Under Test)

    // Mocks
    var mockRepository: MockMoviePlayerRepository!
    var mockCoordinator: MockMoviePlayerCoordinator!
    var mockVMLogic: MockMoviePlayerVMLogic!
    
    // State Collectors
    var viewStates: ValueCollector<MoviePlayerViewState>!
    var errorStates: ValueCollector<String>!
    
    // Cancellables
    var subscriptions: Set<AnyCancellable>!

    override func setUpWithError() throws {
        try super.setUpWithError()
        
        subscriptions = Set<AnyCancellable>()
        mockRepository = MockMoviePlayerRepository()
        mockCoordinator = MockMoviePlayerCoordinator()
        
        let mockMovieModel = DiscoverResultUIModel(id: 456, title: "Mock Title", posterURL: nil)
        let mockParams = MoviePlayerParams(movie: mockMovieModel)
        mockVMLogic = MockMoviePlayerVMLogic(params: mockParams)

        sut = MoviePlayerViewModel(
            repository: mockRepository,
            coordinator: mockCoordinator,
            vmLogic: mockVMLogic
        )
        
        // ViewModel'in state'lerini dinlemek için collector'ları ayarla
        viewStates = ValueCollector(sut.viewState.compactMap { $0 })
        errorStates = ValueCollector(sut.errorState.compactMap { $0 })
    }

    override func tearDownWithError() throws {
        sut = nil
        mockRepository = nil
        mockCoordinator = nil
        mockVMLogic = nil
        viewStates = nil
        errorStates = nil
        subscriptions = nil
        try super.tearDownWithError()
    }
}

// MARK: ViewModel Tests & Service
extension MoviePlayerViewModelTests {

    func test_fetchVideoURL_onSuccess_sendsCorrectViewStates() async throws {
        // [Given]
        let expectedURL = URL(string: "https://example.com/video.m3u8")!
        let expectedTitle = "Test Başlığı"
        
        mockRepository.fetchURLResult = .success(expectedURL)
        mockVMLogic.stubbedVideoTitle = expectedTitle

        // [When]
        sut.fetchVideoURL()
        
        // ViewModel'in içindeki '@MainActor Task'in tamamlanması için kısa bir süre bekle
        try await Task.sleep(nanoseconds: 100_000_000) // 0.1 saniye

        // [Then]
        XCTAssertEqual(viewStates.values.count, 2, "İki adet state yayınlanmalı (loading ve videoLoaded).")
        
        guard viewStates.values.count == 2 else {
            XCTFail("Beklenen sayıda state yayınlanmadı."); return
        }

        XCTAssertEqual(viewStates.values[0], .loading(true), "İlk state loading(true) olmalı.")
        XCTAssertEqual(viewStates.values[1], .videoLoaded(url: expectedURL, title: expectedTitle), "İkinci state videoLoaded olmalı.")
        XCTAssertTrue(errorStates.values.isEmpty, "Başarı durumunda hata yayınlanmamalı.")
    }
    
    func test_fetchVideoURL_onFailure_sendsCorrectErrorAndStates() async throws {
        // [Given]
        let mockError = MockError(description: "Ağ Hatası")
        mockRepository.fetchURLResult = .failure(mockError)

        // [When]
        sut.fetchVideoURL()
        
        try await Task.sleep(nanoseconds: 100_000_000) // 0.1 saniye

        // [Then]
        XCTAssertEqual(viewStates.values.count, 2, "İki adet state yayınlanmalı (loading(true) ve loading(false)).")
        
        guard viewStates.values.count == 2 else {
            XCTFail("Beklenen sayıda state yayınlanmadı."); return
        }
        
        XCTAssertEqual(viewStates.values[0], .loading(true), "İlk state loading(true) olmalı.")
        XCTAssertEqual(viewStates.values[1], .loading(false), "İkinci state loading(false) olmalı.")
        
        XCTAssertEqual(errorStates.values.count, 1, "Bir adet hata yayınlanmalı.")
        XCTAssertEqual(errorStates.values.first, "Failed to fetch video URL.")
    }
}

// MARK: ViewModel Tests & Coordinator
extension MoviePlayerViewModelTests {
    
    func test_closeButtonTapped_invokesCoordinatorDismiss() {
        // [Given]
        XCTAssertFalse(mockCoordinator.invokedDismiss, "Başlangıçta coordinator.dismiss çağrılmamış olmalı.")

        // [When]
        sut.closeButtonTapped()
        
        // [Then]
        XCTAssertTrue(mockCoordinator.invokedDismiss, "closeButtonTapped, coordinator.dismiss'i tetiklemeli.")
        XCTAssertEqual(mockCoordinator.invokedDismissAnimated, true, "Dismiss işlemi animasyonlu olmalı.")
    }
}

// MARK: ViewModel Tests & Player Lifecycle
extension MoviePlayerViewModelTests {

    func test_playerIsReady_sendsUpdateDurationAndPlayStates() {
        // [Given]
        let totalDuration: Double = 180.0 // 3 dakika
        let expectedFormattedTime = "03:00"
        
        // VMLogic'in 180.0 saniye için "03:00" döndüreceğini sapla (stub)
        mockVMLogic.formatTimeHandler = { seconds in
            XCTAssertEqual(seconds, totalDuration, "formatTime doğru saniye ile çağrılmalı.")
            return expectedFormattedTime
        }
        
        // [When]
        sut.playerIsReady(totalDuration: totalDuration)
        
        // [Then]
        XCTAssertEqual(viewStates.values, [
            .updateDurationText(expectedFormattedTime),
            .play
        ], "playerIsReady önce süreyi güncellemeli, sonra otomatik oynatmalı.")
    }
    
    func test_playerDidFail_sendsErrorAndLoadingStates() {
        // [Given]
        // (SUT ayarlanmıştı)
        
        // [When]
        sut.playerDidFail()
        
        // [Then]
        XCTAssertEqual(viewStates.values, [.loading(false)], "Player hata verdiğinde loading state'i false olmalı.")
        XCTAssertEqual(errorStates.values, ["Video could not be loaded."], "Player hata verdiğinde uygun hata mesajı gönderilmeli.")
    }
    
    func test_timeProgressed_sendsUpdateProgressState() {
        // [Given]
        // Önce player'ı hazırla (totalDuration set edilir)
        sut.playerIsReady(totalDuration: 100.0)
        
        let currentTime: Double = 30.0
        let expectedProgress: Float = 0.3
        let expectedTimeText = "00:30"
        
        mockVMLogic.formatTimeHandler = { seconds in
            XCTAssertEqual(seconds, currentTime)
            return expectedTimeText
        }
        
        // 'playerIsReady'den gelen state'leri temizle
        viewStates.values.removeAll()
        
        // [When]
        sut.timeProgressed(to: currentTime)
        
        // [Then]
        XCTAssertEqual(viewStates.values, [
            .updateProgress(progress: expectedProgress, time: expectedTimeText)
        ], "timeProgressed, ilerlemeyi ve zaman metnini güncellemeli.")
    }
    
    func test_timeProgressed_whenTotalDurationIsZero_doesNotSendState() {
        // [Given]
        // playerIsReady çağrılmadı, bu yüzden totalDuration 0 olmalı.
        
        // [When]
        sut.timeProgressed(to: 30.0)
        
        // [Then]
        XCTAssertTrue(viewStates.values.isEmpty, "totalDuration 0 ise .updateProgress state'i gönderilmemeli.")
    }
}

// MARK: ViewModel Tests & Playback Controls
extension MoviePlayerViewModelTests {

    func test_playButtonTapped_sendsPlayState() {
        // [When]
        sut.playButtonTapped()
        // [Then]
        XCTAssertEqual(viewStates.values, [.play])
    }
    
    func test_pauseButtonTapped_sendsPauseState() {
        // [When]
        sut.pauseButtonTapped()
        // [Then]
        XCTAssertEqual(viewStates.values, [.pause])
    }
    
    func test_skip_byPositiveSeconds_sendsSeekState() {
        // [Given]
        sut.playerIsReady(totalDuration: 100.0)
        sut.timeProgressed(to: 20.0)
        viewStates.values.removeAll() // Önceki state'leri temizle
        
        // [When]
        sut.skip(by: 10.0) // 10 saniye ileri sar
        
        // [Then]
        XCTAssertEqual(viewStates.values, [.seek(toSeconds: 30.0)])
    }
    
    func test_skip_byNegativeSeconds_sendsSeekState() {
        // [Given]
        sut.playerIsReady(totalDuration: 100.0)
        sut.timeProgressed(to: 20.0)
        viewStates.values.removeAll()
        
        // [When]
        sut.skip(by: -10.0) // 10 saniye geri sar
        
        // [Then]
        XCTAssertEqual(viewStates.values, [.seek(toSeconds: 10.0)])
    }
    
    func test_skip_byNegativeSeconds_clampsAtZero() {
        // [Given]
        sut.playerIsReady(totalDuration: 100.0)
        sut.timeProgressed(to: 5.0)
        viewStates.values.removeAll()
        
        // [When]
        sut.skip(by: -10.0) // 10 saniye geri sar (5 - 10 = -5)
        
        // [Then]
        XCTAssertEqual(viewStates.values, [.seek(toSeconds: 0.0)], "Geri sarma işlemi 0'ın altına inmemeli (clamp).")
    }
}

// MARK: ViewModel Tests & Seeking
extension MoviePlayerViewModelTests {
    
    func test_beginSeeking_sendsPauseState() {
        // [When]
        sut.beginSeeking()
        // [Then]
        XCTAssertEqual(viewStates.values, [.pause], "Seek başladığında video duraklatılmalı.")
    }
    
    func test_seek_toProgress_sendsSeekState() {
        // [Given]
        sut.playerIsReady(totalDuration: 200.0)
        viewStates.values.removeAll()
        
        // [When]
        sut.seek(toProgress: 0.5) // %50'ye seek et
        
        // [Then]
        XCTAssertEqual(viewStates.values, [.seek(toSeconds: 100.0)])
    }
    
    func test_seek_toProgress_whenTotalDurationIsZero_doesNotSendState() {
        // [Given]
        // playerIsReady çağrılmadı (totalDuration = 0)
        
        // [When]
        sut.seek(toProgress: 0.5)
        
        // [Then]
        XCTAssertTrue(viewStates.values.isEmpty, "totalDuration 0 ise seek state'i gönderilmemeli.")
    }
    
    func test_endSeeking_whenWasPlaying_sendsPlayState() {
        // [When]
        sut.endSeeking(wasPlaying: true)
        // [Then]
        XCTAssertEqual(viewStates.values, [.play], "Seek bittiğinde (ve daha önce oynuyorsa) .play state'i gönderilmeli.")
    }
    
    func test_endSeeking_whenWasNotPlaying_doesNotSendPlayState() {
        // [When]
        sut.endSeeking(wasPlaying: false)
        // [Then]
        XCTAssertTrue(viewStates.values.isEmpty, "Seek bittiğinde (ve daha önce oynamıyorsa) .play state'i gönderilmemeli.")
    }
}
