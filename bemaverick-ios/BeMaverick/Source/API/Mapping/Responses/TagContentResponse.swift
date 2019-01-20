//
//  CommentResponse.swift
//  BeMaverick
//
//  Created by David McGraw on 1/24/18.
//  Copyright © 2018 BeMaverick. All rights reserved.
//

import Foundation
import RealmSwift
import ObjectMapper

public struct TagContentResponse: Mappable {
    
    
    var data : [TagContent]?
    
    
    public init?(map: Map) {
        
    }
    
    mutating public func mapping(map: Map) {
        
        data               <- map["data"]
    
    }
   
    func getChallenges() -> ([Challenge], [String:User], [Video],  [Image])   {
        
        var challenges  : [Challenge] = []
        var users       : [String : User] = [:]
        var videos      : [Video] = []
        var images      : [Image] = []
        
        guard let data = data else {
           
            return (challenges, users, videos, images)
            
        }
        
        for content in data {
            
            if let challenge = content.challenge {
                
                if let user = challenge.apiUserObject {
                    
                    users[user.userId] = user
                    challenge.userId = user.userId
                    if let image = user.apiImageObject {
                        
                        user.profileImageId = image.imageId
                        images.append(image)
                        
                    }
                    
                }
                
                if let video = challenge.apiVideoObject {
                    
                    challenge.videoId = video.videoId
                    videos.append(video)
                    
                }
                
                if let image = challenge.apiImageObject {
                    
                    challenge.mainImageId = image.imageId
                    challenge.imageChallengeId = image.imageId
                    images.append(image)
                    
                }
                
                challenges.append(challenge)
                
            }
            
        }
        
        return (challenges, users, videos, images)
        
    }
    
    func getResponses() -> ([Response], [Challenge], [String:User], [Video],  [Image]) {
        
        var responses : [Response] = []
        let challenges  : [Challenge] = []
        var users       : [String : User] = [:]
        var videos      : [Video] = []
        var images      : [Image] = []
        guard let data = data else {
            
            return (responses, challenges, users, videos, images)
            
        }
        for content in data {
            
            if let response = content.response {
                
                if let user = response.apiUserObject {
                    
                    users[user.userId] = user
                    response.userId = user.userId
                    if let image = user.apiImageObject {
                        
                         user.profileImageId = image.imageId
                         images.append(image)
                        
                    }
                    
                }
                
                if let video = response.apiVideoObject {
                    
                    response.videoId = video.videoId
                    videos.append(video)
                    
                }
                
                if let image = response.apiImageObject {
                    
                    response.imageId = image.imageId
                    images.append(image)
                    
                }
                
                responses.append(response)
                
            }
            
        }
        
        return (responses, challenges, users, videos, images)
        
    }
    
}

public class TagContent: Mappable {

    var _id : String?
    var name : String?
    var contentType : String?
    var contentId : String?
    var created : String?
    var challenge : Challenge?
    var response : Response?
    
    
    var identifier:     Int {
        
        get {
            if let id = _id, let value = Int(id) {
                return value
            }
            return hashValue
        }
        
    }
    
    required public init?(map: Map) { }
    
    public func mapping(map: Map) {
        
        _id               <- map["_id"]
        name                <- map["name"]
        contentType                <- map["contentType"]
        contentId                 <- map["contentId"]
        created       <- map["created"]
        challenge             <- map["challenge"]
        response             <- map["response"]
        
    }
    
}

extension TagContent: Hashable {
    
    public var hashValue: Int {
        return "\(name ?? "NONE")".hashValue
    }
    
    public static func ==(lhs: TagContent, rhs: TagContent) -> Bool {
        return lhs._id == rhs._id
    }
    
}

