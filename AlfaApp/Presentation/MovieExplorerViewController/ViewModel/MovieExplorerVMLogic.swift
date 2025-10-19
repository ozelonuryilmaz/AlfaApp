//
//  MovieExplorerVMLogic.swift
//  AlfaApp
//
//  Created by Onur Yilmaz on 15.10.2025.
//  Copyright (c) 2025 AlfaApp IOS Development Team. All rights reserved.
//

import Foundation

protocol IMovieExplorerVMLogic {
    // Properties
    var genres: [GenreUIModel] { get }
    var currentGenreId: Int? { get }
    
    // Genre Management
    mutating func setGenresResponse(_ genresUIModel: [GenreUIModel])
    mutating func setCurrentGenre(genreId: Int)
    func getFirstGenreId() -> Int?
    func getGenreName(for genreId: Int) -> String?
    func getGenre(before genreId: Int) -> GenreUIModel?
    func getGenre(after genreId: Int) -> GenreUIModel?
    
    // Movie Data & Pagination Management
    mutating func updateMovies(for genreId: Int, with results: DiscoverResultsUIModel)
    func getMovies(for genreId: Int) -> [DiscoverResultUIModel]
    func getNextPageForCurrentGenre() -> Int?
}

struct MovieExplorerVMLogic: IMovieExplorerVMLogic {
    
    // MARK: Properties
    private(set) var genres: [GenreUIModel] = []
    private(set) var currentGenreId: Int?
    
    private var moviesByGenre: [Int: [DiscoverResultUIModel]] = [:]
    private var currentPageByGenre: [Int: Int] = [:]
}


// MARK: Genre Management
internal extension MovieExplorerVMLogic {
    
    // Setter
    
    mutating func setGenresResponse(_ genresUIModel: [GenreUIModel]) {
        self.genres = genresUIModel
    }
    
    mutating func setCurrentGenre(genreId: Int) {
        self.currentGenreId = genreId
    }
    
    // Getter
    
    func getFirstGenreId() -> Int? {
        return genres.first?.id
    }
    
    func getGenreName(for genreId: Int) -> String? {
        return genres.first(where: { $0.id == genreId })?.name
    }
    
    func getGenre(before genreId: Int) -> GenreUIModel? {
        guard let currentIndex = genres.firstIndex(where: { $0.id == genreId }), currentIndex > 0 else {
            return nil
        }
        return genres[currentIndex - 1]
    }
    
    func getGenre(after genreId: Int) -> GenreUIModel? {
        guard let currentIndex = genres.firstIndex(where: { $0.id == genreId }), currentIndex < genres.count - 1 else {
            return nil
        }
        return genres[currentIndex + 1]
    }
}


// MARK: Movie Data & Pagination Management
internal extension MovieExplorerVMLogic {
    
    mutating func updateMovies(for genreId: Int, with results: DiscoverResultsUIModel) {
        // Repository'den gelen tam ve güncel listeyi doğrudan set et
        self.moviesByGenre[genreId] = results.results
        self.currentPageByGenre[genreId] = results.page
    }
    
    func getMovies(for genreId: Int) -> [DiscoverResultUIModel] {
        return moviesByGenre[genreId] ?? []
    }
    
    func getNextPageForCurrentGenre() -> Int? {
        guard let genreId = currentGenreId, let currentPage = currentPageByGenre[genreId] else {
            return 1
        }
        return currentPage + 1
    }
}
