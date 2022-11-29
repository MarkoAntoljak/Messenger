//
//  Message.swift
//  MessengerClone
//
//  Created by Marko Antoljak on 12/2/22.
//

import Foundation
import MessageKit

struct Message: MessageType {
    
    var sender: MessageKit.SenderType
    
    var messageId: String
    
    var sentDate: Date 
    
    var kind: MessageKit.MessageKind
    
}

extension MessageKind {
    
    var description: String {
        
        switch self {
            
        case .text(_):
            return "text"
        case .attributedText(_):
            return "attributed_text"
        case .photo(_):
            return "photo"
        case .video(_):
            return "video"
        case .location(_):
            return "location"
        case .emoji(_):
            return "emoji"
        case .audio(_):
            return "audio"
        case .contact(_):
            return "contact"
        case .linkPreview(_):
            return "link"
        case .custom(_):
            return "custom"
        }
    }
}
