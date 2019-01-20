//
//  MaverickActionSheetAnimator.swift
//  Maverick
//
//  Created by Chris Garvey on 4/11/18.
//  Copyright © 2018 BeMaverick. All rights reserved.
//

import UIKit

class MaverickActionSheetAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    /// The duration of the animation during the transition.
    let duration = 0.7
    
    /**
     Required delegate function indicating the time length of the transition.
     */
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
    
    /**
     Required delegate function indicating what animations should be used for the transition.
     */
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        let containerView = transitionContext.containerView
        let actionSheetView = transitionContext.view(forKey: .to)!
        let toController = transitionContext.viewController(forKey: .to)! as! MaverickActionSheetVC
        
        var visibleContentHeight = round(toController.visibleContentHeight())
        
        if visibleContentHeight < 200 {
            visibleContentHeight = 200
        }
        
        actionSheetView.frame = CGRect(
            x: 0,
            y: containerView.bounds.height,
            width: containerView.bounds.width,
            height: containerView.bounds.height
        )
        
        containerView.addSubview(actionSheetView)
        containerView.bringSubview(toFront: actionSheetView)
        
        let tap = UITapGestureRecognizer(target: toController, action: #selector(MaverickActionSheetVC.dismissFromOutsideTouch(_:)))
        containerView.addGestureRecognizer(tap)
        tap.cancelsTouchesInView = false
        
        UIView.animate(withDuration: duration,
                       delay: 0.0,
                       usingSpringWithDamping: 0.6,
                       initialSpringVelocity: 0.2,
                       options: [.curveEaseOut],
                       animations:
        {
            actionSheetView.center.y -= (CGFloat(visibleContentHeight) + 64)
        }, completion: { _ in
             transitionContext.completeTransition(true)
        })
        
    }
    
    deinit {
        
        log.verbose("💥")
        
    }
    
}
