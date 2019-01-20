//
//  Comment.swift
//  Production
//
//  Created by Garrett Fritz on 2/1/18.
//  Copyright © 2018 BeMaverick. All rights reserved.
//

import Foundation
import RealmSwift
import ObjectMapper

@objcMembers
class Comment: Object, Mappable {
    
    dynamic var _id: String = ""
    dynamic var userId:   String?
    dynamic var body:              String?
    dynamic var created :          String?
    dynamic var contentId : String?
    dynamic var mentions = List<Mention>()
    var userData : User?
    var userImageData : Image?
    var creator = LinkingObjects(fromType: User.self, property: "createdComments")
    var mentionsArray : [Mention]?
    override static func primaryKey() -> String? {
        return "_id"
    }
    
    override static func ignoredProperties() -> [String] {
        
        return ["mentionsArray"]
        
    }
    
    func updateBasicData(_ comment: Comment) {
        
        userId = comment.userId
        body = comment.body
        created = comment.created
        if let items = comment.mentionsArray {
            
            mentions.removeAll()
            mentions.append(objectsIn: items)
            
        }
        
    }
    
    required convenience init?(map: Map) {
        
        self.init()
        
    }
    
    convenience init(id: String) {
        
        self.init()
        self._id = id
        
    }
    
    func mapping(map: Map) {
        
        _id             <- map["_id"]
        body            <- map["body"]
        userId          <- map["meta.user.userId"]
        userData        <- map["meta.user"]
        created         <- map["created"]
        contentId       <- map["parentId"]
        mentionsArray   <- map["meta.mentions"]
        userImageData   <- map["meta.user.profileImage"]
        
        
    }
    
    override var hashValue: Int {
        return _id.hashValue
    }
    
    static func ==(lhs: Comment, rhs: Comment) -> Bool {
        return lhs._id == rhs._id
    }
    
    func getTimeStamp() -> Date? {
        
        var startTime : Date?
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        
        if let start = created, let date = dateFormatter.date(from: start) {
            startTime = date
        }
        return startTime
        
    }
}

