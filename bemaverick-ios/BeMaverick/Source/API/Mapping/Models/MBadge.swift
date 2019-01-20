//
//  MBadge.swift
//  Maverick
//
//  Created by Garrett Fritz on 6/14/18.
//  Copyright © 2018 BeMaverick. All rights reserved.
//

import Foundation
import ObjectMapper
import RealmSwift

@objcMembers
class MBadge: Object, Mappable {
    
    static func getBadge(byIndex filter : Int) -> MBadge {
        
        var badge = MBadge(badgeId: "-1")
        switch filter {
        case 0:
            badge = MBadge.getFirstBadge()
        case 1:
            badge = MBadge.getSecondBadge()
        case 2:
            badge = MBadge.getThirdBadge()
        case 3:
            badge = MBadge.getFourthBadge()
        default:
            break
        }
        return badge
        
    }
    
    static func getIndex(ofBadge badge: MBadge) -> Int? {
        
        for i in 0 ..<  DBManager.sharedInstance.getMaverickBadges().count {
            
            if DBManager.sharedInstance.getMaverickBadges()[i].badgeId == badge.badgeId {
                
                return i
                
            }
            
        }
        
        return nil
        
    }
    
    static func getIndex(ofBadgeId id: String) -> Int? {
        
        for i in 0 ..<  DBManager.sharedInstance.getMaverickBadges().count {
            
            if DBManager.sharedInstance.getMaverickBadges()[i].badgeId == id {
                
                return i
                
            }
            
        }
        
        return nil
        
    }
    
    static func getOrderedBadges() -> [MBadge] {
        
        return DBManager.sharedInstance.getMaverickBadges()
        
    }
    
    static func getFirstBadge() -> MBadge {
        
        return DBManager.sharedInstance.getMaverickBadges()[safe :0] ?? MBadge(badgeId: "-1")
        
    }
    
    static func getSecondBadge() -> MBadge {
        
        return DBManager.sharedInstance.getMaverickBadges()[safe :1] ?? MBadge(badgeId: "-1")
        
    }
    
    static func getThirdBadge() -> MBadge {
        
        return DBManager.sharedInstance.getMaverickBadges()[safe :2] ?? MBadge(badgeId: "-1")
        
    }
    
    static func getFourthBadge() -> MBadge {
        
        return DBManager.sharedInstance.getMaverickBadges()[safe :3] ?? MBadge(badgeId: "-1")
        
    }
    
    dynamic var badgeId :               String = ""
    dynamic var name :                  String?
    dynamic var badgeDescription :                  String?
    dynamic var status :                String?
    dynamic var color :                 String?
    
    dynamic var primaryImageUrl :       String?
    dynamic var secondaryImageUrl :     String?
    dynamic var offsetX :               Int = 0
    dynamic var offsetY :               Int = 0
    
    override static func primaryKey() -> String? {
        
        return "badgeId"
        
    }
    
    func update(badge : MBadge) {
        
        name  = badge.name
        status = badge.status
        color  = badge.color
        
        primaryImageUrl   = badge.primaryImageUrl
        secondaryImageUrl  = badge.secondaryImageUrl
        offsetX  =            badge.offsetX
        offsetY = badge.offsetY
        badgeDescription = badge.badgeDescription
        
    }
    
    required convenience init?(map: Map) {
        
        self.init()
        
    }
    
    convenience init(badgeId: String) {
        
        self.init()
        self.badgeId = badgeId
        
    }
    
    func mapping(map: Map) {
        
        badgeId             <- map["badgeId"]
        name                <- map["name"]
        status              <- map["status"]
        color               <- map["color"]
        
        primaryImageUrl     <- map["primaryImageUrl"]
        secondaryImageUrl   <- map["secondaryImageUrl"]
        offsetX             <- map["offsetX"]
        offsetY             <- map["offsetY"]
        badgeDescription    <- map["description"]
        
    }

    override var hashValue: Int {
        
        return "\(badgeId)".hashValue
        
    }
    
    static func ==(lhs: MBadge, rhs: MBadge) -> Bool {
        
        return lhs.badgeId == rhs.badgeId
        
    }
    
}
