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

class GenericChallengeStreamViewController: ChallengeStreamViewController {
    
    var paginationEnabled = false
    var stream : ConfigurableChallengeStream?
    
    override func viewDidLoad() {
        
        hasNavBar = true
        streamDelegate = self
        Video.appUserMuted = false
        super.viewDidLoad()
        
    }
    
    /**
     Set up viewcontroller with user id and position to start at
     */
    func configure(stream : ConfigurableChallengeStream, paginationEnabled : Bool, initialScrollPosition : Int = 0) {
        
        self.paginationEnabled = paginationEnabled
        self.initialScrollPosition = initialScrollPosition
        self.stream = stream
        showNavBar(withTitle: stream.label ?? "Responses")
        
    }
    
}

extension GenericChallengeStreamViewController : StreamRefreshControllerDelegate {
    
    func configureData() {
        
        
        guard let stream = stream else { return }
        challengeData = stream.items
        attachDataObserver()
        if challengeData.count == 0 {
        
            refresh(tableView?.refreshControl)
        
        }
        showNavBar(withTitle: stream.label ?? "Challenges")
        
    }
    
    func refreshDataRequest() {
        
        guard let stream = stream else { return }
        services.globalModelsCoordinator.getConfigurableSteam(stream: stream, forceRefresh : true) { [weak self] in
            
            self?.refreshCompleted()
            
        }
        
        
        
    }
    
    func loadNextPageRequest() {
        
        guard let stream = stream, paginationEnabled  else {
            nextPageLoadCompleted()
            return
        }
        
        services.globalModelsCoordinator.getConfigurableSteam(stream: stream, forceRefresh: true, offset:challengeData.count) { [weak self] in
            
            self?.nextPageLoadCompleted()
            
        }
        
    }
    
    func getMainSectionItemCount() -> Int {
        
        return challengeData.count
        
    }
    
}
