//
//  Conversation.swift
//  MessengerClone
//
//  Created by Marko Antoljak on 12/5/22.
//

import Foundation


struct Conversation {
    
    let id: String
    
    let receiver: String
    
    let otherUserEmail: String
    
    let latestMessage: LatestMessage
    
}

struct LatestMessage {
    
    let date: String
    
    let text: String
    
    let isRead: Bool
}
