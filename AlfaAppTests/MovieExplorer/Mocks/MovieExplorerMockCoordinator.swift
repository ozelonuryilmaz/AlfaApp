//
//  MovieExplorerMockCoordinator.swift
//  AlfaAppTests
//
//  Created by Onur Yilmaz on 18.10.2025.
//

import Foundation
@testable import AlfaApp

final class MockMovieExplorerCoordinator: IMovieExplorerCoordinator {
    
    private(set) var invokedPresentToMoviePlayerVC: Bool = false
    private(set) var invokedPresentToMoviePlayerVCWithMovie: DiscoverResultUIModel?
    
    func presentToMoviePlayerVC(with movie: DiscoverResultUIModel) {
        invokedPresentToMoviePlayerVC = true
        invokedPresentToMoviePlayerVCWithMovie = movie
    }
}
