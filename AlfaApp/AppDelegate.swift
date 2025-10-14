//
//  AppDelegate.swift
//  AlfaApp
//
//  Created by Onur Yilmaz on 13.10.2025.
//

import UIKit
import FirebaseCore
//import FirebaseAppCheck

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        FirebaseApp.configure()
        
        //AppCheck.setAppCheckProviderFactory(AlfaAppCheckProviderFactory())
        
        return true
    }
    
    // MARK: UISceneSession Lifecycle
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    
}


/*
final class AlfaAppCheckProviderFactory: NSObject, AppCheckProviderFactory {
  func createProvider(with app: FirebaseApp) -> AppCheckProvider? {
    #if targetEnvironment(simulator)
      // Simülatör için App Check çalışmaz, bu yüzden test için bir debug provider kullanın.
      // Konsolda çıkacak olan token'ı Firebase projenize eklemeniz gerekecek.
      return AppCheckDebugProvider(app: app)
    #else
      // Gerçek cihazlar için DeviceCheck provider'ını kullanın.
      return DeviceCheckProvider(app: app)
    #endif
  }
}
*/
