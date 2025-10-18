//
//  MoviePlayerMockCoordinator.swift
//  AlfaAppTests
//
//  Created by Onur Yilmaz on 18.10.2025.
//

import UIKit
@testable import AlfaApp

final class MockMoviePlayerCoordinator: IMoviePlayerCoordinator {
    
    private(set) var invokedDismiss: Bool = false
    private(set) var invokedDismissAnimated: Bool?

    // MARK: IPresentationCoordinator Stubs
    var navigationController: UINavigationController?
    var childCoordinators: [Coordinator] = []
    
    func start() {
        // Test için gerekli değil
    }
    
    func getParams<T>() -> T {
        // Test için gerekli değil, ancak gerekirse sahte veri döndürebilir
        fatalError("getParams not stubbed for MockMoviePlayerCoordinator")
    }
     
    // Test fonksiyonu
    func dismiss(animated: Bool, completion: (() -> Void)?) {
        invokedDismiss = true
        invokedDismissAnimated = animated
        completion?()
    }
}
