//
//  UITextField+Extensions.swift
//  Maverick
//
//  Created by David McGraw on 3/1/18.
//  Copyright © 2018 BeMaverick. All rights reserved.
//

import UIKit

extension UITextField {
    
    /// Expose a placeholder color
    @IBInspectable var placeHolderColor: UIColor? {
        
        get {
            
            if let l = attributedPlaceholder?.length, l > 0 {
                return self.placeHolderColor
            }
            return nil
            
        }
        
        set {
            
            if let value = newValue {
                attributedPlaceholder = NSAttributedString(string: placeholder != nil ? placeholder! : "",
                                                           attributes: [ NSAttributedStringKey.foregroundColor: value ] )
            }
            
        }
        
    }
    
}
