//
//  NSLayoutConstraint+Extensions.swift
//  Maverick
//
//  Created by Garrett Fritz on 6/26/18.
//  Copyright © 2018 BeMaverick. All rights reserved.
//

import Foundation

extension NSLayoutConstraint {
    
    func constraintWithMultiplier(_ multiplier: CGFloat) -> NSLayoutConstraint {
        
        return NSLayoutConstraint(item: self.firstItem!, attribute: self.firstAttribute, relatedBy: self.relation, toItem: self.secondItem, attribute: self.secondAttribute, multiplier: multiplier, constant: self.constant)
    
    }
    
}
