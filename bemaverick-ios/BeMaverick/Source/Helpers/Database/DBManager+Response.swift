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
     Fetches a response from the realm if it exists.
     If it doesn't, it will create a new object with the responseId and add it to the realm.
     All subsequent edits to the user object must be made in a write transaction
     */
    func getResponse(byId responseId: String) -> Response {
        
        if let response = loggedInUserDataBase.object(ofType: Response.self, forPrimaryKey: responseId) {
            
            return response
            
        } else {
            
            let response = Response(responseId: responseId)
            if loggedInUserDataBase.isInWriteTransaction {
                
                loggedInUserDataBase.add(response, update: true)
                
            } else {
                
                attemptLoggedInDBWrite {
                    
                    loggedInUserDataBase.add(response, update: true)
                    
                }
                
            }
            
            return response
            
        }
        
    }
    
    
    /**
     Return status of badged response for given type
     */
    func isResponseBadged(userId : String, responseId: String) -> MBadge? {
       
        for badge in loggedInUserDataBase.objects(MBadge.self) {
            
            if getBadgedResponse(userId:userId, responseId: responseId).badgeTypeIds.contains(badge.badgeId) {
                
                return badge
            
            }
        
        }
        
        return nil
        
    }
    
    
    /**
     Return status of badged response for given type
     */
    func catalystFavoriteResponse(responseId: String, isFavorited : Bool) {
        
        attemptLoggedInDBWrite {
            
            getResponse(byId: responseId).favorite = isFavorited
            
        }
        
    }
    
    
    func addUsersWhoBadgedResponse(response : Response, users: [User], images : [Image], videos : [Video], clearPreviousResults: Bool = true) -> [User] {
        
        var userArray : [User] = []
        attemptLoggedInDBWrite {
            
            _ = assembleResponses(responses: [response], videos: videos, images: images)
            
            userArray.append(contentsOf: updateUsers(withUsers: users, images: images))
            
            
            if clearPreviousResults {
                
                getResponse(byId: response.responseId).badgers.removeAll()
                
            }
            
            getResponse(byId: response.responseId).badgers.append(objectsIn: userArray)
            
            
        }
        
        return userArray
        
    }
    
    
    /**
     Creates a new response object and adds it to the logged in user
     */
    func addNewCreatedResponse(response : [Response], video : [Video], image : [Image]) {
        
        attemptLoggedInDBWrite {
            
            let responseArray = assembleResponses(responses: response, videos: video, images: image)
            
            if let created = responseArray.first {
                
                if let challengeId = created.challengeId {
                    
                    let challenge = getChallenge(byId: challengeId)
                    challenge.responses.insert(created, at: 0)
                    challenge.numResponses += 1
                    
                    let stream = getChallengeStream(byId: ConfigurableChallengeStream.MyRespondedChallengesStreamId)
                    
                    if !stream.items.contains(challenge) {
                        
                        stream.items.insert(challenge, at: 0)
                        
                    }
                    
                }
                
                getLoggedInUser()?.createdResponses.insert(created, at: 0)
                
                
                
            }
            
        }
        
    }
    
    /**
     Deletes a response object
     */
    func deleteResponse(response : Response) {
        
        attemptLoggedInDBWrite {
            
            loggedInUserDataBase.delete(response)
            
        }
        
    }
    
    /**
     update my badged response to remove the badge type from the given response id
     */
    func deleteBadgeFromResponse(responseId id: String, badgeId: String, realmNotificationToken : [NotificationToken]? = nil) {
        
        let badgedResponse = getBadgedResponse(userId: loggedInUserId, responseId:  id)
        let response = getResponse(byId: id)
        
        let shouldWrite = !loggedInUserDataBase.isInWriteTransaction
        if  shouldWrite {
        
            loggedInUserDataBase.beginWrite()
        
        }
        
        // remove the response to the logged in users badged response list
        
        if let index = badgedResponse.badgeTypeIds.index(of: badgeId) {
            badgedResponse.badgeTypeIds.remove(at: index)
            
            // remove this from our inspirations if we arent inspired anymore by it,...
            if badgedResponse.badgeTypeIds.count == 0 {
                
                if let inspirationsList = getLoggedInUser()?.badgedResponses, let index = inspirationsList.index(of: getResponse(byId:  badgedResponse.responseId)) {
                    
                    getLoggedInUser()?.badgedResponses.remove(at: index)
                    
                }
            }
            //if this was on the list remove the badge to the response object
            for badgeToCheck in response.badgeStats {
                
                if badgeToCheck.badgeId == badgeId {
                    
                    badgeToCheck.numReceived = badgeToCheck.numReceived - 1
                    
                }
                
            }
        }
        
        if shouldWrite {
          
            var notificationToken : [NotificationToken] = []
            if let realmNotificationToken = realmNotificationToken {
                notificationToken.append(contentsOf: realmNotificationToken)
                
                
            }
            
            
            do {
                
                try loggedInUserDataBase.commitWrite(withoutNotifying: notificationToken)
           
            } catch {
                
            }
        
        }
        
    }
    
    private func removeNonSelectedBadges(withResponseId id: String,
                                         badgeId: String) {
        var availableBadges = ["1","2","3","4", "5"]
        
        if let index = availableBadges.index(of: badgeId) {
            availableBadges.remove(at: index)
        }
        
        for badgeToRemove in availableBadges {
            deleteBadgeFromResponse(responseId: id, badgeId: badgeToRemove)
        }
    }
    
    /**
     update my badged response to add the badge type from the given response id
     */
    func addBadgeToResponse(responseId id: String, badgeId: String, realmNotificationToken : [NotificationToken]? = nil)
    {
        
        let badgedResponse = getBadgedResponse(userId: loggedInUserId, responseId: id)
        let response = getResponse(byId: id)
        loggedInUserDataBase.beginWrite()
        
        //first add the badge to the response object
        var addedBadge = false
        for badgeToCheck in response.badgeStats {
            
            if badgeToCheck.badgeId == badgeId {
                
                badgeToCheck.numReceived = badgeToCheck.numReceived + 1
                addedBadge = true
                
            }
            
        }
        if !addedBadge {
            
            let badgeToAdd = BadgeStats(badgeTypeId: badgeId)
            badgeToAdd.numReceived = 1
            response.badgeStats.append(badgeToAdd)
            
        }
        
        
        //then add the response to the logged in users badged response list
        if let _ = badgedResponse.badgeTypeIds.index(of: badgeId) {
            
        } else {
            
            badgedResponse.badgeTypeIds.append(badgeId)
            if let list = getLoggedInUser()?.badgedResponses, !list.contains(response) {
            
                getLoggedInUser()?.badgedResponses.insert(response, at: 0)
            
            }
            
        }
        
        removeNonSelectedBadges(withResponseId: id, badgeId: badgeId)
        
        var notificationToken : [NotificationToken] = []
        if let realmNotificationToken = realmNotificationToken {
            
            notificationToken.append(contentsOf: realmNotificationToken)
            
        }
        
        do {
            
            try loggedInUserDataBase.commitWrite(withoutNotifying: notificationToken)
            
        } catch {
            
        }
        
    }
    
    /**
     Set the badged response of the logged in user.  Update is result of API call
     This is used to check for is response badged yes or no
     */
    func setBadgedResponses(userId : String, responses: [String:BadgedResponse]) {
        
        attemptLoggedInDBWrite {
            
            for key in responses.keys {
                
                if let item = responses[key] {
                    
                    let badgedResponse = getBadgedResponse(userId : userId , responseId: key)
                    badgedResponse.badgeTypeIds.removeAll()
                    badgedResponse.badgeTypeIds.append(objectsIn: item.badgeTypeIds)
                    
                }
                
            }
            
        }
        
    }
    
    /**
     Utility function to convert video objects to MaverickMedia and assign them to their responses
     */
    private func assembleResponses(responses responseArray: [Response], videos videoArray : [Video], images imageArray : [Image]) -> List<Response> {
        let blockedUsers = getBlockedUsers()
        let maverickResponses = List<Response>()
        let maverickVideoMedia = processVideos(videos: videoArray)
        let maverickImageMedia = processImages(images: imageArray)
        
        for response in responseArray {
            
            let maverickResponse = getResponse(byId: response.responseId)
            
            maverickResponse.updateBasicResponseData(response)
            if let creator = maverickResponse.getCreator(), blockedUsers.contains( creator ) {
                continue
            }
            
            if let responseBadges = maverickResponse.badges {
                
                maverickResponse.badgeStats.removeAll()
                for value in responseBadges.values {
                    
                    let badge = loggedInUserDataBase.create(BadgeStats.self)
                    badge.setValues(badge: value)
                    maverickResponse.badgeStats.append(badge)
                    
                }
                
            }
            
            if let videoId = response.videoId {
                
                maverickResponse.videoMedia = maverickVideoMedia[videoId]
                
            }
            
            if let imageId = response.imageId {
                
                maverickResponse.imageMedia = maverickImageMedia[imageId]
                
            }
            
            if let coverImageId = response.coverImageId {
                
                maverickResponse.videoCoverImageMedia = maverickImageMedia[coverImageId]
                
            }
            
            if let peekedComments = response.peekComments {
                
                let descriptor = CommentDescriptor()
            
                if let data = peekedComments.data {
                    
                    descriptor.peekedComments.append(objectsIn: addCommentsToRealm(comments: data))
                    
                }
                
                descriptor.numMessages = peekedComments.count ?? 0
                maverickResponse.commentDescriptor = descriptor
            
            }
            
            maverickResponses.append(maverickResponse)

        }
        
        return maverickResponses
        
    }
    
    
    /**
     Aseembles responses and connects them to their videos and user creators.
     Usecase: adding a response to the DB on it's own (from featured or my feed)
     */
    func addResponsesToUsers(owners: [String : User], responses responseArray: [Response], videos videoArray : [Video], images imageArray : [Image] ) -> List<Response> {
        
        let maverickImages = processImages(images: imageArray)
        
        let maverickResponses = assembleResponses(responses: responseArray, videos: videoArray, images: imageArray)
        
        var ownerDictionary = owners
        
        for response in maverickResponses {
            
            guard let ownerId = response.userId, ownerDictionary[ownerId] != nil else { continue }
            let owner = getUser(byId: ownerId)
            if let ownerUpdatedData = ownerDictionary[ownerId] {
                
                owner.updateBasicUserData(ownerUpdatedData)
                
                if let id = ownerUpdatedData.profileImageId {
                    
                    owner.profileImage = maverickImages[id]
                    
                } else {
                    
                    owner.profileImage = nil
                    
                }
                
                if let id = ownerUpdatedData.profileCoverImageId {
                    
                    owner.profileCover = maverickImages[id]
                    
                }
                
            }
            if let index = owner.createdResponses.index(of: response) {
                
                owner.createdResponses[index] = response
                
            } else {
                
                owner.createdResponses.append(response)
                
            }
            
            ownerDictionary[ownerId] = owner
            
        }
        
        return maverickResponses
        
    }
    
    /**
     Adds a list of responses to the user who created them. Also connects the video objects to the response
     */
    func addResponsesToUser(withId userId : String, responses responseArray: [Response], videos videoArray : [Video], images imageArray : [Image], clearPreviousResults: Bool = true) -> List<Response> {
        
        var maverickResponses = List<Response>()
        attemptLoggedInDBWrite {
            
            maverickResponses = assembleResponses(responses: responseArray, videos: videoArray, images: imageArray)
            
            if clearPreviousResults {
                
                getUser(byId: userId).createdResponses.removeAll()
                
            }
            
            getUser(byId: userId).createdResponses.append(objectsIn: maverickResponses)
            
        }
        
        return maverickResponses
        
    }
    
    /**
     Adds a list of responses to the challenge who created them. Also connects the video objects to the response
     */
    func addResponsesToChallenge(withId challengeId : String, owners: [String:User],  challenges : [Challenge], responses responseArray: [Response], videos videoArray : [Video], images imageArray : [Image], clearPreviousResults: Bool = true) {
        
        attemptLoggedInDBWrite {
            
            _ = assembleChallenges(challenges: challenges, videos: videoArray, images: imageArray)
            let maverickResponses = addResponsesToUsers(owners: owners, responses: responseArray, videos: videoArray, images: imageArray)
            
            let challenge = getChallenge(byId: challengeId)
            
            if clearPreviousResults {
                
                challenge.responses.removeAll()
                
            }
            
            for mavResponse in maverickResponses {
           
                if !challenge.responses.contains(mavResponse) {
                
                    challenge.responses.append( mavResponse)
                
                }
            
            }
            
        }
        
    }
    
    func addResponses(owners: [String:User], videos: [Video], images: [Image],  challenges : [Challenge], responses : [Response]) -> List<Response> {
        
        var maverickResponses = List<Response>()
        attemptLoggedInDBWrite {
            
            let challenges = addChallengesToUsers(owners: owners, challenges: challenges, videos: videos, images: images)
            maverickResponses = addResponsesToUsers(owners: owners, responses: responses, videos: videos, images: images)
            linkResponsesToChallenges(challenges: challenges, responses: maverickResponses)
            
        }
        
        return maverickResponses
        
    }
    /**
     Sets the 'My Feed' list for the logged in user.  Builds and adds the responses to the DB and links them to the
     Challenge and users that own them.
     */
    func setMyFeedList(sortOrder : [MultiContentObject], owners: [String:User], videos: [Video], images: [Image],  challenges : [Challenge], responses : [Response], clearPreviousResults: Bool = true) {
        
        attemptLoggedInDBWrite {
            
            let challenges = addChallengesToUsers(owners: owners, challenges: challenges, videos: videos, images: images)
            let responses = addResponsesToUsers(owners: owners, responses: responses, videos: videos, images: images)
            linkResponsesToChallenges(challenges: challenges, responses: responses)
            
            if getLoggedInUser()?.myFeed == nil {
                
                getLoggedInUser()?.myFeed = MultiContentFeed()

            }
            if clearPreviousResults {
                
                getLoggedInUser()?.myFeed?.feed.removeAll()
                getLoggedInUser()?.myFeed?.challenges.removeAll()
                getLoggedInUser()?.myFeed?.responses.removeAll()
                
            }
            
            getLoggedInUser()?.myFeed?.challenges.append(objectsIn: challenges)
            getLoggedInUser()?.myFeed?.responses.append(objectsIn: responses)
            getLoggedInUser()?.myFeed?.feed.append(objectsIn: sortOrder)
            getLoggedInUser()?.myFeed?.feedLastUpdated =  Int(NSDate().timeIntervalSince1970)
            
        }
        
    }
    
    
    func assembleCreatedBadgedResponses(owners: [String:User], videos: [Video], images: [Image],  challenges : [Challenge], responses : [Response]) -> List<Response>? {
        
        var responseResults : List<Response>?
        
        attemptLoggedInDBWrite {
            
            let challenges = addChallengesToUsers(owners: owners, challenges: challenges, videos: videos, images: images)
             responseResults = addResponsesToUsers(owners: owners, responses: responses, videos: videos, images: images)
            linkResponsesToChallenges(challenges: challenges, responses: responseResults!)
         
        }
        
        return responseResults
        
    }
    /**
     Sets the list of responses a given user has badged and assigns the responses to the video content and challenges and users
     that own them
     */
    func setInspirationsList(userId: String, owners: [String:User], videos: [Video], images: [Image],  challenges : [Challenge], responses : [Response], clearPreviousResults: Bool = true) {
        
        
        attemptLoggedInDBWrite {
            
            let challenges = addChallengesToUsers(owners: owners, challenges: challenges, videos: videos, images: images)
            let responses = addResponsesToUsers(owners: owners, responses: responses, videos: videos, images: images)
            linkResponsesToChallenges(challenges: challenges, responses: responses)
            
            if clearPreviousResults {
                
                getUser(byId: userId).badgedResponses.removeAll()
                
            }
            
            getUser(byId: userId).badgedResponses.append(objectsIn: responses)
            
        }
        
    }
    
    func getBadgedResponse(userId : String, responseId: String) -> BadgedResponse {
        
        if let badgedResponse = loggedInUserDataBase.object(ofType: BadgedResponse.self, forPrimaryKey: BadgedResponse.getBadgedResponseId(userId: userId, responseId: responseId)) {
            
            return badgedResponse
            
        } else {
            
            let badgedResponse = BadgedResponse(userId : userId, responseId: responseId, badgeTypeIds: List<String>())
            if loggedInUserDataBase.isInWriteTransaction {
                
                loggedInUserDataBase.add(badgedResponse, update: true)
                
            } else {
                
                attemptLoggedInDBWrite {
                    
                    loggedInUserDataBase.add(badgedResponse, update: true)
                    
                }
                
            }
            
            return badgedResponse
            
        }
        
    }
    
}
