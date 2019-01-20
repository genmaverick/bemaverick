//
//  ChallengesPagerViewController.swift
//  Maverick
//
//  Created by Garrett Fritz on 7/17/18.
//  Copyright © 2018 BeMaverick. All rights reserved.
//

import Foundation

class ChallengesPagerViewController : PagerViewController {
    
    weak var contentPageDelegate : ContentPageViewControllerDelegate?
    
    private var tabNames : [String] = []
    private var categoryStrings : [String] = []
     private var vcs : [UIViewController]?
    
    func configure(with tabNames : [String], categories : [ChallengesPageViewController.challengePageType], categoryStrings : [String], delegate : PagerViewControllerDelegate, services : GlobalServicesContainer) {
        
        self.pageDelegate = delegate
        self.tabNames = tabNames
        self.categoryStrings = categoryStrings
        vcs = []
        for i in 0 ..< tabNames.count {
            
            guard let category = categories[safe: i], let categoryString = categoryStrings[safe : i]  else { continue }
            let data = category == .hashtag ? categoryString : tabNames[safe : i]
            let version = Int(categoryStrings[safe: i] ?? "0") ?? 0
            vcs?.append(self.newViewController(type: category, services: services, data : data, versionNumber: version))
            
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
    
        for vc in orderedViewControllers() {
            
            if let svc = vc as? StreamCollectionViewController {
                
                svc.scrollToTop()
                
            }
            
        }
        
    }
    
    private func newViewController(type : ChallengesPageViewController.challengePageType, services : GlobalServicesContainer?, data : String? = nil, versionNumber : Int = 0) -> UIViewController {
        
        switch type {
        case .first:
            if let vc = R.storyboard.challenges.emptyChallengesPageViewControllerId() {
                
                vc.delegate = contentPageDelegate
                vc.services = services
                return vc
                
            }
            
            
        case .saved:
            if let vc = R.storyboard.challenges.savedChallengePageViewControllerId() {
                
                vc.delegate = contentPageDelegate
                vc.services = services
                return vc
                
            }
            
        case .completed:
            if let vc = R.storyboard.challenges.completedChallengesPageViewControllerId() {
                
                vc.delegate = contentPageDelegate
                vc.services = services
                return vc
                
            }
            
        case .invited:
            if let vc = R.storyboard.challenges.invitedChallengesPageViewControllerId() {
                
                vc.delegate = contentPageDelegate
                vc.services = services
                return vc
                
            }
            
        case .link:
            if let vc = R.storyboard.challenges.linkChallengesPageViewControllerId() {
                
                vc.delegate = contentPageDelegate
                vc.services = services
                return vc
                
            }
            
        case .hashtag:
            if let vc = R.storyboard.challenges.tagChallengesPageViewControllerId() {
                
                vc.delegate = contentPageDelegate
                vc.services = services
                vc.tagName = data?.replacingOccurrences(of: "#", with: "") ?? ""
                return vc
                
            }
            
        case .recent:
            if let vc = R.storyboard.challenges.recentChallengesPageViewControllerId() {
                
                vc.delegate = contentPageDelegate
                vc.services = services
                return vc
                
            }
            
        case .trending:
            if let vc = R.storyboard.challenges.trendingChallengesPageViewControllerId() {
                
                vc.versionNumber = versionNumber
                vc.delegate = contentPageDelegate
                vc.services = services
                return vc
                
            }
            
        }
        
        return UIViewController()
    
    }
    
}
