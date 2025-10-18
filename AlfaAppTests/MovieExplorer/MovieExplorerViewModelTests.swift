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
    var mockVMLogic: MockMovieExplorerVMLogic!
    var mockCacheService: MockMovieCacheService!
    
    // Test Support
    var viewStates: ValueCollector<MovieExplorerViewState>!
    var errorStates: ValueCollector<String>!
    var subscriptions: Set<AnyCancellable>!

    override func setUpWithError() throws {
        try super.setUpWithError()
        subscriptions = Set<AnyCancellable>()
        mockRepository = MockMovieExplorerRepository()
        mockCoordinator = MockMovieExplorerCoordinator()
        mockVMLogic = MockMovieExplorerVMLogic()
        mockCacheService = MockMovieCacheService()

        sut = MovieExplorerViewModel(
            repository: mockRepository,
            coordinator: mockCoordinator,
            vmLogic: mockVMLogic,
            cacheService: mockCacheService
        )
        
        viewStates = ValueCollector(sut.viewState.compactMap { $0 })
        errorStates = ValueCollector(sut.errorState.compactMap { $0 })
    }

    override func tearDownWithError() throws {
        sut = nil
        mockRepository = nil
        mockCoordinator = nil
        mockVMLogic = nil
        mockCacheService = nil
        viewStates = nil
        errorStates = nil
        subscriptions = nil
        try super.tearDownWithError()
    }
    
    // MARK: Initial Data Fetch
    
    func test_fetchInitialData_onSuccess_loadsGenresAndFirstPageMovies() async throws {
        // [GIVEN] Hem 'genres' hem de 'discover' servislerinin başarılı olacağını sapla (stub)
        let mockGenres = GenresUIModel.stub(genres: [GenreUIModel(id: 1, name: "Action")]) //
        let mockMovies = DiscoverResultsUIModel.stub(page: 1, results: [DiscoverResultUIModel.stub(id: 101, title: "Film")])
        
        mockRepository.fetchGenresResult = .success(mockGenres)
        mockRepository.fetchDiscoverResult = .success(mockMovies)
        
        // VMLogic'in ilk kategori ID'sini 1 olarak döndürmesini sağla
        mockVMLogic.stubbedFirstGenreId = 1
        
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
        XCTAssertTrue(mockCacheService.invokedCache, "İlk sayfa filmleri cache'lenmeli.")
        XCTAssertTrue(errorStates.values.isEmpty, "Başarı durumunda hata olmamalı.")
    }
    
    func test_fetchInitialData_onGenreFailure_sendsError() async throws {
        // [GIVEN] 'genres' servisinin hata vereceğini sapla
        mockRepository.fetchGenresResult = .failure(MockError(description: "Genre Error"))
        
        // [WHEN] Başlangıç verisini çek
        sut.fetchInitialData()
        try await Task.sleep(nanoseconds: 100_000_000)

        // [THEN] Sadece 1 state (loading) ve 1 hata state'i olmalı
        XCTAssertEqual(viewStates.values, [.initialLoading])
        XCTAssertEqual(errorStates.values.count, 1)
        XCTAssertEqual(errorStates.values.first, "Kategoriler yüklenemedi: The operation couldn’t be completed. (AlfaAppTests.MockError error 1.)")
    }

    // MARK: - Load Movies (Cache Hit/Miss)

    func test_loadMovies_withCacheHit_sendsCachedMovies() {
        // [GIVEN] Cache servisinin belirli bir kategori için dolu bir entry döndüreceğini sapla
        let cachedMovies = [DiscoverResultUIModel.stub(id: 99, title: "Cached Movie")]
        let cachedEntry = GenreCacheEntry(movies: cachedMovies, currentPage: 1, lastContentOffset: CGPoint(x: 0, y: 100))
        mockCacheService.stubbedEntry = cachedEntry
        
        // [WHEN] Filmleri yükle
        sut.loadMovies(for: 9)
        
        // [THEN] Cache'den gelen filmler ve offset ile .moviesLoaded state'i gönderilmeli
        XCTAssertEqual(viewStates.values, [
            .moviesLoaded(genreId: 9, movies: cachedMovies, initialOffset: cachedEntry.lastContentOffset, isPagination: false)
        ])
        // Repository'nin çağrılmadığını doğrula (en önemlisi)
        XCTAssertNil(mockRepository.invokedFetchDiscoverParams, "Cache hit olduğunda repository çağrılmamalı.")
    }

    func test_loadMovies_withCacheMiss_fetchesNewMovies() async throws {
        // [GIVEN] Cache servisi 'nil' döndürecek (cache miss)
        mockCacheService.stubbedEntry = nil
        
        // Repository'nin yeni filmler döndüreceğini sapla
        let newMovies = DiscoverResultsUIModel.stub(page: 1, results: [DiscoverResultUIModel.stub(id: 101, title: "New Movie")])
        mockRepository.fetchDiscoverResult = .success(newMovies)
        
        // [WHEN] Filmleri yükle
        sut.loadMovies(for: 1)
        try await Task.sleep(nanoseconds: 100_000_000)
        
        // [THEN] Önce loading, sonra yeni filmlerle loaded state'i gönderilmeli
        XCTAssertEqual(viewStates.values, [
            .moviesLoading(genreId: 1),
            .moviesLoaded(genreId: 1, movies: newMovies.results, initialOffset: .zero, isPagination: false)
        ])
        
        // Repository'nin doğru parametrelerle çağrıldığını doğrula
        XCTAssertEqual(mockRepository.invokedFetchDiscoverParams?.genreId, 1)
        XCTAssertEqual(mockRepository.invokedFetchDiscoverParams?.page, 1)
        // Yeni verinin cache'lendiğini doğrula
        XCTAssertTrue(mockCacheService.invokedCache)
    }

    // MARK: Pagination
    
    func test_loadNextPage_onSuccess_appendsMovies() async throws {
        // [GIVEN] Gerekli bağımlılıkları ayarla
        let genreId = 1
        let currentMovies = [DiscoverResultUIModel.stub(id: 1, title: "Film 1")]
        let currentEntry = GenreCacheEntry(movies: currentMovies, currentPage: 1, lastContentOffset: .zero) //
        let newPageMovies = DiscoverResultsUIModel.stub(page: 2, results: [DiscoverResultUIModel.stub(id: 2, title: "Film 2")])
        let mergedMovies = currentMovies + newPageMovies.results
        let mergedEntry = GenreCacheEntry(movies: mergedMovies, currentPage: 2, lastContentOffset: .zero) //
        
        mockVMLogic.stubbedCurrentGenreId = genreId // VMLogic'in mevcut kategoriyi bilmesini sağla
        mockCacheService.stubbedEntry = currentEntry // Cache'in 1. sayfayı bilmesini sağla
        mockRepository.fetchDiscoverResult = .success(newPageMovies) // Repo'nun 2. sayfayı dönmesini sağla
        mockVMLogic.processNextPageHandler = { _, _ in mergedEntry } // VMLogic'in veriyi birleştirmesini sağla
        
        // [WHEN] Sonraki sayfayı yükle
        sut.loadNextPage()
        try await Task.sleep(nanoseconds: 100_000_000)
        
        // [THEN] Repository'nin 2. sayfayı istediğini doğrula
        XCTAssertEqual(mockRepository.invokedFetchDiscoverParams?.genreId, genreId)
        XCTAssertEqual(mockRepository.invokedFetchDiscoverParams?.page, 2)
        
        // VMLogic'in birleştirme işlemini yaptığını doğrula
        XCTAssertTrue(mockVMLogic.invokedProcessNextPage)
        
        // Cache'in yeni birleştirilmiş veri ile güncellendiğini doğrula
        XCTAssertTrue(mockCacheService.invokedCache)
        
        // View'a birleştirilmiş listenin gönderildiğini doğrula
        XCTAssertEqual(viewStates.values, [
            .moviesLoaded(genreId: genreId, movies: mergedMovies, initialOffset: .zero, isPagination: true)
        ])
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
        XCTAssertTrue(mockCacheService.invokedUpdateContentOffset)
        XCTAssertEqual(mockCacheService.invokedUpdateContentOffsetParams?.genreId, genreId)
        XCTAssertEqual(mockCacheService.invokedUpdateContentOffsetParams?.offset, offset)
    }
}
