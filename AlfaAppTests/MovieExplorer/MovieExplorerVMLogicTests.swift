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

    // MARK: Calculation Tests (processNextPage)
    
    func test_processNextPage_withUniqueMovies() {
        // [GIVEN] Mevcut bir cache ve yeni filmler (duplicate yok)
        let currentMovies = [DiscoverResultUIModel.stub(id: 1, title: "Film 1")]
        let currentEntry = GenreCacheEntry(movies: currentMovies, currentPage: 1, lastContentOffset: .zero)
        let newMovies = [DiscoverResultUIModel.stub(id: 2, title: "Film 2")]
        let newResults = DiscoverResultsUIModel.stub(page: 2, results: newMovies)
        
        // [WHEN] Sayfa işleme fonksiyonunu çağır
        let updatedEntry = sut.processNextPage(currentEntry: currentEntry, newResults: newResults)
        
        // [THEN] Yeni entry, filmleri birleştirmiş ve sayfayı artırmış olmalı
        XCTAssertEqual(updatedEntry?.movies.count, 2)
        XCTAssertEqual(updatedEntry?.currentPage, 2)
        XCTAssertEqual(updatedEntry?.movies.last?.title, "Film 2")
    }
    
    func test_processNextPage_withOnlyDuplicateMovies_returnsNil() {
        // [GIVEN] Mevcut bir cache ve SADECE duplicate olan yeni filmler
        let currentMovies = [DiscoverResultUIModel.stub(id: 1, title: "Film 1")]
        let currentEntry = GenreCacheEntry(movies: currentMovies, currentPage: 1, lastContentOffset: .zero)
        let newMovies = [DiscoverResultUIModel.stub(id: 1, title: "Film 1")] // Duplicate ID
        let newResults = DiscoverResultsUIModel.stub(page: 2, results: newMovies)
        
        // [WHEN] Sayfa işleme fonksiyonunu çağır
        let updatedEntry = sut.processNextPage(currentEntry: currentEntry, newResults: newResults)
        
        // [THEN] Benzersiz yeni film olmadığı için nil dönmeli (pagination durmalı)
        XCTAssertNil(updatedEntry)
    }

    func test_processNextPage_withMixedMovies_appendsOnlyUnique() {
        // [GIVEN] Mevcut bir cache ve karışık (duplicate + unique) filmler
        let currentMovies = [DiscoverResultUIModel.stub(id: 1, title: "Film 1")]
        let currentEntry = GenreCacheEntry(movies: currentMovies, currentPage: 1, lastContentOffset: .zero)
        let newMovies = [
            DiscoverResultUIModel.stub(id: 1, title: "Film 1 - Duplicate"),
            DiscoverResultUIModel.stub(id: 2, title: "Film 2 - Unique")
        ]
        let newResults = DiscoverResultsUIModel.stub(page: 2, results: newMovies)
        
        // [WHEN] Sayfa işleme fonksiyonunu çağır
        let updatedEntry = sut.processNextPage(currentEntry: currentEntry, newResults: newResults)
        
        // [THEN] Sadece benzersiz olan filmi eklemeli (toplam 2 film)
        XCTAssertEqual(updatedEntry?.movies.count, 2)
        XCTAssertEqual(updatedEntry?.movies.last?.title, "Film 2 - Unique")
    }

    func test_processNextPage_withEmptyNewResults_returnsNil() {
        // [GIVEN] Servisten boş bir 'results' dizisi geldi
        let currentEntry = GenreCacheEntry(movies: [], currentPage: 1, lastContentOffset: .zero)
        let newResults = DiscoverResultsUIModel.stub(page: 2, results: [])
        
        // [WHEN] Sayfa işleme fonksiyonunu çağır
        let updatedEntry = sut.processNextPage(currentEntry: currentEntry, newResults: newResults)
        
        // [THEN] Boş sonuç geldiği için nil dönmeli
        XCTAssertNil(updatedEntry)
    }
}
