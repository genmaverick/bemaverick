//
//  DismissableViewController.swift
//  Maverick
//
//  Created by Garrett Fritz on 9/25/18.
//  Copyright © 2018 BeMaverick. All rights reserved.
//

import Foundation

class DismissableViewController : ViewController {
    
    var initialTouchPoint: CGPoint = CGPoint(x: 0,y: 0)
    
    @IBAction func panGestureRecognizerHandler(_ sender: UIPanGestureRecognizer) {
        
        let touchPoint = sender.location(in: self.view?.window)
        
        if sender.state == UIGestureRecognizerState.began {
            
            initialTouchPoint = touchPoint
            
        } else if sender.state == UIGestureRecognizerState.changed {
            
            let offset = touchPoint.y - initialTouchPoint.y
            
            if offset > 0 {
                
                
                self.view.frame = CGRect(x: 0, y: offset, width: self.view.frame.size.width, height: self.view.frame.size.height)
                
                var alphaValue =  ((300 - offset) / 300)
                if alphaValue < 0 {
                    alphaValue = 0
                }
                
                self.view.alpha = alphaValue
                
            }
            
        } else if sender.state == UIGestureRecognizerState.ended || sender.state == UIGestureRecognizerState.cancelled {
            
            if touchPoint.y - initialTouchPoint.y > 100 {
                
                self.dismiss(animated: true, completion: nil)
                
            } else {
                
                UIView.animate(withDuration: 0.3, animations: {
                    
                    self.view.alpha = 1
                    self.view.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height)
                    
                })
                
            }
            
        }
        
    }
    
}
