//
//  UserInspirationStreamViewController.swift
//  Maverick
//
//  Created by Garrett Fritz on 3/1/18.
//  Copyright © 2018 BeMaverick. All rights reserved.
//

import Foundation
import RealmSwift

class UserInspirationStreamViewController : ResponseStreamTableViewController {
    
    /// User id of the badger of these responses
    private var userId : String?
    /// User object of the badger of these responses
    private var user : User?
    
    override func viewDidLoad() {
        
        hasNavBar = true
        streamDelegate = self
        Video.appUserMuted = false
        super.viewDidLoad()
        
    }
    
    /**
     Setup view with user id and starting position
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

extension UserInspirationStreamViewController : StreamRefreshControllerDelegate {
    
    /**
     Called on view did load, meant to be overriden to load in data and set the
     data update observer
     */
    func configureData() {
        guard let userId = userId else { return }
        
        let user = services.globalModelsCoordinator.getUser(withId: userId)
        
        responseData = user.badgedResponses
        responseDataResults = user.getUnownedBadgedResponses()
        
        guard let responseDataResults = responseDataResults else { return }
        
        // this is an interesting case, we dont want to update this guy with every change to the inspirations list since it is a bit jarring(sp?) so, just load the initial data set
        //TODO: this breaks pagination
        if user.userId == services.globalModelsCoordinator.loggedInUser?.userId {
            responsesUpdatedToken = responseDataResults.observe { [weak self] changes in
                
                guard let weakself = self else { return }
                weakself.tableView?.refreshControl?.endRefreshing()
                
                switch changes {
                    
                case .initial:
                    
                    UIView.performWithoutAnimation({
                        weakself.tableView?.reloadSections([weakself.responseTableViewSection], with: .none)
                    })
                    
                default:
                    break
                    
                }
                
            }
        } else {
            attachDataObserver()
        }
        
         if initialScrollPosition == 0 {
        
            refresh(tableView?.refreshControl)
        
        }
        title = R.string.maverickStrings.userInspirationStreamTitle(user.username ?? "User")
        
    }
    
    /**
     Function to be overriden by subclass, this should fire off the API request
     The completion block of request should call refreshCompleted()
     */
    func refreshDataRequest() {
        guard let userId = userId else {
            
            self.refreshCompleted()
            return
            
        }
        
        services.globalModelsCoordinator.getUserBadgedResponses(forUserId: userId) { [weak self] in
            
            self?.refreshCompleted()
            
        }
    }
    
    /**
     Function to be overriden by subclass, this should fire off the API request
     The completion block of request should call nextPageLoadCompleted()
     */
    func loadNextPageRequest() {
        
        guard let userId = userId else {
            
            self.refreshCompleted()
            return
            
        }
        
        services.globalModelsCoordinator.getUserBadgedResponses(forUserId: userId, offset: streamDelegate?.getMainSectionItemCount() ?? 0) { [weak self] in
            
            self?.nextPageLoadCompleted()
            
        }
        
    }
    
    /**
     Get item count
     */
    func getMainSectionItemCount() -> Int {
        
        return responseDataResults?.count ?? responseData.count
        
    }
    
}

