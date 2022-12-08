//
//  DatabaseManager.swift
//  MessengerClone
//
//  Created by Marko Antoljak on 11/28/22.
//

import Foundation
import FirebaseFirestore
import MessageKit

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
        case GetMessagesError
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
    public func createNewConversation(with otherUser: User, receiverName: String, firstMessage: Message, completion: @escaping (Bool) -> Void) {
        
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
        let senderConversationData: [String: Any] = [
            
            "id" : conversationID,
            "other_user_email" : otherUser.email,
            "receiver" : receiverName,
            "latest_message" : [
                "date_sent" : messageDate,
                "message" : messageContent,
                "is_read" : false
            ]
            
        ]
        
        // recepient data to create or append to
        let recepientConversationData: [String: Any] = [
            "id" : conversationID,
            "other_user_email" : currentEmail,
            "receiver" : "ME",
            "latest_message" : [
                "date_sent" : messageDate,
                "message" : messageContent,
                "is_read" : false
            ]
        ]
        
        let refRecipient = database.collection("users").document(otherUser.email)
        
        refRecipient.getDocument { snapshot, error in
            
            guard let snapshot = snapshot, error == nil else {
                completion(false)
                print("Error: there was an error with completion")
                return
            }
            
            guard var documentData = snapshot.data() else {
                completion(false)
                print("there is no document")
                return
            }
            
            
            if var conversations = documentData["conversations"] as? [[String: Any]] {
                // append
                conversations.append(recepientConversationData)
                
                documentData["conversations"] = conversations
                
            } else {
                // create
                documentData["conversations"] = [recepientConversationData]
            }
            
            refRecipient.setData(documentData) { error in
                
                guard error == nil else {
                    completion(false)
                    print("Error")
                    return
                }
            }
            
        }
        
        
        let refSender = database.collection("users").document(currentEmail)
        
        refSender.getDocument { snapshot, error in
            
            guard let snapshot = snapshot, error == nil else {
                completion(false)
                print("Error: there was an error with snapshot listener")
                return
            }
            
            guard var documentData = snapshot.data() else {
                completion(false)
                print("Error: no data in document")
                return
            }
            
            if var conversations = documentData["conversations"] as? [[String: Any]] {
                
                // append to existing conversation
                conversations.append(senderConversationData)
                documentData["conversations"] = conversations
                
            } else {
                
                // create new conversation
                documentData["conversations"] = [senderConversationData]
            }
            
            // set new data
            refSender.setData(documentData) { error in
                
                guard error == nil else {
                    
                    completion(false)
                    print("Error: there was a problem with adding data")
                    return
                }
                
                createMessageConversation(conversationID: conversationID, receiverName: receiverName, firstMessage: firstMessage, completion: completion)
            }
            
        }
    }
    
    private func createMessageConversation(conversationID: String, receiverName: String, firstMessage: Message, completion: @escaping (Bool) -> Void) {
        
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
            "receiver" : receiverName,
            "is_read" : false
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
            
            guard let conversationCollection = document["conversations"] as? [[String:Any]] else {
                print("No conversations yet")
                completion(.success([]))
                return
            }
            
            let conversations: [Conversation] = conversationCollection.compactMap({ dictionary in
                
                let id = dictionary["id"] as! String
                let receiver = dictionary["receiver"] as! String
                let otherUserEmail = dictionary["other_user_email"] as! String
                let latestMessage = dictionary["latest_message"] as! [String:Any]
                let isRead = latestMessage["is_read"] as! Bool
                let message = latestMessage["message"] as! String
                let dateSentTimestamp = latestMessage["date_sent"] as! Timestamp
                
                //formating time adn date when message was sent
                let date = dateSentTimestamp.dateValue()
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "dd/MM/yyyy"
                let strDate = dateFormatter.string(from: date)
                
                let latestMessageObj = LatestMessage(date: strDate, text: message, isRead: isRead)
                
                let conversation = Conversation(id: id, receiver: receiver, otherUserEmail: otherUserEmail, latestMessage: latestMessageObj)
                
                return conversation
            })
            
            completion(.success(conversations))
            
        }
    }
    
    /// Get all messages for specific conversation
    /// - Parameters:
    ///   - id: id of the conversation
    ///   - completion: handler that sends back an array of messages or error
    public func getMessagesForConversation(with id: String, completion: @escaping (Result<[Message],Error>) -> Void) {
        
        database.collection("users").document("\(id)").getDocument { snapshot, error in
            
            guard error == nil, let snapshot = snapshot else {
                completion(.failure(ErrorType.GetMessagesError))
                print("Error: there was a problem with snapshot")
                return
            }
            
            guard let document = snapshot.data(),
                  
                  let messagesCollection = document["messages"] as? [[String:Any]]
                    
            else {
                completion(.failure(ErrorType.GetMessagesError))
                print("Error: no data in document")
                return
            }
            
            let messages: [Message]
            
            messages = messagesCollection.compactMap({ dictionary in
                
                let content = dictionary["content"] as! String
                let dateTimestamp = dictionary["date"] as! Timestamp
                let id = dictionary["id"] as! String
                let isRead = dictionary["is_read"] as! Bool
                let receiver = dictionary["receiver"] as! String
                let senderEmail = dictionary["sender_email"] as! String
                let type = dictionary["type"] as! String
                
                //formating time adn date when message was sent
                let date = dateTimestamp.dateValue()
//                let dateFormatter = DateFormatter()
//                dateFormatter.dateFormat = "dd/MM/yyyy HH:mm"
                
                guard let url = UserDefaults.standard.url(forKey: "profilePictureURL") else {
                    print("url is nil")
                    return
                }
                
                let photoURL = String(contentsOf: url)
                
                let sender = Sender(senderId: senderEmail, displayName: receiver, photoURL: photoURL)
                
                let message = Message(sender: sender, messageId: id, sentDate: date, kind: .text(content))
                
                return message
            })
            
            completion(.success(messages))
            
        }
        
    }
    
    /// sending message
    /// - Parameters:
    ///   - conversation: which conversation the user is currently in
    ///   - message: message to send
    ///   - completion: handler that sends back boolean of success
    public func sendMessage(to conversation: String, message: Message, completion: @escaping (Bool) -> Void) {}
}
