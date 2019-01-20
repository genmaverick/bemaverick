//
//  APIService+User.swift
//  BeMaverick
//
//  Created by David McGraw on 10/1/17.
//  Copyright © 2017 BeMaverick. All rights reserved.
//

import Foundation
import Alamofire
import AlamofireObjectMapper

extension APIService {

   
    
    /**
     Fetches the user details for the authorized user
     
     - parameter completionHandler: The closure called upon completion with the response data
     */
    func getLoggedInUserDetails(basic : Bool, completionHandler: @escaping UserDetailsRequestCompletedClosure) {
        
        log.verbose("📥 Fetching user details for the authorized user")
        
        Alamofire.request(UserRouter.me(basic: basic))
            .validate({ (urlRequest, urlResponse, data) -> Request.ValidationResult in
                
                return self.checkInactiveOrRevoked(request: urlRequest, urlResponse: urlResponse, data: data)
                
            })
            .validate()
            .responseObject { (response: DataResponse<UserDetailsResponse>) in
                
                if let error = response.error, let data = response.data {
                    log.error("❌ Failed to fetch user details: \(error)")
                    return completionHandler(response.value, MaverickError.apiServiceRequestFailed(reason: .dataError(data: data, error: error)))
                }
                
                completionHandler(response.value, nil)
                
        }
        
    }
    
    /**
     Fetches the user details for the provided email addresses
     
     - parameter completionHandler: The closure called upon completion with the response data
     */
    func getContacts(byEmails emails: [String], phone : [String], completionHandler: @escaping UserDetailsRequestCompletedClosure) {
        
        
        let emailsCSV = emails.joined(separator: ",")
        
        let phoneCSV = phone.joined(separator: ",")
        
        
       
    
        
        log.verbose("📥 Fetching user by emails for \(emailsCSV) and phone : \(phoneCSV)")
        
        Alamofire.request(UserRouter.getContactsOnMaverick(emails_CSV: emailsCSV, phoneNumbers_CSV: phoneCSV))
            .validate()
            .responseObject { (response: DataResponse<UserDetailsResponse>) in
                
                if let error = response.error {
                    log.error("❌ Failed Fetching user by emails for  : \(error) + \(error.localizedDescription)")
                    print(response.debugDescription)
                    return completionHandler(response.value, MaverickError.apiServiceRequestFailed(reason: .dataError(data: response.data ?? Data() , error: error)))
                }
                
                completionHandler(response.value, nil)
                
        }
        
    }
    
    /**
     Fetches the user details based on query string
     
     - parameter completionHandler: The closure called upon completion with the response data
     */
    func searchUsers(byString query: String, completionHandler: @escaping UserSearchRequestCompletedClosure) {
        
        log.verbose("📥 Fetching user by query for \(query)")
        
        Alamofire.request(UserRouter.searchUsers(query: query))
            .validate()
            .responseArray {(response: DataResponse<[SearchUser]>) -> Void in
                
                if let error = response.error, let data = response.data {
                    log.error("❌ Failed Fetching user by query for  : \(query) + \(error.localizedDescription)")
                    print(response.debugDescription)
                    return completionHandler(response.value, MaverickError.apiServiceRequestFailed(reason: .dataError(data: data, error: error)))
                }
                
                completionHandler(response.value, nil)
        
        }
        
    }
                    
    /**
     Fetches the user details for the provided Facebook IDs
     
     - parameter completionHandler: The closure called upon completion with the response data
     */
    func getContacts(byFacebookIds ids: [String], completionHandler: @escaping UserDetailsRequestCompletedClosure) {
        
        let ids = ids.joined(separator: ",")
        
        log.verbose("📥 Fetching Maverick users by Facebook for \(ids)")
        
        Alamofire.request(UserRouter.getFacebookContactsOnMaverick(ids: ids))
            .validate()
            .responseObject { (response: DataResponse<UserDetailsResponse>) in
                
                if let error = response.error, let data = response.data {
                    log.error("❌ Failed Fetching user by facebook ids: \(error) + \(error.localizedDescription)")
                    return completionHandler(response.value, MaverickError.apiServiceRequestFailed(reason: .dataError(data: data, error: error)))
                }
                
                completionHandler(response.value, nil)
        }
        
    }

    /**
      Invites the user for the provided email addresses
     
     - parameter completionHandler: The closure called upon completion with the response data
     */
    func inviteContacts(byEmails emails: [String], inviteUrl : String, subject : String, body : String, completionHandler: @escaping UserDetailsRequestCompletedClosure) {
        
        let emailsCSV = emails.joined(separator: ",")
        log.verbose("📥 inviting user by emails for \(emailsCSV)")
        
        Alamofire.request(UserRouter.inviteContacts(emails_CSV: emailsCSV, invite_url : inviteUrl, subject: subject, body: body))
            .validate()
            .responseObject { (response: DataResponse<UserDetailsResponse>) in
                
                if let error = response.error, let data = response.data {
                    log.error("❌ Failed inviting user by emails for \(emailsCSV) : \(error)")
                    return completionHandler(response.value, MaverickError.apiServiceRequestFailed(reason: .dataError(data: data, error: error)))
                }
                
                completionHandler(response.value, nil)
                
        }
        
    }
    
    
    /**
     Fetches the user details for the provided user id
     
     - parameter completionHandler: The closure called upon completion with the response data
     */
    func getUserDetails(forUserId id: String, completionHandler: @escaping UserDetailsRequestCompletedClosure) {
        
        log.verbose("📥 Fetching user details for user id \(id)")
        
        Alamofire.request(UserRouter.getDetails(id: id))
            .validate()
            .responseObject { (response: DataResponse<UserDetailsResponse>) in
                
                if let error = response.error, let data = response.data {
                    log.error("❌ Failed to fetch user details: \(error)")
                    return completionHandler(response.value, MaverickError.apiServiceRequestFailed(reason: .dataError(data: data, error: error)))
                }
                
                completionHandler(response.value, nil)
                
        }
        
    }
    
    /**
     Fetches the user favorite (saved) challenges for the authorized user
     
     - parameter completionHandler: The closure called upon completion with the response data
     */
    func getUserSavedChallenges(count: Int = 20, offset: Int = 0, completionHandler: @escaping UserDetailsRequestCompletedClosure) {
        
        log.verbose("📥 Fetching user saved challenges")
        
        Alamofire.request(UserRouter.getSavedChallenges(count : count, offset: offset))
            .validate()
            .responseObject { (response: DataResponse<UserDetailsResponse>) in
                
                if let error = response.error, let data = response.data {
                    log.error("❌ Failed to fetch favorited challenges: \(error)")
                    return completionHandler(response.value, MaverickError.apiServiceRequestFailed(reason: .dataError(data: data, error: error)))
                }
                
                completionHandler(response.value, nil)
                
        }
        
    }
    
    /**
     Fetches the user favorite (saved) challenges for the authorized user
     
     - parameter completionHandler: The closure called upon completion with the response data
     */
    func getUserSavedContent(completionHandler: @escaping UserDetailsRequestCompletedClosure) {
        
        log.verbose("📥 Fetching user saved content")
        
        Alamofire.request(UserRouter.getSavedContent)
            .validate()
            .responseObject { (response: DataResponse<UserDetailsResponse>) in
                
                if let error = response.error, let data = response.data {
                    log.error("❌ Failed to fetch saved contents: \(error)")
                    return completionHandler(response.value, MaverickError.apiServiceRequestFailed(reason: .dataError(data: data, error: error)))
                }
                
                completionHandler(response.value, nil)
                
        }
        
    }
    /**
     Retrieve a list of responses based on the authorized user
     
     - parameter count:             The amount of responses to fetch
     - parameter offset:            The offset to fetch by
     - parameter completionHandler: The closure called upon completion with the response data
     */
    open func getMyFeed(withCount count: Int = 20,
                                  offset: Int = 0,
                                  completionHandler: @escaping ResponseRequestCompletedClosure)
    {
        
        log.verbose("📥 Fetching my feed, \(count), offset by \(offset)")
        
        Alamofire.request(UserRouter.getMyFeed(count: count, offset: offset))
            .validate()
            .responseObject { (response: DataResponse<ResponsesResponse>) in
                
                if let error = response.error, let data = response.data {
                    log.error("❌ Failed to fetch response feed: \(error)")
                    return completionHandler(response.value, MaverickError.apiServiceRequestFailed(reason: .dataError(data: data, error: error)))
                }
                
                completionHandler(response.value, nil)
                
        }
        
    }
    
    /**
     Fetches responses that the authorized user has badged
     
     - parameter badge:             A badge type used to filter the response
     - parameter userId:            The user id to retrieve badge data for
     - parameter count:             The total responses
     - parameter offset:            The offset from 0 to fetch
     - parameter completionHandler: The closure called upon completion with the response data
     */
    func getUserBadgedResponses(withBadge badgeId: String? = nil,
                                userId: String,
                                count: Int = 50,
                                offset: Int = 0,
                                completionHandler: @escaping UserDetailsRequestCompletedClosure) {
        
       
        log.verbose("📥 Fetching user responses with badge \(badgeId ?? "n/a"), \(count), \(offset)")
        
        Alamofire.request(UserRouter.getBadgedResponses(badgeId: badgeId, userId: userId, count: count, offset: offset))
            .validate()
            .responseObject { (response: DataResponse<UserDetailsResponse>) in
                
                if let error = response.error, let data = response.data {
                    log.error("❌ Failed to fetch responses: \(error)")
                    return completionHandler(response.value, MaverickError.apiServiceRequestFailed(reason: .dataError(data: data, error: error)))
                }
                
                completionHandler(response.value, nil)
                
        }
        
    }
    
    /**
     Fetches responses that the authorized user has badged
     
     - parameter count:             The total responses
     - parameter offset:            The offset from 0 to fetch
     - parameter completionHandler: The closure called upon completion with the response data
     */
    func getUsers(count: Int = 20,
                  offset: Int = 0,
                  completionHandler: @escaping UsersRequestCompletedClosure) {
        
        log.verbose("📥 Fetching users \(count), offset by \(offset)")
        
        Alamofire.request(UserRouter.getUsers(count: count, offset: offset))
            .validate()
            .responseObject { (response: DataResponse<UsersResponse>) in
                
                if let error = response.error, let data = response.data {
                    log.error("❌ Failed to fetch users: \(error)")
                    return completionHandler(response.value, MaverickError.apiServiceRequestFailed(reason: .dataError(data: data, error: error)))
                }
                
                completionHandler(response.value, nil)
                
        }
        
    }
    
    /**
     Favorites a challenge for the authorized user
     
     - parameter id:        The challenge id to favorite
     */
    open func saveChallenge(withId id: String,
                                completionHandler: @escaping ResponseRequestCompletedClosure) {
        
        log.verbose("📥 Favorite challenge with id \(id)")
        
        Alamofire.request(UserRouter.toggleSaveChallenge(id: id, action: "add"))
            .validate()
            .responseObject { (response: DataResponse<ResponsesResponse>) in
                
                if let error = response.error, let data = response.data {
                    log.error("❌ Failed to favorite challenge \(error)")
                    return completionHandler(response.value, MaverickError.apiServiceRequestFailed(reason: .dataError(data: data, error: error)))
                }
                
                completionHandler(response.value, nil)
                
        }
        
    }
    
    
    /**
     Removes the challenge as a favorite from the authorized user's account
     
     - parameter id:        The challenge id to remove as a favorite
     */
    open func unSaveChallenge(withId id: String,
                                  completionHandler: @escaping ResponseRequestCompletedClosure) {
        
        log.verbose("📥 unsave challenge  with id \(id)")
        
        Alamofire.request(UserRouter.toggleSaveChallenge(id: id, action: "remove"))
            .validate()
            .responseObject { (response: DataResponse<ResponsesResponse>) in
                
                if let error = response.error, let data = response.data {
                    log.error("❌ Failed to unsave challeneg \(error)")
                    return completionHandler(response.value, MaverickError.apiServiceRequestFailed(reason: .dataError(data: data, error: error)))
                }
                
                completionHandler(response.value, nil)
                
        }
        
    }
    
    /**
     Favorites a content for the authorized user
     
     - parameter id:        The content id to favorite
     */
    open func favoriteContent(withId id: String,
                                completionHandler: @escaping ResponseRequestCompletedClosure) {
        
        log.verbose("📥 Save content with id \(id)")
        
        Alamofire.request(UserRouter.toggleSaveContent(id: id, action: "add"))
            .validate()
            .responseObject { (response: DataResponse<ResponsesResponse>) in
                
                if let error = response.error, let data = response.data {
                    log.error("❌ Failed to save content \(error)")
                    return completionHandler(response.value, MaverickError.apiServiceRequestFailed(reason: .dataError(data: data, error: error)))
                }
                
                completionHandler(response.value, nil)
                
        }
        
    }
    
    /**
     Removes the content as a favorite from the authorized user's account
     
     - parameter id:        The challenge id to remove as a favorite
     */
    open func removeContentFavorite(withId id: String,
                                      completionHandler: @escaping ResponseRequestCompletedClosure) {
        
        log.verbose("📥 Remove content as a favorite with id \(id)")
        
        Alamofire.request(UserRouter.toggleSaveContent(id: id, action: "remove"))
            .validate()
            .responseObject { (response: DataResponse<ResponsesResponse>) in
                
                if let error = response.error, let data = response.data {
                    log.error("❌ Failed to remove content as a favorite \(error)")
                    return completionHandler(response.value, MaverickError.apiServiceRequestFailed(reason: .dataError(data: data, error: error)))
                }
                
                completionHandler(response.value, nil)
                
        }
        
    }
    
    /**
     Adds catalyst favorited response
     
     - parameter id:        The challenge id to remove as a favorite
     */
    open func catalystFavoriteResponse(withId id: String, isFavorite : Bool,
                                    completionHandler: @escaping ResponseRequestCompletedClosure) {
        
        
        let action = isFavorite ? "favorite" : "unfavorite"
        log.verbose("📥 Catalyst favorite response with id \(id)")
        
        Alamofire.request(UserRouter.catalystFavoriteResponse(id: id, action: action))
            .validate()
            .responseObject { (response: DataResponse<ResponsesResponse>) in
                
                if let error = response.error, let data = response.data {
                    log.error("❌ Failed to add catalyst favorite \(error)")
                    return completionHandler(response.value, MaverickError.apiServiceRequestFailed(reason: .dataError(data: data, error: error)))
                }
                
                completionHandler(response.value, nil)
                
        }
        
    }
    
    
    /**
     Updates the authorized user's profile with the provided information
     
     - parameter notificationSetting:    The notification setting to update
     - parameter isEnabled:        setting value
     - parameter completionHandler: The closure called upon completion with the response data
     */
    func updateProfileDetails(notificationSetting: Constants.NotificationSettings, isEnabled: Bool,
                              completionHandler: @escaping ResponseRequestCompletedClosure)
    {
        
        log.verbose("📥 Updating user profile details with notification setting \(notificationSetting.stringValue) enabled : \(isEnabled)")
        
        let key = "preferences[\(notificationSetting.rawValue)]"
        Alamofire.request(UserRouter.editNotificationSetting(settingKey: key, settingEnabled: isEnabled ? "1" : "0" ))
            .validate()
            .responseObject { (response: DataResponse<ResponsesResponse>) in
                
                if let error = response.error, let data = response.data {
                    log.error("❌ Failed to update user notification setting \(error)")
                    return completionHandler(response.value, MaverickError.apiServiceRequestFailed(reason: .dataError(data: data, error: error)))
                }
                
                completionHandler(response.value, nil)
                
        }
        
    }
    
    
    /**
     Updates the authorized user's profile with the provided information
     
     - parameter bio:               The user bio
     - parameter firstName:         The user first name
     - parameter lastName:          The user lastName
     - parameter completionHandler: The closure called upon completion with the response data
     */
    func updateProfileDetails(withBio bio: String, firstName: String, lastName: String, username: String, completionHandler: @escaping ResponseRequestCompletedClosure)
    {
        
        log.verbose("📥 Updating user profile details with bio \(bio)")
        
        Alamofire.request(UserRouter.editDetails(bio: bio, firstName: firstName, lastName: lastName, username: username))
            .validate()
            .responseObject { (response: DataResponse<ResponsesResponse>) in
                
                if let error = response.error, let data = response.data {
                    log.error("❌ Failed to update user profile \(error)")
                    return completionHandler(response.value, MaverickError.apiServiceRequestFailed(reason: .dataError(data: data, error: error)))
                }
                
                completionHandler(response.value, nil)
                
        }
        
    }
    
    /**
     Updates the authorized user's profile avatar with the provided image data
     
     - parameter data:              The image data to upload
     - parameter completionHandler: The closure called upon completion with the response data
    */
    func updateProfileAvatar(withLocalImageData data: Data?,
                             completionHandler: @escaping ResponseRequestCompletedClosure)
    {
        
        log.verbose("📥 Updating user avatar")
        
        Alamofire.request(UserRouter.uploadAvatar(data: data))
            .validate()
            .responseObject { (response: DataResponse<ResponsesResponse>) in
                
                if let error = response.error, let data = response.data {
                    log.error("❌ Failed to update user avatar \(error)")
                    return completionHandler(response.value, MaverickError.apiServiceRequestFailed(reason: .dataError(data: data, error: error)))
                }
                
                completionHandler(response.value, nil)
                
        }
        
    }
    
    /**
     Updates user cover image to a canned preset
     - parameter coverId: The id of the cover
     - parameter tintColor: hex string for background color
     - parameter completionHandler: The closure called upon completion with the response data
     */
    func updateProfilePresetCoverImage(withPreset coverId: Int, tintColor: String, completionHandler: @escaping ResponseRequestCompletedClosure) {
        
        log.verbose("📥 Updating user cover image with Preset Cover")
        Alamofire.request(UserRouter.uploadPresetCover(profileCoverPresetImageId: coverId, profileCoverTint: tintColor))
            .validate()
            .responseObject { (response: DataResponse<ResponsesResponse>) in
                
                if let error = response.error, let data = response.data {
                    log.error("❌ Failed to update user preset cover \(error)")
                    return completionHandler(response.value, MaverickError.apiServiceRequestFailed(reason: .dataError(data: data, error: error)))
                }
                
                completionHandler(response.value, nil)
                
        }
        
    }
    /**
     Updates the authorized user's profile cover image with the provided image data
     
     - parameter data:              The image data to upload
     - parameter completionHandler: The closure called upon completion with the response data
     */
    func updateProfileCoverImage(withLocalImageData data: Data,
                                 completionHandler: @escaping ResponseRequestCompletedClosure)
    {
        
        log.verbose("📥 Updating user cover image")
        
        Alamofire.request(UserRouter.uploadCoverImage(data: data))
            .validate()
            .responseObject { (response: DataResponse<ResponsesResponse>) in
                
                if let error = response.error, let data = response.data {
                    log.error("❌ Failed to update user cover image \(error)")
                    return completionHandler(response.value, MaverickError.apiServiceRequestFailed(reason: .dataError(data: data, error: error)))
                }
                
                completionHandler(response.value, nil)
                
        }
        
    }
    
    /**
     Updates the authorized user's password
     
     - parameter current:           The user's current password
     - parameter new:               The new password
     - parameter completionHandler: The closure called upon completion with the response data
     */
    func updateUserPassword(withCurrentPassword current: String,
                            newPassword new: String,
                            completionHandler: @escaping ResponseRequestCompletedClosure)
    {
        
        log.verbose("📥 Updating user password")
        
        Alamofire.request(UserRouter.updatePassword(current: current, new: new))
            .validate()
            .responseObject { (response: DataResponse<ResponsesResponse>) in
                
                if let error = response.error, let data = response.data {
                    log.error("❌ Failed to update user password \(error)")
                    return completionHandler(response.value, MaverickError.apiServiceRequestFailed(reason: .dataError(data: data, error: error)))
                }
                
                completionHandler(response.value, nil)
                
        }
        
    }
    
    /**
     Sends the authorized user's message.
     
     - parameter name:              The user's name
     - parameter email:             The user's email
     - parameter username:          The user's username
     - parameter message:           The user's message
     - parameter completionHandler: The closure called upon completion with the response data
     */
    func sendUserMessage(name: String, email: String, username: String, message: String, completionHandler: @escaping ResponseRequestCompletedClosure) {
        
        log.verbose("📥 Sending user message")
        
        Alamofire.request(SiteRouter.sendMessage(name: name, email: email, username: username, message: message))
            .validate()
            .responseObject { (response: DataResponse<ResponsesResponse>) in
                
                if let error = response.error, let data = response.data {
                    log.error("❌ Failed to send user message \(error)")
                    return completionHandler(response.value, MaverickError.apiServiceRequestFailed(reason: .dataError(data: data, error: error)))
                }
                
                completionHandler(response.value, nil)
                
        }
        
    }
    
    /**
     Deactivates the authorized user's account, should result in a logout
     
     - parameter completionHandler: The closure called upon completion with the response data
     */
    func deactivateUserAccount(deactivate : Bool,
                            completionHandler: @escaping ResponseRequestCompletedClosure)
    {
        
        log.verbose("📥 Deactivating user account")
        
        Alamofire.request(UserRouter.deactivateAccount(deactivate: deactivate ? "1" : "0"))
            .validate()
            .responseObject { (response: DataResponse<ResponsesResponse>) in
                
                if let error = response.error, let data = response.data {
                    log.error("❌ Failed to delete user account \(error)")
                    return completionHandler(response.value, MaverickError.apiServiceRequestFailed(reason: .dataError(data: data, error: error)))
                }
                
                completionHandler(response.value, nil)
                
        }
        
    }
    
    /**
     Retrieves a list of followers and users who are following
     
     - parameter id:    The user id to retrieve data for
    */
    open func getFollowDetails(forUserId id: String,
                               completionHandler: @escaping ResponseRequestCompletedClosure) {
        
        log.verbose("📥 Get follow details for user with id \(id)")
        
        Alamofire.request(UserRouter.getFollowDetails(userId: id))
            .validate()
            .responseObject { (response: DataResponse<ResponsesResponse>) in
                
                if let error = response.error, let data = response.data {
                    log.error("❌ Failed to get follow details \(error)")
                    return completionHandler(response.value, MaverickError.apiServiceRequestFailed(reason: .dataError(data: data, error: error)))
                }
                
                completionHandler(response.value, nil)
                
        }
        
    }
    
    /**
     Follow a user with a provided id
     
     - parameter id:        The user id to follow
     */
    open func followUser(withId id: String,
                         completionHandler: @escaping ResponseRequestCompletedClosure) {
        
        log.verbose("📥 Follow user with id \(id)")
        
        Alamofire.request(UserRouter.toggleFollow(id: id, action: "follow"))
            .validate()
            .responseObject { (response: DataResponse<ResponsesResponse>) in
                
                if let error = response.error, let data = response.data {
                    log.error("❌ Failed to follow user \(error)")
                    return completionHandler(response.value, MaverickError.apiServiceRequestFailed(reason: .dataError(data: data, error: error)))
                }
                
                completionHandler(response.value, nil)
                
        }
        
    }
    
    
    /**
     Unfollow a user with a provided id
     
     - parameter id:        The user id to unfollow
     */
    open func unfollowUser(withId id: String,
                           completionHandler: @escaping ResponseRequestCompletedClosure) {
    
        log.verbose("📥 Unfollow user with id \(id)")
        
        Alamofire.request(UserRouter.toggleFollow(id: id, action: "unfollow"))
            .validate()
            .responseObject { (response: DataResponse<ResponsesResponse>) in
                
                if let error = response.error, let data = response.data {
                    log.error("❌ Failed to unfollow user \(error)")
                    return completionHandler(response.value, MaverickError.apiServiceRequestFailed(reason: .dataError(data: data, error: error)))
                }
                
                completionHandler(response.value, nil)
                
        }
        
    }
    
    /**
     Forces a user to unfollow you
     
     - parameter id:        The user id to remove as a follower
     */
    open func removeFollower(withId id: String,
                             completionHandler: @escaping ResponseRequestCompletedClosure) {
        
        log.verbose("📥 Remove follower with id \(id)")
        
        Alamofire.request(UserRouter.removeFollower(id: id))
            .validate()
            .responseObject { (response: DataResponse<ResponsesResponse>) in
                
                if let error = response.error, let data = response.data {
                    log.error("❌ Failed to remove a follower \(error)")
                    return completionHandler(response.value, MaverickError.apiServiceRequestFailed(reason: .dataError(data: data, error: error)))
                }
                
                completionHandler(response.value, nil)
                
        }
        
    }
 
}
