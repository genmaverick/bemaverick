//
//  MaverickTextField.swift
//  BeMaverick
//
//  Created by David McGraw on 10/23/17.
//  Copyright © 2017 BeMaverick. All rights reserved.
//

import UIKit

class MaverickTextField: UITextField {
    
    var insetX: CGFloat = 0
    
    var insetY: CGFloat = 0
    
    /**
     Placeholder position
     */
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: insetX, dy: insetY)
    }
    
    /**
     Text position
     */
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: insetX, dy: insetY)
    }
    
}
