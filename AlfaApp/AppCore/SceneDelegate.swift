//
//  SceneDelegate.swift
//  AlfaApp
//
//  Created by Onur Yilmaz on 13.10.2025.
//

import UIKit
// import SecurityKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        let window = UIWindow(windowScene: windowScene)
        let movieExplorerCoordinator = MovieExplorerCoordinator(window: window)
        movieExplorerCoordinator.start()
    }
    
    func sceneDidDisconnect(_ scene: UIScene) { }
    
    func sceneDidBecomeActive(_ scene: UIScene) { }
    
    func sceneWillResignActive(_ scene: UIScene) { }
    
    func sceneWillEnterForeground(_ scene: UIScene) {
        
        // TODO: App foreground’a geldiğinde veya 5 dakikada bir SecurityKit ile güvenlik kontrolü yap, gerekirse erişimi kısıtla.
        // TODO: ConfidentialKit'den faydalanarak Code Obfuscation yap.
        
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) { }
    
}

