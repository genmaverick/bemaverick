//
//  Reward.swift
//  Maverick
//
//  Created by Garrett Fritz on 9/11/18.
//  Copyright © 2018 BeMaverick. All rights reserved.
//

import Foundation
import ObjectMapper
import RealmSwift

@objcMembers
class Reward: Object, Mappable {
    
    enum RewardTypes : String {
        
        case coverPhotoEditor = "PROFILE_COVER_PHOTO_EDITOR"
        case imageChallenge = "CREATE_CHALLENGES_WITH_CAMERA"
        case linkChallenge = "POST_LINK_CHALLENGES"
        case videoChallenge = "POST_VIDEO_CHALLENGE"
        case stickerPack_1 = "STICKER_PACK_1"
        case stickerPack_2 = "STICKER_PACK_2"
        
    }
    
    dynamic var _id = ""
    dynamic var key : String?
    dynamic var name : String?
    dynamic var rewardDescription : String?
    dynamic var level : Level?
    
    var completed : Bool = false
    
    override static func ignoredProperties() -> [String] {
        return [
        "completed"
        ]
    }
    override static func primaryKey() -> String? {
        
        return "_id"
        
    }
    
    required convenience init?(map: Map) {
        
        self.init()
        
    }
    
    func update(reward: Reward) {
        
        key = reward.key
        name = reward.name
        rewardDescription = reward.rewardDescription
        level = reward.level
    }
    
    convenience init(id : String) {
        
        self.init()
        self._id = id
        
    }
    
    func mapping(map: Map) {
        
        _id                 <- map["_id"]
        key                 <- map["key"]
        name                <- map["name"]
        rewardDescription   <- map["description"]
        level               <- map["level"]
        
    }
    
}
