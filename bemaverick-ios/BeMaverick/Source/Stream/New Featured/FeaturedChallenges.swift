//
//  FeaturedChallenges.swift
//  Maverick
//
//  Created by Garrett Fritz on 5/21/18.
//  Copyright © 2018 BeMaverick. All rights reserved.
//

import Foundation
import RealmSwift

class FeaturedChallenges : FeaturedRow<Challenge> {
    
    private var featuredTableViewCell : FeaturedRowTableViewCell?
    var stream : ConfigurableChallengeStream?
    
    required init(services: GlobalServicesContainer, seeMoreDelegate: FeaturedSeeMoreCollectionViewCellDelegate, stream : ConfigurableChallengeStream, forceRefresh : Bool) {
        
        super.init(services: services, seeMoreDelegate: seeMoreDelegate, forceRefresh: forceRefresh)
        self.stream = stream
        
        data =  self.stream?.items
        hasFooter = stream.paginated
        loadData()
        
    }
    
    override class func pathForImage(forItem challenge: Challenge) -> URL? {
        
        return LargeContentCollectionViewCell.getMainImageUrl(primaryImage: challenge.imageChallengeMedia, fallbackImage : challenge.mainImageMedia)
        
    }
    
    override func configure( featuredTableViewCell : FeaturedRowTableViewCell?) {
        
        self.featuredTableViewCell = featuredTableViewCell
        self.featuredTableViewCell?.setTitle(title: stream?.label ?? "Challenges", contentType: .challenge, highlighted: false)
        notificationToken?.invalidate()
        if let stream = stream, stream.items.count == 0 {
            
            print("✅ reinstate stream: \(stream.label ?? "no label")")
            data = DBManager.sharedInstance.getChallengeStream(byId: stream.streamId).items
        
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
            
            services.globalModelsCoordinator.getConfigurableSteam(stream: stream, forceRefresh : forceRefresh) { [weak self] in
                
                if stream.items.count == 0 {
                    
                    self?.data = DBManager.sharedInstance.getChallengeStream(byId: stream.streamId).items
                   
                    DispatchQueue.main.async {
                        
                        self?.featuredTableViewCell?.collectionView.reloadData()
                        
                    }
                    
                    
                }
                
            }
            
        }
        
    }
    
    override func getSeeMoreViewController(index: Int, section : Int = 0) -> ViewController? {
        
        if index >= maxItemCount, let stream = stream, let vc = R.storyboard.feed.genericChallengeStreamViewControllerId() {
            
            vc.services = services
            vc.configure(stream: stream, paginationEnabled: true, initialScrollPosition: index - 1)
            
            return vc
            
        }
        
        
        
        if let vc = R.storyboard.challenges.challengeDetailsViewControllerId() {
            
            vc.services = services
            
            if let data = data, let challenge = data[safe: index] {
                
                vc.configure(with: challenge, in: Array(data))
                
            }
            
            return vc
            
        }
        
        return nil
        
    }
    
}
