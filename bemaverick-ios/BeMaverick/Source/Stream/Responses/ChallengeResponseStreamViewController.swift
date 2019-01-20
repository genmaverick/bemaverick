//
//  ChallengeResponseFeedViewController.swift
//  Maverick
//
//  Created by Garrett Fritz on 3/1/18.
//  Copyright © 2018 BeMaverick. All rights reserved.
//

import Foundation

class ChallengeResponseStreamViewController : ResponseStreamTableViewController {
    
    /// Challenge Id of the owners of the resposnes
    var challengeId : String?
    /// Challenge owner of the resposnes
    private var challenge : Challenge!
    
    override func viewDidLoad() {
        
        hasNavBar = true
        streamDelegate = self
        additionalSafeAreaTop = 62
        Video.appUserMuted = false
        super.viewDidLoad()
        
    }
    
    /**
     Setup view with challenge Id and starting position
     */
    func configure(challengeId : String, initialScrollPosition : Int = 0) {
        
        self.initialScrollPosition = initialScrollPosition
        self.challengeId = challengeId
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        _ = super.tableView(tableView, cellForRowAt: indexPath)
        return getResponseCell(cellForRowAt: indexPath)
        
    }
    
}

extension ChallengeResponseStreamViewController : StreamRefreshControllerDelegate {
    
    func configureData() {
        
        guard let challengeId = challengeId else { return }
        challenge = services.globalModelsCoordinator.challenge(forChallengeId: challengeId)
        responseData = challenge.responses
        attachDataObserver()
        if initialScrollPosition == 0 {
            refresh(tableView?.refreshControl)
        }
        showNavBar(withTitle: R.string.maverickStrings.challengeResponseStreamTitle(challenge.title ?? "Challenge"))
        
        
    }
    
    func refreshDataRequest() {
        
        services.globalModelsCoordinator.getResponses(forChallengeId: challenge.challengeId) { [weak self]  result in
            
            self?.refreshCompleted()
            
        }
    }
    
    func loadNextPageRequest() {
        
        services.globalModelsCoordinator.getResponses(forChallengeId: challenge.challengeId, offset: responseData.count) { [weak self] result in
            
            self?.nextPageLoadCompleted()
            
        }
        
    }
    
    func getMainSectionItemCount() -> Int {
        
        return responseData.count
        
    }
    
}
