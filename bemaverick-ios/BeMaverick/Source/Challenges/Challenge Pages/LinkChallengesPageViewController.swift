//
//  LinkChallengesPageViewController.swift
//  Maverick
//
//  Created by Garrett Fritz on 7/19/18.
//  Copyright © 2018 BeMaverick. All rights reserved.
//

import Foundation


class LinkChallengesPageViewController : ChallengesPageViewController {
    
    override func viewDidLoad() {
        
        streamDelegate = self
        super.viewDidLoad()
        
    }
    
    override func getEmptyTitle() -> String {
        
        return "Link Challenges"
        
    }
    
    override func getEmptySubTitle() -> String {
        
        return "Challenges that link out to different websites will post here"
        
    }
    
}


extension LinkChallengesPageViewController : StreamRefreshControllerDelegate {
    
    func getMainSectionItemCount() -> Int {
        
        return getItemCount()
        
    }
    
    func refreshDataRequest() {
        
        let _ = services.globalModelsCoordinator.getLinkChallenges(forceRefresh : true) {[weak self] (error) in
            
            self?.refreshCompleted()
            
        }
        
    }
    
    func configureData() {
        
        challenges = services.globalModelsCoordinator.getLinkChallenges(forceRefresh : false)
        
        updateNotification = challenges.observe { [weak self] changes in
            
               guard self?.isVisible ?? false else { return }
            DispatchQueue.main.async {
                
                self?.collectionView.reloadData()
                self?.collectionView.layoutIfNeeded()
                
            }
          
            
        }
        
        refreshCompleted()
        
    }
    
    func loadNextPageRequest() {
        
        let _ = services.globalModelsCoordinator.getLinkChallenges(forceRefresh : true, offset : challenges.count) {[weak self] (error) in
            
            self?.nextPageLoadCompleted()
            
        }
        
    }
    
}

