//
//  NavigationCoordinator.swift
//  AlfaApp
//
//  Created by Onur Yilmaz on 15.10.2025.
//

import UIKit

protocol INavigationCoordinator : AnyObject {
    func pop(animated: Bool)
    func popToRoot(animated: Bool)
}

class NavigationCoordinator: BaseCoordinator, INavigationCoordinator {
    
    private weak var navigationController: UINavigationController?

    required init(navigationController: UINavigationController?) {
        self.navigationController = navigationController
        super.init()
    }
    
    override func showScreen(viewController: UIViewController, animated: Bool = true, completion: (() -> Void)? = nil) {
        navigationController?.pushViewController(viewController, animated: animated)
    }
    
    func pop(animated: Bool = true) {
        navigationController?.popViewController(animated: animated)
    }
    
    func popToRoot(animated: Bool = true) {
        navigationController?.popToRootViewController(animated: animated)
    }
    
    func popTo(viewController: UIViewController, animated: Bool = true) {
        navigationController?.popToViewController(viewController, animated: animated)
    }
    
    func setRoot(viewControllers: [UIViewController], animated: Bool = true) {
        navigationController?.viewControllers = viewControllers
    }
    
    func presentNavigationController(presentationStyle: UIModalPresentationStyle = .fullScreen, animated: Bool = true, completion: (() -> Void)? = nil) {
        guard let topViewController = topViewController(), let navController = currentNavigationController() else { return }
        navController.modalPresentationStyle = presentationStyle
        topViewController.present(navController, animated: animated, completion: completion)
    }
    
    func currentNavigationController() -> UINavigationController? {
        navigationController
    }
}
