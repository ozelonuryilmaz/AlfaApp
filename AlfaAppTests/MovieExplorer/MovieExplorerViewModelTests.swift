//
//  MovieExplorerViewModelTests.swift
//  AlfaAppTests
//
//  Created by Onur Yilmaz on 18.10.2025.
//

import XCTest
import Combine
@testable import AlfaApp

final class MovieExplorerViewModelTests: XCTestCase {

    // SUT
    var sut: MovieExplorerViewModel!

    // Mocks
    var mockRepository: MockMovieExplorerRepository!
    var mockCoordinator: MockMovieExplorerCoordinator!
    var mockScrollPositionService: MockScrollPositionService!
    var mockVMLogic: MockMovieExplorerVMLogic!
    
    // Test Support
    var viewStates: ValueCollector<MovieExplorerViewState>!
    var errorStates: ValueCollector<String>!
    var subscriptions: Set<AnyCancellable>!

    override func setUpWithError() throws {
        try super.setUpWithError()
        subscriptions = Set<AnyCancellable>()
        mockRepository = MockMovieExplorerRepository()
        mockCoordinator = MockMovieExplorerCoordinator()
        mockScrollPositionService = MockScrollPositionService()
        mockVMLogic = MockMovieExplorerVMLogic()

        sut = MovieExplorerViewModel(
            repository: mockRepository,
            coordinator: mockCoordinator,
            scrollPositionService: mockScrollPositionService,
            vmLogic: mockVMLogic
        )
        
        viewStates = ValueCollector(sut.viewState.compactMap { $0 })
        errorStates = ValueCollector(sut.errorState.compactMap { $0 })
    }

    override func tearDownWithError() throws {
        sut = nil
        mockRepository = nil
        mockCoordinator = nil
        mockScrollPositionService = nil
        mockVMLogic = nil
        viewStates = nil
        errorStates = nil
        subscriptions = nil
        try super.tearDownWithError()
    }
    
    // MARK: Initial Data Fetch
    
    func test_fetchInitialData_onSuccess_loadsGenresAndFirstPageMovies() async throws {
        // [GIVEN] Hem 'genres' hem de 'discover' servislerinin başarılı olacağını sapla (stub)
        let mockGenres = GenresUIModel.stub(genres: [GenreUIModel(id: 1, name: "Action")])
        let mockMovies = DiscoverResultsUIModel.stub(page: 1, results: [DiscoverResultUIModel.stub(id: 101, title: "Film")])
        
        mockRepository.fetchGenresResult = .success(mockGenres)
        mockRepository.fetchDiscoverResult = .success(mockMovies)
        
        // VMLogic'in ilk kategori ID'sini 1 olarak döndürmesini sağla
        mockVMLogic.stubbedFirstGenreId = 1
        // VMLogic'in yeni filmleri döndürmesini sağla
        mockVMLogic.stubbedMovies = mockMovies.results
        // Scroll servisi .zero döndürsün
        mockScrollPositionService.stubbedPosition = .zero
        
        // [WHEN] Başlangıç verisini çek
        sut.fetchInitialData()
        try await Task.sleep(nanoseconds: 100_000_000) // Async @MainActor task'in bitmesini bekle

        // [THEN] State'lerin doğru sırada tetiklendiğini doğrula
        XCTAssertEqual(viewStates.values, [
            .initialLoading,
            .genresLoaded,
            .moviesLoading(genreId: 1),
            .moviesLoaded(genreId: 1, movies: mockMovies.results, initialOffset: .zero, isPagination: false)
        ])
        
        // Bağımlılıkların doğru çağrıldığını doğrula
        XCTAssertTrue(mockVMLogic.invokedSetGenresResponse, "Kategoriler VMLogic'e set edilmeli.")
        XCTAssertTrue(mockVMLogic.invokedSetCurrentGenre, "İlk kategori VMLogic'e set edilmeli.")
        // Repository'nin 'forceRefresh: true' ile çağrıldığını doğrula
        XCTAssertEqual(mockRepository.invokedFetchDiscoverParams?.genreId, 1)
        XCTAssertEqual(mockRepository.invokedFetchDiscoverParams?.page, 1)
        XCTAssertEqual(mockRepository.invokedFetchDiscoverParams?.forceRefresh, true)
        // VMLogic'in filmleri güncellediğini doğrula
        XCTAssertTrue(mockVMLogic.invokedUpdateMovies)
        XCTAssertTrue(errorStates.values.isEmpty, "Başarı durumunda hata olmamalı.")
    }
    
    func test_fetchInitialData_onGenreFailure_sendsError() async throws {
        // [GIVEN] 'genres' servisinin hata vereceğini sapla
        let error = MockError(description: "Kategori Hatası")
        mockRepository.fetchGenresResult = .failure(error)
        
        // [WHEN] Başlangıç verisini çek
        sut.fetchInitialData()
        try await Task.sleep(nanoseconds: 100_000_000)

        // [THEN] Sadece 1 state (loading) ve 1 hata state'i olmalı
        XCTAssertEqual(viewStates.values, [.initialLoading])
        XCTAssertEqual(errorStates.values.count, 1)
        // ViewModel'deki yeni hata formatına uy
        let expectedError = "Kategoriler yüklenemedi: \(error.localizedDescription)"
        XCTAssertEqual(errorStates.values.first, expectedError)
    }

    // MARK: Load Movies
    
    func test_loadMovies_fetchesNewMoviesAndReadsOffset() async throws {
        // [GIVEN] Cache servisi 'nil' döndürecek (cache miss)
        let expectedOffset = CGPoint(x: 0, y: 150)
        mockScrollPositionService.stubbedPosition = expectedOffset
        
        // Repository'nin yeni filmler döndüreceğini sapla
        let newMovies = DiscoverResultsUIModel.stub(page: 1, results: [DiscoverResultUIModel.stub(id: 101, title: "New Movie")])
        mockRepository.fetchDiscoverResult = .success(newMovies)
        mockVMLogic.stubbedMovies = newMovies.results
        
        // [WHEN] Filmleri 'forceRefresh: false' ile yükle
        sut.loadMovies(for: 1, forceRefresh: false)
        try await Task.sleep(nanoseconds: 100_000_000)
        
        // [THEN] Önce loading, sonra yeni filmlerle ve doğru offset ile loaded state'i gönderilmeli
        XCTAssertEqual(viewStates.values, [
            .moviesLoading(genreId: 1),
            .moviesLoaded(genreId: 1, movies: newMovies.results, initialOffset: expectedOffset, isPagination: false)
        ])
        
        // Repository'nin doğru parametrelerle çağrıldığını doğrula
        XCTAssertEqual(mockRepository.invokedFetchDiscoverParams?.genreId, 1)
        XCTAssertEqual(mockRepository.invokedFetchDiscoverParams?.page, 1)
        XCTAssertEqual(mockRepository.invokedFetchDiscoverParams?.forceRefresh, false)
        // Yeni verinin VMLogic'e işlendiğini doğrula
        XCTAssertTrue(mockVMLogic.invokedUpdateMovies)
        // Scroll pozisyonunun okunduğunu doğrula
        XCTAssertTrue(mockScrollPositionService.invokedGetPosition)
    }

    // MARK: Pagination
    
    func test_loadNextPage_onSuccess_appendsMovies() async throws {
        // [GIVEN] Gerekli bağımlılıkları ayarla
        let genreId = 1
        let nextPage = 2
        let newPageMovies = DiscoverResultsUIModel.stub(page: 2, results: [DiscoverResultUIModel.stub(id: 2, title: "Film 2")])
        
        mockVMLogic.stubbedCurrentGenreId = genreId
        mockVMLogic.stubbedNextPage = nextPage // VMLogic'in sonraki sayfayı (2) döndürmesini sağla
        mockRepository.fetchDiscoverResult = .success(newPageMovies) // Repo'nun 2. sayfayı dönmesini sağla
        mockScrollPositionService.stubbedPosition = .zero
        
        // [WHEN] Sonraki sayfayı yükle
        sut.loadNextPage()
        try await Task.sleep(nanoseconds: 100_000_000)
        
        // [THEN] Repository'nin 2. sayfayı istediğini doğrula
        XCTAssertEqual(mockRepository.invokedFetchDiscoverParams?.genreId, genreId)
        XCTAssertEqual(mockRepository.invokedFetchDiscoverParams?.page, nextPage)
        XCTAssertEqual(mockRepository.invokedFetchDiscoverParams?.forceRefresh, false) // Pagination'da refresh false olmalı
        
        // VMLogic'in birleştirme işlemini yaptığını doğrula
        XCTAssertTrue(mockVMLogic.invokedUpdateMovies)
        
        // View'a 'isPagination: true' state'inin gönderildiğini doğrula
        let lastState = viewStates.values.last
        XCTAssertEqual(lastState, .moviesLoaded(genreId: genreId, movies: [DiscoverResultUIModel(id: 2, title: "Film 2", posterURL: nil)], initialOffset: .zero, isPagination: true))
    }

    // MARK: Coordinator & Cache Actions
    
    func test_movieTapped_invokesCoordinator() {
        // [GIVEN] Sahte bir film modeli
        let movie = DiscoverResultUIModel.stub(id: 123, title: "Tapped Movie")
        
        // [WHEN] Filme tıklandı
        sut.movieTapped(movie: movie)
        
        // [THEN] Coordinator'ın doğru fonksiyonu doğru parametre ile çağırdığını doğrula
        XCTAssertTrue(mockCoordinator.invokedPresentToMoviePlayerVC)
        XCTAssertEqual(mockCoordinator.invokedPresentToMoviePlayerVCWithMovie?.id, 123)
    }

    func test_saveScrollPosition_invokesCacheService() {
        // [GIVEN] Sahte bir offset ve kategori ID'si
        let offset = CGPoint(x: 0, y: 500)
        let genreId = 3
        
        // [WHEN] Scroll pozisyonunu kaydet
        sut.saveScrollPosition(offset, for: genreId)
        
        // [THEN] Cache servisinin doğru fonksiyonu doğru parametrelerle çağırdığını doğrula
        XCTAssertTrue(mockScrollPositionService.invokedSavePosition)
        XCTAssertEqual(mockScrollPositionService.invokedSavePositionParams?.genreId, genreId)
        XCTAssertEqual(mockScrollPositionService.invokedSavePositionParams?.offset, offset)
    }
    
    // MARK: Deinit
    
    func test_deinit_clearsCaches() {
        // [GIVEN] SUT'u lokal bir değişkende oluştur
        var localSut: MovieExplorerViewModel? = MovieExplorerViewModel(
            repository: mockRepository,
            coordinator: mockCoordinator,
            scrollPositionService: mockScrollPositionService,
            vmLogic: mockVMLogic
        )
        
        // Başlangıçta fonksiyonların çağrılmadığını doğrula
        XCTAssertFalse(mockRepository.invokedClearCache)
        XCTAssertFalse(mockScrollPositionService.invokedClearCache)
        
        // [WHEN] SUT referansı nil yapılır ve deinit tetiklenir
        localSut = nil
        
        // [THEN] Her iki cache servisi de temizlenmeli
        XCTAssertTrue(mockRepository.invokedClearCache)
        XCTAssertTrue(mockScrollPositionService.invokedClearCache)
    }
}
