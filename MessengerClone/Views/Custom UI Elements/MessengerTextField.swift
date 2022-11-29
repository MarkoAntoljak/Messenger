//
//  MessengerTextField.swift
//  MessengerClone
//
//  Created by Marko Antoljak on 11/28/22.
//

import UIKit

class MessengerTextField: UITextField {

    // MARK: Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        layer.masksToBounds = true
        layer.cornerRadius = 10
        autocorrectionType = .no
        leftViewMode = .always
        tintColor = .black
        textColor = .black
        leftView = UIView(frame: CGRect(x: 0, y: 10, width: 10, height: height))
        autocapitalizationType = .none
        
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }


}
