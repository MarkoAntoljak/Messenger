//
//  SceneDelegate.swift
//  MessengerClone
//
//  Created by Marko Antoljak on 11/28/22.
//

import UIKit
import FirebaseAuth

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    public static let shared = SceneDelegate()

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        let window = UIWindow(windowScene: windowScene)
        
        self.window = window
        
        /// check if the user is already signed in
        if AuthManager.shared.isSignedIn {
            
            guard let email = AuthManager.shared.email else {return}
            
            DatabaseManager.shared.getUserData(with: email) { result in
                
                switch result {
                    
                case . failure(let error):
                    print(error)
                    
                case .success(let dictionary):
                    
                    let user = User(dictionary: dictionary)
                    
                    window.rootViewController = TabBarViewController(user: user)
                }
            }
            
        } else {
            
            let navVC = UINavigationController(rootViewController: SignInViewController())
            window.rootViewController = navVC
            
        }
        
        window.makeKeyAndVisible()
    }

}

