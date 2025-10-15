//
//  PresentationCoordinator.swift
//  AlfaApp
//
//  Created by Onur Yilmaz on 15.10.2025.
//

import UIKit

protocol IPresentationCoordinator : AnyObject {
    func dismiss(animated: Bool, completion: (() -> Void)?)
}

class PresentationCoordinator: BaseCoordinator, IPresentationCoordinator {
    
    private weak var presentedViewController: UIViewController?
    
    required init(presenterViewController: UIViewController?) {
        self.presentedViewController = presenterViewController
        super.init()
    }
    
    override func showScreen(viewController: UIViewController, animated: Bool = true, completion: (() -> Void)? = nil) {
        presentedViewController?.present(viewController, animated: animated, completion: completion)
    }
    
    func dismiss(animated: Bool = true, completion: (() -> Void)? = nil) {
        presentedViewController?.dismiss(animated: animated, completion: completion)
    }
    
    func currentViewController() -> UIViewController? {
        presentedViewController
    }
}
