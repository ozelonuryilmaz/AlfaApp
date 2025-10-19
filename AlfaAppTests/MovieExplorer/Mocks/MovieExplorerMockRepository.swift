//
//  MovieExplorerMockRepository.swift
//  AlfaAppTests
//
//  Created by Onur Yilmaz on 18.10.2025.
//

import Foundation
@testable import AlfaApp
// @testable import AlfaDomain

final class MockMovieExplorerRepository: IMovieExplorerRepository {
    
    var fetchGenresResult: Result<GenresUIModel, Error>!
    var fetchDiscoverResult: Result<DiscoverResultsUIModel, Error>!
    
    private(set) var invokedFetchDiscoverParams: (genreId: Int, page: Int, forceRefresh: Bool)?
    private(set) var invokedClearCache: Bool = false
    
    func fetchGenres() async throws -> GenresUIModel {
        try fetchGenresResult.get()
    }
    
    func fetchDiscover(genreId: Int, page: Int, forceRefresh: Bool) async throws -> DiscoverResultsUIModel {
        invokedFetchDiscoverParams = (genreId, page, forceRefresh)
        return try fetchDiscoverResult.get()
    }
    
    func clearCache() {
        invokedClearCache = true
    }
}
