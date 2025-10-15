//
//  MovieExplorerCoordinator.swift
//  AlfaApp
//
//  Created by Onur Yilmaz on 15.10.2025.
//  Copyright (c) 2025 AlfaApp IOS Development Team. All rights reserved.
//

import UIKit

protocol IMovieExplorerCoordinator: AnyObject {
    
}

final class MovieExplorerCoordinator: RootableCoordinator, IMovieExplorerCoordinator {
    
    override func start() {
        let controller = MovieExplorerBuilder.generate(coordinator: self)
        let navigationController = UINavigationController(rootViewController: controller)
        
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
    }
}
