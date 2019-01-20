//
//  MaverickAccount.swift
//  Maverick
//
//  Created by Chris Garvey on 6/22/18.
//  Copyright © 2018 BeMaverick. All rights reserved.
//

import Foundation
import RealmSwift

@objcMembers
class RealmMaverickAccount: Object {
    
    dynamic var username: String? = nil
    dynamic var accessToken: String? = nil
    dynamic var refreshToken: String? = nil
    
    /// Return the tokens for the object if they exist
    func getTokens() -> (String?, String?)? {
        
        if let accessToken = accessToken, let refreshToken = refreshToken {
            return (accessToken, refreshToken)
        } else {
            return nil
        }
        
    }
    
    /// Setting the primary key
    override static func primaryKey() -> String? {
        return "username"
    }
    
}

