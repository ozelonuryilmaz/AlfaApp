//
//  MovieExplorerTestSupport.swift
//  AlfaAppTests
//
//  Created by Onur Yilmaz on 18.10.2025.
//

import Foundation
@testable import AlfaApp

// MARK: Stub Helpers

extension GenresUIModel {
    /// Testlerde kolayca sahte model oluşturmak için helper
    static func stub(genres: [GenreUIModel]) -> GenresUIModel {
        return GenresUIModel(genres: genres)
    }
}

extension DiscoverResultsUIModel {
    /// Testlerde kolayca sahte model oluşturmak için helper
    static func stub(page: Int, results: [DiscoverResultUIModel]) -> DiscoverResultsUIModel {
        return DiscoverResultsUIModel(page: page, results: results, total_pages: 10, total_results: 100)
    }
}

extension DiscoverResultUIModel {
    /// Testlerde hızlıca sahte film oluşturmak için helper
    static func stub(id: Int, title: String) -> DiscoverResultUIModel {
        return DiscoverResultUIModel(id: id, title: title, posterURL: nil)
    }
}


// MARK: Equatable for ViewState

// XCTAssertEqual ile view state'lerini karşılaştırabilmek için gereklidir.
extension MovieExplorerViewState: Equatable {
    public static func == (lhs: MovieExplorerViewState, rhs: MovieExplorerViewState) -> Bool {
        switch (lhs, rhs) {
        case (.initialLoading, .initialLoading):
            return true
        case (.genresLoaded, .genresLoaded):
            return true
        case (.moviesLoading(let lGenreId), .moviesLoading(let rGenreId)):
            return lGenreId == rGenreId
        case (.moviesLoaded(let lGenreId, let lMovies, let lOffset, let lPag),
              .moviesLoaded(let rGenreId, let rMovies, let rOffset, let rPag)):
            // 'movies' dizisi (DiscoverResultUIModel) 'Hashable' (ve dolayısıyla 'Equatable')
            return lGenreId == rGenreId &&
                   lMovies == rMovies &&
                   lOffset == rOffset &&
                   lPag == rPag
        default:
            return false
        }
    }
}
