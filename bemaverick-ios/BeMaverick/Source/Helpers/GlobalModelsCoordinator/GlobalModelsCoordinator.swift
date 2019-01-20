//
//  GlobalModelsCoordinator.swift
//  BeMaverick
//
//  Created by David McGraw on 9/14/17.
//  Copyright © 2017 BeMaverick. All rights reserved.
//

import Foundation
import ObjectMapper
import Signals
import RealmSwift

import Crashlytics

enum DataFeedType {
    case challenges
}

/**
 A GlobalModelsCoordinator is an object responsibile for managing global models
 for the session.
 */
class GlobalModelsCoordinator {
    
    // MARK: - Public Properties
    
    let feed_expiration_hours = 5
    /// Fired when featured responses have been fetched and updated
    let onResponsesFetchedSignal = Signal<Bool>()
    
    /// Fired when an there is progress on an upload
    let onResponsesUploadProgressSignal = Signal<CGFloat>()
    
    /// Fired when an there is progress on an upload
    let onChallengeUploadProgressSignal = Signal<CGFloat>()
    
    var isFetchingUserProgress = false
    
    /// Fired when a response upload completed
    let onResponsesUploadCompletedSignal = Signal<(error: String?, response: Response?, fileUrl: String?, channels: [SocialShareChannels])>()
    
    /// Fired when a response upload completed
    let onChallengeUploadCompletedSignal = Signal<(error: String?, challenge: Challenge?, fileUrl: String?, channels: [SocialShareChannels])>()
    
    
    /// Fired when challenges have been fetched and updated
    let onChallengesFetchedSignal = Signal<Bool>()
    
    /// Fired when challenge responses have been fetched
    let onChallengeResponsesFetchedSignal = Signal<Bool>()
    
    /// Fired when the user's favorite challenges are fetched
    let onUserFavoriteChallengesFetchedSignal = Signal<[Challenge]>()
    
    /// Fired when a deep link has been opened
    let onFABVisibilityChanged = Signal<Bool>()
    
    
    /// Fired when a deep link has been opened
    let onDeepLinkSignal = Signal<Constants.DeepLink>()
    
    /// Fired when a Project is accomplished for the first time
    let onProjectAchieved = Signal<Project>()
    
    /// Fired when a level is accomplished for the first time
    let onLevelAchieved = Signal<Level>()
    
    
    /// Fired when a deep link has been opened
    let onOverridenDeepLinkSignal = Signal<Constants.DeepLink?>()
    
    
    /// An instance to the `APIService` to interface with the platform
    open var apiService: APIService!
    
    /// An instance to the `AuthorizationManager` responsible for active credentials
    open var authorizationManager: AuthorizationManager!
    
    var fromSignup = false;
    open var loggedInUser: User? {
        
        get {
            
            return DBManager.sharedInstance.getLoggedInUser()
            
        }
        
    }
    
    
    
    open var siteConfig: MaverickConfiguration {
        
        get {
            
            return DBManager.sharedInstance.getConfiguration()
            
        }
        
    }
    
    
    init() {
        
        setUpMainUserDB()
        log.verbose("⚙ Initializing GlobalModelsCoordinator")
    }
    
    private func setUpMainUserDB() {
        
        DBManager.sharedInstance.initializeLoggedInUser()
        
    }
    // MARK: - Public Methods
    
    
    open func getPresetProfileCover(byId id: String) -> MaverickMedia? {
        
        return DBManager.sharedInstance.getMaverickMedia(byId: id, type: .cover)
        
    }
    
    open func getPresetCovers() -> Results<MaverickMedia> {
        
        return DBManager.sharedInstance.loggedInUserDataBase.objects(MaverickMedia.self).filter("mediaTypeRawValue = %@", "cover")
        
    }
    
    func prefetch(backgroundAppRefresh: Bool, completionHandler: ((_ success : Bool) -> Void)? = nil) {
        
        if let loggedInUser = loggedInUser {
            
            refreshMaverickStream(forceRefresh: backgroundAppRefresh, downloadAssets: backgroundAppRefresh)
            getChallenges(forceRefresh: backgroundAppRefresh, downloadAssets: backgroundAppRefresh, featuredType: .challengeStream)
            getMyFeed(forceRefresh: backgroundAppRefresh, downloadAssets : backgroundAppRefresh)
            getMaverickBadges()
//            getProgression(for: loggedInUser.userId)
            
            getUserFollowingData(forUserId: loggedInUser.userId)
              getSuggestedUsers()
            let _ = getMyRespondedChallenges(forceRefresh : true, completionHandler: nil)
            
            let _ = getMyInvitedChallenges(forceRefresh : true, completionHandler: nil)
            
            let _ = getNoResponseChallenges(forceRefresh : true, completionHandler: nil)
            
            let _ = getTrendingChallenges(versionNumber: 1, forceRefresh: true)
            let _ = getTrendingChallenges(versionNumber: 0, forceRefresh: true)
            let _ = getTrendingChallenges(versionNumber: 2, forceRefresh: true)
            
            getSavedChallenges(completionHandler: nil)
            getThemes()
            refreshSiteConfigData()
            //until we build synchronous prefetch, give some time before calling it quits
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + (backgroundAppRefresh ? 10 : 0.1), execute: {
                
                completionHandler?(true)
                
            })
            return
            
        }
        
        completionHandler?(false)
        
    }
    
    func logout() {
        
        DBManager.sharedInstance.logout()
        
    }
    /**
     Fetch the user data for the authorized user
     */
    func reloadLoggedInUser(basic : Bool = true, completionHandler: (() -> Void)? = nil) {
        
        guard let accessToken = authorizationManager.currentAccessToken?.accessToken, accessToken != "" else {
            completionHandler?()
            return
        }
        
        
        apiService.getLoggedInUserDetails(basic : basic) { response, error in
            
            guard let userId = response?.loginUser?.userId,
                let user = response?.users?[userId] else {
                    completionHandler?()
                    return
            }
            
            user.userId = userId
            if DBManager.sharedInstance.getLoggedInUser()?.isRevoked ?? false {
                
                self.authorizationManager.onUserReinstatedSignal.fire(true)
                
            }
            
            let imageArray = response?.images?.map { $0.value } ?? []
            if let loggedInData = response?.loginUser {
                
                user.parentEmailAddress = loggedInData.parentEmailAddress
                user.emailAddress = loggedInData.emailAddress
                user.isEmailVerified = loggedInData.isEmailVerified
                user.isAccountRevoked = loggedInData.isAccountRevoked
                user.vpcStatus = loggedInData.vpcStatus
                AnalyticsManager.identify(loggedInUser: user)
                DBManager.sharedInstance.loginUser(userId: userId)
                let _ = DBManager.sharedInstance.addUser(userObject: user, images: imageArray, loggedInData: true)
                
            }
            
            
            self.reloadLoggedInUserData()
            completionHandler?()
            
        }
        
        
    }
    
    func getTags(withQuery query : String, completionHandler: @escaping (([Hashtag]?) -> Void)) {
        
        guard query.count > 1 else {
            completionHandler(nil)
            return
        }
        apiService.getTags(withQuery: query, completionHandler: { response, error in
            
            guard  error == nil else {
                
                completionHandler(nil)
                return
                
            }
            
            completionHandler(response)
            
        })
        
    }
    
    func getTagContent(contentType: Constants.ContentType, tagName name : String, count : Int = 25, offset : Int = 0, completionHandler: @escaping ((List<Challenge>?, List<Response>?) -> Void)) {
        
        guard name.count > 1 else {
            
            completionHandler(nil, nil)
            return
            
        }
        
        apiService.getTagContent(contentType : contentType, tagName: name, count : count, offset : offset) { response, error in
            
            guard  error == nil, let response = response else {
                
                completionHandler(nil, nil)
                return
                
            }
            
            let (c_challenges,  c_users, c_videos, c_images) = response.getChallenges()
            
            let (r_responses, r_challenges,  r_users, r_videos, r_images) = response.getResponses()
            
            let challengeList = DBManager.sharedInstance.addChallenges(owners: c_users, videos: c_videos, images: c_images,  challenges: c_challenges)
            
            let responseList = DBManager.sharedInstance.addResponses(owners: r_users, videos: r_videos, images: r_images, challenges: r_challenges, responses: r_responses)
            
            completionHandler(challengeList, responseList)
            
        }
        
    }
    
    
    /**
     Fetch the user data for the authorized user
     */
    open func refreshSiteConfigData() {
        
        guard let accessToken = authorizationManager.currentAccessToken?.accessToken, accessToken != "" else { return }
        
        apiService.getSiteConfig { response, error in
            
            guard let urls = response?.config?.profileCoverPresetImageUrls else { return }
            
            DBManager.sharedInstance.setConfiguration(profileCoverUrls: urls)
            
        }
        
    }
    
    /**
     Fetch the badge data
     */
    func getMaverickBadges() {
        
        guard let accessToken = authorizationManager.currentAccessToken?.accessToken, accessToken != "" else { return }
        
        apiService.getMaverickBadges { response in
            
            guard let badges = response?.badges, let sortOrder = response?.sortOrder else { return }
            
            DBManager.sharedInstance.setMaverickBadges(sortOrder: sortOrder, badges: badges.map { $0.value })
            
        }
        
    }
    
    /**
     Fetch the theme data
     */
    func getThemes() {
        
        guard let accessToken = authorizationManager.currentAccessToken?.accessToken, accessToken != "" else { return }
        
        apiService.getThemes { response in
            
            guard let themes = response?.themes else { return }
            
            DBManager.sharedInstance.setUserChallengeThemes(sortOrder:      response?.sortOrder, themes: themes)
            
        }
        
    }
    
    
    /**
     Update user profile information for the authorized user
     
     - parameter bio:               The user bio
     - parameter completionHandler: The closure called upon completion with the response data
     */
    open func updateUserData(withBio bio: String, firstName: String, lastName: String, username: String, completionHandler: ((MaverickError?) -> Void)? = nil)
    {
        
        guard let accessToken = authorizationManager.currentAccessToken?.accessToken, accessToken != "", let _ = loggedInUser?.userId else {
            
            completionHandler?(nil)
            return
            
        }
        
        apiService.updateProfileDetails(withBio: bio, firstName: firstName, lastName: lastName, username: username) { response, error in
            
            if error != nil {
                completionHandler?(error)
                return
            }
            let updatedBio = response?.users?[self.loggedInUser?.userId ?? "na"]?.bio ?? bio
              let updatedLastname = response?.users?[self.loggedInUser?.userId ?? "na"]?.lastName ?? lastName
              let updatedFirstName = response?.users?[self.loggedInUser?.userId ?? "na"]?.firstName ?? firstName
            let updatedUsername = response?.users?[self.loggedInUser?.userId ?? "na"]?.username ?? username
            DBManager.sharedInstance.updateEditProfileData(firstName: updatedFirstName, lastName: updatedLastname, bio : updatedBio, username: updatedUsername)
            
            self.getProgression()
                
            
            completionHandler?(nil)
            
        }
        
    }
    
    /**
     Toggle user notification setting for the authorized user
     
     - parameter settingkey: key of setting
     - parameter enabled: bool state
     - parameter completionHandler: The closure called upon completion with the response data
     */
    open func updateUserData(notificationSetting setting: Constants.NotificationSettings, isEnabled: Bool, completionHandler: ((MaverickError?) -> Void)? = nil)
    {
        
        guard let accessToken = authorizationManager.currentAccessToken?.accessToken, accessToken != "", let _ = loggedInUser?.userId else {
            completionHandler?(nil)
            return
        }
        
        
        apiService.updateProfileDetails(notificationSetting : setting, isEnabled: isEnabled) { response, error in
            
            if error != nil {
                completionHandler?(error)
                return
                
            }
            
            
            
            completionHandler?(nil)
            
        }
        
        DBManager.sharedInstance.updateNotificationSetting(setting :setting, isEnabled: isEnabled)
        
        
    }
    
    /**
     Update the user profile avatar for the authorized user
     
     - parameter data:              The image avatar data to upload (use jpeg)
     - parameter completionHandler: The closure called upon completion with the response data
     */
    open func updateUserAvatar(withImageData data: Data?,
                               completionHandler: (() -> Void)? = nil)
    {
        
        guard let accessToken = authorizationManager.currentAccessToken?.accessToken, accessToken != "" else {
            completionHandler?()
            return
        }
        
        apiService.updateProfileAvatar(withLocalImageData: data) { response, error in
            self.reloadLoggedInUser(completionHandler: completionHandler)
        }
        
    }
    
    /**
     Update the user preset cover for the authorized user
     
     - parameter data:              The image avatar data to upload (use jpeg)
     - parameter completionHandler: The closure called upon completion with the response data
     */
    open func updateUserCover(withPreset id: Int, tintColor: UIColor? = nil,
                              completionHandler: ((MaverickError?) -> Void)? = nil)
    {
        
        guard let accessToken = authorizationManager.currentAccessToken?.accessToken, let userId = loggedInUser?.userId, accessToken != "" else {
            
            completionHandler?(MaverickError.authenticationFailed)
            return
            
        }
        
        let colorString = tintColor?.hexString ?? ""
        let stringId = String(id)
        
        apiService.updateProfilePresetCoverImage(withPreset: id, tintColor: colorString) { response, error in
            
            guard error == nil else {
                
                completionHandler?(error)
                return
                
            }
            
            DBManager.sharedInstance.setPresetCoverImage( coverId : stringId)
            
            completionHandler?(error)
            
        }
        
    }
    
    /**
     Update the user's profile cover image for the authorized user
     
     - parameter data:              The image avatar data to upload (use jpeg)
     - parameter completionHandler: The closure called upon completion with the response data
     */
    open func updateUserCoverImage(withImageData data: Data,
                                   completionHandler: (() -> Void)? = nil)
    {
        
        guard let accessToken = authorizationManager.currentAccessToken?.accessToken, accessToken != "" else {
            completionHandler?()
            return
        }
        
        apiService.updateProfileCoverImage(withLocalImageData: data) { response, error in
            
            self.reloadLoggedInUser(completionHandler: completionHandler)
            
            
        }
        
    }
    
    /**
     Deactivates / activates the authorized user's account, should result in a logout
     
     - parameter completionHandler: The closure called upon completion with the response data
     */
    func toggleActivation(deactivate: Bool, completionHandler: ((_ error: MaverickError?) -> Void)? = nil)
    {
        
        guard let accessToken = authorizationManager.currentAccessToken?.accessToken, accessToken != "" else {
            
            completionHandler?(nil)
            return
            
        }
        
        apiService.deactivateUserAccount(deactivate: deactivate) { response, error in
            
            completionHandler?(error)
            
        }
        
    }
    
    /**
     Update the user password for the authorized user
     
     - parameter current:           The current password
     - parameter new:               The password to update the user with
     - parameter completionHandler: The closure called upon completion with the response data
     */
    open func updateUserPassword(withCurrentPassword current: String,
                                 newPassword new: String,
                                 completionHandler: ((_ error: MaverickError?) -> Void)? = nil)
    {
        
        guard let accessToken = authorizationManager.currentAccessToken?.accessToken, accessToken != "" else {
            completionHandler?(nil)
            return
        }
        
        apiService.updateUserPassword(withCurrentPassword: current, newPassword: new) { response, error in
            completionHandler?(error)
        }
        
    }
    
    /**
     Send the user's message from the Contact Us Form.
     - parameter message: The message to be sent.
     - parameter completionHandler: The closure called upon completion with the response data.
     */
    open func submitContactUsForm(withMessage message: String, completionHandler: ((_ error: MaverickError?) -> Void)? = nil) {
        
        guard let accessToken = authorizationManager.currentAccessToken?.accessToken, let user = loggedInUser, accessToken != "" else {
            completionHandler?(nil)
            return
        }
        
        let name: String = {
            
            let firstName = user.firstName ?? "Unknown First Name"
            let lastName = user.lastName ?? "Unknown Last Name"
            
            return firstName + lastName
            
        }()
        
        let email: String = {
            
            if let emailAddress = user.emailAddress {
                return emailAddress
            } else if let parentEmailAddress = user.parentEmailAddress {
                return parentEmailAddress
            } else {
                return R.string.maverickStrings.supportEmailAddress()
            }
            
        }()
        
        let username = user.username ?? ""
        
        apiService.sendUserMessage(name: name, email: email, username: username, message: message) { response, error in
            completionHandler?(error)
        }
        
    }
    
    /**
     Verify the identity of the parent
     
     - parameter completionHandler: The closure called upon completion with the response data
     */
    open func moderateText(text : String,
                           completionHandler:  @escaping (_ replacement: String?) -> Void)
    {
        
        apiService.moderate(text: text, completionHandler: { (response) in
            
            guard let replacement = response?.text else {
                completionHandler(nil)
                return
                
            }
            if text != replacement {
                
                completionHandler(replacement)
                return
                
            }
            completionHandler(nil)
            
            
        })
        
    }
    
    
    
    /**
     Verify the identity of the parent
     
     - parameter completionHandler: The closure called upon completion with the response data
     */
    open func verifyParentInfo(withFirstName firstName: String,
                               lastName: String,
                               address: String,
                               zip: String,
                               ssn: String,
                               childUserId: String,
                               retry: Int = 0,
                               completionHandler:  ((_ error: MaverickError?) -> Void)? = nil)
    {
        
        apiService.verifyParentInfo(withFirstName: firstName,
                                    lastName: lastName,
                                    address: address,
                                    zip: zip,
                                    ssn: ssn,
                                    childUserId: childUserId,
                                    retry: retry )
        { response, error in
            
            completionHandler?(error)
            
        }
        
    }
    
    /**
     Update the status of the VPC for the kid account
     
     - parameter childId: The user id to update
     - parameter status: The VPC status (0 or 1)
     - parameter completionHandler: The closure called upon completion with the response data
     */
    open func updateVPCStatus(withChildId childId: String,
                              status: Int = 0,
                              completionHandler:  ((_ error: MaverickError?) -> Void)? = nil)
    {
        
        apiService.updateVPCStatus(withChildId: childId, status: status) { response, error in
            completionHandler?(nil)
            
        }
        
    }
    
    /**
     Determine and set if user has seen this particular version's suggested upgrade
     
     - parameter versionNumber: The suggested versionNumber to evaluate
     
     */
    func hasSeenSuggestedUpgrade( versionNumber : String) -> Bool {
        
        return DBManager.sharedInstance.hasSeenSuggestedUpgrade(versionNumber: versionNumber)
    }
    
    
}
