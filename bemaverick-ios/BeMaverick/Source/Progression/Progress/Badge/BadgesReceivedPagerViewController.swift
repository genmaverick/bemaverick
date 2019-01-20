//
//  BadgesReceivedPagerViewController.swift
//  Maverick
//
//  Created by Garrett Fritz on 9/17/18.
//  Copyright © 2018 BeMaverick. All rights reserved.
//

import Foundation


class BadgesReceivedPagerViewController : PagerViewController {
    
    private var vcs : [UIViewController]?
    weak var contentPageDelegate : ContentPageViewControllerDelegate?
    
    func configure(user : User, delegate : PagerViewControllerDelegate, services : GlobalServicesContainer, initialSection : Int) {
        
        allowLooping = false
        self.pageDelegate = delegate
        vcs = []
        
        for badgesStats in user.badgeStats {
        
             guard badgesStats.numReceived > 0 else { continue }
            if let vc = R.storyboard.progression.badgesReceivedPageViewControllerId() {
              
                vc.delegate = contentPageDelegate
                vc.user = user
                vc.badgeId = badgesStats.badgeId
                vc.services = services
                vcs?.append(vc)
                
            }
        
        }
        
        if let firstViewController = orderedViewControllers()[safe: initialSection] {
         
            setViewControllers([firstViewController],
                               direction: .forward,
                               animated: true,
                               completion: nil)
        
        }
        
        pageDelegate?.paginatedViewController(paginatedViewController: self, didUpdatePageCount: orderedViewControllers().count)
        
    }
    
    override func orderedViewControllers() -> [UIViewController] {
        
        return vcs ?? []
        
    }
    
    func scrollToTop() {
        
        for _ in orderedViewControllers() {
            
        }
        
    }
    
}
