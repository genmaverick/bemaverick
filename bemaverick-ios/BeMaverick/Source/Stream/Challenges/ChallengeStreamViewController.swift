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

/**
 `MyFeed` displays a feed of responses from followers/following
 */
class ChallengeStreamViewController: StreamTableViewController {
    
    /// Data for challenge items in table
    var challengeData = List<Challenge>() 
    override func viewWillDisappear(_ animated: Bool) {
       
        super.viewWillDisappear(animated)
        services.globalModelsCoordinator.onFABVisibilityChanged.fire(true)
    
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        services.globalModelsCoordinator.onFABVisibilityChanged.fire(false)
        
    }
    /// observer for data updates
    internal var challengesUpdatedToken : NotificationToken?
    
    // MARK: - Lifecycle
    
    deinit {
        
    
        challengesUpdatedToken?.invalidate()
        
    }
    
    /**
     Return the url in string format to use for the prefetching of an image.
     - parameter challenge: The challenge whose image will be prefetched.
     */
    private func pathForImage(forChallenge challenge: Challenge) -> URL? {
        
        return ContentTableViewCell.getMainImageUrl(primaryImage: challenge.imageChallengeMedia, fallbackImage : challenge.mainImageMedia)
        
    }
    
    override func viewDidLoad() {
        hasNavBar = true
        services = (UIApplication.shared.delegate as! AppDelegate).services
        
        super.viewDidLoad()
        tableView?.prefetchDataSource = self
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        _ = super.tableView(tableView, cellForRowAt: indexPath)
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.contentTableViewCellID, for: indexPath),
            let challenge = challengeData[safe: indexPath.row] else { return  UITableViewCell() }
        
        cell.delegate = self
        let hasResponded = services.globalModelsCoordinator.isChallengeResponded(challengeId : challenge.challengeId)
        let isSaved = services.globalModelsCoordinator.isSaved(contentType: .challenge, withId: challenge.challengeId)
        cell.configure(with: challenge, isSaved: isSaved, hasResponded: hasResponded)
     
        return cell
        
    }
    
    func attachDataObserver() {
        
        challengesUpdatedToken = challengeData.observe { [weak self] changes in
            
            guard let tableView = self?.tableView else { return }
            tableView.refreshControl?.endRefreshing()
            switch changes {
                
            case .initial:
                
                UIView.performWithoutAnimation({
                    tableView.reloadData()
                })
                        self?.checkInitialScrollPosition()
                
            case .update(_, let deletions, let insertions, let modifications):
                
                // Query results have changed, so apply them to the UITableView
                tableView.beginUpdates()
                tableView.insertRows(at: insertions.map({ IndexPath(row: $0, section: 0) }), with: .none)
                tableView.deleteRows(at: deletions.map({ IndexPath(row: $0, section: 0)}),
                                     with: .none)
                tableView.reloadRows(at: modifications.map({ IndexPath(row: $0, section: 0) }),
                                     with: .none)
                tableView.endUpdates()
                
            case .error(let error):
                // handle error
                log.verbose(error.localizedDescription)
                
            }
            
            
        }
        
    }
  
    
}

extension ChallengeStreamViewController: UITableViewDataSourcePrefetching {
    
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {

        let challenges = indexPaths.compactMap { challengeData[safe: $0.row] }
        let urlsToFetch = challenges.compactMap { pathForImage(forChallenge: $0) }
        ImagePrefetcher(urls: urlsToFetch).start()
        
    }
    
}

