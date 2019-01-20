//
//  DBManager+AuthorizationManager.swift
//  Maverick
//
//  Created by Chris Garvey on 6/22/18.
//  Copyright © 2018 BeMaverick. All rights reserved.
//

import Foundation
import RealmSwift

extension DBManager {
    
    /**
     Deletes a Maverick Account object
     */
    func deleteMaverickAccount(account: RealmMaverickAccount) {
        
        try! database.write {
            database.delete(account)
        }
        
    }
    
    /**
     Retrieves a Maverick Account from Realm. If it does not exist, a new one is created and returned.
     */
    func getMaverickAccount(forUser user: String) -> RealmMaverickAccount {
        
        var maverickAccount = database.objects(RealmMaverickAccount.self).first
        
        if maverickAccount == nil {
            
            maverickAccount = RealmMaverickAccount()
            maverickAccount!.username = user
            
            if database.isInWriteTransaction {
                
                database.add(maverickAccount!)
                
            } else {
                
                try! database.write {
                
                    database.add(maverickAccount!)
                
                }
                
            }
            
        }
        
        return maverickAccount!
        
    }
    
    
    /**
     Sets the tokens for a realm maverick account.
     */
    func setTokensForAccount(withUsername username: String, token: String, refreshToken: String) {
        
        try! database.write {
            
            database.create(RealmMaverickAccount.self, value: ["username": username, "accessToken": token, "refreshToken": refreshToken], update: true)
            
        }
        
    }
    
}
