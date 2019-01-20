//
//  SavedChallengePageViewController.swift
//  Maverick
//
//  Created by Garrett Fritz on 7/19/18.
//  Copyright © 2018 BeMaverick. All rights reserved.
//

import Foundation


class TagChallengesPageViewController : ChallengesPageViewController {
    
    var tagName : String = ""
    
    
    override func viewDidLoad() {
        
        streamDelegate = self
        super.viewDidLoad()
        
    }
    
    override func trackScreen() {
        
        if shouldTrackScreen {
            
            AnalyticsManager.trackScreen(location: self, withProperties: ["tag" : tagName])
            
        }
        
    }
    
    override func getEmptyTitle() -> String {
        
        return "Nothing yet!"
        
    }
    
    override func getEmptySubTitle() -> String {
        
        return "So far there have been no Challenges with #\(tagName), create one now and see this page come to life!"
        
    }
    
}


extension TagChallengesPageViewController : StreamRefreshControllerDelegate {
    
    func getMainSectionItemCount() -> Int {
        
        return getItemCount()
        
    }
    
    
    func refreshDataRequest() {
        
        services.globalModelsCoordinator.getTagContent(contentType: .challenge, tagName: tagName) { [weak self] (challenges, responses) in
            
            if let list = challenges {
                
                self?.challenges = list
                
            }
            
            self?.loadingNewPage = false
            DispatchQueue.main.async {
                
                self?.collectionView.reloadData()
                self?.collectionView.layoutIfNeeded()
                self?.refreshCompleted()
                
            }
            
        }
        
    }
    
    func configureData() {
        
        loadingNewPage = true
        services.globalModelsCoordinator.getTagContent(contentType: .challenge,tagName: tagName) { [weak self] (challenges, responses) in
            
            if let list = challenges {
                
                self?.challenges = list
                
            }
            
            self?.loadingNewPage = false
            DispatchQueue.main.async {
                self?.firstLoad = true
                self?.collectionView.reloadData()
                self?.collectionView.layoutIfNeeded()
                self?.refreshCompleted()
                
            }
            
            
        }
        
        
    }
    
    //added delay here because calling nextpageloadCompleted immediately can stomp on the currently reloading process
    func loadNextPageRequest() {
        
        services.globalModelsCoordinator.getTagContent(contentType: .challenge,tagName: tagName, offset: challenges.count) { [weak self] (challenges, responses) in
            
            if let list = challenges {
                
                self?.challenges.append(objectsIn: list)
                
            }
            
            
            
            DispatchQueue.main.async {
                
                self?.nextPageLoadCompleted()
                self?.collectionView.reloadData()
                self?.collectionView.layoutIfNeeded()
                
                
            }
            
            
        }
        
    }
    
    
}

