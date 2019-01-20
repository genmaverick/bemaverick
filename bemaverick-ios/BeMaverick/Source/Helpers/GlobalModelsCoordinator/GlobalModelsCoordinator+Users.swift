//
//  GlobalModelsCoordinator+Users.swift
//  BeMaverick
//
//  Created by David McGraw on 11/28/17.
//  Copyright © 2017 BeMaverick. All rights reserved.
//

import Foundation
import RealmSwift
import Kingfisher

extension GlobalModelsCoordinator {
    
    
    
    // MARK: - Public Methods
    
    open func reloadLoggedInUserData() {
        
        guard let id  = loggedInUser?.userId else { return }
        getUserDetails(forUserId: id) { }
        getUserBadgedResponses(forUserId: id)
        getUserFollowingData(forUserId: id)
        getSuggestedUsers()
        
    }
    
    
    /**
     Determine if the authorized user is following a user with the id
     */
    open func isFollowingUser(userId id: String) -> Bool {
        
        return DBManager.sharedInstance.isFollowing(userId: id)
        
    }
    
    /**
     Determine if the challenge is a favorite of the user
     */
    open func isSaved(contentType: Constants.ContentType, withId id: String) -> Bool {
        
        return DBManager.sharedInstance.isSaved(contentType: contentType, withId: id)
        
    }
    
    /**
     Determine if the challenge is a favorite of the user
     */
    open func isChallengeResponded(challengeId: String) -> Bool {
        
        
        return DBManager.sharedInstance.isChallengeResponded(challengeId: challengeId)
        
    }
    
    /**
     Check if a particular badge is selected for a response
    */
    open func isResponseBadged(userId : String, responseId: String, badge: MBadge) -> Bool {
        
        if let selectedBadge = DBManager.sharedInstance.isResponseBadged(userId: userId, responseId: responseId) {
        
            return selectedBadge.badgeId == badge.badgeId
            
        }
        return false
        
    }
    
    /**
     Return the badge selected for a response
    */
    open func getSelectedBadge(userId : String, responseId : String) -> MBadge? {
        
       return DBManager.sharedInstance.isResponseBadged(userId: userId, responseId: responseId)
        
    }
    
    /**
     Fetches the user details for the provided email addresses
     
     - parameter completionHandler: The closure called upon completion with the response data
     */
    open func getContacts(byEmails emails: [String], phone : [String], completionHandler: @escaping ((List<User>?) -> Void)) {
        
        guard let accessToken = authorizationManager.currentAccessToken?.accessToken, accessToken != "" else {
            completionHandler(nil)
            return
        }
        
        apiService.getContacts(byEmails: emails, phone : phone) { (response, error) in
            
            guard error == nil else {
                
                completionHandler(nil)
                return
                
            }
            
            let userArray = response?.users?.map { $0.value } ?? []
            let imageArray = response?.images?.map { $0.value } ?? []
            let users =  DBManager.sharedInstance.assembleUsers(users: userArray, images: imageArray)
            completionHandler(users)
            
        }
        
    }
    
    /**
     Fetches the user details for the provided facebook ids
     
     - parameter completionHandler: The closure called upon completion with the response data
     */
    open func getContacts(byFacebookIds ids: [String], completionHandler: @escaping ((List<User>?) -> Void)) {
        
        guard let accessToken = authorizationManager.currentAccessToken?.accessToken, accessToken != "" else {
            completionHandler(nil)
            return
        }
        
        apiService.getContacts(byFacebookIds: ids) { (response, error) in
            
            guard error == nil else {
                
                completionHandler(nil)
                return
                
            }
            
            let userArray = response?.users?.map { $0.value } ?? []
            let imageArray = response?.images?.map { $0.value } ?? []
            let users = DBManager.sharedInstance.assembleUsers(users: userArray, images: imageArray)
            completionHandler(users)
            
        }
        
    }
    
    /**
     Fetches the user details for the provided email addresses
     
     - parameter completionHandler: The closure called upon completion with the response data
     */
    open func inviteContacts(byEmails emails: [String], inviteUrl : String, subject : String, body : String, completionHandler: @escaping ((List<User>?) -> Void)) {
        
        guard let accessToken = authorizationManager.currentAccessToken?.accessToken, accessToken != "" else {
            completionHandler(nil)
            return
        }
        
        apiService.inviteContacts(byEmails: emails, inviteUrl: inviteUrl, subject: subject, body: body) { (response, error) in
            
            guard error == nil else {
                
                completionHandler(nil)
                return
                
            }
            completionHandler(nil)
            
        }
        
    }
    
    /**
     Retrieve the user details for a user
     
     - parameter id:    The id for the user to fetch
     */
    open func getUserDetails(forUserId userId: String? = nil, completionHandler: (() -> Void)? = nil) {
        
        guard let accessToken = authorizationManager.currentAccessToken?.accessToken, accessToken != "" else {
            completionHandler?()
            return
        }
        
        if let id = userId != nil ? userId : loggedInUser?.userId {
            apiService.getUserDetails(forUserId: id) { userDetailsResponse, error in
                
                guard error == nil,
                    let user = userDetailsResponse?.users?[id] else {
                        
                        completionHandler?()
                        return
                        
                }
                
                let images = userDetailsResponse?.images?.map { $0.value } ?? []
                
                DBManager.sharedInstance.attemptLoggedInDBWrite {
                    
                    _ = DBManager.sharedInstance.addUser(userObject: user, images: images, includeStats: true)
                    
                }
                
                completionHandler?()
                
            }
            
        }
        
    }
    
    open func getUserByUsername(username : String) -> User? {
        
        return DBManager.sharedInstance.getUser(byUsername : username)
        
    }
    /**
     Retreive a list of users from the platform
     
     - returns: A list of users
     */
    open func getSuggestedUsers() {
        
        apiService.getUsers(completionHandler: { response, error in
            
            guard error == nil else { return }
            
            let userArray = response?.users?.map { $0.value } ?? []
            let userIds = response?.searchResults?.users?.userIds  ?? []
            let images = response?.images?.map { $0.value } ?? []
            DBManager.sharedInstance.setSuggestedUserList(userIds: userIds, images: images, withUsers: userArray)
            
        })
        
    }
    
   
    
    /**
     Retrieve the 'My Feed' for the logged in user
     
     - parameter count:             The amount of responses to fetch
     - parameter offset:            The offset to fetch by
     - parameter completionHandler: The closure called upon completion with the response data
     */
    open func getMyFeed(withCount count: Int = 20,
                                  offset: Int = 0,
                                  forceRefresh : Bool,
                                  downloadAssets : Bool,
                                  completionHandler: (() -> Void)? = nil)
    {
        
        if !forceRefresh, let timeStamp = loggedInUser?.myFeed?.feedLastUpdated, timeStamp > ( Int(NSDate().timeIntervalSince1970) - (60 * 60 * feed_expiration_hours) ) {
            print("✅ Skipping: User Response refresh")
            return
            
        }
        print("✅ executing: User Response refresh")

        
        apiService.getMyFeed(withCount: count, offset: offset) { response, error  in
            
            
            guard error == nil else {
                
                completionHandler?()
                return
                
            }
            guard let sortOrder = response?.multiContentOrder else {
                    
                    completionHandler?()
                    return
                    
            }
            
            let userDictionary = response?.users  ?? [:]
            let challengeDictionary = response?.challenges ?? [:]
            let responseDictionary = response?.responses ?? [:]
            
            let responseArray = responseDictionary.map { $0.value }
            
            let challengeArray = challengeDictionary.map { $0.value }
            let videoArray = response?.videos?.map { $0.value } ?? []
            let imageArray = response?.images?.map { $0.value } ?? []
            
            DBManager.sharedInstance.setMyFeedList(sortOrder: sortOrder, owners: userDictionary, videos: videoArray, images: imageArray, challenges: challengeArray, responses: responseArray, clearPreviousResults: offset == 0)
            
            if downloadAssets {
                
                var imageURLs : [URL] = []
                
                for i in 0 ..< min( 4, responseArray.count) {
                    
                    if let apiResponse = responseArray[safe: i] {
                        
                        let response = self.response(forResponseId: apiResponse.responseId)
                        
                        VideoPlayerView.prefetchVideo(media: response.videoMedia)
                        
                        if let url = FeaturedResponses.pathForImage(forItem: response) {
                            
                            imageURLs.append(url)
                            
                        }
                    
                    }
                    
                }
                
                ImagePrefetcher(urls: imageURLs) {  skippedResources, failedResources, completedResources in
                    
                    if ImagePrefetcher.logOn {
                        print("🎥 prefetching  Complete for my feed ")
                        print("🎥 : skippedResources : \(skippedResources.count)")
                        print("🎥 : failedResources : \(failedResources)")
                        for resource in failedResources {
                            print("🎥 : failedResource \(resource.downloadURL)")
                        }
                        print("🎥 : completedResources : \(completedResources.count)")
                    }
                    
                    }.start()
                
            }
            
            completionHandler?()
            self.onResponsesFetchedSignal.fire(true)
            
        }
        
    }
    
    
    open func getUserCreatedBadgedResponses(withBadge badgeId: String? = nil,
                                     forUserId id: String? = nil,
                                     count: Int = 50,
                                     offset: Int = 0,
                                     completionHandler: @escaping ((List<Response>?) -> Void)) {
        
        let id = id ?? loggedInUser?.userId ?? ""
        apiService.getUserCreatedResponses(forUserId: id, badgeId: badgeId, count: count, offset: offset) { response in
            
            guard var userDictionary = response?.users,
                
                let responseDictionary = response?.responses,
                let sortOrder = response?.users?[id]?.searchResults?.responses?.responseIds else {
                    
                    completionHandler(nil)
                    return
                    
            }
            
            let challengeDictionary = response?.challenges ?? [:]
            var responseArray : [Response] = []
            
            
            for responseId in sortOrder {
                
                if let response =  responseDictionary[responseId] {
                    
                    responseArray.append(response)
                    
                }
                
            }
            let challengeArray = challengeDictionary.map { $0.value }
            let videoArray = response?.videos?.map { $0.value } ?? []
            let imageArray = response?.images?.map { $0.value } ?? []
            
            
            let responses = DBManager.sharedInstance.assembleCreatedBadgedResponses(owners: userDictionary, videos: videoArray, images: imageArray, challenges: challengeArray, responses: responseArray)
            completionHandler(responses)
        }
    }
    /**
     Retrieve responses that the user badged. Provide a badge type to filter the
     request.
     
     - parameter badge:             A badge type used to filter the response
     - parameter id:                The user id to fetch badged responses for
     - parameter completionHandler: The closure called upon completion with the response data
     */
    open func getUserBadgedResponses(forUserId id: String? = nil,
                                     count: Int = 50,
                                     offset: Int = 0,
                                     completionHandler: (() -> Void)? = nil) {
        
        let id = id ?? loggedInUser?.userId ?? ""
        apiService.getUserBadgedResponses(userId: id, count: count, offset: offset) { response, error in
            
            
            if let myResponses = response?.users?[id]?.responses {
                
                var newDictionary : [String:BadgedResponse] = [:]
                
                for key in myResponses.keys {
                    
                    if let ids = myResponses[key]?.badgeIds{
                        
                        let list = List<String>()
                        list.append(objectsIn: ids)
                        let badgedResponse = BadgedResponse(userId: id, responseId: key, badgeTypeIds: list)
                        newDictionary[key] = badgedResponse
                        
                    }
                }
                DBManager.sharedInstance.setBadgedResponses(userId : id, responses: newDictionary)
            }
            
            guard var userDictionary = response?.users,
                
                let responseDictionary = response?.responses,
                let sortOrder = response?.users?[id]?.searchResults?.badgedResponses?.responseIds else {
                    
                    completionHandler?()
                    return
                    
            }
            
            let challengeDictionary = response?.challenges ?? [:]
            var responseArray : [Response] = []
            for index in sortOrder {
                if let responses = responseDictionary[index]
                {
                    responseArray.append(responses)
                }
            }
            let challengeArray = challengeDictionary.map { $0.value }
            let videoArray = response?.videos?.map { $0.value } ?? []
            let imageArray = response?.images?.map { $0.value } ?? []
          
            userDictionary.removeValue(forKey: id)
            DBManager.sharedInstance.setInspirationsList(userId: id, owners: userDictionary, videos: videoArray, images: imageArray, challenges: challengeArray, responses: responseArray, clearPreviousResults: offset == 0)
            completionHandler?()
            
        }
        
    }
    
    
    open func getUser(withId id: String) -> User {
        
        return DBManager.sharedInstance.getUser(byId: id)
        
    }
    
  
    
    func isInvited(id : String, mode : Constants.ContactMode) -> Bool {
        
        return DBManager.sharedInstance.isInvited(id:id, mode: mode)
        
    }
    
    func setInvited(id : [String], mode : Constants.ContactMode) {
        
        DBManager.sharedInstance.setInvited(id: id, mode: mode)
        
    }
    
   
    /**
     Retreive a list of follow data for a user
     
     - parameter id:       The user id to fetch follow data for
     */
    open func getUserFollowingData(forUserId id: String? = nil, completionHandler: ((List<User>, List<User>) -> Void)? = nil) {
        
        let userId = id ?? DBManager.sharedInstance.loggedInUserId
        
        apiService.getFollowDetails(forUserId: userId) { response, error in
            
            guard error == nil else {
                
                completionHandler?(List<User>(), List<User>())
                return
                
            }
            
            if let userArray = response?.users?.map({ $0.value }),
                let mainUser = response?.users?.filter({ $0.value.userId == userId }).first?.value {
                
                let (followers, following) = DBManager.sharedInstance.setFollowersList(forUser: mainUser, withUsers: userArray)
                
                completionHandler?(followers, following)
                return
                
            }
            
            completionHandler?(List<User>(), List<User>())
            
        }
        
    }
    
    func getUsers(byUsername username : String, contentType : Constants.ContentType?, contentId : String?, completionHandler: @escaping ((List<User>?) -> Void)) {
        
        guard username.count > 1 else {
            completionHandler(nil)
            return
        }
        apiService.searchUsers(byString: username, completionHandler: { response, error in
            
            guard let response = response, error == nil else { return }
            
            let results = DBManager.sharedInstance.getWeightedUserSearch(byQuery: username, contentType: contentType, contentId: contentId, apiUsers: response)
            completionHandler(results)
            
        })
        
    }
    
    /**
     Retreive a list of challenges that the authorized user favorited
     
     - parameter id:       The user id to fetch follow data for
     */
    open func getSavedChallenges(count : Int = 20, offset : Int = 0, completionHandler: (() -> Void)?) {
        
        apiService.getUserSavedChallenges(count: count, offset : offset) { [weak self] response, error in
            
            guard let userDictionary = response?.users, let userId = self?.loggedInUser?.userId, let challengeDictionary = response?.challenges, let savedChallengeIds = userDictionary[userId]?.savedChallengeIds else {
                
                completionHandler?()
                return
                
            }
            
            let videoArray = response?.videos?.map { $0.value } ?? []
            let imageArray = response?.images?.map { $0.value } ?? []
           
            var challengeArray : [Challenge] = []
            for id in savedChallengeIds {
                
                if let challenge = challengeDictionary[id] {
                    
                    challengeArray.append(challenge)
                    
                }
            }
            
            DBManager.sharedInstance.setSavedChallengesList(items: challengeArray, videos: videoArray, images: imageArray, owners: userDictionary, clearPreviousResults: offset == 0)
            
             completionHandler?()
        }
        
    }
    
    
    
    /**
     Follow a user if the authorized user is not already follow them, otherwise
     unfollow them.
     
     - parameter id:        The user id to follow or unfollow
     */
    open func toggleUserFollow(follow : Bool, withId id: String, completionHandler: @escaping () -> Void) {
        
        
        DBManager.sharedInstance.toggleFollowing(userId: id, shouldFollow: follow)
        
        if follow {
            
            apiService.followUser(withId: id, completionHandler: { value, error in
                
                if error == nil {
                    
                    self.getProgression()
                    
                }
                completionHandler()
            })
            
            
        } else {
            
            apiService.unfollowUser(withId: id, completionHandler: { _, _ in
                
                completionHandler()
            
            })
            
        }
        
    }
    
    open func getBlockedUsers() -> Results<User> {
        
        return DBManager.sharedInstance.getBlockedUsers()
        
    }
    
    open func blockUser(withId id : String, isBlocked : Bool ) {
        
        if isBlocked {
            
            removeUserFollow(withId: id){}
            AnalyticsManager.Profile.trackBlockUser(userId: id)
            apiService.unfollowUser(withId: id, completionHandler: { _, _ in
                
            })
            
        } else {
            
            AnalyticsManager.Profile.trackUnBlockUser(userId: id)
            
        }
        
        DBManager.sharedInstance.blockUser( withId : id, isBlocked : isBlocked )
    
    }
    
    /**
     Forces a user to unfollow you
     
     - parameter id:        The user id to remove as a follower
     */
    open func removeUserFollow(withId id: String, completionHandler: @escaping () -> Void) {
        
        apiService.removeFollower(withId: id) { _, _ in
            completionHandler()
        }
        
    }
    
    /**
     Favorite or unfavorite a challenge
     
     - parameter id:        The challenge id to favorite or unfavorite
     */
    open func toggleSaveChallenge(withId id: String, isSaved : Bool) {
        
        if isSaved {
            
            apiService.saveChallenge(withId: id) { _, _ in
                
            }
            
        } else {
            
            apiService.unSaveChallenge(withId: id) { _, _ in
                
            }
            
        }
        
        DBManager.sharedInstance.toggleSaved(contentType: .challenge, withId: id, shouldSave: isSaved)
        
    }
    /**
     Favorite or a response (catalyst only action)
     
     - parameter id:        The response id to favorite
     */
    open func catalystFavoriteResponse(withId id: String, isFavorite : Bool = true) {
        
        apiService.catalystFavoriteResponse(withId: id, isFavorite: isFavorite) { (response, error) in
            
        }
        
        DBManager.sharedInstance.catalystFavoriteResponse(responseId: id, isFavorited: isFavorite)
        
    }
    
    
}
