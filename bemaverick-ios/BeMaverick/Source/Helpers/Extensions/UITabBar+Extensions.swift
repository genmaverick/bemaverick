//
//  UITabBar+Extensions.swift
//  Maverick
//
//  Created by Garrett Fritz on 8/17/18.
//  Copyright © 2018 BeMaverick. All rights reserved.
//

import Foundation


extension UITabBarController {
    
    func setTabBarVisible(visible:Bool, duration: TimeInterval, animated:Bool) {
        
        guard tabBarIsVisible() != visible else { return }
        let frame = self.tabBar.frame
        let height = frame.size.height
        let offsetY = (visible ? -height : height)
        
        // animation
        if animated {
            
            UIViewPropertyAnimator(duration: duration, curve: .linear) {
                
                self.updatePositions(offsetY: offsetY)
                
                }.startAnimation()
            
        } else {
            
            updatePositions(offsetY: offsetY)
            
        }
        
    }
    
    func updatePositions(offsetY : CGFloat) {
        
        self.tabBar.frame.offsetBy(dx:0, dy:offsetY)
        self.view.frame = CGRect(x:0,y:0,width: self.view.frame.width, height: self.view.frame.height + offsetY)
        self.view.setNeedsDisplay()
        self.view.layoutIfNeeded()
        
    }
    
    func tabBarIsVisible() ->Bool {
        
        return self.tabBar.frame.origin.y < UIScreen.main.bounds.height
        
    }
    
}
