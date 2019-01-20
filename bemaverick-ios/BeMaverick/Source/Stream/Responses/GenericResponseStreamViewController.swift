//
//  GenericResponseStreamViewController.swift
//  Maverick
//
//  Created by Garrett Fritz on 6/5/18.
//  Copyright © 2018 BeMaverick. All rights reserved.
//

import Foundation

class GenericResponseStreamViewController : ResponseStreamTableViewController {
    
    var paginationEnabled = false
    var stream : ConfigurableResponseStream?
    private var streamId : String?
    override func viewDidLoad() {
        
        if let streamId = streamId {
            
            stream = services.globalModelsCoordinator.getResponseStream(by: streamId)
        
        }
        showNavBar(withTitle: stream?.label ?? "Responses")
        hasNavBar = true
        streamDelegate = self
        Video.appUserMuted = false
        super.viewDidLoad()
        
    }
    
    /**
     Set up viewcontroller with user id and position to start at
     */
    func configure(streamId : String, paginationEnabled : Bool, initialScrollPosition : Int = 0) {
        
        self.paginationEnabled = paginationEnabled
        self.initialScrollPosition = initialScrollPosition
        self.streamId = streamId
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        _ = super.tableView(tableView, cellForRowAt: indexPath)
        return getResponseCell(cellForRowAt: indexPath)
        
    }
    
}


extension GenericResponseStreamViewController : StreamRefreshControllerDelegate {
    
    func configureData() {
        
        
        guard let stream = stream else { return }
        responseData = stream.items
        attachDataObserver()
        
        if responseData.count == 0 {
        
            refresh(tableView?.refreshControl)
        
        }
        showNavBar(withTitle: stream.label ?? "Responses")
        
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
        
        services.globalModelsCoordinator.getConfigurableSteam(stream: stream, forceRefresh: true, offset: responseData.count) { [weak self] in
            
            self?.nextPageLoadCompleted()
            
        }
        
    }
    
    func getMainSectionItemCount() -> Int {
        
        return responseData.count
        
    }
    
}
