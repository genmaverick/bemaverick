//
//  Pencil.swift
//  BeMaverick
//
//  Created by David McGraw on 1/31/18.
//  Copyright © 2018 BeMaverick. All rights reserved.
//

import Foundation
import UIKit
import JotUI

class Pencil: Pen {
    
    override init() {
        super.init(withMinSize: 3.0, maxSize: 7.0, minAlpha: 0.4, maxAlpha: 0.6)
    }

    override func textureForStroke() -> JotBrushTexture! {
        return PencilBrushTexture.sharedInstance
    }
    
    open override func updateSize(size: Constants.RecordingBrushSize) {
        
        var penSize: CGFloat = 7.0
        
        switch size {
        case .size1:
            penSize = 4
        case .size2:
            penSize = 5
        case .size3:
            penSize = 7
        case .size4:
            penSize = 9
        case .size5:
            penSize = 11
        case .size6:
            penSize = 13
        }
        
        minSize = penSize / 2.0
        maxSize = penSize
        
    }
    
}
