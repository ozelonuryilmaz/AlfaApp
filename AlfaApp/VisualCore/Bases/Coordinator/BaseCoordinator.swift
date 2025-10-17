//
//  BaseCoordinator.swift
//  AlfaApp
//
//  Created by Onur Yilmaz on 15.10.2025.
//

import UIKit

typealias DefaultDismissCallback = (() -> Void)

protocol ICoordinatorParams { }

// MARK: Coordinator Protocol
protocol Coordinator: AnyObject {
    var params: ICoordinatorParams? { get set }
    var willDismissCallback: DefaultDismissCallback? { get set }
    var didDismissCallback: DefaultDismissCallback? { get set }
    
    func start()
    func showScreen(viewController: UIViewController, animated: Bool, completion: (() -> Void)?)
    func coordinate(to coordinator: Coordinator)
    func with(data: ICoordinatorParams?) -> Self
}

// MARK: RootableCoordinator
class RootableCoordinator: NSObject, Coordinator {
 
    var params: ICoordinatorParams?
    internal var willDismissCallback: DefaultDismissCallback?
    internal var didDismissCallback: DefaultDismissCallback?

    let window: UIWindow?

    init(window: UIWindow?) {
        self.window = window
    }

    deinit {
        print("killed: \(type(of: self))")
    }
    
    func start() {
        fatalError("Start method should be implemented.")
    }
    
    func coordinate(to coordinator: Coordinator) {
        start()
    }

    func showScreen(viewController: UIViewController, animated: Bool, completion: (() -> Void)?) {
        start()
    }
    
    func with(data: ICoordinatorParams?) -> Self {
        self.params = data
        return self
    }
}

// MARK: BaseCoordinator
class BaseCoordinator: Coordinator {
    
    var params: ICoordinatorParams?
    var willDismissCallback: DefaultDismissCallback?
    var didDismissCallback: DefaultDismissCallback?

    deinit {
        print("killed: \(Self.self)")
    }
    
    // MARK: Abstract
    func start() {
        fatalError("start() must be overridden in subclass")
    }
    
    func showScreen(viewController: UIViewController, animated: Bool, completion: (() -> Void)?) {
        fatalError("showScreen() must be overridden in subclass")
    }
    
    func coordinate(to coordinator: Coordinator) {
        coordinator.start()
    }
    
    func with(data: ICoordinatorParams?) -> Self {
        self.params = data
        return self
    }

    func with(willDismissCallback: DefaultDismissCallback?) -> Self {
        self.willDismissCallback = willDismissCallback
        return self
    }

    func with(didDismissCallback: DefaultDismissCallback?) -> Self {
        self.didDismissCallback = didDismissCallback
        return self
    }
    
    func topViewController() -> UIViewController? {
        return UIApplication.shared
            .connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first(where: { $0.isKeyWindow })?
            .rootViewController?
            .topMostViewController()
    }
}

extension BaseCoordinator {
    
    func getParams<T: ICoordinatorParams>() -> T {
        guard let data = params as? T else {
            fatalError("Invalid Params type. Expected: \(T.self), got: \(String(describing: params))")
        }
        return data
    }
}

// MARK: UIViewController Extension
private extension UIViewController {

    func topMostViewController() -> UIViewController {
        if let presented = presentedViewController {
            return presented.topMostViewController()
        }
        if let nav = self as? UINavigationController {
            return nav.visibleViewController?.topMostViewController() ?? nav
        }
        if let tab = self as? UITabBarController {
            return tab.selectedViewController?.topMostViewController() ?? tab
        }
        return self
    }
}
