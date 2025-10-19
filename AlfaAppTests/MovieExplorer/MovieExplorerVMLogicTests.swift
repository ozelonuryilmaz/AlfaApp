//
//  MovieExplorerVMLogicTests.swift
//  AlfaAppTests
//
//  Created by Onur Yilmaz on 18.10.2025.
//

import XCTest
@testable import AlfaApp

final class MovieExplorerVMLogicTests: XCTestCase {

    var sut: MovieExplorerVMLogic!
    var mockGenres: [GenreUIModel]!

    override func setUpWithError() throws {
        try super.setUpWithError()
        sut = MovieExplorerVMLogic()
        
        // [GIVEN] Testler için sahte bir kategori listesi oluştur
        mockGenres = [
            GenreUIModel(id: 1, name: "Action"),
            GenreUIModel(id: 2, name: "Comedy"),
            GenreUIModel(id: 3, name: "Drama")
        ]
        sut.setGenresResponse(mockGenres)
    }

    override func tearDownWithError() throws {
        sut = nil
        mockGenres = nil
        try super.tearDownWithError()
    }

    // MARK: Getter Tests
    
    func test_getGenre_before_success() {
        // [WHEN] Ortadaki bir kategoriden (Comedy) bir öncekini istiyoruz
        let previousGenre = sut.getGenre(before: 2) // ID: 2 (Comedy)
        
        // [THEN] Bir önceki kategori (Action) gelmeli
        XCTAssertEqual(previousGenre?.id, 1)
        XCTAssertEqual(previousGenre?.name, "Action")
    }
    
    func test_getGenre_before_atFirstIndex_returnsNil() {
        // [WHEN] Listenin başındaki kategoriden (Action) bir öncekini istiyoruz
        let previousGenre = sut.getGenre(before: 1) // ID: 1 (Action)
        
        // [THEN] Sınırların dışında olduğu için nil dönmeli
        XCTAssertNil(previousGenre)
    }
    
    func test_getGenre_after_success() {
        // [WHEN] Ortadaki bir kategoriden (Comedy) bir sonrakini istiyoruz
        let nextGenre = sut.getGenre(after: 2) // ID: 2 (Comedy)
        
        // [THEN] Bir sonraki kategori (Drama) gelmeli
        XCTAssertEqual(nextGenre?.id, 3)
        XCTAssertEqual(nextGenre?.name, "Drama")
    }

    func test_getGenre_after_atLastIndex_returnsNil() {
        // [WHEN] Listenin sonundaki kategoriden (Drama) bir sonrakini istiyoruz
        let nextGenre = sut.getGenre(after: 3) // ID: 3 (Drama)
        
        // [THEN] Sınırların dışında olduğu için nil dönmeli
        XCTAssertNil(nextGenre)
    }

    // MARK: Movie & Pagination Tests
    
    func test_updateMovies_storesMoviesAndPage() {
        // [GIVEN] 1. sayfa için filmler
        let moviesPage1 = [DiscoverResultUIModel.stub(id: 1, title: "Film 1")]
        let resultsPage1 = DiscoverResultsUIModel.stub(page: 1, results: moviesPage1)
        
        // [WHEN] 1. sayfayı VMLogic'e işle
        sut.updateMovies(for: 10, with: resultsPage1)
        
        // [THEN] Filmler ve sayfa doğru depolanmalı
        XCTAssertEqual(sut.getMovies(for: 10).count, 1)
        XCTAssertEqual(sut.getMovies(for: 10).first?.title, "Film 1")
        
        // [GIVEN] 2. sayfa için filmler
        let moviesPage2 = [DiscoverResultUIModel.stub(id: 2, title: "Film 2")]
        let resultsPage2 = DiscoverResultsUIModel.stub(page: 2, results: moviesPage2)
        
        // [WHEN] 2. sayfayı işle (Yeni VMLogic artık birleştirme yapmıyor, üzerine yazıyor)
        sut.updateMovies(for: 10, with: resultsPage2)
        
        // [THEN] VMLogic artık *sadece* 2. sayfa filmlerini tutmalı
        XCTAssertEqual(sut.getMovies(for: 10).count, 1)
        XCTAssertEqual(sut.getMovies(for: 10).first?.title, "Film 2")
    }
    
    func test_getNextPage_whenNotSet_returnsOne() {
        // [WHEN] Sonraki sayfa istenir
        let nextPage = sut.getNextPageForCurrentGenre()
        
        // [THEN] Varsayılan olarak 1. sayfayı döndürmeli
        XCTAssertEqual(nextPage, 1)
    }

    func test_getNextPage_whenPageOneExists_returnsTwo() {
        // [GIVEN] 1. sayfa verisi işlenmiş ve mevcut kategori set edilmiş
        let moviesPage1 = [DiscoverResultUIModel.stub(id: 1, title: "Film 1")]
        let resultsPage1 = DiscoverResultsUIModel.stub(page: 1, results: moviesPage1)
        sut.setCurrentGenre(genreId: 10)
        sut.updateMovies(for: 10, with: resultsPage1)
        
        // [WHEN] Sonraki sayfa istenir
        let nextPage = sut.getNextPageForCurrentGenre()
        
        // [THEN] 2. sayfayı (1 + 1) döndürmeli
        XCTAssertEqual(nextPage, 2)
    }
}
