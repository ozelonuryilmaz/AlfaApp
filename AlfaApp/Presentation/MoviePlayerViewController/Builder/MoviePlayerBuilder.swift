//
//  MoviePlayerBuilder.swift
//  AlfaApp
//
//  Created by Onur Yilmaz on 17.10.2025.
//  Copyright (c) 2025 AlfaApp IOS Development Team. All rights reserved.
//

import Foundation

enum MoviePlayerBuilder {
    
    static func generate(coordinator: IMoviePlayerCoordinator & BaseCoordinator,
                         didDismissCallback: DefaultDismissCallback?) -> MoviePlayerViewController {
        
        let movieUrlUsecase = MovieUrlUseCaseProvider.makeMovieUrlUseCase()
        let repository: IMoviePlayerRepository = MoviePlayerRepository(movieUrlUsecase: movieUrlUsecase)
        
        let params: MoviePlayerParams = coordinator.getParams()
        let vmLogic: IMoviePlayerVMLogic = MoviePlayerVMLogic(params: params)
        
        let viewModel: IMoviePlayerViewModel = MoviePlayerViewModel(
            repository: repository,
            coordinator: coordinator,
            vmLogic: vmLogic
        )
        
        return MoviePlayerViewController(
            viewModel: viewModel,
            didDismissCallback: didDismissCallback
        )
    }
}
