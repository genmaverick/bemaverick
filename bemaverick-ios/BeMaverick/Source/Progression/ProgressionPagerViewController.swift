//
//  ProgressionPagerViewController.swift
//  Maverick
//
//  Created by Garrett Fritz on 9/13/18.
//  Copyright © 2018 BeMaverick. All rights reserved.
//

import Foundation


class ProgressionPagerViewController : PagerViewController {
    
    private var vcs : [UIViewController]?
    
    func configure( delegate : PagerViewControllerDelegate, services : GlobalServicesContainer) {
        
        allowLooping = false
        self.pageDelegate = delegate
        vcs = []
        if let vc = R.storyboard.progression.myProgressViewControllerId() {
            vc.services = services
            vcs?.append(vc)
            
        }
        
        if let vc = R.storyboard.progression.progressionLeaderboardViewControllerId() {
            
            vc.services = services
            vcs?.append(vc)
            
        }
        
        
        if let firstViewController = orderedViewControllers().first {
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
