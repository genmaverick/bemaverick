//
//  FeaturedStreamViewController.swift
//  BeMaverick
//
//  Created by David McGraw on 1/11/18.
//  Copyright © 2018 BeMaverick. All rights reserved.
//

import UIKit
import RealmSwift
import AVKit
import Kingfisher


class FeaturedChallengeStreamViewController: ChallengeStreamViewController {
    
    override func viewDidLoad() {
        
        hasNavBar = true
        streamDelegate = self
        super.viewDidLoad()
        
        
    }
    
  
    
}

extension FeaturedChallengeStreamViewController : StreamRefreshControllerDelegate {
    
    /**
     Function to be overriden by subclass, this should fire off the API request
     The completion block of request should call refreshCompleted()
     */
    func refreshDataRequest() {
        
        services.globalModelsCoordinator.getChallenges( forceRefresh: true, downloadAssets: false, featuredType: .challengeStream) { [weak self] error in
            
            self?.refreshCompleted()
            
        }
        
    }
    
    
    /**
     Called on view did load, meant to be overriden to load in data and set the
     data update observer
     */
    func configureData() {
        services = (UIApplication.shared.delegate as! AppDelegate).services
        
        guard let stream = services.globalModelsCoordinator.loggedInUser?.availableChallenges else { return }
        challengeData = stream
        attachDataObserver()
      
        refreshCompleted()
        
    }
    
    /**
     Function to be overriden by subclass, this should fire off the API request
     The completion block of request should call nextPageLoadCompleted()
     */
    func loadNextPageRequest() {
        
        services.globalModelsCoordinator.getChallenges(offset: challengeData.count, forceRefresh: true, downloadAssets: false, featuredType: .challengeStream) { [weak self] error in
            
            self?.nextPageLoadCompleted()
            
        }
        
    }
    
    /**
     Get item count
     */
    func getMainSectionItemCount() -> Int {
        
        return challengeData.count
    }
    
   

}
