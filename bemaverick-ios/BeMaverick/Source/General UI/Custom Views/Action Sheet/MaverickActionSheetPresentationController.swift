//
//  MaverickActionSheetPresentationController.swift
//  Maverick
//
//  Created by Chris Garvey on 4/12/18.
//  Copyright © 2018 BeMaverick. All rights reserved.
//

import UIKit

class MaverickActionSheetPresentationController: UIPresentationController {
    
    override func presentationTransitionWillBegin() {

        UIView.animate(withDuration: 0.2, animations: {
            self.presentingViewController.view.alpha = 0.5
            
        })
        
    }
    
    override func dismissalTransitionWillBegin() {
        if let coordinator = presentingViewController.transitionCoordinator {
            
            coordinator.animate(alongsideTransition: { (context) -> Void in
                self.presentingViewController.view.alpha = 1.0
            }, completion: nil)
            
        }
        
    }
    
}
