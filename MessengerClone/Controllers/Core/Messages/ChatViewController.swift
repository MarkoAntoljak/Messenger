//
//  ChatViewController.swift
//  MessengerClone
//
//  Created by Marko Antoljak on 11/29/22.
//

import UIKit
import MessageKit
import InputBarAccessoryView

class ChatViewController: MessagesViewController {
    
    // MARK: Attributes

    private lazy var messages = [Message]()
    
    public var isNewChat = false
    
    public var user: User
    
    private let selfSender: Sender? = {
        
        guard let email = UserDefaults.standard.string(forKey: "email") else {return nil}
        let sender = Sender(senderId: email, displayName: "Sir John Ive", photoURL: "")
        
        return sender
    }()
    
    // MARK: UI Elements
    
    // MARK: Init
    
    init(user: User) {
    
        self.user = user
        
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    // MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // configure tabbar and navbar
        navigationController?.tabBarController?.tabBar.isHidden = true
        title = user.fullName
        navigationItem.largeTitleDisplayMode = .never
        view.backgroundColor = .systemBackground
        
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesDisplayDelegate = self
        messageInputBar.delegate = self
        
    }
    
    private func createMessageID() -> String? {
        
        guard let currentUserEmail = UserDefaults.standard.string(forKey: "email") else {return nil}
        
        let newid = "\(user.email)_\(currentUserEmail)_\(Date())"
        
        return newid
    }
    
}


// MARK: Messages Delegates and DataSource
extension ChatViewController: MessagesDataSource, MessagesLayoutDelegate, MessagesDisplayDelegate {
    
    func currentSender() -> MessageKit.SenderType {
        
        if let senderType = selfSender {
            return senderType
        }
        
        fatalError()
        return Sender(senderId: "1", displayName: "", photoURL: "")
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessageKit.MessagesCollectionView) -> MessageKit.MessageType {
        return messages[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessageKit.MessagesCollectionView) -> Int {
        return messages.count
    }
    
    
}

extension ChatViewController: InputBarAccessoryViewDelegate {
    
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        
        guard !text.replacingOccurrences(of: " ", with: "").isEmpty,
        let selfSender = self.selfSender,
        let messageID = createMessageID() else {return}
        
        // send message
        if isNewChat {
            // create new chat in database
            let message = Message(sender: selfSender, messageId: messageID, sentDate: Date(), kind: .text(text))
            
            DatabaseManager.shared.createNewConversation(with: user, name: title ?? "", firstMessage: message) { [weak self] success in
                
                if success { print("message sent")} else { print("cannot send, error occured")}
                
                
            }
            
        } else {
            // append to existing chat conversation
        }
    }
}
