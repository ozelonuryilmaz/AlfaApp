//
//  MovieExplorerMockVMLogic.swift
//  AlfaAppTests
//
//  Created by Onur Yilmaz on 18.10.2025.
//

import Foundation
@testable import AlfaApp

final class MockMovieExplorerVMLogic: IMovieExplorerVMLogic {

    // MARK: Stubs
    var stubbedGenres: [GenreUIModel] = []
    var stubbedCurrentGenreId: Int?
    var stubbedFirstGenreId: Int?
    var stubbedGenreName: String?
    var stubbedGenreBefore: GenreUIModel?
    var stubbedGenreAfter: GenreUIModel?
    
    // Handler: Karmaşık fonksiyonların davranışını dışarıdan yönetmek için
    var processNextPageHandler: ((GenreCacheEntry, DiscoverResultsUIModel) -> GenreCacheEntry?)?
    
    // MARK: Spies (Casuslar)
    private(set) var invokedSetGenresResponse: Bool = false
    private(set) var invokedSetCurrentGenre: Bool = false
    private(set) var invokedProcessNextPage: Bool = false

    // MARK: Protocol Implementation
    
    var genres: [GenreUIModel] { stubbedGenres }
    var currentGenreId: Int? { stubbedCurrentGenreId }
    
    init() {}
    
    func setGenresResponse(_ genresUIModel: [GenreUIModel]) {
        invokedSetGenresResponse = true
        stubbedGenres = genresUIModel
    }
    
    func setCurrentGenre(genreId: Int) {
        invokedSetCurrentGenre = true
        stubbedCurrentGenreId = genreId
    }
    
    func getFirstGenreId() -> Int? {
        return stubbedFirstGenreId
    }
    
    func getGenreName(for genreId: Int) -> String? {
        return stubbedGenreName
    }
    
    func getGenre(before genreId: Int) -> GenreUIModel? {
        return stubbedGenreBefore
    }
    
    func getGenre(after genreId: Int) -> GenreUIModel? {
        return stubbedGenreAfter
    }
    
    func processNextPage(currentEntry: GenreCacheEntry, newResults: DiscoverResultsUIModel) -> GenreCacheEntry? {
        invokedProcessNextPage = true
        // Eğer bir handler tanımlanmışsa onu kullan, yoksa nil dön
        return processNextPageHandler?(currentEntry, newResults)
    }
}
