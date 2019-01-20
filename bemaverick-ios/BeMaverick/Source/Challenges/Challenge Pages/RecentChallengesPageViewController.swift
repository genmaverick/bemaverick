//
//  SavedChallengePageViewController.swift
//  Maverick
//
//  Created by Garrett Fritz on 7/19/18.
//  Copyright © 2018 BeMaverick. All rights reserved.
//

import Foundation


class RecentChallengesPageViewController : ChallengesPageViewController {
    
    override func viewDidLoad() {
        
        streamDelegate = self
        super.viewDidLoad()
        
    }
    
}

extension RecentChallengesPageViewController : StreamRefreshControllerDelegate {
    
    func getMainSectionItemCount() -> Int {
        
        return getItemCount()
        
    }
    
    func refreshDataRequest() {
        
        services.globalModelsCoordinator.getChallenges( forceRefresh: true, downloadAssets: false, featuredType: .challengeStream) { [weak self] error in
            
            self?.refreshCompleted()
            
        }
        
    }
    
    func configureData() {
        
        guard let stream = services.globalModelsCoordinator.loggedInUser?.availableChallenges else { return }
        challenges = stream
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
        
        collectionView.reloadData()
        
        services.globalModelsCoordinator.getChallenges(offset: challenges.count, forceRefresh: true, downloadAssets: false, featuredType: .challengeStream) { [weak self] error in
            
            self?.nextPageLoadCompleted()
            
        }
        
    }
   
    
}
