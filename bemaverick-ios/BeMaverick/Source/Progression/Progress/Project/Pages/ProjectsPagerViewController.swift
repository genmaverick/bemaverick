//
//  ProjectsPagerViewController.swift
//  Maverick
//
//  Created by Garrett Fritz on 9/17/18.
//  Copyright © 2018 BeMaverick. All rights reserved.
//

import Foundation


class ProjectsPagerViewController : PagerViewController {
    
    private var vcs : [UIViewController]?
    
    func configure(user : User, delegate : PagerViewControllerDelegate, services : GlobalServicesContainer, initialSection : ProjectProgressTableViewCell.ProjectProgressViewFilter) {
        
        allowLooping = false
        self.pageDelegate = delegate
        vcs = []
        
        var selectedPage = 0
        if user.progression?.hasInProgress() ?? false {
            
            if let vc = R.storyboard.progression.projectsPageViewControllerId() {
                
                
                vc.filter = .inProgress
                vc.user = user
                vc.services = services
                vcs?.append(vc)
                
            }
            
            if (user.progression?.hasCompleted() ?? false) && initialSection == .completed{
                
                  selectedPage = 1
            }
            
        }
        
        if user.progression?.hasCompleted()  ?? false {
            
            if let vc = R.storyboard.progression.projectsPageViewControllerId() {
                
                vc.user = user
                vc.filter = .completed
                vc.services = services
                vcs?.append(vc)
                
            }
            
        }
        
        if let firstViewController = orderedViewControllers()[safe: selectedPage] {
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
