//
//  GlobalModelsCoordinator+AuthorizationManager.swift
//  Maverick
//
//  Created by Chris Garvey on 6/22/18.
//  Copyright © 2018 BeMaverick. All rights reserved.
//

import Foundation
import RealmSwift

extension GlobalModelsCoordinator {
    
    /**
     Deletes a user's credentials
     - parameter account: The credentials to be deleted.
     */
    func removeMaverickAccountFromRealm(forAccount account: RealmMaverickAccount) {
        
        DBManager.sharedInstance.deleteMaverickAccount(account: account)
        
    }
    
    /**
     Retrieves a user's credentials
     - parameter account: The credentials to be retrieved.
     */
    func retrieveMaverickAccount(forUser user: String) -> RealmMaverickAccount {
        
        return DBManager.sharedInstance.getMaverickAccount(forUser: user)
        
    }
    
    /**
     Sets a user's credentials
     - parameter username: the user's username.
     - parameter token: the user's access token to make API requests.
     - parameter refreshToken: the user's refresh token used to retrieve new access tokens to make API requests.
     */
    func setCredential(forUsername username: String, token: String, refreshToken: String) {
        
        DBManager.sharedInstance.setTokensForAccount(withUsername: username, token: token, refreshToken: refreshToken)
        
    }
    
}
