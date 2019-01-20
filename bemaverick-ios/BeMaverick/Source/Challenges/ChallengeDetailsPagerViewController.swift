//
//  ChallengeDetailsPagerViewController.swift
//  Maverick
//
//  Created by Garrett Fritz on 7/17/18.
//  Copyright © 2018 BeMaverick. All rights reserved.
//

import Foundation

class ChallengeDetailsPagerViewController : PagerViewController {
    
    private var challenges : [Challenge] = []
    weak var contentPageDelegate : ContentPageViewControllerDelegate?
    private var startingIndex = 0
    private var initialTransition = true
    func getTransitionFrame() -> CGRect? {
        
        guard let currentViewController = self.viewControllers?.first else { return nil }
        guard initialTransition || getCurrentPage() == startingIndex else { return .zero }
        initialTransition = false
        if let cvc = currentViewController as? ChallengeDetailsPageViewController {
            
            return cvc.getTransitionFrame()
            
        }
        
        return nil
        
    }
    
    func configure(with challenges : [Challenge], startingIndex : Int, services : GlobalServicesContainer) {
        
        allowLooping = false
        self.startingIndex = startingIndex
        self.challenges = challenges
        vcs = []
        
        for challenge in challenges {
            
            vcs?.append(self.newViewController(challenge: challenge, services: services))
            
        }
        
        if let firstViewController = orderedViewControllers()[safe : startingIndex + 0] {
            setViewControllers([firstViewController],
                               direction: .forward,
                               animated: true,
                               completion: nil)
        }
        
        pageDelegate?.paginatedViewController(paginatedViewController: self, didUpdatePageCount: orderedViewControllers().count)
        
        
    }
    private var vcs : [UIViewController]?
    
    override func orderedViewControllers() -> [UIViewController] {
        
        return vcs ?? []
        
    }
    
    func scrollToTop() {
        
        for vc in orderedViewControllers() {
            
            if let svc = vc as? ChallengeDetailsPageViewController {
                
                svc.scrollToTop()
                
            }
            
        }
        
    }
    
    private func newViewController(challenge : Challenge, services : GlobalServicesContainer?) -> UIViewController {
        
//        if let vc = R.storyboard.feed.challengeResponseStreamViewControllerId() {
//            
//            vc.services = services
//            vc.challengeId = challenge.challengeId
//            return vc
//            
//        }
       
        
        if let vc = R.storyboard.challenges.challengeDetailsPageViewControllerId() {
            
            vc.shouldTrackScreen = false
            vc.services = services
            vc.configure(with: challenge, startMinimized: false)
            vc.delegate = contentPageDelegate
            return vc
            
        }
        
        return UIViewController()
        
    }
    
}
