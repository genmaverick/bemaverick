//
//  HashtagPagerViewController.swift
//  Maverick
//
//  Created by Garrett Fritz on 7/26/18.
//  Copyright © 2018 BeMaverick. All rights reserved.
//

import Foundation


class HashtagPagerViewController : PagerViewController {
    
    private var tabNames : [Constants.ContentType] = [.challenge, .response]
    weak var contentPageDelegate : ContentPageViewControllerDelegate?
    
    
    func configure(with tagName : String, delegate : PagerViewControllerDelegate, services : GlobalServicesContainer) {
        
        self.pageDelegate = delegate
        
        
        vcs = []
        for name in tabNames {
            
            vcs?.append(self.newViewController(type: name, services: services, tagName : tagName))
            
        }
        
        if let firstViewController = orderedViewControllers().first {
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
    
    private func newViewController(type : Constants.ContentType, services : GlobalServicesContainer?, tagName : String) -> UIViewController {
        
        switch type {
        case .challenge:
            if let vc = R.storyboard.challenges.tagChallengesPageViewControllerId() {
                
                vc.shouldTrackScreen = false
                vc.delegate = contentPageDelegate
                vc.services = services
                vc.tagName = tagName
                return vc
                
            }
            
        case .response:
            if let vc = R.storyboard.feed.hashtagResponseStreamViewControllerId() {
                
                vc.shouldTrackScreen = false
                vc.delegate = contentPageDelegate
                vc.services = services
                vc.tagName  = tagName
                return vc
                
            }
         
        }
        
        return UIViewController()
        
    }
    
}
