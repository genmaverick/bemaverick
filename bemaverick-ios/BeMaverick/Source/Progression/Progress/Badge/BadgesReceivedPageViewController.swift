
//
//  BadgesReceivedPageViewController.swift
//  Maverick
//
//  Created by Garrett Fritz on 9/17/18.
//  Copyright © 2018 BeMaverick. All rights reserved.
//

import Foundation

class BadgesReceivedPageViewController: ResponsesPageViewController {
    
    var user : User?
    var badgeId : String?
    var tagName : String = ""
    
    override func viewDidLoad() {
        
        streamDelegate = self
        super.viewDidLoad()
        
    }
    
    override func getEmptyTitle() -> String {
        
        return "Nothing yet!"
        
    }
    
    override func getEmptySubTitle() -> String {
        
        return "So far there have been no Responses with this badge type!"
        
    }
    
}


extension BadgesReceivedPageViewController : StreamRefreshControllerDelegate {
    
    func getMainSectionItemCount() -> Int {
        
        return getItemCount()
        
    }
    
    
    func refreshDataRequest() {
        
        
        services.globalModelsCoordinator.getUserCreatedBadgedResponses(withBadge: badgeId, forUserId: user?.userId, count: 25, offset: 0) { [weak self] (results) in
            if let results = results {
               
                self?.responses = results
                
            }
            
            DispatchQueue.main.async {
                
                self?.refreshCompleted()
                self?.collectionView.reloadData()
                self?.collectionView.layoutIfNeeded()
                
            }
        
        }
        
    }
    
    func configureData() {
        
        loadingNewPage = true
        services.globalModelsCoordinator.getUserCreatedBadgedResponses(withBadge: badgeId, forUserId: user?.userId, count: 25, offset: 0) { [weak self] (results) in
            
            if let results = results {
           
                self?.responses = results
               
            }
            
            DispatchQueue.main.async {
                
                self?.refreshCompleted()
                self?.collectionView.reloadData()
                self?.collectionView.layoutIfNeeded()
                
                
            }
            
        }
        
    }
    
    func loadNextPageRequest() {
        
        services.globalModelsCoordinator.getUserCreatedBadgedResponses(withBadge: badgeId, forUserId: user?.userId, offset : responses.count) { [weak self] (results) in
            
            if let results = results {
                
                self?.responses.append(objectsIn: results)
                self?.nextPageLoadCompleted()
                DispatchQueue.main.async {
                    
                    self?.collectionView.reloadData()
                    self?.collectionView.layoutIfNeeded()
                    
                }
            
            } else {
                
                self?.nextPageLoadCompleted()
                
            }
            
        }
        
    }
    
}
