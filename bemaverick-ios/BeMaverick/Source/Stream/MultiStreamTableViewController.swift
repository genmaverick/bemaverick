//
//  MultiStreamTableViewController.swift
//  Maverick
//
//  Created by Garrett Fritz on 3/1/18.
//  Copyright © 2018 BeMaverick. All rights reserved.
//

import Foundation
import RealmSwift
import Kingfisher

class MultiStreamTableViewController : StreamTableViewController {

    /// Data for response items in table
    var responseData = List<MultiContentObject>()
    
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
              
            case .update(_, let deletions, let insertions, let modifications):
            
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
    internal func getCell(cellForRowAt indexPath: IndexPath) -> ContentTableViewCell {
        
        guard let cell = tableView?.dequeueReusableCell(withIdentifier: R.reuseIdentifier.contentTableViewCellID, for: indexPath)
            
         else {
                
                return  ContentTableViewCell()
                
            }
        
        
         cell.delegate = self
        guard let object = responseData[safe: indexPath.row] else { return cell }
        
        switch object.type {
        case .challenge:
            
            let challenge = services.globalModelsCoordinator.challenge(forChallengeId: object.id)
            let hasResponded = services.globalModelsCoordinator.isChallengeResponded(challengeId : challenge.challengeId)
            let isSaved = services.globalModelsCoordinator.isSaved(contentType: .challenge, withId: challenge.challengeId)
            cell.configure(with: challenge, isSaved: isSaved, hasResponded: hasResponded)
            
            
            
            
        case .response:
            
            let response = services.globalModelsCoordinator.response(forResponseId: object.id)
            
                ResponseStreamTableViewController.configure(cell: cell, withResponse: response, services: services)
            
            
            
        default:
            break
        }
        
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

extension MultiStreamTableViewController: UITableViewDataSourcePrefetching {
    
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        
        let responses = indexPaths.compactMap { responseData[safe: $0.row] }
        let urlsToFetch : [URL] = responses.compactMap {
          
            guard let val = $0 as? Response else { return URL(fileURLWithPath: "asdf") }
            return pathForImage(forResponse: val)
            
        }
        ImagePrefetcher(urls: urlsToFetch).start()
        
    }
    
}

