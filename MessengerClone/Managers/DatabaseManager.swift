//
//  DatabaseManager.swift
//  MessengerClone
//
//  Created by Marko Antoljak on 11/28/22.
//

import Foundation
import FirebaseFirestore

struct DatabaseManager {
    
    // MARK: Attributes
    
    /// singleton
    public static let shared = DatabaseManager()
    /// database object init
    private let database = Firestore.firestore()
    
    enum ErrorType: Error {
        
        case SearchingUsersError
        case GetConversationsError
        case GetUsersError
    }
    
    
    // MARK: Init
    private init(){}
    
    // MARK: Functions
    
    public func addNewUser(firstName: String, lastName: String, email: String, completion: @escaping (Bool) -> Void) {
        
        let path = database.collection("users").document(email.lowercased())
        
        let userData: [String: Any] = [
            "firstName" : firstName,
            "lastName" : lastName,
            "email" : email,
            "fullName" : "\(firstName) \(lastName)"
        ]
        
        path.setData(userData) { error in
            
            guard error == nil else {
                print("Error: cannot add new user to the database")
                completion(false)
                return
            }

            completion(true)
        }
    }
    
    public func getUserData(with email: String, completion: @escaping (Result<[String : Any], Error>) -> Void) {
        
        let path = database.collection("users").document(email.lowercased())
        
        path.getDocument { snapshot, error in
            
            guard let snapshot = snapshot, error == nil else {
                completion(.failure(ErrorType.GetUsersError))
                print("Error: there was an error with snapshot")
                return
            }
            
            guard let data: [String: Any] = snapshot.data() else {
                completion(.failure(ErrorType.GetUsersError))
                print("Error: there is no data in document")
                return
            }
            
            completion(.success(data))
            
        }
    }
    
    
    /// Getting all users from database
    /// - Parameters:
    ///   - email: email of
    ///   - completion: handler that sends back the result of an array in  json string format or error
    public func getAllUsersData(completion: @escaping (Result<[User], Error>) -> Void) {
        
        let path = database.collection("users")
        
        path.getDocuments { snapshot, error in
            
            guard let snapshot = snapshot, error == nil else {
                completion(.failure(ErrorType.SearchingUsersError))
                print("Error: there was an error with snapshot listener")
                return
            }
            
            
            var users = [User]()
            
            for document in snapshot.documents {
                
                let userData = document.data()
                
                users.append(User(dictionary: userData))
            }
            
            completion(.success(users))
            
        }
        
    }
    
    // MARK: Sending and receiving messages
    
    /// Creating new conversation with the selected user
    /// - Parameters:
    ///   - fullName: user full name
    ///   - firstMessage: first message to send
    ///   - completion: handler that sends back boolean of success
    public func createNewConversation(with otherUser: User, name: String, firstMessage: Message, completion: @escaping (Bool) -> Void) {
        
        guard let currentEmail = UserDefaults.standard.string(forKey: "email")?.lowercased() else {return}
        
        let messageDate = firstMessage.sentDate
        
        let conversationID = "conversation_\(firstMessage.messageId)"
        
        var messageContent = ""
        
        // message type
        switch firstMessage.kind {
            
            // text messagage
        case .text(let messageText):
            
            messageContent = messageText
            
        case .attributedText(_):
            break
        case .photo(_):
            break
        case .video(_):
            break
        case .location(_):
            break
        case .emoji(_):
            break
        case .audio(_):
            break
        case .contact(_):
            break
        case .linkPreview(_):
            break
        case .custom(_):
            break
        }

        // data to create or append to
        let newConversationData: [String: Any] = [
            
            "id" : conversationID,
            "other_user_email" : otherUser.email,
            "name" : name,
            "latest_message" : [
                "date_sent" : messageDate,
                "message" : messageContent,
                "is_read" : false
            ]
            
        ]
        
        let ref = database.collection("users").document(currentEmail)
        
        ref.getDocument { snapshot, error in
            
            guard let snapshot = snapshot, error == nil else {
                completion(false)
                print("Error: there was an error with snapshot listener")
                return
            }
            
            guard var data = snapshot.data() else {
                completion(false)
                print("Error: no data in document")
                return
            }
            
            if var conversations = data["conversations"] as? [[String: Any]] {
                
                // append to existing conversation
                conversations.append(newConversationData)
                data["conversations"] = conversations
                
            } else {
                
                // create new conversation
                data["conversations"] = [newConversationData]
            }
            
            // set new data
            ref.setData(data) { error in
                
                guard error == nil else {
                    
                    completion(false)
                    print("Error: there was a problem with adding data")
                    return
                }
                
                createMessageConversation(conversationID: conversationID, name: name, firstMessage: firstMessage, completion: completion)
            }
            
        }
    }
    
    private func createMessageConversation(conversationID: String, name: String, firstMessage: Message, completion: @escaping (Bool) -> Void) {
        
        guard let currentUserEmail = UserDefaults.standard.string(forKey: "email") else {
            completion(false)
            print("Error: cannot detect current user email")
            return
        }
        
        var messageContent = ""
    
        switch firstMessage.kind {
            
        case .text(let messageText):
            
            messageContent = messageText
            
        case .attributedText(_):
            break
        case .photo(_):
            break
        case .video(_):
            break
        case .location(_):
            break
        case .emoji(_):
            break
        case .audio(_):
            break
        case .contact(_):
            break
        case .linkPreview(_):
            break
        case .custom(_):
            break
        }

        
        let message: [String: Any] = [
            "id" : firstMessage.messageId,
            "type" : firstMessage.kind.description,
            "content" : messageContent,
            "date" : firstMessage.sentDate,
            "sender_email" : currentUserEmail,
            "is_read" : false,
            "name" : name
        ]
        
        let data: [String: Any] = [
            "messages" : [
                message
            ]
        ]
        
        database.collection("users").document("\(conversationID)").setData(data) { error in
            
            guard error == nil else {
                completion(false)
                print("Error: cannot create messages node.")
                return
            }
            
            completion(true)
            
        }
    }
    
    /// Get all conversations for specific user
    /// - Parameters:
    ///   - fullName: full name of the user
    ///   - completion: handler that sends back an array of conversations or error
    public func getAllConversations(for user: User, completion: @escaping (Result<[Conversation],Error>) -> Void) {
        
        database.collection("users").document("\(user.email)").getDocument { snapshot, error in
            
            guard error == nil, let snapshot = snapshot else {
                completion(.failure(ErrorType.GetConversationsError))
                print("Error: there was a problem with snapshot")
                return
            }
            
            guard let document = snapshot.data() else {
                completion(.failure(ErrorType.GetConversationsError))
                print("Error: no data in document")
                return
            }
            
            var conversations = [Conversation]()
            
            guard let conversationCollection = document["conversation"] as? [String:Any],
                  let id = conversationCollection["id"] as? String,
                  let name = conversationCollection["name"] as? String,
                  let otherUserEmail = conversationCollection["other_user_email"] as? String,
                  let latestMessage = conversationCollection["latest_message"] as? [String:Any],
                  let isRead = latestMessage["is_read"] as? Bool,
                  let message = latestMessage["message"] as? String,
                  let dateSent = latestMessage["date_sent"] as? String else {
                completion(.success([]))
                return
            }
    
            let latestMessageObj = LatestMessage(date: dateSent, text: message, isRead: isRead)
            
            let conversation = Conversation(id: id, name: name, otherUserEmail: otherUserEmail, latestMessage: latestMessageObj)
            
            conversations.append(conversation)
            
            completion(.success(conversations))
        }
    }
    
    /// Get all messages for specific conversation
    /// - Parameters:
    ///   - id: id of the conversation
    ///   - completion: handler that sends back an array of messages or error
    public func getMessagesForConversation(with id: String, completion: @escaping (Result<String,Error>) -> Void) {}
    
    /// sending message
    /// - Parameters:
    ///   - conversation: which conversation the user is currently in
    ///   - message: message to send
    ///   - completion: handler that sends back boolean of success
    public func sendMessage(to conversation: String, message: Message, completion: @escaping (Bool) -> Void) {}
}
