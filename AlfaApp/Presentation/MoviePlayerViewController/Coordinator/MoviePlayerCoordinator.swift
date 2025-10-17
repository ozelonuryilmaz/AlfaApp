//
//  MoviePlayerCoordinator.swift
//  AlfaApp
//
//  Created by Onur Yilmaz on 17.10.2025.
//  Copyright (c) 2025 AlfaApp IOS Development Team. All rights reserved.
//

import Foundation

protocol IMoviePlayerCoordinator: IPresentationCoordinator {
    
}

final class MoviePlayerCoordinator: PresentationCoordinator, IMoviePlayerCoordinator {
    
    override func start() {
        let controller = MoviePlayerBuilder.generate(coordinator: self, didDismissCallback: self.didDismissCallback)
        controller.modalPresentationStyle = .fullScreen
        showScreen(viewController: controller)
    }
}
