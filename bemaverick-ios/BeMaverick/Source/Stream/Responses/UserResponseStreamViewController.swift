//
//  ChallengeResponseFeedViewController.swift
//  Maverick
//
//  Created by Garrett Fritz on 3/1/18.
//  Copyright © 2018 BeMaverick. All rights reserved.
//

import Foundation
import RealmSwift

class UserResponseStreamViewController : ResponseStreamTableViewController {
    
    /// User id of the user who created these responses
    private var userId : String?
    /// User who created these responses
    private var user : User?
    
    override func viewDidLoad() {
        
        hasNavBar = true
        streamDelegate = self
        Video.appUserMuted = false
        super.viewDidLoad()
        
    }
    
    /**
     Set up viewcontroller with user id and position to start at
     */
    func configure(userId : String, initialScrollPosition : Int = 0) {
        
        self.initialScrollPosition = initialScrollPosition
        self.userId = userId
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        _ = super.tableView(tableView, cellForRowAt: indexPath)
        return getResponseCell(cellForRowAt: indexPath)
        
    }
    
}

extension UserResponseStreamViewController : StreamRefreshControllerDelegate {
    
    func configureData() {
        
        guard let userId = userId else { return }
        
        user = services.globalModelsCoordinator.getUser(withId: userId)
        if let list = user?.createdResponses {
        
            responseData = list
        
        }
        attachDataObserver()
        if initialScrollPosition == 0 {
            refresh(tableView?.refreshControl)
        }
        
        showNavBar(withTitle: R.string.maverickStrings.userResponseStreamTitle(user?.username ?? "User"))

        
    }
    
    func refreshDataRequest() {
        
        guard let userId = userId else { return }
        services.globalModelsCoordinator.getUserCreatedResponses(forUserID: userId){ [weak self] in
            
            self?.refreshCompleted()
            
        }
        
    }
    
    func loadNextPageRequest() {
        
        guard let userId = userId else { return }
        services.globalModelsCoordinator.getUserCreatedResponses(forUserID: userId, offset : getMainSectionItemCount() ){ [weak self] in
            
            self?.nextPageLoadCompleted()
            
        }
        
    }
    
    func getMainSectionItemCount() -> Int {
        
        return responseData.count
        
    }
    
    
}
