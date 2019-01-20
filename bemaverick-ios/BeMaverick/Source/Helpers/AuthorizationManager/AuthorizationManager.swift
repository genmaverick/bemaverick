//
//  AuthorizationManager.swift
//  BeMaverick
//
//  Created by David McGraw on 9/14/17.
//  Copyright © 2017 BeMaverick. All rights reserved.
//

import Foundation
import Locksmith
import Signals
import TwitterKit
import FBSDKLoginKit
import RealmSwift

// DEPRECATED: This MaverickAccount is used only to migrate existing tokens from the keychain to Realm. Once migrated, this struct can be removed.
struct MaverickAccount: CreateableSecureStorable,
    DeleteableSecureStorable,
    ReadableSecureStorable,
GenericPasswordSecureStorable {
    
    let username: String
    
    let token: String
    let refreshToken: String
    
    // GenericPasswordSecureStorable
    let service = "Maverick"
    var account: String { return username }
    
    // CreateableSecureStorable
    var data: [String : Any] {
        return ["token": token, "refreshToken": refreshToken]
    }
    
}

/**
 The authorization object used to manage credentials within the local keychain
 */
class AuthorizationManager {
    
    // MARK: - Signals
    
    /// Fired when a user is authorized and the data was saved in the keychain
    let onUserAuthorizedSignal = Signal<Bool>()
    
    /// Fired when a is marked as inactive or revoked
    let onUserInactiveSignal = Signal<Constants.RevokedMode?>()
    
    /// Fired when a user is authorized and the data was saved in the keychain
    let onUserReinstatedSignal = Signal<Bool>()
    
    
    // MARK: - Private Properties
    
    /// The last specific point in time that a token has been refreshed
    private var lastRefreshTokenDate = Date.distantPast
    
    /// The maverick account in Realm that contains the user's tokens
    private var maverickAccount: RealmMaverickAccount {
        
        get {
            
            return apiService!.globalModelsCoordinator.retrieveMaverickAccount(forUser: defaultAccount)
            
        }
        
    }
    
    /// The default user account name
    private let defaultAccount: String = "maverick-user"
    
    
    // MARK: - Public Properties
    
    /// The token used to make API requests
    open var currentAccessToken: (accessToken: String?, refreshToken: String?)? {
        
        get {
            return getAccessToken()
        }
        
        set {
            setAccessToken(withToken: newValue?.accessToken, refreshToken: newValue?.refreshToken)
        }
        
    }
    
    /// A temporary client access token used during onboarding
    open var clientAccessToken: String?
    
    /// The access key to S3
    open var accessKeyS3: String = "AKIAILVXMLMU2X62NCSQ"
    
    /// The secret key to S3
    open var secretKeyS3: String = "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"
    
    /// A reference to the global `APIService` to perform platform calls
    open var apiService: APIService?
    
    /// The active environment under authorization
    open var environment: Constants.APIEnvironmentType {
        get {
            return DBManager.sharedInstance.getConfiguration().apiEnvironment
        }
        
        set {
            
            DBManager.sharedInstance.setAPIEnvironment(newValue)
            
            if IntegrationConfig.segmentOnlyOnDev && newValue == Constants.APIEnvironmentType.production, AnalyticsManager.isInitialized  {
                
                SEGAnalytics.shared().disable()
                AnalyticsManager.isInitialized = false
           
            } else if !AnalyticsManager.isInitialized {
                
                AnalyticsManager.initialize()
          
            }
            
        }
   
    }
    
    open var customBackendURL : String? {
        get {
            return DBManager.sharedInstance.getConfiguration().apiCustomURL
        }
        
        set {
            
            DBManager.sharedInstance.setAPIEnvironment(.custom, customURL: newValue)
            
        }
    }
    
    
    // MARK: - Lifecycle
    
    init() {
        
        log.verbose("⚙ Initializing Authorization Manager")
        
        /// Delete existing credentials if the app was deleted + re-installed
        if !UserDefaults.standard.appDidCompleteFirstRun {
        
            CameraManager.removeAllSavedSessions()
            UserDefaults.standard.appDidCompleteFirstRun = true
            
        }
        
    }
    
    // MARK: - Public Methods
    
    /**
     Remove local credentials for the user
     */
    open func logout() {
        
        deleteExistingCredential()
        CameraManager.removeAllSavedSessions()
        
        // Clear TWTR
        if let userId = TWTRTwitter.sharedInstance().sessionStore.session()?.userID {
            TWTRTwitter.sharedInstance().sessionStore.logOutUserID(userId)
        }
        
        // Clear FB
        let fbLoginManager: FBSDKLoginManager = FBSDKLoginManager()
        fbLoginManager.logOut()
        
        onUserAuthorizedSignal.fire(false)
        (UIApplication.shared.delegate as! AppDelegate).forceLogout()
        
    }
    
    
    /**
     Refresh the authorization token with platform if last refresh > 5 minutes ago
     */
    open func refreshAuthorizationCredentials(completionHandler: ((_ success : Bool) -> Void)? = nil) {

        
        if  lastRefreshTokenDate.timeIntervalSinceNow < -300 {
            
            lastRefreshTokenDate = Date()
            
            guard let refreshToken = currentAccessToken?.refreshToken, refreshToken != "" else {
                
                completionHandler?(false)
                logout()
                return
                
            }
            
            apiService?.refreshUserAuthorizationToken(withRefreshToken: refreshToken, completionHandler: { response, error in
                
                
                // if for some reason validation is failing, the code is no good and we might as well log out
                if let error = error, error.statusCode == 400 {
                    
                    self.logout()
                    completionHandler?(false)
                    
                    return
                    
                }
                
                // getting past this step is a matter of internet connection, so don't log out
                guard let token = response?.accessToken, let refreshToken = response?.refreshToken else {
                    
                    completionHandler?(false)
                    return
                    
                }
            
                self.currentAccessToken = (token, refreshToken)
                self.onUserAuthorizedSignal.fire(true)
                completionHandler?(true)
                
            })
        
        }
    
    }
    
    // MARK: - Private Methods
    
    /**
     Retrieves the access token stored in the secure store (if any). First, tries to retrieve it from Realm. If one from Realm is not found, checks the keychain for legacy tokens and then save those legacy tokens to Realm so we don't need to reach into the keychain again.
     */
    private func getAccessToken() -> (accessToken: String?, refreshToken: String?)? {
        
        // check initially if there are any tokens in Realm db
        if let credential = maverickAccount.getTokens() {
            return credential
        } else if let credential = readAccountCredentials() {
            // save to realm so we don't need to hit the keychain ever again... while we're at it, delete the legacy keychain credential because we won't need it again
            currentAccessToken = credential
            onUserAuthorizedSignal.fire(true)
            deleteExistingCredential(forKeychain: true)
            return credential
        } else {
            return nil
        }
        
    }
    
    /**
     Sets the existing account credential with the provided token. If nil, the
     existing token will be cleared.
     */
    private func setAccessToken(withToken token: String?, refreshToken: String?) {
        
        guard let token = token, let refreshToken = refreshToken else {
            deleteExistingCredential()
            return
        }
        
        log.debug("Setting token \(token) with refresh token \(refreshToken)")
        
        apiService?.globalModelsCoordinator.setCredential(forUsername: defaultAccount, token: token, refreshToken: refreshToken)
//        onUserAuthorizedSignal.fire(true)
        
    }
    
    /**
     DEPRECATED: Attempts to read the secure store and fetch the token associated with the local account. After the tokens are migrated to Realm in getAccessTokens(), this should be removed. It is used now only to initially retrive tokens to move them to Realm.
     */
    private func readAccountCredentials() -> (accessToken: String?, refreshToken: String?)? {
        
        guard let credential = MaverickAccount(username: defaultAccount, token: "", refreshToken: "").readFromSecureStore(),
            let data = credential.data,
            let token = data["token"] as? String else {
                log.error("❌ Unable to locate an account within the secure store")
                return nil
        }
        return (token, data["refreshToken"] as? String)
        
    }
    
    /**
     Removes the credential from the secure store or Realm for the generic user 'maverick-user'
     */
    private func deleteExistingCredential(forKeychain: Bool = false) {
        // DEPRECATED IF Statement: Only used for migration purposes. Otherwise, can be removed once the keychain is no longer being used.
        if forKeychain {
            
            do {
                
                try MaverickAccount(username: defaultAccount, token: "", refreshToken: "").deleteFromSecureStore()
                log.debug("✅ Removed credential from secure store")
                
            } catch {
                log.error("❌ Unable to delete credential: \(error.localizedDescription)")
            }
            
        } else {
            
            apiService?.globalModelsCoordinator.removeMaverickAccountFromRealm(forAccount: maverickAccount)
           
            log.debug("✅ Removed account and associated credentials from Realm")
            
        }
        
    }
    
}
