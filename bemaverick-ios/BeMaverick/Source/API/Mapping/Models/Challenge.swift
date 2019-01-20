//
//  Challenge.swift
//  BeMaverick
//
//  Created by David McGraw on 9/18/17.
//  Copyright © 2017 BeMaverick. All rights reserved.
//

import Foundation
import ObjectMapper
import RealmSwift

@objcMembers
class Challenge: Object, Mappable, ShareableType  {
    
    //API Properties
    dynamic var challengeId:                    String = ""
    dynamic var userId:                         String?
    dynamic var title:                          String?
    dynamic var label:                          String?
    dynamic var videoId:                        String?
    dynamic var mainImageUrl:                   String?
    dynamic var cardImageUrl:                   String?
    dynamic var cardImageId:                    String?
    dynamic var mainImageId:                    String?
    dynamic var imageChallengeId:               String?
    
    dynamic var mainCardMedia:                  MaverickMedia?
    dynamic var mainImageMedia:                 MaverickMedia?
    dynamic var imageChallengeMedia:            MaverickMedia?
    dynamic var winnerResponseId:               String?
    dynamic var sortOrder:                      Int?
    dynamic var tagIds:                         [String]?
    dynamic var numResponses:                   Int = 0
    dynamic var stats:                          Stat?
    dynamic var commentDescriptor:              CommentDescriptor?
    dynamic var startString:                    String?
    dynamic var endString:                      String?
    dynamic var status:                         String?
    dynamic var badgeIds:                       [String]?
    dynamic var userIdsWithMostRecentResponse:  [String]?
    dynamic var startTime :                     Date?
    dynamic var endTime :                       Date?
    dynamic var videoMedia :                    MaverickMedia?
    dynamic var responses =                     List<Response>()
   
    dynamic var mentionUserIds =                List<String>()
    dynamic var numComments:                    Int?
    dynamic var comments =                      List<Comment>()
    
   
    dynamic var linkURL:                        String?
     dynamic var link_fetched = false
    dynamic var linkURL_title:                        String?
    dynamic var linkURL_description:                        String?
    dynamic var linkURL_imageURL:                        String?
    dynamic var linkURL_siteName:                        String?
    
    var peekComments :                  CommentResponse?
    
    dynamic var creator = LinkingObjects(fromType: User.self, property: "ownedChallenges")
    
    func myShareableType() -> SocialShareType {
        return SocialShareType.challenge
    }
    
    func getCreator() -> User? {
        
        return creator.filter("userId = %@", userId ?? "").first
        
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
    
    // Used for processed properties
    override static func ignoredProperties() -> [String] {
        
        return ["userIdsWithMostRecentResponse", "badgeIds", "tagIds", "searchResults", "peekComments","apiUserObject","apiVideoObject","apiImageObject"]
    
    }
    
    var searchResults:              SearchResults?
    var apiImageObject: Image?
    var apiVideoObject: Video?
    var apiUserObject: User?
    
    override static func primaryKey() -> String? {
        return "challengeId"
    }
    
    func updateBasicData(_ challenge: Challenge) {
        
        userId = challenge.userId
        title = challenge.title
        label = challenge.label
        
        if title == " " {
            title = nil
        }
        if label == " " {
            label = nil
        }
        
        status = challenge.status
        searchResults = challenge.searchResults
        mediaType = challenge.mediaType
        mentionUserIds.removeAll()
        mentionUserIds.append(objectsIn: challenge.mentionUserIds)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
     
        if let start = challenge.startString, let date = dateFormatter.date(from: start) {
            startTime = date
        }
        if let end = challenge.endString, let date = dateFormatter.date(from: end) {
            endTime = date
        }
        
        numResponses = challenge.numResponses
        peekComments = challenge.peekComments
      
           
      linkURL = challenge.linkURL
        
      
        
    }
    
  
    
    required convenience init?(map: Map) {
        
        self.init()
        
    }
    
    convenience init(challengeId: String) {
    
        self.init()
        self.challengeId = challengeId
        
    }
    
    func isDeleted() -> Bool {
        
        if let status = status, status == "deleted" {
            
            return true
        
        }
        
        return false
    
    }
    
    func mapping(map: Map) {
        
        status                          <- map["status"]
        challengeId                     <- map["challengeId"]
        userId                          <- map["userId"]
        title                           <- map["title"]
        label                           <- map["description"]
        videoId                         <- map["videoId"]
        mainImageUrl                    <- map["mainImageUrl"]
        cardImageUrl                    <- map["cardImageUrl"]
        startString                     <- map["startTime"]
        endString                       <- map["endTime"]
        winnerResponseId                <- map["winnerResponseId"]
        sortOrder                       <- map["sortOrder"]
        tagIds                          <- map["tagIds"]
        badgeIds                        <- map["badgeIds"]
        numResponses                    <- map["numResponses"]
        mainImageId                     <- map["mainImageId"]
        cardImageId                     <- map["cardImageId"]
        imageChallengeId                <- map["imageId"]
        mediaTypeRawValue               <- map["challengeType"]
        var mentionUserIdsRaw : [String]? = nil
        mentionUserIdsRaw               <- map["mentionUserIds"]
        
        if let mentionUserIdsRaw = mentionUserIdsRaw {
            mentionUserIds.append(objectsIn: mentionUserIdsRaw)
        }
        userIdsWithMostRecentResponse   <- map["userIdsWithMostRecentResponse"]
        searchResults                   <- map["searchResults"]
        peekComments                    <- map["peekComments"]
        
        apiImageObject                  <- map["image"]
        if apiImageObject == nil {
             apiImageObject                  <- map["mainImage"]
        }
        apiVideoObject                  <- map["video"]
        apiUserObject                   <- map["user"]
        linkURL                         <- map["linkUrl"]
        
        
    }
    
    func isOver() -> Bool {
        
        guard let endTime = endTime else { return false }
        return endTime.timeIntervalSinceNow.sign == .minus
        
        
    }
    
    override var hashValue: Int {
        return "\(challengeId) \(title ?? "NONE")".hashValue
    }
    
    static func ==(lhs: Challenge, rhs: Challenge) -> Bool {
        return lhs.challengeId == rhs.challengeId
    }
}

