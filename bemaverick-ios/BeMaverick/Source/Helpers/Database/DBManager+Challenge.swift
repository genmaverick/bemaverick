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
     Fetches a challenge from the realm if it exists.
     If it doesn't, it will create a new object with the challengeId and add it to the realm.
     All subsequent edits to the object must be made in a write transaction
     */
    func getChallenge(byId challengeId: String) -> Challenge {
        
        if let challenge = loggedInUserDataBase.object(ofType: Challenge.self, forPrimaryKey: challengeId) {
            
            return challenge
            
        } else {
            
            let challenge = Challenge(challengeId: challengeId)
            if loggedInUserDataBase.isInWriteTransaction {
                
                loggedInUserDataBase.add(challenge, update: true)
                
            } else {
                
                attemptLoggedInDBWrite {
                    
                    loggedInUserDataBase.add(challenge, update: true)
                    
                }
                
            }
            
            return challenge
            
        }
        
    }
    
    /**
     Creates a new response object and adds it to the logged in user
     */
    func addNewCreatedChallenge(challenge : [Challenge], video : [Video], image : [Image]) {
        
        attemptLoggedInDBWrite {
            
            let challengeArray = assembleChallenges(challenges: challenge, videos: video, images: image)
            
            
            if let challengeToAdd = challengeArray.first {
                
                getLoggedInUser()?.createdChallenges.insert(challengeToAdd, at: 0)
                getLoggedInUser()?.availableChallenges.insert(challengeToAdd, at: 0)
                
                    getLoggedInUser()?.ownedChallenges.insert(challengeToAdd, at: 0)
            
            }
                
            
        }
        
    }
    
    
    /**
     Utility function to convert videos to MaverickMedia objects and assign to the given challenges
     */
    func assembleChallenges(challenges challengeArray: [Challenge], videos videoArray : [Video], images imageArray : [Image] ) -> List<Challenge> {
        
        let maverickChallenges = List<Challenge>()
        let maverickImageMedia = processImages(images: imageArray)
        let maverickVideoMedia = processVideos(videos: videoArray)
        let blockedUsers = getBlockedUsers()
        
        for challenge in challengeArray {
            
            if let creator = challenge.getCreator(), blockedUsers.contains( creator ) {
                continue
            }
            let maverickChallenge = getChallenge(byId: challenge.challengeId)
            maverickChallenge.updateBasicData(challenge)
            
            if let videoId = challenge.videoId {
                
                maverickChallenge.videoMedia = maverickVideoMedia[videoId]
                
            }
            
            if let intID = challenge.cardImageId {
                
                let imageId = String(intID)
                maverickChallenge.mainCardMedia = maverickImageMedia[imageId]
                
            }
            
            if let intID = challenge.mainImageId {
                
                let imageId = String(intID)
                maverickChallenge.mainImageMedia = maverickImageMedia[imageId]
                
            }
            
            if let intID = challenge.imageChallengeId {
                
                let imageId = String(intID)
                maverickChallenge.imageChallengeMedia = maverickImageMedia[imageId]
                
            }
            
            if let peekedComments = challenge.peekComments {
                
                let descriptor = CommentDescriptor()
                
                if let data = peekedComments.data {
                    
                    descriptor.peekedComments.append(objectsIn: addCommentsToRealm(comments: data))
                    
                }
                
                descriptor.numMessages = peekedComments.count ?? 0
                maverickChallenge.commentDescriptor = descriptor
                
            }
           
            maverickChallenges.append(maverickChallenge)
            
        }
        
        return maverickChallenges
        
    }
    
   
    
    /**
     Assigns videos to challenges and challenges to their creators so everything is all linked in the DB
     Usecase: adding a challenge to the DB on it's own (from saved challenges)
     */
    func addChallengesToUsers(owners: [String : User], challenges challengeArray: [Challenge], videos videoArray : [Video], images imageArray : [Image] ) -> List<Challenge> {
        
        let maverickImages = processImages(images: imageArray)
        let maverickChallenges = assembleChallenges(challenges: challengeArray, videos: videoArray, images: imageArray)
        
        for challenge in maverickChallenges {
            
            guard let ownerId = challenge.userId else { continue }
            let owner = getUser(byId: ownerId)
            if let ownerUpdatedData = owners[ownerId] {
                
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
            
            if let index = owner.ownedChallenges.index(of: challenge) {
                
                owner.ownedChallenges[index] = challenge
                
            } else {
                
                owner.ownedChallenges.append(challenge)
                
            }
            
            
            loggedInUserDataBase.add(owner, update: true)
      
        }
        
        return maverickChallenges
    }
    
    /**
     Usecase: fetching a list of challenges created by a user
     */
    func addChallengesToUser(withId userId : String, challenges challengeArray: [Challenge], videos videoArray : [Video], images imageArray : [Image], clearPreviousResults: Bool = true) {
        
        attemptLoggedInDBWrite {
            
            let maverickChallenges = assembleChallenges(challenges: challengeArray, videos: videoArray, images: imageArray)
            
            if clearPreviousResults {
                
                getUser(byId: userId).createdChallenges.removeAll()
                
            }
            
            for challenge in maverickChallenges {
                
                if challenge.userId == userId {
                
                    let creator =  getUser(byId: userId)
                        
                   creator.createdChallenges.append(challenge)
                
                    if let index = creator.ownedChallenges.index(of: challenge) {
                        
                        creator.ownedChallenges[index] = challenge
                        
                    } else {
                        
                        creator.ownedChallenges.append(challenge)
                        
                    }
                    
                }
            
            }
            
        }
        
    }
    
    /**
     Function to see if logged in user has responded to the given challenge
     */
    func isChallengeResponded(challengeId: String)  -> Bool {
        
        if let me = getLoggedInUser() {

            let foundCreatedResponse = me.createdResponses.filter("challengeId = %@", challengeId).first != nil
            let foundInList = getChallengeStream(byId: ConfigurableChallengeStream.MyRespondedChallengesStreamId).items.contains(getChallenge(byId: challengeId))
            
            return foundInList || foundCreatedResponse

        }
        return false
        
    }
    
    func getEmptyChallenges() -> Results<Challenge> {
        
        return loggedInUserDataBase.objects(Challenge.self).filter("numResponses = %@", 0)
        
    }
    
    /**
     simply adds given challenges to DB
     */
    func addChallenges(owners: [String:User], videos: [Video], images imageArray : [Image], challenges : [Challenge]) -> List<Challenge>? {
       
        var challengeList : List<Challenge>?
        attemptLoggedInDBWrite {
            
             challengeList = addChallengesToUsers(owners: owners, challenges: challenges, videos: videos, images: imageArray)
        
        }
        
        return challengeList
        
    }
    
    /**
     Sets the available challenges list for the logged in user, used to populate the third tab on the main UI
     also assigns the video to the challenges and links them to their creator user objects
     */
    func setChallengesList(owners: [String:User], videos: [Video], images imageArray : [Image], challenges : [Challenge], clearPreviousResults: Bool = true) {
        
        attemptLoggedInDBWrite {
            
            let challenges = addChallengesToUsers(owners: owners, challenges: challenges, videos: videos, images: imageArray)
          
           
            
            if clearPreviousResults {
                
                  getLoggedInUser()?.availableChallenges.removeAll()
                
            }
            
            getLoggedInUser()?.availableChallenges.append(objectsIn: challenges)
            getLoggedInUser()?.availableChallengesLastUpdate =  Int(NSDate().timeIntervalSince1970)
            
        }
        
    }
    
    /**
     Sets the challenges list with no responses
     */
    func setNoResponseChallengesStream(owners: [String:User], videos: [Video], images imageArray : [Image], challenges : [Challenge], clearPreviousResults: Bool = true) {
        
        attemptLoggedInDBWrite {
            
            let challenges = addChallengesToUsers(owners: owners, challenges: challenges, videos: videos, images: imageArray)
            
            let stream = getChallengeStream(byId: ConfigurableChallengeStream.NoResponseStreamId)
            if clearPreviousResults {
                
                stream.items.removeAll()
                
                
            }
            
            stream.items.append(objectsIn: challenges)
            stream.lastAPIUpdate =  Int(NSDate().timeIntervalSince1970)
            
        }
        
    }
    
    /**
     Sets the my responded challenges list
     */
    func setMyRespondedChallengesStream(owners: [String:User], videos: [Video], images imageArray : [Image], challenges : [Challenge], clearPreviousResults: Bool = true) {
        
        attemptLoggedInDBWrite {
            
            let challenges = addChallengesToUsers(owners: owners, challenges: challenges, videos: videos, images: imageArray)
            
            let stream = getChallengeStream(byId: ConfigurableChallengeStream.MyRespondedChallengesStreamId)
            if clearPreviousResults {
                
                stream.items.removeAll()
                
                
            }
            
            stream.items.append(objectsIn: challenges)
            stream.lastAPIUpdate =  Int(NSDate().timeIntervalSince1970)
            
        }
        
    }
    
    /**
     Sets the my responded challenges list
     */
    func setMyInvitedChallengesStream(owners: [String:User], videos: [Video], images imageArray : [Image], challenges : [Challenge], clearPreviousResults: Bool = true) {
        
        attemptLoggedInDBWrite {
            
            let challenges = addChallengesToUsers(owners: owners, challenges: challenges, videos: videos, images: imageArray)
            
            let stream = getChallengeStream(byId: ConfigurableChallengeStream.MyInvitedChallengesStreamId)
            if clearPreviousResults {
                
                stream.items.removeAll()
                
                
            }
            
            stream.items.append(objectsIn: challenges)
            stream.lastAPIUpdate =  Int(NSDate().timeIntervalSince1970)
            
        }
        
    }
    
    /**
     Sets the linked challenges list
     */
    func setLinkChallengesStream(owners: [String:User], videos: [Video], images imageArray : [Image], challenges : [Challenge], clearPreviousResults: Bool = true) {
        
        attemptLoggedInDBWrite {
            
            let challenges = addChallengesToUsers(owners: owners, challenges: challenges, videos: videos, images: imageArray)
            
            let stream = getChallengeStream(byId: ConfigurableChallengeStream.LinkChallengesStreamId)
            if clearPreviousResults {
                
                stream.items.removeAll()
                
                
            }
            
            stream.items.append(objectsIn: challenges)
            stream.lastAPIUpdate =  Int(NSDate().timeIntervalSince1970)
            
        }
        
    }
    
    /**
     Sets the challenges list for trending challenges
     */
    func setTrendingChallengesStream(owners: [String:User], videos: [Video], images imageArray : [Image], challenges : [Challenge], versionNumber : Int, clearPreviousResults: Bool = true) {
        
        attemptLoggedInDBWrite {
            
            let challenges = addChallengesToUsers(owners: owners, challenges: challenges, videos: videos, images: imageArray)
            
            let stream = getChallengeStream(byId: "\(ConfigurableChallengeStream.TrendingChallengesStreamId)_\(versionNumber)")
            
            if clearPreviousResults {
                stream.items.removeAll()
            }
            
            stream.items.append(objectsIn: challenges)
            stream.lastAPIUpdate =  Int(NSDate().timeIntervalSince1970)
            
        }
        
    }
    
    /**
     Sets the available challenges list for the logged in user, used to populate the third tab on the main UI
     also assigns the video to the challenges and links them to their creator user objects
     */
    func setFeaturedChallengesList(owners: [String:User], videos: [Video], images imageArray : [Image], challenges : [Challenge], clearPreviousResults: Bool = true) {
        
        attemptLoggedInDBWrite {
            
            let challenges = addChallengesToUsers(owners: owners, challenges: challenges, videos: videos, images: imageArray)
            
            if clearPreviousResults {
                
                getLoggedInUser()?.featuredChallenges.removeAll()
                
            }
            
            getLoggedInUser()?.featuredChallenges.append(objectsIn: challenges)
            
        }
        
    }
    
    /**
     Sets the saved challenges items for the logged in user.
     Also assembles the challenge objects with videos and links to their owners in the DB
     */
    func setSavedChallengesList(items: [Challenge], videos : [Video], images: [Image], owners: [String : User], clearPreviousResults: Bool = true) {
        
        attemptLoggedInDBWrite {
            
            let maverickChallenges = addChallengesToUsers(owners: owners, challenges: items, videos: videos, images: images)
            
            if clearPreviousResults {
                
                getLoggedInUser()?.savedChallenges.removeAll()
                
            }
            
            getLoggedInUser()?.savedChallenges.append(objectsIn: maverickChallenges)
            
        }
        
    }
    
    /**
     Deletes a challenge object
     */
    func deleteChallenge(challenge: Challenge) {
        
        attemptLoggedInDBWrite {
            
            loggedInUserDataBase.delete(challenge)
            
        }
        
    }
    
}
