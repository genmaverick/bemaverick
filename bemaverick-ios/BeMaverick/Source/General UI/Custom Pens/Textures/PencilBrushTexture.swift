//
//  PencilBrushTexture.swift
//  BeMaverick
//
//  Created by David McGraw on 1/31/18.
//  Copyright © 2018 BeMaverick. All rights reserved.
//

import Foundation
import JotUI

class PencilBrushTexture: JotBrushTexture, NSCopying {
    
    // MARK: - Static
    
    /// A shared intance for this texture
    static let sharedInstance = PencilBrushTexture()
    
    required override init() {
        super.init()
    }
    
    required init!(from dictionary: [AnyHashable : Any]!) {
        fatalError("init(from:) has not been implemented")
    }
    
    func copy(with zone: NSZone? = nil) -> Any {
        return type(of: self).init()
    }
    
    // MARK: - Override
    
    override var texture: UIImage! {
        return brushTexture()!.texture
    }
    
    override var name: String! {
        return "pencilTexture"
    }
    
    override func bind() -> Bool {
        return brushTexture()!.bind()
    }
    
    override func unbind() {
        
        guard let curContext = JotGLContext.current() as? JotGLContext else {
            assertionFailure("Cannot unbind texture to nil gl context")
            return
        }
        
        guard let texture = curContext.contextProperties.object(forKey: name as NSString) as? JotBrushTexture else {
            assertionFailure("Cannot unbind unbilt brush texture")
            return
        }
        
        texture.unbind()
        
    }
    
    // MARK: - Private Methods
    
    private func brushTexture() -> BaseBrushTexture? {
        
        guard let curContext = JotGLContext.current() as? JotGLContext else {
            assertionFailure("Cannot unbind texture to nil gl context")
            return nil
        }
        
        var texture: BaseBrushTexture? = curContext.contextProperties.object(forKey: name as NSString) as? BaseBrushTexture
            
        if texture == nil {
            
            texture = BaseBrushTexture()
            curContext.contextProperties.setObject(texture!, forKey: name as NSString)
            
        }
        return texture!
        
    }
    
}
