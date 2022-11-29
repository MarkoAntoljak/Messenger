//
//  AppDelegate.swift
//  MessengerClone
//
//  Created by Marko Antoljak on 11/28/22.
//

import UIKit
import FirebaseCore
import IQKeyboardManager


@main
class AppDelegate: UIResponder, UIApplicationDelegate {



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        /// configuring firebase into app
        FirebaseApp.configure()
    
        /// configuring keyboard manager
        let keyboardManager = IQKeyboardManager.shared()
        keyboardManager.isEnabled = true
        
        return true
    }

}

