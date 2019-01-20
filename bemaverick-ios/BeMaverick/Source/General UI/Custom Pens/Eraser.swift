//
//  Eraser.swift
//  BeMaverick
//
//  Created by David McGraw on 1/31/18.
//  Copyright © 2018 BeMaverick. All rights reserved.
//

import Foundation
import UIKit
import JotUI

class Eraser: Pen {
    
    override init() {
        super.init(withMinSize: 12, maxSize: 60, minAlpha: 1, maxAlpha: 1)
    }

    override open func updateSize(size: Constants.RecordingBrushSize) {
        
        var penSize: CGFloat = 30.0
        
        switch size {
        case .size1:
            penSize = 15
        case .size2:
            penSize = 25
        case .size3:
            penSize = 30
        case .size4:
            penSize = 35
        case .size5:
            penSize = 45
        case .size6:
            penSize = 60
        }
        
        minSize = penSize
        maxSize = penSize
        
    }
    
}

extension Eraser {
    
    /**
     Use pressure data to determine the width at a new touch location
     */
    override func width(forCoalescedTouch coalescedTouch: UITouch!, from touch: UITouch!) -> CGFloat {
        
        var width: CGFloat = 0
        
        if shouldUseVelocity {
            
            width = (velocity - 1)
            
            if width > 0 {
                width = 0
            }
            
            width = maxSize + abs(width) * (minSize - maxSize)
            
            if width < 1 {
                width = 1
            }
            
        } else {
            
            width = minSize + (maxSize + minSize) * coalescedTouch.force
            width = max(minSize, min(maxSize, width))
            
        }
        
        return width
        
    }
    
    /**
     Returns no color to erase
    */
    override func color(forCoalescedTouch coalescedTouch: UITouch!, from touch: UITouch!) -> UIColor! {
        return nil
    }
    
}
