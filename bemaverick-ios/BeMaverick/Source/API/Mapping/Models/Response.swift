//
//  Response.swift
//  BeMaverick
//
//  Created by David McGraw on 9/19/17.
//  Copyright © 2017 BeMaverick. All rights reserved.
//

import Foundation
import ObjectMapper
import RealmSwift

@objcMembers
class Response: Object, Mappable, ShareableType  {
    
    dynamic var responseId:             String = ""
    dynamic var userId:                 String?
    dynamic var challengeId:            String?
    dynamic var videoId:                String?
    dynamic var imageId:                String?
    dynamic var coverImageId:           String?
    dynamic var label:                  String?
    dynamic var tagIds:                 [String]?
    dynamic var status:                     String?
    dynamic var searchResults:          SearchResults?
    dynamic var commentDescriptor:      CommentDescriptor?
    dynamic var badges:                 [String: BadgeStats]?
    dynamic var badgeIds:               [String]?
    dynamic var numComments:            Int?
    dynamic var badgeStats =        List<BadgeStats>()
    dynamic var badgers        =        List<User>()
    dynamic var imageMedia:             MaverickMedia?
    dynamic var videoCoverImageMedia:   MaverickMedia?
    dynamic var videoMedia:             MaverickMedia?
   
    dynamic var favorite:               Bool = false
    dynamic var comments =              List<Comment>()
    var peekComments :                  CommentResponse?
    
    var creator = LinkingObjects(fromType: User.self, property: "createdResponses")
    var challengeOwner = LinkingObjects(fromType: Challenge.self, property: "responses")
    
    func myShareableType() -> SocialShareType {
        return SocialShareType.response
    }
    
    @objc dynamic private var mediaTypeRawValue = Constants.MediaType.video.rawValue
    var mediaType: Constants.MediaType {
        get {
            return Constants.MediaType(rawValue: mediaTypeRawValue) ??  Constants.MediaType.video
        }
        set {
            mediaTypeRawValue = newValue.rawValue
        }
    }
    
    func getCreator() -> User? {
        return creator.filter("userId = %@", userId ?? "").first
    }
    
    
    // Used for processed properties
    override static func ignoredProperties() -> [String] {
        return ["badges", "badgeIds", "tagIds", "peekComments","apiUserObject","apiVideoObject","apiImageObject"]
        
    }
    
    
    var apiImageObject: Image?
    var apiVideoObject: Video?
    var apiUserObject: User?
    
    
    func mapping(map: Map) {
        
        peekComments        <- map["peekComments"]
        responseId          <- map["responseId"]
        userId              <- map["userId"]
        label               <- map["description"]
        challengeId         <- map["challengeId"]
        videoId             <- map["videoId"]
        badges              <- map["badges"]
        badgeIds            <- map["badgeIds"]
        tagIds              <- map["tagIds"]
        searchResults       <- map["searchResults"]
        coverImageId        <- map["coverImageId"]
        mediaTypeRawValue   <- map["responseType"]
        imageId             <- map["imageId"]
        favorite            <- map["favorite"]
        status              <- map["status"]
        
        apiImageObject                  <- map["image"]
        apiVideoObject                  <- map["video"]
        apiUserObject                   <- map["user"]
        
    }
    
    func isActive() -> Bool {
        
        if let status = status, status != "active" {
            
            return false
            
        }
        
        return true
        
    }
    
    func updateBasicResponseData(_ response : Response) {
        
        userId = response.userId
        label = response.label
        status = response.status
        challengeId = response.challengeId
        videoId = response.videoId
        imageId = response.imageId
        coverImageId = response.coverImageId
        tagIds = response.tagIds
        searchResults = response.searchResults
        badges = response.badges
        badgeIds = response.badgeIds
        mediaType = response.mediaType
        favorite = response.favorite
        peekComments = response.peekComments
        
    }
    
    var identifier:     Int {
        
        get {
            if let value = Int(responseId) {
                return value
            }
            return hashValue
        }
        
    }
    
    required convenience init?(map: Map) {
        
        self.init()
        
    }
    
    convenience init(responseId: String) {
        self.init()
        self.responseId = responseId
        
    }
    
    
    override static func primaryKey() -> String? {
        return "responseId"
    }
    
    
    override var hashValue: Int {
        return "\(responseId) \(userId ?? "NONE")".hashValue
    }
    
    static func ==(lhs: Response, rhs: Response) -> Bool {
        return lhs.responseId == rhs.responseId
    }
    
    
}

