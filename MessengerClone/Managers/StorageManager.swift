//
//  StorageManager.swift
//  MessengerClone
//
//  Created by Marko Antoljak on 11/29/22.
//

import Foundation
import FirebaseStorage

struct StorageManager {
    
    // MARK: Attributes
    /// singleton
    public static let shared = StorageManager()
    /// storage instance
    private let storage = Storage.storage().reference()
    
    // error types
    enum ErrorType: Error {
        
        case PhotoUploadError
        case DownloadURLError
        case ProfilePictureUrlError
    }
    
    // MARK: Functions
    
    
    /// Inserting profile photo into Firebase storage
    /// - Parameters:
    ///   - username: user username
    ///   - fileName: profile picture file name
    ///   - photoData: profile photo png data
    ///   - completion: completion handler that sends back result of string or error
    public func insertProfilePicture(user: User, fileName: String, photoData: Data, completion: @escaping (Result<String,Error>) -> Void) {
        
        let path = storage.child("users/\(user.email.lowercased())/\(fileName)")
        
        path.putData(photoData) { _, error in
            
            // handling error
            guard error == nil else {
                completion(.failure(ErrorType.PhotoUploadError))
                print("Error: uploading profile picture to storage.")
                return
            }
            
            // download url
            path.downloadURL { url, error in
                
                guard error == nil else {
                    print("Error: downloading profile picture from storage.")
                    completion(.failure(ErrorType.DownloadURLError))
                    return
                }
                
                // get the url from storage as string
                if let url = url {
                    
                    let stringURL = url.absoluteString
                    completion(.success(stringURL))
                    
                }
            }
        }
        
    }

    
    
    /// Downloading profile picture from storage
    /// - Parameters:
    ///   - path: path to the profile picture of the current user
    ///   - completion: handler that sends back result of profile pic url or error
    public func downloadProfilePictureURL(path: String, completion: @escaping (Result<URL,Error>) -> Void) {
        
        let reference = storage.child(path)
        
        reference.downloadURL { url, error in
            
            guard let url = url, error == nil else {
                print("Error: cannot download profile picture URL from Storage")
                completion(.failure(ErrorType.ProfilePictureUrlError))
                return
            }
            
            completion(.success(url))
        }
        
    }
    
    
}
