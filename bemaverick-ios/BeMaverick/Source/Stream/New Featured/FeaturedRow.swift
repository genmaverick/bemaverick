//
//  FeaturedRow.swift
//  Maverick
//
//  Created by Garrett Fritz on 5/21/18.
//  Copyright © 2018 BeMaverick. All rights reserved.
//

import Foundation
import RealmSwift
import Kingfisher

class FeaturedRow <T:RealmCollectionValue> : FeaturedRowBase {
    
    var data : List<T>?  {
      
        didSet {
            
            if let data = data {
               
                let items = Array(data)
                let urlsToFetch = items.compactMap { FeaturedRow.pathForImage(forItem: $0) }
//                ImagePrefetcher(urls: urlsToFetch).start()
                
            }
        
        }
        
    }
    
   
    
    
    /**
     Return the url in string format to use for the prefetching of an image.
     - parameter challenge: The challenge whose image will be prefetched.
     */
    class func pathForImage(forItem item: T) -> URL? {
        
        return nil
        
    }
    
    deinit {
        
        notificationToken?.invalidate()
        log.verbose("💥")
        
    }
    
    func configure( featuredTableViewCell : FeaturedRowTableViewCell?) {
        
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        var count = data?.count ?? 0
        
        if count > maxItemCount {
            
            count = maxItemCount + (hasFooter ? 1 : 0)
            
        }
        
        return count
        
    }
    
    func getFooterCell(collectionView: UICollectionView, indexPath: IndexPath) -> UICollectionViewCell? {
        
        if hasFooter && indexPath.row  >= maxItemCount {
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: R.reuseIdentifier.featuredSeeMoreCollectionViewCellId, for: indexPath)!
            
            cell.tag = collectionView.tag
            cell.delegate = seeMoreDelegate
            return cell
            
        }
        return nil
    }
    
    override func collectionView(_ collectionView: UICollectionView,
                                 cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        
        guard let gmc = services.globalModelsCoordinator else { return UICollectionViewCell() }
        
        if let footer = getFooterCell(collectionView: collectionView, indexPath: indexPath) {
            return footer
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: R.reuseIdentifier.largeContentCollectionViewCellId,
                                                      for: indexPath)!
        
        if let responses = data as? List<Response>,  let response = responses[safe: indexPath.row ]
            
        {
            
            if let loggedInId = gmc.loggedInUser?.userId {
                
                    cell.setSelectedBadge(selected: services.globalModelsCoordinator.getSelectedBadge(userId: loggedInId, responseId: response.responseId))
                
            }
            
            cell.configure(withResponse: response)
            
        } else if let challenges = data as? List<Challenge>,  let challenge = challenges[safe: indexPath.row]
        {
            
            cell.configure(withChallenge: challenge)
            
        }
        
        return cell
        
    }
    
}
