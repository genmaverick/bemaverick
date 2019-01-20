//
//  MaverickActionSheetTransitioningDelegate.swift
//  Maverick
//
//  Created by Chris Garvey on 4/12/18.
//  Copyright © 2018 BeMaverick. All rights reserved.
//

import UIKit

class MaverickActionSheetTransitioningDelegate: NSObject, UIViewControllerTransitioningDelegate {

    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return MaverickActionSheetAnimator()
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return nil
    }
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return MaverickActionSheetPresentationController(presentedViewController: presented, presenting: presenting)
    }
    
}
