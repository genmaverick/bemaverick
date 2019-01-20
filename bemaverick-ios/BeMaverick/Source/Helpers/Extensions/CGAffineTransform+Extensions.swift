//
//  CGAffineTransform+Extensions.swift
//  Maverick
//
//  Created by David McGraw on 4/9/18.
//  Copyright © 2018 BeMaverick. All rights reserved.
//

import Foundation


extension CGAffineTransform {
    
    /**
     Return a transform with Rotation + Scale applied
    */
    public static func makeRotation(_ angle: CGFloat, scale: CGFloat) -> CGAffineTransform {
        
        let angle   = angle * CGFloat.pi / 180.0
        let rotate  = CGAffineTransform(rotationAngle: angle)
        let scale   = CGAffineTransform(scaleX: scale, y: scale)
        return rotate.concatenating(scale)
        
    }
    
}
