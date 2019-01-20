//
//  SummaryDetailsPresentAnimationController.swift
//  Maverick
//
//  Created by Garrett Fritz on 8/15/18.
//  Copyright © 2018 BeMaverick. All rights reserved.
//

import Foundation

class SummaryDetailsPresentAnimationController : NSObject, UIViewControllerAnimatedTransitioning {
    
    var duration : TimeInterval
    var isPresenting : Bool
    var originFrame : CGRect
    var image : UIImage
    
    public let CustomAnimatorTag = 99
    
    init(duration : TimeInterval, isPresenting : Bool, originFrame : CGRect, image : UIImage?) {
        self.duration = duration
        self.isPresenting = isPresenting
        self.originFrame = originFrame
        self.image = image ?? R.image.back_purple()!
    }
    
    func animatePresent(using transitionContext: UIViewControllerContextTransitioning) {
        
        let container = transitionContext.containerView
        
        guard let fromView = transitionContext.view(forKey: UITransitionContextViewKey.from) else { return }
        
        guard let endController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to) as? ViewController else { return }
        
        container.addSubview(endController.view)
        let transitionFrame = endController.getTransitionFrame() ?? CGRect.zero
        let transitionImageView = UIImageView(frame: originFrame)
        transitionImageView.image = image
        
        container.addSubview(transitionImageView)
        endController.view.alpha = 0
        
        for viewToFade : UIView in endController.getTransitionAlphaView() {
            
            viewToFade.alpha  =  0.0
            
        }
        
        UIView.animate(withDuration: duration - 0.2 , animations: {
            
            transitionImageView.frame = transitionFrame
            endController.view.frame = fromView.frame
            endController.view.alpha = 1
            
            
        }, completion: { (finished) in
            
            UIView.animate(withDuration: 0.05 , animations: {
                for viewToFade : UIView in endController.getTransitionAlphaView() {
                    
                    viewToFade.alpha  = 1.0
                    
                }
                
            }) { finished in
                
                UIView.animate(withDuration: 0.15 , animations: {
                    
                       transitionImageView.alpha = 0.0
                    
                    
                }) { finished in
                    
               
                endController.transitionCompleted()
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
                transitionImageView.removeFromSuperview()
              
                }
            
            }
            
        })
        
    }
    
    func animateDismiss(using transitionContext: UIViewControllerContextTransitioning) {
        
        let container = transitionContext.containerView
        
        guard let endController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to) as? ViewController else { return }
        
        guard let startController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from) as? ViewController else { return }
        
        container.insertSubview(endController.view, belowSubview: startController.view)
        var fullTransition = true
        //if .zero, that means the initial view has left the screen, so just fade back in the original
        var transitionFrame = startController.getTransitionFrame()  ?? CGRect.zero
        if transitionFrame == .zero {
            transitionFrame = originFrame
            fullTransition = false
        }
        
        let transitionImageView = UIImageView(frame:  transitionFrame)
        transitionImageView.image = image
        
        if fullTransition {
       
            container.addSubview(transitionImageView)
        
        } else {
          
            container.insertSubview(transitionImageView, belowSubview: startController.view)
            
        }
        
        
        endController.view.alpha = 1
        
        endController.view.layoutIfNeeded()
        
        UIView.animate(withDuration: self.duration , animations: {
            
            transitionImageView.frame = self.originFrame
            startController.view.alpha =  0
            for viewToFade : UIView in startController.getTransitionAlphaView() {
                
                viewToFade.alpha  = 0.0
                
            }
            
            
        }, completion: { (finished) in
            
            endController.transitionCompleted()
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            transitionImageView.removeFromSuperview()
            
        })
        
        
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        if isPresenting {
            
            animatePresent(using: transitionContext)
            
        } else {
            
            animateDismiss(using: transitionContext)
            
        }
        
    }
    
    func animationEnded(_ transitionCompleted: Bool) {
        
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
    
    
}

