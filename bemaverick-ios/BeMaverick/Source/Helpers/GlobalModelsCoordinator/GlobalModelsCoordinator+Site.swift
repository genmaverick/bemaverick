//
//  GlobalModelsCoordinator+Site.swift
//  BeMaverick
//
//  Created by David McGraw on 1/18/18.
//  Copyright © 2018 BeMaverick. All rights reserved.
//

import Foundation
import Kingfisher
import RealmSwift

extension GlobalModelsCoordinator {
    
    // MARK: - Public Methods
    
    
    func getMaverickStream() -> MaverickFeed {
        
       return DBManager.sharedInstance.getMaverickStream()
        
    }

    
    /**
     Retrieves the "Maverick Stream" feed which contains a variety of responses
     and challenges
     
     - parameter count:     The amount of content to fetch
     - parameter offset:    The offset to the fetched amount
     - parameter completionHandler: An array of tuples containing the type and id of the content
     */
    open func refreshMaverickStream(forceRefresh: Bool, downloadAssets : Bool = false, completionHandler: ((_ streams: MaverickFeed) -> Void)? = nil) {

        
        // If timestamp less than 24 hours old then return and don't refresh
        if !forceRefresh && getMaverickStream().lastAPIRequest > ( Int(NSDate().timeIntervalSince1970) - (60 * 60 * feed_expiration_hours) ) {
            print("✅ Skipping: featured refresh")
            return
        }
        print("✅ executing: featured refresh")
        
        apiService.getMaverickStream() { response in
     
            guard var objectIds = response?.order, let streamsDictionary = response?.streams else {
                completionHandler?(DBManager.sharedInstance.getMaverickStream())
                return
            }
        
            print("✅ list before : \(objectIds)")
            let overrideCount = Variables.Content.featuredStreamOrderOverride.count()
            for i in 0 ..< overrideCount {
                
                if let item = Variables.Content.featuredStreamOrderOverride.object(at: overrideCount - i - 1) as? String {
                    
                    if streamsDictionary[item] != nil {
                        
                        if let index = objectIds.index(of: item) {
                            
                            objectIds.remove(at: index)
                            
                        }
                        
                        objectIds.insert(item, at: 0)
                        
                    }
                    
                }
                
            }
            print("✅ list after : \(objectIds)")
            var objects: [Stream] = []
            
            for item in objectIds {
                
                
                if let stream = streamsDictionary[item] {
                
                    guard stream.label != nil else { continue }
                    
                    let queryKeys = List<String>()
                    let queryValues = List<String>()
                    if let queries = stream.query {
                      
                        stream.queryKeys = List<String>()
                        for key in queries.keys {
                            
                            if !Stream.ignoredQueryParams.contains(key), let value = queries[key] as? String  {
                            
                                queryKeys.append(key)
                                queryValues.append(value)
                            
                            }
                            
                        }
                     
                        stream.queryValues = queryValues
                        stream.queryKeys = queryKeys
                    
                    }
                    
                    objects.append(stream)
                    
                }
               
            }
            
            let feed = DBManager.sharedInstance.setMaverickStream(streams: objects)
            
            if downloadAssets {
                
                for stream in feed.streams {
                    
                    switch stream.type {
                        
                    case .advertisement:
                        
                        if let path = self.getAdvertisementStream(by: stream.id).imageMedia?.URLOriginal, let url = URL(string: path) {
                       
                            
                            ImagePrefetcher(urls: [url]) { skippedResources, failedResources, completedResources in
                                
                                if ImagePrefetcher.logOn {
                                    print("🎥 prefetching ADVERTISEMENT Complete")
                                    print("🎥 ADVERTISEMENT : skippedResources : \(skippedResources.count)")
                                    print("🎥 ADVERTISEMENT : failedResources : \(failedResources)")
                                    for resource in failedResources {
                                        print("🎥 ADVERTISEMENT : failedResource \(resource.downloadURL)")
                                    }
                                    print("🎥 ADVERTISEMENT : completedResources : \(completedResources.count)")
                                }
                                
                                }.start()

                        }
                       
                        
                    case .challenge :
                        
                        let configStream = self.getChallengeStream(by: stream.id)
                        self.getConfigurableSteam(stream: configStream, downloadAssets: downloadAssets, forceRefresh: true)
                        
                    case .response:
                        
                        let configStream = self.getResponseStream(by: stream.id)
                        self.getConfigurableSteam(stream: configStream, downloadAssets: downloadAssets, forceRefresh: true)
                        
                    }
                    
                }
                
            }
            
            completionHandler?(feed)
            
        }
        
    }
    
    
    /**
     Retrieves the "Configuratble Stream" feed which contains a variety of responses
     and challenges
     
     - parameter count:     The amount of content to fetch
     - parameter offset:    The offset to the fetched amount
     - parameter completionHandler: An array of tuples containing the type and id of the content
     */
    open func getConfigurableSteam(stream: Stream, downloadAssets : Bool = false, forceRefresh : Bool, count : Int = 20, offset : Int = 0, completionHandler: (() -> Void)? = nil) {
        
        
        if offset == 0 {
            if !forceRefresh, stream.lastAPIUpdate > ( Int(NSDate().timeIntervalSince1970) - (60 * 60 * feed_expiration_hours) ) {
                print("✅ Skipping: getConfigurableSteam: \(stream.label ?? stream.streamId) refresh")
                return
                
            }
        }
        print("✅ executing: getConfigurableSteam: \(stream.label ?? stream.streamId) refresh")
        
        apiService.getConfigurableStream(stream: stream, count : count, offset : offset) {[weak self] response in
            
            guard let response = response else { return }
            
            if let challengeId = stream.challengeId, challengeId != "" {
                
                let _ = self?.challenge(forChallengeId: challengeId, fetchDetails: true)
            
            }
            
            let owners = response.users ?? [:]

            var responseArray = response.responses?.map { $0.value } ?? []
            let videoArray = response.videos?.map { $0.value } ?? []
            let imageArray = response.images?.map { $0.value } ?? []
            var challengeArray = response.challenges?.map { $0.value } ?? []
            
            if let responseIds = response.searchResults?.responses?.responseIds  {
                
                responseArray.removeAll()
                for id in responseIds {
                
                    if let response = response.responses?[id] {
                    
                        responseArray.append(response)
                    
                    }
                
                }
                
            }
            
            if let challengeIds = response.searchResults?.challenges?.challengeIds  {
                
                challengeArray.removeAll()
                for id in challengeIds {
                    
                    if let challenge = response.challenges?[id] {
                        
                        challengeArray.append(challenge)
                        
                    }
                    
                }
                
            }
            
            DBManager.sharedInstance.setConfigurableStream(originStream: stream,  owners: owners, videos: videoArray, images: imageArray, challenges: challengeArray, responses: responseArray, clearPreviousResults: offset == 0)
          
            if downloadAssets {
                
                var imageURLs : [URL] = []
                for i in 0 ..< min( 4, responseArray.count) {
                    
                    if let apiResponse = responseArray[safe: i], let response = self?.response(forResponseId: apiResponse.responseId) {
                        
                        VideoPlayerView.prefetchVideo(media: response.videoMedia)
                        
                        if let url = FeaturedResponses.pathForImage(forItem: response) {
                            
                            imageURLs.append(url)
                            
                        }
                        
                    }
                    
                }
                
                
                for i in 0 ..< min( 4, challengeArray.count) {
                    
                    if let apiChallenge = challengeArray[safe: i], let challenge = self?.challenge(forChallengeId: apiChallenge.challengeId) {
                        
                        VideoPlayerView.prefetchVideo(media: challenge.videoMedia)
                        
                        if let url = FeaturedChallenges.pathForImage(forItem: challenge) {
                            
                            imageURLs.append(url)
                            
                        }
                        
                    }
                    
                }
                
                ImagePrefetcher(urls: imageURLs) {  skippedResources, failedResources, completedResources in
                    
                    if ImagePrefetcher.logOn {
                        print("🎥 prefetching  Complete for \(stream.label ?? stream.streamId)")
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
        
        }
   
    }
    
    func getChallengeStream(by id : String) -> ConfigurableChallengeStream {
        
        return DBManager.sharedInstance.getChallengeStream(byId:id)
        
    }
    
    func getResponseStream(by id : String) -> ConfigurableResponseStream {
        
        return DBManager.sharedInstance.getResponseStream(byId: id)
        
    }
    
    func getAdvertisementStream(by id : String) -> ConfigurableAdvertisementStream {
        
        return DBManager.sharedInstance.getAdvertisementStream(byId: id)
        
    }
    
    func getStreamType(by id : String) -> Constants.FeaturedStreamType {
        
        return DBManager.sharedInstance.getStreamType(byId: id)
        
    }
    
}
