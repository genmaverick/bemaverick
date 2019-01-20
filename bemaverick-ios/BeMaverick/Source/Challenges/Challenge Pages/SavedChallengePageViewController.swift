//
//  SavedChallengePageViewController.swift
//  Maverick
//
//  Created by Garrett Fritz on 7/19/18.
//  Copyright © 2018 BeMaverick. All rights reserved.
//

import Foundation


class SavedChallengePageViewController : ChallengesPageViewController {
    
    override func viewDidLoad() {
        
        streamDelegate = self
        super.viewDidLoad()
        
    }
  
    override func getEmptyTitle() -> String {
        
        return "Nothing Saved"
        
    }
    
    override func getEmptySubTitle() -> String {
        
        return "In a hurry? Save Challenges you are interested in and we will keep them here for you!"
        
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if isEmpty, let cell = collectionView.dequeueReusableCell(withReuseIdentifier: R.reuseIdentifier.emptyCollectionCellId, for: indexPath)
        {
            
            cell.emptyView.configure(title: getEmptyTitle(), subtitle: getEmptySubTitle(), dark: false, emptySaved : true)
            return cell
            
            
            
        } else {
            
            return super.collectionView(collectionView, cellForItemAt: indexPath)
            
        }
        
        
    }
}

extension SavedChallengePageViewController : StreamRefreshControllerDelegate {
    func getMainSectionItemCount() -> Int {
        
        return getItemCount()
        
    }
    
    
    func refreshDataRequest() {
        
        services.globalModelsCoordinator.getSavedChallenges() { [weak self] in
            
            self?.refreshCompleted()
            
        }
        
    }
    
    func configureData() {
        
        guard let user = services.globalModelsCoordinator.loggedInUser else { return }
        challenges = user.savedChallenges
        
        updateNotification = challenges.observe { [weak self] changes in
            
               guard self?.isVisible ?? false else { return }
            DispatchQueue.main.async {
                
                self?.collectionView.reloadData()
                self?.collectionView.layoutIfNeeded()
                
            }
            
        }
        
        refreshCompleted()
        
    }
    
    //added delay here because calling nextpageloadCompleted immediately can stomp on the currently reloading process
    func loadNextPageRequest() {
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.2) { [weak self] in
            
            self?.nextPageLoadCompleted()
            
        }
        
    }
    
}
