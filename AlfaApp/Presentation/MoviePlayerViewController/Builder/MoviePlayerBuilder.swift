//
//  MoviePlayerBuilder.swift
//  AlfaApp
//
//  Created by Onur Yilmaz on 17.10.2025.
//  Copyright (c) 2025 AlfaApp IOS Development Team. All rights reserved.
//

import Foundation

enum MoviePlayerBuilder {
    
    static func generate(coordinator: IMoviePlayerCoordinator & BaseCoordinator) -> MoviePlayerViewController {
        
        let repository: IMoviePlayerRepository = MoviePlayerRepository()
        let params: MoviePlayerParams = coordinator.getParams()
        let vmLogic: IMoviePlayerVMLogic = MoviePlayerVMLogic(params: params)
        
        let viewModel: IMoviePlayerViewModel = MoviePlayerViewModel(
            repository: repository,
            coordinator: coordinator,
            vmLogic: vmLogic
        )
        
        return MoviePlayerViewController(
            viewModel: viewModel
        )
    }
}
