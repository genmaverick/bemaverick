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
    
    
    func getStreamType(byId id : String) -> Constants.FeaturedStreamType {
        
        if  getResponseStream(byId: id).label != nil {
            return .response
        }
        if  getChallengeStream(byId: id).label != nil {
            return .challenge
        }
        if  getAdvertisementStream(byId: id).label != nil {
            return .advertisement
        }
        return .response
    }
    
    func getResponseStream(byId streamId : String) -> ConfigurableResponseStream {
        
        if let stream = loggedInUserDataBase.object(ofType: ConfigurableResponseStream.self, forPrimaryKey: streamId) {
            
            return stream
            
        } else {
            
            let stream = ConfigurableResponseStream(streamId: streamId)
            
            if loggedInUserDataBase.isInWriteTransaction {
                
                loggedInUserDataBase.add(stream, update: false)
                
            } else {
                
                attemptLoggedInDBWrite {
                    
                    loggedInUserDataBase.add(stream, update: false)
                    
                }
                
            }
            
            return stream
            
        }
        
    }
    
    func getChallengeStream(byId streamId: String) -> ConfigurableChallengeStream {
        
        
            if let stream = loggedInUserDataBase.object(ofType: ConfigurableChallengeStream.self, forPrimaryKey: streamId) {
                
                return stream
                
            } else {
                
                let  stream = ConfigurableChallengeStream(streamId: streamId)
                
                if loggedInUserDataBase.isInWriteTransaction {
                    
                    loggedInUserDataBase.add(stream, update: true)
                    
                } else {
                    
                    attemptLoggedInDBWrite {
                        
                        loggedInUserDataBase.add(stream, update: true)
                        
                    }
                    
                }
                
                return stream
                
            }
            
       
      
        
    }
    
    func getAdvertisementStream(byId streamId: String) -> ConfigurableAdvertisementStream {
        
        
        if let stream = loggedInUserDataBase.object(ofType: ConfigurableAdvertisementStream.self, forPrimaryKey: streamId) {
            
            return stream
            
        } else {
            
            let  stream = ConfigurableAdvertisementStream(streamId: streamId)
            
            if loggedInUserDataBase.isInWriteTransaction {
                
                loggedInUserDataBase.add(stream, update: true)
                
            } else {
                
                attemptLoggedInDBWrite {
                    
                    loggedInUserDataBase.add(stream, update: true)
                    
                }
                
            }
            
            return stream
            
        }
        
        
    }
    
    func setConfigurableStream(originStream : Stream, owners: [String:User], videos: [Video], images: [Image],  challenges : [Challenge], responses : [Response], clearPreviousResults: Bool) {
        
        attemptLoggedInDBWrite {
            
            let challenges = addChallengesToUsers(owners: owners, challenges: challenges, videos: videos, images: images)
            let responses = addResponsesToUsers(owners: owners, responses: responses, videos: videos, images: images)
            linkResponsesToChallenges(challenges: challenges, responses: responses)
            
            switch originStream.getContentType() {
            case .advertisement:
                
                break
                
            case .challenge:
                
                let stream = getChallengeStream(byId: originStream.streamId)
                if clearPreviousResults {
                    stream.items.removeAll()
                }
                stream.items.append(objectsIn: challenges)
                stream.lastAPIUpdate =  Int(NSDate().timeIntervalSince1970)
                
            case .response:
                let stream = getResponseStream(byId: originStream.streamId)
                
                if clearPreviousResults {
                    stream.items.removeAll()
                }
                if let challengeId = stream.challengeId, challengeId != "" {
                
                    stream.challenge = getChallenge(byId: challengeId)
                
                } else {
                    
                    stream.challenge = nil
                
                }
                
                stream.items.append(objectsIn: responses)
                
                stream.lastAPIUpdate = Int(NSDate().timeIntervalSince1970)
                
                
            }

            
        }
        
    }
    
    func setMaverickStream(streams : [Stream]) -> MaverickFeed {
        
        let feed = getMaverickStream()
        
        attemptLoggedInDBWrite {
            
            feed.streams.removeAll()
            for stream in streams {
                
                switch stream.getContentType() {
                    
                case .advertisement:
                    let realmStream = getAdvertisementStream(byId: stream.streamId)
                   
                    realmStream.update(data: stream)
                    if let image = stream.image {
                        
                        realmStream.imageMedia = processImages(images: [image])[image.imageId]
                    
                    }
                    feed.streams.append(MultiContentObject(type: stream.getContentType(), id: stream.streamId))
                    
                case .response:
                    
                    let realmStream = getResponseStream(byId: stream.streamId)
                    realmStream.update(data: stream)
                    
                    feed.streams.append(MultiContentObject(type: stream.getContentType(), id: stream.streamId))
                    
                case .challenge:
                    
                    let realmStream = getChallengeStream(byId: stream.streamId)
                    realmStream.update(data: stream)
                    
                    feed.streams.append(MultiContentObject(type: stream.getContentType(), id: stream.streamId))
                    
                }
                
                
            }
         
            feed.lastAPIRequest = Int(NSDate().timeIntervalSince1970)
            
        }
        
        
        return feed
        
    }
}
