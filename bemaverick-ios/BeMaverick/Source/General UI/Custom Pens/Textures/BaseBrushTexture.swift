//
//  BaseBrushTexture.swift
//  BeMaverick
//
//  Created by David McGraw on 1/31/18.
//  Copyright © 2018 BeMaverick. All rights reserved.
//

import Foundation
import JotUI
import CoreGraphics

class BaseBrushTexture: JotBrushTexture {
    
    var cachedTexture: UIImage!
    
    required init!(from dictionary: [AnyHashable : Any]!) {
        super.init(from: dictionary)
    }
    
    override init() {
        
        super.init()
        configureTexture()
        
    }
    
    init(withImage image: UIImage) {
        
        super.init()
        cachedTexture = image
    }
    
    override var texture: UIImage! {
        return cachedTexture
    }
    
    // MARK: - Texture
    
    fileprivate func configureTexture() {
        
        if cachedTexture != nil { return }
        
        UIGraphicsBeginImageContext(CGSize(width: 64, height: 64))
        
        let context = UIGraphicsGetCurrentContext()!
        UIGraphicsPushContext(context)

        let numLocs = 3
        let locations: [CGFloat] = [0.1, 0.2, 1.0]
        let comps: [CGFloat] = [ 1.0, 1.0, 1.0, 1.0,
                                 1.0, 1.0, 1.0, 1.0,
                                 1.0, 1.0, 1.0, 0.0 ]
        
        let colorspace = CGColorSpaceCreateDeviceRGB()
        
        let gradient = CGGradient.init(colorSpace: colorspace,
                                       colorComponents: comps,
                                       locations: locations,
                                       count: numLocs)!
        
        let center = CGPoint(x: 32, y: 32)
        let radius: CGFloat = 30
        
        context.drawRadialGradient(gradient,
                                   startCenter: center,
                                   startRadius: 0,
                                   endCenter: center,
                                   endRadius: radius,
                                   options: CGGradientDrawingOptions.drawsAfterEndLocation)
        
        UIGraphicsPopContext()
        
        cachedTexture = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
    }
    
    
}
