//
//  Extensions.swift
//  MessengerClone
//
//  Created by Marko Antoljak on 11/28/22.
//

import Foundation
import UIKit

/// extension of UIView for easier use of variable names
extension UIView {
    
    var top: CGFloat {
        return frame.origin.y
    }
    
    var bottom: CGFloat {
        return top + frame.height
    }
    
    var left: CGFloat {
        return frame.origin.x
    }
    
    var right: CGFloat {
        return left + frame.width
    }
    
    var width: CGFloat {
        return frame.width
    }
    
    var height: CGFloat {
        return frame.height
    }
}
