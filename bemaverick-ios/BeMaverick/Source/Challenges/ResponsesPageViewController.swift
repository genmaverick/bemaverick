//
//  ResponsesPageViewController.swift
//  Maverick
//
//  Created by Garrett Fritz on 8/13/18.
//  Copyright © 2018 BeMaverick. All rights reserved.
//

import Foundation

import RealmSwift

class ResponsesPageViewController : ContentPageCollectionViewController {
    
    var responses = List<Response>()
    var updateNotification : NotificationToken?
    
    deinit {
        
        updateNotification?.invalidate()
        
    }
   
    func getItemCount() -> Int {
        
        if !firstLoad {
            return 1
        }
        
        let count = responses.count
        if count > 0 {
            
            isEmpty = false
            if loadingNewPage {
                
                return count + 1
                
            }
            
            return count
            
        } else {
            
            hasReachedEnd = true
            isEmpty = true
            return 1
            
        }
        
    }
    
    override func cellTapped(cell: SmallContentCollectionViewCell) {
        
        super.cellTapped(cell: cell)
        
        guard let contentId = cell.contentId else { return }
        showSingleItem(forContentType: .response, contentId: contentId)
        
    }

    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if let cell = getEmptyCell(indexPath: indexPath) {
            
            return cell
            
        }
        
        let itemCount = collectionView.numberOfItems(inSection: collectionView.numberOfSections - 1)
        if  !hasReachedEnd && indexPath.row >= itemCount - 6 {
            
            loadNextPage()
            
        }
        
        if let response = responses[safe: indexPath.row] {
            
            if let cell = getResponseCell(response: response, indexPath: indexPath) {
                
                return cell
                
            }
            
        }
        
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: R.reuseIdentifier.pagingCollectionViewCellId,
                                                         for: indexPath) {
            
            cell.activityIndicator.startAnimating()
            return cell
            
        }
        
        return UICollectionViewCell()
        
    }
    
}
