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
    
    var stubbedMovies: [DiscoverResultUIModel] = []
    var stubbedNextPage: Int?
    
    // MARK: Spies (Casuslar)
    private(set) var invokedSetGenresResponse: Bool = false
    private(set) var invokedSetCurrentGenre: Bool = false
    
    private(set) var invokedUpdateMovies: Bool = false
    private(set) var invokedGetMovies: Bool = false
    private(set) var invokedGetNextPage: Bool = false

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
    
    func updateMovies(for genreId: Int, with results: DiscoverResultsUIModel) {
        invokedUpdateMovies = true
        stubbedMovies = results.results
    }
    
    func getMovies(for genreId: Int) -> [DiscoverResultUIModel] {
        invokedGetMovies = true
        return stubbedMovies
    }
    
    func getNextPageForCurrentGenre() -> Int? {
        invokedGetNextPage = true
        return stubbedNextPage
    }
}
