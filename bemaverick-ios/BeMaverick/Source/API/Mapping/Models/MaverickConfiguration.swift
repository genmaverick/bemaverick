//
//  MaverickModel.swift
//  BeMaverick
//
//  Created by Garrett Fritz on 2/8/18.
//  Copyright © 2018 BeMaverick. All rights reserved.
//

import Foundation
import RealmSwift

@objcMembers
class MaverickConfiguration: Object {
    
    dynamic var ID =                            "main"
    dynamic var loggedInUserId =                "anon"
    
    dynamic var suggestedUpgradeVersionNumber:  String = ""
    dynamic var invitedEmails =                 List<String>()
    dynamic var invitedPhones =                 List<String>()
    dynamic var invitedFacebookIds =            List<String>()
    dynamic var hasSeenTextPostCoachMark =      false
    dynamic var badgeOrder      =               List<String>()
    dynamic var ugcThemes       =               List<String>()
    
    dynamic var tutorial_seen_challenges =      false
    dynamic var tutorial_seen_myfeed =          false
    dynamic var tutorial_seen_featured =        false
    dynamic var tutorial_seen_ugc_swipe =        0
    
    @objc dynamic private var apiEnvironmentRawValue = Constants.APIEnvironmentType.development.rawValue
    
    dynamic var apiEnvironment: Constants.APIEnvironmentType {
        get {
            return Constants.APIEnvironmentType(rawValue: apiEnvironmentRawValue)!
        }
        set {
            apiEnvironmentRawValue = newValue.rawValue
        }
    }
    
    func getImageSalt() -> String {
        
        switch apiEnvironment {
        case .production:
            return  "L8qtWL.tCtbPA3pTM9Jsu9XG"
        case .staging:
            return  "64NnupTkk%7XmtTUq6xQbzWw"
        default:
            return "64NnupTkk%7XmtTUq6xQbzWw"
        }
        
    }
    
    dynamic var apiCustomURL : String?
    
    override static func primaryKey() -> String? {
        
        return "ID"
        
    }
    
}


@objcMembers
class CachedVideo: Object {
    
    dynamic var lastUsed : Date?
    dynamic var path : String = ""
    override static func primaryKey() -> String? {
        
        return "path"
        
    }
    
    convenience init(path : String) {
        
        self.init()
        self.lastUsed = Date()
        self.path = path
        
    }
    
    
}

