//
//  Features.swift
//  Maverick
//
//  Created by Garrett Fritz on 9/20/18.
//  Copyright © 2018 BeMaverick. All rights reserved.
//

import Foundation
import ObjectMapper
import RealmSwift

@objcMembers
class Features: Object, Mappable {
    
    
    dynamic var linkChallenges = false
    dynamic var createChallenges = true
    dynamic var cameraChallenges = false
    dynamic var customCover = false
    dynamic var stickerPack1 = false
    dynamic var stickerPack2 = false
    dynamic var theme1 = false
    dynamic var theme2 = false
    
    func setValues(features: Features) {
        
        linkChallenges = features.linkChallenges
        cameraChallenges = features.cameraChallenges
        customCover = features.customCover
        stickerPack1 = features.stickerPack1
        stickerPack2 = features.stickerPack2
        createChallenges = features.createChallenges
    }
    
    required convenience init?(map: Map) {
        
        self.init()
        
    }
    
   
    func mapping(map: Map) {
        
       
        
    }
    
}
