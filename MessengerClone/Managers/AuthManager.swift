//
//  AuthManager.swift
//  MessengerClone
//
//  Created by Marko Antoljak on 11/28/22.
//

import Foundation
import FirebaseAuth

struct AuthManager {
    
    // MARK: Attributes
    /// singleton
    public static let shared = AuthManager()
    
    private let auth = Auth.auth()
    
    var email: String? {
       
        guard let currentUser = auth.currentUser else {return nil}
        
        return currentUser.email
    }
    
    /// checking current user
    public var isSignedIn: Bool {
        
        return auth.currentUser != nil
    }
    
    // MARK: Init
    private init() {}
    
    // MARK: Functions
    
    
    /// Signing in the existing user
    /// - Parameters:
    ///   - email: user email
    ///   - password: user password
    ///   - completion: handler that sends back boolean of success
    public func signIn(email: String, password: String, completion: @escaping (Bool) -> Void) {
        
        auth.signIn(withEmail: email, password: password) { result, error in
            
            guard result != nil, error == nil else {
                
                print("Error: Cannot sign in the user.")
                completion(false)
                return
            }
            
            completion(true)
        }
    }
    
    
    /// Registering the user
    /// - Parameters:
    ///   - username: user username
    ///   - email: user email
    ///   - password: user password
    ///   - completion: handler that sends back boolean of success
    public func signUp(firstName: String, lastName: String, email: String ,password: String, completion: @escaping (Bool) -> Void) {
        
        auth.createUser(withEmail: email, password: password) { result, error in
            
            guard error == nil, result != nil else {
                print("Error: failed to create a new user.")
                completion(false)
                return
            }
    
            DatabaseManager.shared.addNewUser(firstName: firstName, lastName: lastName, email: email) { success in
                
                completion(success)
            }
            
        }
    }
    
    /// Signing out the user
    public func signOut(completion: @escaping (Bool) -> Void) {
        
        do {
            
            try auth.signOut()
            
        } catch {
            
            print(error.localizedDescription)
            completion(false)
        }
        
        completion(true)
    }
    
    
    

    
}
