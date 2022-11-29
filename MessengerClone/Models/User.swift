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
}
