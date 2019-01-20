//
//  TagResponsesPageViewController.swift
//  Maverick
//
//  Created by Garrett Fritz on 7/19/18.
//  Copyright © 2018 BeMaverick. All rights reserved.
//

import Foundation


class TagResponsesPageViewController : ResponsesPageViewController {
    
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
        
        return "So far there have been no Responses with #\(tagName), create one now and see this page come to life!"
        
    }
    
}


extension TagResponsesPageViewController : StreamRefreshControllerDelegate {
    
    func getMainSectionItemCount() -> Int {
        
        return getItemCount()
        
    }
    
    
    func refreshDataRequest() {
        
        services.globalModelsCoordinator.getTagContent(contentType: .response, tagName: tagName) { [weak self] (challenges, responses) in
            
            if let list = responses {
                
                self?.responses = list
                
            }
            DispatchQueue.main.async {
                
                self?.collectionView.reloadData()
                self?.collectionView.layoutIfNeeded()
                self?.refreshCompleted()
                
            }
            
        }
        
    }
    
    func configureData() {
        
        loadingNewPage = true
 services.globalModelsCoordinator.getTagContent(contentType: .response,tagName: tagName) { [weak self] (challenges, responses) in
            
            if let list = responses {
                
                self?.responses = list
                
            }
    
    self?.loadingNewPage = false
           self?.firstLoad = true
            DispatchQueue.main.async {
                
                self?.collectionView.reloadData()
                self?.collectionView.layoutIfNeeded()
                self?.refreshCompleted()
                
            }
            
            
        }
        
        
    }
    
    //added delay here because calling nextpageloadCompleted immediately can stomp on the currently reloading process
    func loadNextPageRequest() {
        
        services.globalModelsCoordinator.getTagContent(contentType: .response,tagName: tagName, offset: responses.count) { [weak self] (challenges, responses) in
            
            if let list = responses {
                
                self?.responses.append(objectsIn: list)
                
            }
            
            
            self?.loadingNewPage = false
            DispatchQueue.main.async {
            
                self?.nextPageLoadCompleted()
                self?.collectionView.reloadData()
                self?.collectionView.layoutIfNeeded()
                
                
            }
            
            
        }
        
    }
    
}

