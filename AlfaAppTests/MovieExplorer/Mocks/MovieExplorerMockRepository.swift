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
    
    private(set) var invokedFetchDiscoverParams: (genreId: Int, page: Int)?
    
    func fetchGenres() async throws -> GenresUIModel {
        try fetchGenresResult.get()
    }
    
    func fetchDiscover(genreId: Int, page: Int) async throws -> DiscoverResultsUIModel {
        invokedFetchDiscoverParams = (genreId, page)
        return try fetchDiscoverResult.get()
    }
}
