//
//  DBManager+Content.swift
//  BeMaverick
//
//  Created by Garrett Fritz on 2/14/18.
//  Copyright © 2018 BeMaverick. All rights reserved.
//

import Foundation
import RealmSwift

extension DBManager {
    
    /**
     Initialization function when user launches app after if user is logged in
     */
    func initializeLoggedInUser() {
        
        
        if loggedInUserId != getConfiguration().loggedInUserId {
            
            loggedInUserId = getConfiguration().loggedInUserId
            initializeLoggedInUserDB(loggedInUserId)
            Leanplum.setUserId(loggedInUserId)
            Leanplum.forceContentUpdate {
                Leanplum.forceContentUpdate {
                    Leanplum.forceContentUpdate {
                        Leanplum.forceContentUpdate()
                    }
                }
            }
            
        }
        
    }
    
    /**
     Called on login, fires initialization functions
     */
    func loginUser(userId: String) {
        
        try! database.write {
            
            database.create(MaverickConfiguration.self, value : ["loggedInUserId" : userId], update: true)
            
        }
        
        initializeLoggedInUser()
        
    }
    
    /**
     Shortcut method to return logged in user
     */
    func getLoggedInUser() -> User? {
        
        return getUser(byId: loggedInUserId)
        
    }
    
    func setPresetCoverImage(coverId : String) {
        
         DBManager.sharedInstance.attemptLoggedInDBWrite {
            
            getLoggedInUser()?.profileCoverPresetImageId = coverId
            getLoggedInUser()?.profileCoverImageType = Constants.ProfileCoverType.preset
            getLoggedInUser()?.profileCover = getMaverickMedia(byId: coverId, type: .cover)
        
        }
    
    }
    
    /**
     Fetches a challenge from the realm if it exists.
     If it doesn't, it will create a new object with the userId and add it to the realm.
     All subsequent edits to the object must be made in a write transaction
     */
    func getUser(byId userId: String) -> User {
        
        if let user = loggedInUserDataBase.object(ofType: User.self, forPrimaryKey: userId) {
            
            return user
            
        } else {
            
            let user = User(userId: userId)
            if loggedInUserDataBase.isInWriteTransaction {
                
                loggedInUserDataBase.add(user, update: true)
                
            } else {
                
                attemptLoggedInDBWrite {
                    
                    loggedInUserDataBase.add(user, update: true)
                    
                }
                
            }
            
            return user
            
        }
        
    }
    
    func getUser(byUsername username : String) -> User? {
        
        let scope = loggedInUserDataBase.objects(User.self).filter("username == %@", username)
        return scope.first
        
    }
    
    /**
     Adds a user object to the realm.  Optional values are set for different endpoints returning different portions of
     the user object so we don't overwrite data just because we have a partial result object
     */
    func addUser(userObject: User, images: [Image], loggedInData : Bool = false, includeStats: Bool = false)  -> User {
        
        let userToUpdate = getUser(byId: userObject.userId)
        
        attemptLoggedInDBWrite {
            
            let maverickImages = processImages(images: images)
            userToUpdate.updateBasicUserData(userObject, includeStats: includeStats)
            
            if loggedInData {
                
                userToUpdate.updateLoggedInUserData(userObject)
                
                if userToUpdate.myFeed == nil {
                    
                    userToUpdate.myFeed = MultiContentFeed()
                
                }
                
            }
            
            if let id = userObject.profileImageId {
                
                userToUpdate.profileImage = maverickImages[id]
                
            } else {
                
                userToUpdate.profileImage = nil
           
            }
            
            if let id = userObject.profileCoverImageId {
                
                userToUpdate.profileCover = maverickImages[id]
                
            }
            
            //Merge in system preset cover if set
            if userToUpdate.profileCoverImageType == .preset {
                
                if let coverId =  userToUpdate.profileCoverPresetImageId {
                    
                    userToUpdate.profileCover = getMaverickMedia(byId: coverId, type: .cover)
                    
                }
                
            }
            
            if let responseBadges = userObject.badges {
                
                userToUpdate.badgeStats.removeAll()
                for value in responseBadges.values {
                    
                    let badge = loggedInUserDataBase.create(BadgeStats.self)
                    badge.setValues(badge: value)
                    userToUpdate.badgeStats.append(badge)
                    
                }
                
            }
            
            loggedInUserDataBase.add(userToUpdate, update: true)
       
        }
        
          return userToUpdate
        
    }
    
    func getBlockedUsers() -> Results<User> {
        
        return loggedInUserDataBase.objects(User.self).filter("isBlocked = true")
   
    }
    
    func blockUser(withId id : String, isBlocked : Bool ) {
        
        let userToBlock = getUser(byId: id)
        attemptLoggedInDBWrite {
            userToBlock.isBlocked = isBlocked
        }
    }
    
    /**
     Adds a list of users to DB
     */
    func updateUsers(withUsers users: [User], images : [Image]) -> [User] {
        
        var userArray : [User] = []
        attemptLoggedInDBWrite {
            
            for user in users {
                
               userArray.append(addUser(userObject: user,  images: images))
                
            }
            
        }
        
        return userArray
        
    }
    
    /**
     Adds a list of users to DB
     */
    func updateUsers(withUsers users: [SearchUser]) -> List<User> {
        
        let maverickUsers = List<User>()
        
        attemptLoggedInDBWrite {
            
            for user in users {
                
                guard let id = user.user_id else { continue }
                let maverickUser = getUser(byId: id)
                maverickUser.updateBasicUserData(user)
                
                if maverickUser.profileImage == nil, let imageData = user.profile_image {
                    
                    let image = processImages(images: [imageData])
                    maverickUser.profileImage = image[imageData.imageId]
                    
                }
                
                maverickUsers.append(maverickUser)
            }
            
        }
        
        return maverickUsers
        
    }
    
    
    /**
     Call to update particular properties on a user object in the DB - needs to have at least ["userId": {userId}]
     */
    func updateUserFields(value: Any) {
        
        attemptLoggedInDBWrite {
            
            loggedInUserDataBase.create(User.self, value: value, update: true)
            
        }
        
    }
    
    func updateEditProfileData(firstName: String, lastName: String, bio : String, username: String) {
        
        attemptLoggedInDBWrite {
            
            getLoggedInUser()?.firstName = firstName
            getLoggedInUser()?.lastName = lastName
            getLoggedInUser()?.bio = bio
            getLoggedInUser()?.username = username
     
        }
        
    }
    
    func updateNotificationSetting(setting : Constants.NotificationSettings, isEnabled : Bool) {
        
        attemptLoggedInDBWrite {
            
            switch setting {
                
            case .push:
                getLoggedInUser()?.pushEnabled = isEnabled
            
            case .push_follower:
                getLoggedInUser()?.pushFollowerEnabled = isEnabled
            
            case .push_posts:
                getLoggedInUser()?.pushPostsEnabled = isEnabled
            
            case .push_general:
                getLoggedInUser()?.pushGeneralEnabled = isEnabled
                
            }
            
            if let user = getLoggedInUser() {
            
                AnalyticsManager.identify(loggedInUser: user)
            
            }
        }
        
    }
    
    func setUploadingSession(sessionId : String) {
    
        attemptLoggedInDBWrite {
            
            getLoggedInUser()?.uploadingSessionIds.append(sessionId)
        
        }
        
    }
    
    func removeUploadingSession(sessionId : String) {
        
        attemptLoggedInDBWrite {
            
            if let index =  getLoggedInUser()?.uploadingSessionIds.index(of: sessionId) {
                
                getLoggedInUser()?.uploadingSessionIds.remove(at: index)
         
            }
            
        }
        
    }
    
    func getUsers(byUsername value : String) -> Results<User> {
        
        return loggedInUserDataBase.objects(User.self).filter("username CONTAINS[cd] %@ OR firstName BEGINSWITH[cd] %@ OR lastName BEGINSWITH[cd] %@", value, value, value)
        
    }
    
    func assembleUsers(users: [User], images : [Image], sortOrder: [String]? = nil) -> List<User> {
        
        var processedUserDictionary : [String:User] = [:]
        let processedUsers = List<User>()
        let blockedUsers = getBlockedUsers()
        
        attemptLoggedInDBWrite {
            
            
            let maverickImages = processImages(images: images)
            
            //first merge user data into existing db entries
            for userItem in users {
                
                let userToAdd = getUser(byId: userItem.userId)
                userToAdd.updateBasicUserData(userItem)
                if let imageId = userToAdd.profileImageId {
                    
                    userToAdd.profileImage = maverickImages[imageId]
                    
                } else {
                    
                    userToAdd.profileImage = nil
                    
                }
                
                if let responseBadges = userItem.badges {
                    
                    userToAdd.badgeStats.removeAll()
                    for value in responseBadges.values {
                        
                        let badge = loggedInUserDataBase.create(BadgeStats.self)
                        badge.setValues(badge: value)
                        userToAdd.badgeStats.append(badge)
                        
                    }
                    
                }
                
                if blockedUsers.contains(userToAdd) {
                    continue
                }
                
                if sortOrder != nil {
                    
                    processedUserDictionary[userToAdd.userId] = userToAdd
                    
                } else {
                    
                    processedUsers.append(userToAdd)
                    
                }
                
            }
            
        }
        
        if let sortOrder = sortOrder {
            
            //populate the maverickSuggested based with the new maverick users
            for id in sortOrder {
                
                if let userItem = processedUserDictionary[id] {
                    
                    processedUsers.append(userItem)
                    
                }
                
            }
            
        }
        
        return processedUsers
        
    }
    
    /**
     Sets value for list of users to be displayed in various 'suggested' UI elements
     */
    func setSuggestedUserList(userIds: [String], images: [Image], withUsers items: [User], clearPreviousResults: Bool = true) {
        
        attemptLoggedInDBWrite {
            
            let users = assembleUsers(users: items, images: images, sortOrder: userIds)
            
            if clearPreviousResults {
                getLoggedInUser()?.suggestedUsers.removeAll()
            }
            
            getLoggedInUser()?.suggestedUsers.append(objectsIn: users)
            
        }
        
    }
    
    
    
    /**
     Sets list of followers and following for a particular user
     returns:  return (maverickFollowers, maverickFollowing)
     */
    func setFollowersList(forUser user: User, withUsers items: [User]) -> (List<User>, List<User>){
        
        var maverickUsers : [String:User] = [:]
        let maverickFollowing = List<User>()
        let maverickFollowers = List<User>()
        
        attemptLoggedInDBWrite {
            
            //first merge user data into existing db entries
            for userItem in items {
                
                let userToAdd = getUser(byId: userItem.userId)
                userToAdd.updateBasicUserData(userItem, includeStats: user.userId == userItem.userId)
                maverickUsers[userToAdd.userId] = userToAdd
                
            }
            
            let mainUser = getUser(byId: user.userId)
            mainUser.followerUserIds.removeAll()
            if let API_followerUserIds = user.API_followerUserIds {
                
                for id in API_followerUserIds {
                    
                    if let user = maverickUsers[id] {
                        
                        maverickFollowers.append(user)
                        
                    }
                
                    mainUser.followerUserIds.append(id)
                
                }
            
            }
            mainUser.followingUserIds.removeAll()
            if let API_followingUserIds = user.API_followingUserIds {
                
                for id in API_followingUserIds {
                    
                    if let user = maverickUsers[id] {
                        
                        maverickFollowing.append(user)
                        
                    }
                    
                    mainUser.followingUserIds.append(id)
                   
                }
                
            }
            
            if loggedInUserId == mainUser.userId {
                
                mainUser.loggedInUserFollowing.removeAll()
                mainUser.loggedInUserFollowing.append(objectsIn: maverickFollowing)
                
            }
            
        }
        
        return (maverickFollowers, maverickFollowing)
        
    }
    
    /**
     Check if logged in user is following the given user
     */
    func isFollowing(userId id: String) -> Bool {
        
        if let me = getLoggedInUser() {
            
            return me.followingUserIds.contains(id)
            
        }
        
        return false
        
    }
    
    /**
     Toggle whether or not the logged in user is following the given user
     */
    func toggleFollowing(userId id: String, shouldFollow: Bool) {
      
        let tickTimestamp = Date()
       
        guard let me = getLoggedInUser() else { return }
         print("🤕 toggleFollowing getLoggedInUser : \(id) : \(shouldFollow) : \(Date().timeIntervalSince(tickTimestamp))")
        if shouldFollow {
            
            attemptLoggedInDBWrite {
                
                me.followingUserIds.append(id)
                me.stats?.numFollowingUsers += 1
                
            }
            
        } else {
            
            if let index = me.followingUserIds.index(of: id) {
                
                attemptLoggedInDBWrite {
                    
                    me.followingUserIds.remove(at: index)
                    me.stats?.numFollowingUsers -= 1
                    
                }
            }
        }
           print("🤕 toggleFollowing completed : \(id) : \(shouldFollow) : \(Date().timeIntervalSince(tickTimestamp))")
    }
}
