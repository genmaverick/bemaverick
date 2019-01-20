//
//  ChallengesPageViewController.swift
//  Maverick
//
//  Created by Garrett Fritz on 7/17/18.
//  Copyright © 2018 BeMaverick. All rights reserved.
//

import Foundation
import RealmSwift

protocol ContentPageViewControllerDelegate : class {
    
    func toggleSearchVisibility(isVisible : Bool, force : Bool)
    
    func transitionItemSelected(selectedImage : UIImage?, selectedFrame : CGRect?)
    
}

class ChallengesPageViewController : ContentPageCollectionViewController {
    
    enum challengePageType : String {
        
        case trending = "trending"
        case saved = "saved"
        case completed = "completed"
        case first = "first"
        case recent = "recent"
        case hashtag = "hashtag"
        case invited = "invited"
        case link = "link"
        
    }
    
    
    var challenges = List<Challenge>()
    var updateNotification : NotificationToken?
    
    
    deinit {
        
        updateNotification?.invalidate()
        
    }
    
    override func cellTapped(cell: SmallContentCollectionViewCell) {
       
        super.cellTapped(cell: cell)
          
        guard let contentId = cell.contentId else { return }
        showChallengeDetails(forChallenge: contentId, challenges: Array(challenges))
        
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if scrollView.contentOffset.y <= 0 {
            
            delegate?.toggleSearchVisibility(isVisible: true, force: false)
            
        } else if scrollView.contentOffset.y > 44 && scrollView.contentSize.height > scrollView.frame.height + 60 {
            
            delegate?.toggleSearchVisibility(isVisible: false, force: false)
            
        }
        
    }
    
    func getItemCount() -> Int {
        
        if !firstLoad {
            return 1
        }
        
        let count = challenges.count
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
    
    
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if let cell = getEmptyCell(indexPath: indexPath) {
            
            return cell
            
        }
        
        let itemCount = collectionView.numberOfItems(inSection: collectionView.numberOfSections - 1)
        if  !hasReachedEnd && indexPath.row >= itemCount - 6 {
            
            loadNextPage()
            
        }
        
        
        if let challenge = challenges[safe: indexPath.row] {
            
            if let cell = getChallengeCell(challenge: challenge, indexPath: indexPath) {
                
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

