//
//  ResponseStreamTableViewController.swift
//  Maverick
//
//  Created by Garrett Fritz on 3/1/18.
//  Copyright © 2018 BeMaverick. All rights reserved.
//

import Foundation
import RealmSwift
import Kingfisher

class ResponseStreamTableViewController : StreamTableViewController {

    /// Data for response items in table
    var responseData = List<Response>() 
    /// Data for response items in table
    var responseDataResults : Results<Response>?
    /// observer for data updates
    var responsesUpdatedToken : NotificationToken?
    /// section of tableview that holds the response list, default 0
    var responseTableViewSection = 0
    /// Where to seed the list
    
    deinit {
        
      responsesUpdatedToken?.invalidate()
        
    }
    
    /**
     Attached the responseUpdatedToken to the responseData object to update
     table when realm collction is updated.
    */
    internal func attachDataObserver() {
        
        responsesUpdatedToken = responseData.observe { [weak self] changes in
            
            guard let weakself = self else { return }
            weakself.tableView?.refreshControl?.endRefreshing()
            
            switch changes {
                
            case .initial:
                
                weakself.tableView?.reloadSections([weakself.responseTableViewSection], with: .none)
                    weakself.checkInitialScrollPosition()
              
            case .update(_, _, _, _):
            
                // Query results have changed, so apply them to the UITableView
                weakself.tableView?.reloadData()
                
                
            case .error(let error):
                // handle error
                log.verbose(error.localizedDescription)
                ()
                
            }
            
        }
    }
    
    override func addBadge(responseId id: String, badgeId: String, remove: Bool, cell : Any?) {
        
        var notificationTokens : [NotificationToken] = []
        if let responsesUpdatedToken = responsesUpdatedToken {
            notificationTokens.append(responsesUpdatedToken)
        }
        
        
        if remove {
            
            services.globalModelsCoordinator.deleteBadgeFromResponse(withResponseId: id, badgeId: badgeId, realmNotificationToken: notificationTokens) { success in
                
            }
        } else {
            
            services.globalModelsCoordinator.addBadgeToResponse(withResponseId: id, badgeId: badgeId, realmNotificationToken: notificationTokens) { success in
                
            }
            
        }
        
    }
    
    /**
     Utility function to populate contenttableviewcell with response data
     */
    static func configure(cell : ContentTableViewCell, withResponse response: Response, services : GlobalServicesContainer) {
        
        
        if let loggedInId =  services.globalModelsCoordinator.loggedInUser?.userId {
            
            cell.setSelectedBadge(badge: services.globalModelsCoordinator.getSelectedBadge(userId: loggedInId, responseId: response.responseId))
            
        }
        
        cell.configure(with: response)
        
        
    }
    

    /**
     Populate a ContentTableViewCell based on the indexPath
    */
    internal func getResponseCell(cellForRowAt indexPath: IndexPath) -> ContentTableViewCell {
        
        guard let cell = tableView?.dequeueReusableCell(withIdentifier: R.reuseIdentifier.contentTableViewCellID, for: indexPath)
            
         else {
                
                return  ContentTableViewCell()
                
            }
        
        var response = responseDataResults?[safe: indexPath.row]
        
        if response == nil {
            
            response = responseData[safe: indexPath.row]
            
        }
        
        guard let unwrappedResponse = response else { return cell }
        cell.delegate = self
        ResponseStreamTableViewController.configure(cell: cell, withResponse: unwrappedResponse, services: services)
        
        return cell
        
    }
 
    /**
     Return the url in string format to use for the prefetching of an image.
     - parameter challenge: The challenge whose image will be prefetched.
     */
    private func pathForImage(forResponse response: Response) -> URL? {
        
        return ContentTableViewCell.getMainImageUrl(primaryImage: response.imageMedia, fallbackImage : response.videoCoverImageMedia)
        
    }
    
}

extension ResponseStreamTableViewController: UITableViewDataSourcePrefetching {
    
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        
        let responses = indexPaths.compactMap { responseData[safe: $0.row] }
        let urlsToFetch = responses.compactMap {  pathForImage(forResponse: $0) }
        ImagePrefetcher(urls: urlsToFetch).start()
        
    }
    
}

