//
//  GlobalModelsCoordinator+Challenges.swift
//  BeMaverick
//
//  Created by David McGraw on 9/18/17.
//  Copyright © 2017 BeMaverick. All rights reserved.
//

import Foundation
import Kingfisher
import RealmSwift

extension GlobalModelsCoordinator {
    
    
    // MARK: - Public Methods
    
     func getEmptyChallenges() -> Results<Challenge> {
     
        return DBManager.sharedInstance.getEmptyChallenges()
        
    }
    /**
     Look for an existing challenge with the provided challenge id
     */
    open func challenge(forChallengeId id: String, fetchDetails : Bool = false) -> Challenge {
        
        if fetchDetails {
            
            apiService.getChallengeDetails(challengeId: id) { (response, error) in
                
                guard let userDictionary = response?.users else { return }
                
                let challengeArray = response?.challenges?.map { $0.value } ?? []
                let videoArray = response?.videos?.map { $0.value } ?? []
                let imageArray = response?.images?.map { $0.value } ?? []
                
                DBManager.sharedInstance.addChallenges(owners: userDictionary, videos: videoArray, images: imageArray,  challenges: challengeArray)
                
                
            }
            
        }
        
        return DBManager.sharedInstance.getChallenge(byId: id)
        
    }
    
    
    /**
     Retrieve the responses for a provided userID
     */
    open func getUserCreatedChallenges(forUserID id: String,
                                      count: Int = 25,
                                      offset: Int = 0,
                                      completionHandler: (() -> Void)? = nil) {
        
        apiService.getUserCreatedChallenges(forUserId: id, count: count, offset: offset) { response in
            
            guard let creator = response?.users?[id] else {
                
                completionHandler?()
                return
                
            }
            var challenges : [Challenge] = []
            let challengeIds = response?.searchResults?.challenges?.challengeIds  ?? []
            
            for challengeId in challengeIds {
                
                if let challenge =  response?.challenges?[challengeId] {
                    
                    challenges.append(challenge)
                    
                }
                
            }

            
            let videos = response?.videos?.map { $0.value } ?? []
            let images = response?.images?.map { $0.value } ?? []
            
            DBManager.sharedInstance.attemptLoggedInDBWrite {
                
                let _ = DBManager.sharedInstance.addUser(userObject: creator, images: images)
                let _ = DBManager.sharedInstance.addChallengesToUser(withId: creator.userId, challenges: challenges, videos: videos, images: images, clearPreviousResults: offset == 0)
                
              
                
                
            }
            completionHandler?()
            
        }
        
    }
    
    /**
     Look for an existing challenge with the provided challenge id
     */
    open func getNoResponseChallenges(forceRefresh : Bool, count: Int = 25, offset : Int = 0, completionHandler: ((_ error: MaverickError?) -> Void)? = nil) -> List<Challenge> {
        
        let stream = DBManager.sharedInstance.getChallengeStream(byId: ConfigurableChallengeStream.NoResponseStreamId)
        
        if !forceRefresh, stream.lastAPIUpdate > ( Int(NSDate().timeIntervalSince1970) - (60 * 60 * feed_expiration_hours) ) {
            print("✅ Skipping: getNoResponseChallenges refresh")
            return stream.items
        }
        
        
            apiService.getChallengesNoResponse(withCount: count, offset: offset) { (response, error) in
                
                if let error = error {
                    
                    completionHandler?(error)
                    return
                
                }
                
                guard let userDictionary = response?.users, let challengeDictionary = response?.challenges else {
                    
                    completionHandler?(nil)
                    return
                    
                }
                
                var challengeArray : [Challenge] = []
                if let sortOrder = response?.searchResults?.challenges?.challengeIds {
                    
                    for index in sortOrder {
                        
                        if let challenge = challengeDictionary[index]
                        {
                            
                            challengeArray.append(challenge)
                            
                        }
                    }
                    
                } else {
                    
                    challengeArray = challengeDictionary.map { $0.value }
                
                }
                
                let videoArray = response?.videos?.map { $0.value } ?? []
                let imageArray = response?.images?.map { $0.value } ?? []
                DBManager.sharedInstance.setNoResponseChallengesStream(owners: userDictionary, videos: videoArray, images: imageArray, challenges: challengeArray, clearPreviousResults: offset == 0)
                
                  completionHandler?(nil)
            }
            
        
        return stream.items
        
    }
    
    /**
     Look for an existing challenge with the provided challenge id
     */
    open func getMyRespondedChallenges(forceRefresh : Bool, count: Int = 25, offset : Int = 0, completionHandler: ((_ error: MaverickError?) -> Void)? = nil) -> List<Challenge> {
        
        let stream = DBManager.sharedInstance.getChallengeStream(byId: ConfigurableChallengeStream.MyRespondedChallengesStreamId)
        
        if !forceRefresh, stream.lastAPIUpdate > ( Int(NSDate().timeIntervalSince1970) - (60 * 60 * feed_expiration_hours) ) {
            print("✅ Skipping: getMyRespondedChallenges refresh")
            return stream.items
        }
        
        
        apiService.getMyRespondedChallenges(withCount: count, offset: offset) { (response, error) in
            
            if let error = error {
                
                completionHandler?(error)
                return
                
            }
            
            guard let userDictionary = response?.users, let challengeDictionary = response?.challenges else {
                
                completionHandler?(nil)
                return
                
            }
            
            var challengeArray : [Challenge] = []
            if let sortOrder = response?.searchResults?.challenges?.challengeIds {
                
                for index in sortOrder {
                    
                    if let challenge = challengeDictionary[index]
                    {
                        
                        challengeArray.append(challenge)
                        
                    }
                }
                
            } else {
                
                challengeArray = challengeDictionary.map { $0.value }
                
            }
            
            let videoArray = response?.videos?.map { $0.value } ?? []
            let imageArray = response?.images?.map { $0.value } ?? []
             DBManager.sharedInstance.setMyRespondedChallengesStream(owners: userDictionary, videos: videoArray, images: imageArray, challenges: challengeArray, clearPreviousResults: offset == 0)
            
            completionHandler?(nil)
        }
        
        return stream.items
        
    }
    
    
    
    
    /**
     Look for an existing challenge with the provided challenge id
     */
    open func getLinkChallenges(forceRefresh : Bool, count: Int = 25, offset : Int = 0, completionHandler: ((_ error: MaverickError?) -> Void)? = nil) -> List<Challenge> {
        
        let stream = DBManager.sharedInstance.getChallengeStream(byId: ConfigurableChallengeStream.LinkChallengesStreamId)
        
        if !forceRefresh, stream.lastAPIUpdate > ( Int(NSDate().timeIntervalSince1970) - (60 * 60 * feed_expiration_hours) ) {
            print("✅ Skipping: getLinkChallenges refresh")
            return stream.items
        }
        
        
        apiService.getLinkChallenges(withCount: count, offset: offset) { (response, error) in
            
            if let error = error {
                
                completionHandler?(error)
                return
                
            }
            
            guard let userDictionary = response?.users, let challengeDictionary = response?.challenges else {
                
                DBManager.sharedInstance.setLinkChallengesStream(owners: [:], videos: []  , images: [], challenges: [], clearPreviousResults: offset == 0)
                completionHandler?(nil)
                return
                
            }
            
            var challengeArray : [Challenge] = []
            if let sortOrder = response?.searchResults?.challenges?.challengeIds {
                
                for index in sortOrder {
                    
                    if let challenge = challengeDictionary[index]
                    {
                        
                        challengeArray.append(challenge)
                        
                    }
                    
                }
                
            } else {
                
                challengeArray = challengeDictionary.map { $0.value }
                
            }
            
            let videoArray = response?.videos?.map { $0.value } ?? []
            let imageArray = response?.images?.map { $0.value } ?? []
            DBManager.sharedInstance.setLinkChallengesStream(owners: userDictionary, videos: videoArray, images: imageArray, challenges: challengeArray, clearPreviousResults: offset == 0)
            
            completionHandler?(nil)
        }
        
        return stream.items
        
    }
    
    /**
     Look for an existing challenge with the provided challenge id
     */
    open func getMyInvitedChallenges(forceRefresh : Bool, count: Int = 25, offset : Int = 0, completionHandler: ((_ error: MaverickError?) -> Void)? = nil) -> List<Challenge> {
        
        let stream = DBManager.sharedInstance.getChallengeStream(byId: ConfigurableChallengeStream.MyInvitedChallengesStreamId)
        
        if !forceRefresh, stream.lastAPIUpdate > ( Int(NSDate().timeIntervalSince1970) - (60 * 60 * feed_expiration_hours) ) {
            print("✅ Skipping: getMyInvitedChallenges refresh")
            return stream.items
        }
        
        
        apiService.getMyInvitedChallenges(withCount: count, offset: offset) { (response, error) in
            
            if let error = error {
                
                completionHandler?(error)
                return
                
            }
            
            guard let userDictionary = response?.users, let challengeDictionary = response?.challenges else {
                
                DBManager.sharedInstance.setMyInvitedChallengesStream(owners: [:], videos: []  , images: [], challenges: [], clearPreviousResults: offset == 0)
                completionHandler?(nil)
                return
                
            }
            
            var challengeArray : [Challenge] = []
            if let sortOrder = response?.searchResults?.challenges?.challengeIds {
                
                for index in sortOrder {
                    
                    if let challenge = challengeDictionary[index]
                    {
                        
                        challengeArray.append(challenge)
                        
                    }
                
                }
                
            } else {
                
                challengeArray = challengeDictionary.map { $0.value }
                
            }
            
            let videoArray = response?.videos?.map { $0.value } ?? []
            let imageArray = response?.images?.map { $0.value } ?? []
            DBManager.sharedInstance.setMyInvitedChallengesStream(owners: userDictionary, videos: videoArray, images: imageArray, challenges: challengeArray, clearPreviousResults: offset == 0)
            
            completionHandler?(nil)
        }
        
        return stream.items
        
    }
    
    
    /**
     Retrieve the trending challenges.
     */
    @discardableResult
    open func getTrendingChallenges(versionNumber : Int, forceRefresh: Bool, count: Int = 25, offset : Int = 0, completionHandler: ((_ error: MaverickError?) -> Void)? = nil) -> List<Challenge> {
        
        let stream = DBManager.sharedInstance.getChallengeStream(byId: "\(ConfigurableChallengeStream.TrendingChallengesStreamId)_\(versionNumber)")
        
        if !forceRefresh, stream.lastAPIUpdate > ( Int(NSDate().timeIntervalSince1970) - (60 * 60 * feed_expiration_hours) ) {
            print("✅ Skipping: getTrendingChallenges refresh")
            return stream.items
        }
        
        
        apiService.getTrendingChallenges(versionNumber : versionNumber, withCount: count, offset: offset) { (response, error) in
            
            if let error = error {
                
                completionHandler?(error)
                return
                
            }
            
            guard let userDictionary = response?.users, let challengeDictionary = response?.challenges else {
                
                completionHandler?(nil)
                return
                
            }
            
            var challengeArray: [Challenge] = []
            if let sortOrder = response?.searchResults?.challenges?.challengeIds {
                
                for index in sortOrder {
                    
                    if let challenge = challengeDictionary[index]
                    {
                        
                        challengeArray.append(challenge)
                        
                    }
                }
                
            } else {
                
                challengeArray = challengeDictionary.map { $0.value }
                
            }
            
            let videoArray = response?.videos?.map { $0.value } ?? []
            let imageArray = response?.images?.map { $0.value } ?? []
            DBManager.sharedInstance.setTrendingChallengesStream(owners: userDictionary, videos: videoArray, images: imageArray, challenges: challengeArray, versionNumber: versionNumber, clearPreviousResults: offset == 0)
            
            completionHandler?(nil)
        }
        
        return stream.items
        
    }
    
    /**
     Edits an existing challenge
     
     */
    open func editChallenge(challengeId id: String,
                            title: String?,
                            mentions: [String]?,
                            description: String?,
                            linkUrl : String?,
                            completionHandler: @escaping (_ error: MaverickError?) -> Void)
    {
        
        var mentionsASV : String? = nil
        if let mentions = mentions {
         
            mentionsASV = "@\(mentions.joined(separator: "@"))"
        
        }
        
        apiService.editChallenge(challengeId: id, title: title, mentions: mentionsASV, description: description, linkUrl: linkUrl) { (response, error) in
            
            if let error = error {
                
                completionHandler(error)
                return
                
            }
            guard response != nil else {
                
                completionHandler(nil)
                return
                
            }
            
            DispatchQueue.main.async {
                
                DBManager.sharedInstance.attemptLoggedInDBWrite {
                    
                    
                    let challenge = DBManager.sharedInstance.getChallenge(byId: id)
                    
                    challenge.label = description
                    challenge.title = title
                    challenge.linkURL = linkUrl
                    if let challengeFromApi = response?.challenges?[challenge.challengeId] {
                        
                        challenge.mentionUserIds.removeAll()
                        challenge.mentionUserIds.append(objectsIn: challengeFromApi.mentionUserIds)
                        
                    }
                    
                }
                
            }
            
            completionHandler(nil)
            
        }
        
    }
    
    /**
     Retrieve the available challenges
     */
    open func getChallenges(withCount count: Int = 25,
                            offset: Int = 0,
                            forceRefresh : Bool,
                            downloadAssets : Bool,
                            status: Constants.MaverickChallengeStatus = .active,
                            
                            featuredType: Constants.ChallengeFeaturedType,
                            completionHandler: ((_ error: MaverickError?) -> Void)? = nil)
    {
        
        if !forceRefresh, let timeStamp = loggedInUser?.availableChallengesLastUpdate, timeStamp > ( Int(NSDate().timeIntervalSince1970) - (60 * 60 * feed_expiration_hours) ) {
            print("✅ Skipping: CHALLENGES TAB refresh")
            return
        }
        print("✅ executing: CHALLENGES TAB refresh")

        
        apiService.getChallenges(withCount: count, offset: offset, status: status, featuredType : featuredType) { response, error in
            
            guard error == nil else {
                completionHandler?(error)
                return
            }
           
            guard let userDictionary = response?.users, let challengeDictionary = response?.challenges, let sortOrder = response?.searchResults?.challenges?.challengeIds else {
                
                 completionHandler?(nil)
                return
                
            }
            
            var challengeArray : [Challenge] = []
            for index in sortOrder {
                
                if let challenge = challengeDictionary[index]
                {
                    
                    challengeArray.append(challenge)
                    
                }
            }
            
            let videoArray = response?.videos?.map { $0.value } ?? []
            let imageArray = response?.images?.map { $0.value } ?? []
        
            if featuredType == .challengeStream {
                
                DBManager.sharedInstance.setChallengesList(owners: userDictionary, videos: videoArray,images: imageArray,  challenges: challengeArray, clearPreviousResults : offset == 0)
                
            } else if featuredType == .maverickStream {
                
                DBManager.sharedInstance.setFeaturedChallengesList(owners: userDictionary, videos: videoArray,images: imageArray,  challenges: challengeArray, clearPreviousResults : offset == 0)
                
            }
            
            completionHandler?(nil)
            
            if downloadAssets {
                
                var imageURLs : [URL] = []
               
                for i in 0 ..< min( 4, challengeArray.count) {
                    
                    if let apiChallenge = challengeArray[safe: i] {
                        
                        let challenge = self.challenge(forChallengeId: apiChallenge.challengeId)
                        
                        VideoPlayerView.prefetchVideo(media: challenge.videoMedia)
                        
                        if let url = FeaturedChallenges.pathForImage(forItem: challenge) {
                            
                            imageURLs.append(url)
                            
                        }
                    }
                    
                }
                
                ImagePrefetcher(urls: imageURLs) {  skippedResources, failedResources, completedResources in
                    
                    if ImagePrefetcher.logOn {
                        print("🎥 prefetching  Complete for challenges \(featuredType)")
                        print("🎥 : skippedResources : \(skippedResources.count)")
                        print("🎥 : failedResources : \(failedResources)")
                        for resource in failedResources {
                            print("🎥 : failedResource \(resource.downloadURL)")
                        }
                        print("🎥 : completedResources : \(completedResources.count)")
                    }
                    
                    }.start()
                
            }
            
        }
        
    }
    
    /**
     Deletes a challenge and refreshes the user data
     */
    open func deleteChallenge(forChallenge challenge: Challenge) {
        
        guard let intId = Int(challenge.challengeId) else { return }
        
        apiService.deleteChallenge(forChallengeId: intId) { _, _ in
            
        }
        
        // TODO: we should fix this at some point... the challenge should only be deleted from the persistent store once we receive the object back from the api service confirming it's been deleted so that we don't get into a potentially inconsistent state
        DBManager.sharedInstance.deleteChallenge(challenge: challenge)
        
    }
    
    // MARK: - Private Methods
    
  
    
}
