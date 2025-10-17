//
//  MovieExplorerCoordinator.swift
//  AlfaApp
//
//  Created by Onur Yilmaz on 15.10.2025.
//  Copyright (c) 2025 AlfaApp IOS Development Team. All rights reserved.
//

import UIKit

protocol IMovieExplorerCoordinator: AnyObject {
    func presentToMoviePlayerVC(with movie: DiscoverResultUIModel)
}

final class MovieExplorerCoordinator: RootableCoordinator, IMovieExplorerCoordinator {
    
    private var childCoordinators: [Coordinator] = []
    private weak var navigationController: UINavigationController?
    
    override func start() {
        let controller = MovieExplorerBuilder.generate(coordinator: self)
        let navigationController = UINavigationController(rootViewController: controller)
        self.navigationController = navigationController
        
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
    }
    
    func presentToMoviePlayerVC(with movie: DiscoverResultUIModel) {
        guard let navigationController = navigationController else { return }
        let moviePlayerCoordinator = MoviePlayerCoordinator(presenterViewController: navigationController)
            .with(data: MoviePlayerParams(movie: movie))
        
        moviePlayerCoordinator.didDismissCallback = { [weak self, weak moviePlayerCoordinator] in
            guard let self = self, let coordinator = moviePlayerCoordinator else { return }
            self.removeChildCoordinator(coordinator)
        }
        
        childCoordinators.append(moviePlayerCoordinator)
        moviePlayerCoordinator.start()
    }
    
    private func removeChildCoordinator(_ coordinator: Coordinator) {
        childCoordinators = childCoordinators.filter { $0 !== coordinator }
    }
}
