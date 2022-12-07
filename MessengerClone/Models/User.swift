//
//  User.swift
//  MessengerClone
//
//  Created by Marko Antoljak on 11/29/22.
//

import Foundation

struct User {
    
    let firstName: String
    
    let lastName: String
    
    let email: String
    
    var fullName: String {
        
        return "\(firstName) \(lastName)"
    }
    
    var profilePictureFilename: String {
        
        let storagePath = "profilePhoto.png"
        
        UserDefaults.standard.set(storagePath, forKey: "profilePictureURLString")
        
        return storagePath
    }
    
    var hasProfilePicture: Bool
    
    init(dictionary : [String: Any]) {
        self.firstName = dictionary["firstName"] as? String ?? ""
        self.lastName = dictionary["lastName"] as? String ?? ""
        self.email = dictionary["email"] as? String ?? ""
        self.hasProfilePicture = true
    }
    
}
