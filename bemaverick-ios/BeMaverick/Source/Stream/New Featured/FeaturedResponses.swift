//
//  FeaturedRow.swift
//  Maverick
//
//  Created by Garrett Fritz on 5/21/18.
//  Copyright © 2018 BeMaverick. All rights reserved.
//

import Foundation
import RealmSwift

class FeaturedResponses : FeaturedRow<Response> {
    
    private var featuredTableViewCell : FeaturedRowTableViewCell?
    var stream : ConfigurableResponseStream?
    
    required init(services: GlobalServicesContainer, seeMoreDelegate: FeaturedSeeMoreCollectionViewCellDelegate, stream : ConfigurableResponseStream, forceRefresh : Bool) {
        
        super.init(services: services, seeMoreDelegate: seeMoreDelegate, forceRefresh: forceRefresh)
        
        
        if let count = Int(stream.maxCount ?? "0"), count > 0 {
              self.maxItemCount = count
        }
      
        self.stream = stream 
        
        data = self.stream?.items
        hasFooter = stream.paginated
        loadData()
        
    }
    
    override class func pathForImage(forItem response: Response) -> URL? {
        
        return LargeContentCollectionViewCell.getMainImageUrl(primaryImage: response.imageMedia, fallbackImage : response.videoCoverImageMedia)
        
    }
    
    override func configure( featuredTableViewCell : FeaturedRowTableViewCell?) {
        
        self.featuredTableViewCell = featuredTableViewCell
        self.featuredTableViewCell?.setTitle(title: stream?.label ?? "Responses", contentType: .response, highlighted: stream?.challenge ?? nil != nil)
        notificationToken?.invalidate()
        if let stream = stream, stream.items.count == 0 {
            
            data = DBManager.sharedInstance.getResponseStream(byId: stream.streamId).items
            
        }
        
        guard !DBManager.sharedInstance.loggedInUserDataBase.isInWriteTransaction else {
            
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.75, execute: {
                
                guard !DBManager.sharedInstance.loggedInUserDataBase.isInWriteTransaction else { return }
                self.notificationToken = self.data?.observe { [weak self] changes in
                    
                    DispatchQueue.main.async {
                        
                        self?.featuredTableViewCell?.collectionView.reloadData()
                        
                    }
                    
                }
            })
            
            return
            
        }
        notificationToken = data?.observe { [weak self] changes in
            
            DispatchQueue.main.async {
                
                self?.featuredTableViewCell?.collectionView.reloadData()
                
            }
            
        }
        
    }
    
    override func loadData() {
        
        if let stream = stream {
            
            services.globalModelsCoordinator.getConfigurableSteam(stream: stream, forceRefresh : forceRefresh)
            
        }
        
    }
    
    override func getTitleTappedViewController() -> ViewController? {
        
        if let stream = stream, let vc = R.storyboard.feed.genericResponseStreamViewControllerId() {
            
            vc.services = services
            vc.configure(streamId: stream.streamId, paginationEnabled: hasFooter)
            
            return vc
            
        }
        
        return nil
        
    }
    
    override func getSeeMoreViewController(index : Int, section : Int = 0) -> ViewController? {
        
        if let challenge = stream?.challenge, section == 0 {
         
            if let vc = R.storyboard.challenges.challengeDetailsPageViewControllerId() {
                
                vc.services = services
                
                    vc.configure(with: challenge, startMinimized: false)
                
                return vc
                
            }
       
        }
        
        if let stream = stream {
            
            if let challenge = stream.challenge, index >= maxItemCount {
                
                if let vc = R.storyboard.challenges.challengeDetailsPageViewControllerId() {
                    
                    vc.services = services
                    vc.configure(with: challenge, startMinimized: true)
                    
                    return vc
                    
                }
                
            }
            
            if let vc = R.storyboard.feed.genericResponseStreamViewControllerId() {
                
                vc.services = services
                vc.configure(streamId: stream.streamId, paginationEnabled: hasFooter, initialScrollPosition: index)
                
                return vc
                
            }
            
            
        }
        return nil
        
    }
    
    override func collectionView(_ collectionView: UICollectionView,
                                 cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        
       
        
        if let challenge = stream?.challenge {
            
            if let footer = getFooterCell(collectionView: collectionView, indexPath: indexPath) {
                
                return footer
                
            }
            
            if indexPath.section == 0 {
                
                if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: R.reuseIdentifier.largeContentCollectionViewCellId,
                                                                 for: indexPath) {
                    
                    cell.configure(withChallenge: challenge)
                    return cell
                    
                }
                
            } else if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: R.reuseIdentifier.smallContentCollectionViewCellId,
                                                                    for: indexPath), let responses = data, let response = responses[safe: indexPath.row ] {
                cell.configure(with: response)
                
                return cell
                
            }
            
        }
        
        return super.collectionView(collectionView, cellForItemAt: indexPath)
        
    }

    
}



