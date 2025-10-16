//
//  MovieExplorerBuilder.swift
//  AlfaApp
//
//  Created by Onur Yilmaz on 15.10.2025.
//  Copyright (c) 2025 AlfaApp IOS Development Team. All rights reserved.
//

import Foundation

enum MovieExplorerBuilder {
    
    static func generate(coordinator: IMovieExplorerCoordinator) -> MovieExplorerViewController {
        
        let genreUsecase = GenreUseCaseProvider.makeGenreUseCase()
        let discoverUsecase = DiscoverUseCaseProvider.makeDiscoverUseCase()
        let repository: IMovieExplorerRepository = MovieExplorerRepository(genreUsecase: genreUsecase, discoverUsecase: discoverUsecase)
        
        let vmLogic: IMovieExplorerVMLogic = MovieExplorerVMLogic()
        let cacheService: IMovieCacheService = MovieCacheService.shared
        
        let viewModel: IMovieExplorerViewModel = MovieExplorerViewModel(
            repository: repository,
            coordinator: coordinator,
            vmLogic: vmLogic,
            cacheService: cacheService
        )
        
        return MovieExplorerViewController(
            viewModel: viewModel
        )
    }
}
