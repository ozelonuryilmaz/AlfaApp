//
//  AppDelegate.swift
//  AlfaApp
//
//  Created by Onur Yilmaz on 13.10.2025.
//

import UIKit
import FirebaseCore
// import FirebaseAppCheck
// import TrustKit


@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        FirebaseApp.configure()
        
        //AppCheck.setAppCheckProviderFactory(AlfaAppCheckProviderFactory())
        
        // TODO: Apple Developer hesabı aktifleştiğinde
        // TODO: AppAttest ve DeviceCheck için FirebaseAppCheck kullanılacak
        
        // TODO: SSL Pining için TrustKit kullanılacak
        
        return true
    }
    
    // MARK: UISceneSession Lifecycle
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) { }
    
}

/*
final class AlfaAppCheckProviderFactory: NSObject, AppCheckProviderFactory {
  func createProvider(with app: FirebaseApp) -> AppCheckProvider? {
    #if targetEnvironment(simulator)
      // Simülatör için App Check çalışmaz, bu yüzden test için bir debug provider kullanılmalıdır
      // Konsolda çıkacak olan token'ı Firebase projene eklemeyi unutma
      return AppCheckDebugProvider(app: app)
    #else
      // Gerçek cihazlar için DeviceCheck provider kullanılmalıdır
      return DeviceCheckProvider(app: app)
    #endif
  }
}
*/
