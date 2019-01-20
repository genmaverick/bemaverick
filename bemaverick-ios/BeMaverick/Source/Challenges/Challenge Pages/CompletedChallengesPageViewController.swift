//
//  SavedChallengePageViewController.swift
//  Maverick
//
//  Created by Garrett Fritz on 7/19/18.
//  Copyright © 2018 BeMaverick. All rights reserved.
//

import Foundation


class CompletedChallengesPageViewController : ChallengesPageViewController {
    
    override func viewDidLoad() {
        
        streamDelegate = self
        super.viewDidLoad()
        
    }
    
    override func getEmptyTitle() -> String {
        
        return "Complete Challenges!"
        
    }
    
    override func getEmptySubTitle() -> String {
        
        return "Respond to some Challenges and see this page come to life!"
        
    }
  
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    
        let cell = super.collectionView(collectionView, cellForItemAt: indexPath)
        
        if let challengeCell = cell as? SmallContentCollectionViewCell {
            
            
            challengeCell.completeIcon.isHidden = false
            return challengeCell
            
        }
        
        return cell
    
    }
    
}


extension CompletedChallengesPageViewController : StreamRefreshControllerDelegate {
    
    func getMainSectionItemCount() -> Int {
        
        return getItemCount()
        
    }
    
    func refreshDataRequest() {
        
        let _ = services.globalModelsCoordinator.getMyRespondedChallenges(forceRefresh : true) {[weak self] (error) in
            
            self?.refreshCompleted()
            
        }
        
    }
    
    func configureData() {
        
        challenges = services.globalModelsCoordinator.getMyRespondedChallenges(forceRefresh : false)
        
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
        
        let _ = services.globalModelsCoordinator.getMyRespondedChallenges(forceRefresh : true, offset : challenges.count) {[weak self] (error) in
            
            self?.nextPageLoadCompleted()
            
        }
        
    }
    
}

