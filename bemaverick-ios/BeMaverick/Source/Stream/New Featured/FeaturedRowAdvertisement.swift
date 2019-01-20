//
//  FeaturedRow.swift
//  Maverick
//
//  Created by Garrett Fritz on 5/21/18.
//  Copyright © 2018 BeMaverick. All rights reserved.
//

import Foundation
import RealmSwift

class FeaturedRowAdvertisement : FeaturedRowBase {

    var stream : ConfigurableAdvertisementStream?
    
    var deeplink : String?
    var image : MaverickMedia?
    
    required init(services: GlobalServicesContainer, seeMoreDelegate: FeaturedSeeMoreCollectionViewCellDelegate, stream : ConfigurableAdvertisementStream?) {
        
        super.init(services: services, seeMoreDelegate: seeMoreDelegate, forceRefresh: false)
        guard let stream  = stream else { return }
        
        self.stream = stream
        self.image = stream.imageMedia
        self.deeplink = stream.deepLink
    
    }

}



