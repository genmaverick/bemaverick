//
//  SavedChallengePageViewController.swift
//  Maverick
//
//  Created by Garrett Fritz on 7/19/18.
//  Copyright © 2018 BeMaverick. All rights reserved.
//

import Foundation


class EmptyChallengesPageViewController : ChallengesPageViewController {
    
    override func viewDidLoad() {
        
        streamDelegate = self
        super.viewDidLoad()
        
    }
  
}

extension EmptyChallengesPageViewController : StreamRefreshControllerDelegate {
    func getMainSectionItemCount() -> Int {
        
       return getItemCount()
    
    }
    
    
    func refreshDataRequest() {
       
        let _ = services.globalModelsCoordinator.getNoResponseChallenges(forceRefresh : true) {[weak self] (error) in
            
            self?.refreshCompleted()
            
        }
        
    }
    
    func configureData() {
        
        challenges = services.globalModelsCoordinator.getNoResponseChallenges(forceRefresh : false)
        
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
        
        let _ = services.globalModelsCoordinator.getNoResponseChallenges(forceRefresh : true, offset : challenges.count) {[weak self] (error) in
            
           self?.nextPageLoadCompleted()
            
        }
        
    }
    
}
