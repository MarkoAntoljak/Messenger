//
//  TabBarViewController.swift
//  MessengerClone
//
//  Created by Marko Antoljak on 11/28/22.
//

import UIKit

class TabBarViewController: UITabBarController {
    
    // MARK: Attributes
    
    // MARK: UI Elements
    
    
    // MARK: Init
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        
        setUpControllers()
            
    }
    
    // MARK: Functions
    
    private func setUpControllers() {
        
        let chat = UINavigationController(rootViewController: ConversationsViewController(user: getUser()))
        let profile = UINavigationController(rootViewController: ProfileViewController())
        
        chat.tabBarItem = UITabBarItem(title: "Messages", image: UIImage(systemName: "bubble.left"), tag: 0)
        profile.tabBarItem = UITabBarItem(title: "Profile", image: UIImage(systemName: "person.crop.circle"), tag: 1)
        
        setViewControllers([chat, profile], animated: true)
        
    }
    
    /// getting user based on local stored data
    private func getUser() -> User {
        
        guard let firstName = UserDefaults.standard.string(forKey: "firstName"),
              let lastName = UserDefaults.standard.string(forKey: "lastName"),
              let fullName = UserDefaults.standard.string(forKey: "fullName"),
              let email = UserDefaults.standard.string(forKey: "lastName") else {return User(dictionary: [:])}
        
        let user = User(dictionary: [
            "firstName" : firstName,
            "lastName" : lastName,
            "fullName" : fullName,
            "email" : email
        ])
        
        return user
        
    }

    
  
    
}
