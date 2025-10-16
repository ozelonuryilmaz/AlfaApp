//
//  MovieExplorerVMLogic.swift
//  AlfaApp
//
//  Created by Onur Yilmaz on 15.10.2025.
//  Copyright (c) 2025 AlfaApp IOS Development Team. All rights reserved.
//

import Foundation

protocol IMovieExplorerVMLogic {
    var genres: [GenreUIModel] { get set }
    var currentGenreId: Int? { get }
    
    init()
    
    func getFirstGenreId() -> Int?
    mutating func setCurrentGenre(genreId: Int)
    func processNextPage(currentEntry: GenreCacheEntry, newResults: DiscoverResultsUIModel) -> GenreCacheEntry?
}

struct MovieExplorerVMLogic: IMovieExplorerVMLogic {
    
    // MARK: Properties
    var genres: [GenreUIModel] = []
    private(set) var currentGenreId: Int?
    
    // MARK: Initialize
    init() { }
    
    // MARK: - State Management & Calculations
    
    func getFirstGenreId() -> Int? {
        return genres.first?.id
    }
    
    mutating func setCurrentGenre(genreId: Int) {
        self.currentGenreId = genreId
    }
    
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
