//
//  UIButton+Extensions.swift
//  BeMaverick
//
//  Created by David McGraw on 1/5/18.
//  Copyright © 2018 BeMaverick. All rights reserved.
//

import UIKit

extension UIButton {
    
    /**
     Applies a default shadow to the text, offset 0, 1
     */
    open func applyDefaultDarkShadow() {
        
        titleLabel?.layer.shadowOffset = CGSize(width: 0.0, height: 1.0)
        titleLabel?.layer.shadowOpacity = 0.5
        titleLabel?.layer.shadowRadius = 1.0
        titleLabel?.layer.shouldRasterize = true
        
    }
    
}
