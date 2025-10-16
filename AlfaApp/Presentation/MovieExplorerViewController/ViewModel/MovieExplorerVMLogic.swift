//
//  MovieExplorerVMLogic.swift
//  AlfaApp
//
//  Created by Onur Yilmaz on 15.10.2025.
//  Copyright (c) 2025 AlfaApp IOS Development Team. All rights reserved.
//

import Foundation

protocol IMovieExplorerVMLogic {
    var genres: [GenreUIModel] { get }
    var currentGenreId: Int? { get }
    
    init()
    
    // Setter
    mutating func setGenresResponse(_ genresUIModel: [GenreUIModel])
    mutating func setCurrentGenre(genreId: Int)
    
    // Getter
    func getFirstGenreId() -> Int?
    func getGenreName(for genreId: Int) -> String?
    func getGenre(before genreId: Int) -> GenreUIModel?
    func getGenre(after genreId: Int) -> GenreUIModel?
    
    // Calculations
    func processNextPage(currentEntry: GenreCacheEntry, newResults: DiscoverResultsUIModel) -> GenreCacheEntry?
}

struct MovieExplorerVMLogic: IMovieExplorerVMLogic {
    
    // MARK: Properties
    private(set) var genres: [GenreUIModel] = []
    private(set) var currentGenreId: Int?
    
    // MARK: Initialize
    init() { }
    
}

// MARK: Setter
internal extension MovieExplorerVMLogic {
    
    mutating func setGenresResponse(_ genresUIModel: [GenreUIModel]) {
        self.genres = genresUIModel
    }
    
    mutating func setCurrentGenre(genreId: Int) {
        self.currentGenreId = genreId
    }
}

// MARK: Getter
internal extension MovieExplorerVMLogic {
    
    func getFirstGenreId() -> Int? {
        return genres.first?.id
    }
    
    func getGenreName(for genreId: Int) -> String? {
        return genres.first(where: { $0.id == genreId })?.name
    }
    
    func getGenre(before genreId: Int) -> GenreUIModel? {
        guard let currentIndex = genres.firstIndex(where: { $0.id == genreId }),
              currentIndex > 0 else {
            return nil
        }
        return genres[currentIndex - 1]
    }
    
    func getGenre(after genreId: Int) -> GenreUIModel? {
        guard let currentIndex = genres.firstIndex(where: { $0.id == genreId }),
              currentIndex < genres.count - 1 else {
            return nil
        }
        return genres[currentIndex + 1]
    }
}

// MARK: Calculations
internal extension MovieExplorerVMLogic {
    
    func processNextPage(currentEntry: GenreCacheEntry, newResults: DiscoverResultsUIModel) -> GenreCacheEntry? {
        if newResults.results.isEmpty { return nil }
        
        let existingMovieIDs = Set(currentEntry.movies.map { $0.id })
        let uniqueNewMovies = newResults.results.filter { !existingMovieIDs.contains($0.id) }
        
        if uniqueNewMovies.isEmpty {
            print("Pagination Warning: Page \(newResults.page) contained only duplicate movies.")
            return nil
        }
        
        var updatedMovies = currentEntry.movies
        updatedMovies.append(contentsOf: uniqueNewMovies)
        
        let updatedEntry = GenreCacheEntry(
            movies: updatedMovies,
            currentPage: newResults.page,
            lastContentOffset: currentEntry.lastContentOffset
        )
        
        return updatedEntry
    }
}
