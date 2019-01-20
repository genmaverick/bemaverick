//
//  PassthroughTouchView.swift
//  Maverick
//
//  Created by David McGraw on 4/1/18.
//  Copyright © 2018 BeMaverick. All rights reserved.
//

import UIKit

class PassthroughTouchView: UIView {
    
    /**
     Allow a touch to be passed through to underlying views
    */
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        
        let v = super.hitTest(point, with: event)
        return v == self ? nil : v
        
    }
    
}
