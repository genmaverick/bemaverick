//
//  FeaturedRow.swift
//  Maverick
//
//  Created by Garrett Fritz on 5/21/18.
//  Copyright © 2018 BeMaverick. All rights reserved.
//

import Foundation
import RealmSwift

class FeaturedRowBase {
    
    
    var offset : CGPoint = CGPoint.zero
    var maxItem = 0
    var hasFooter = false
    var services : GlobalServicesContainer!
    var maxItemCount : Int = 10
    var notificationToken : NotificationToken?
    var forceRefresh = false
    
    weak var seeMoreDelegate : FeaturedSeeMoreCollectionViewCellDelegate?
    
    init(services : GlobalServicesContainer, seeMoreDelegate : FeaturedSeeMoreCollectionViewCellDelegate, forceRefresh : Bool) {
        
        self.forceRefresh = forceRefresh
        self.maxItemCount = Int(Variables.Content.featuredRowMaxItemCount.intValue())
        self.services = services
        self.seeMoreDelegate = seeMoreDelegate
    
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return 1
        
    }
    
    func getSeeMoreViewController(index : Int, section : Int = 0) -> ViewController? {
        
        return nil
    
    }
    
    func getTitleTappedViewController() -> ViewController? {
        
        return nil
        
    }
    
    
    func loadData() {
        
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        
        return UICollectionViewCell()
        
        
    }
    
}



