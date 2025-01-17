//
//  AppDelegate.swift
//  IconSearch
//
//  Created by Evgeniy Goncharov on 01.08.2024.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, 
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = SearchViewController()
        window?.makeKeyAndVisible()
        return true
    }
}
