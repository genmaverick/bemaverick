//
//  Stream.swift
//  Maverick
//
//  Created by Garrett Fritz on 5/29/18.
//  Copyright © 2018 BeMaverick. All rights reserved.
//

import Foundation

import ObjectMapper
import RealmSwift

@objcMembers
class Stream: Object, Mappable {
    
    static var ignoredQueryParams  = ["count", "appKey"]
    
    dynamic var streamId        :   String = ""
    dynamic var label           :   String?
    dynamic var host            :   String?
    dynamic var pathname        :   String?
    dynamic var query           :   [String : Any]?
    dynamic var content         :   List<String>?
    dynamic var modelType       :   String?
    dynamic var deepLink        :   String?
    dynamic var lastAPIUpdate   :   Int = -1
    dynamic var paginated       :   Bool = false
    dynamic var maxCount        :   String?
    dynamic var challengeId        :   String?
    
    dynamic var imageMedia      :   MaverickMedia?
    dynamic var queryKeys       =   List<String>()
    dynamic var queryValues     =   List<String>()
    
    var count : Int?
    var offset : Int?
    var image                   :   Image?
    var identifier:     Int {
        
        get {
            if let value = Int(streamId) {
                return value
            }
            return hashValue
        }
        
    }
    
    
    required convenience init?(map: Map) {
        
        self.init()
        
    }
    
    convenience init(streamId: String) {
        
        self.init()
        self.streamId = streamId
        
    }
    
    
    override static func primaryKey() -> String? {
        return "streamId"
    }
    
    func update(data : Stream) {
        
        self.label = data.label
        self.host   = data.host
        self.pathname = data.pathname
        self.query = data.query
        self.content = data.content
        self.modelType = data.modelType
        self.queryKeys.removeAll()
        self.queryKeys.append(objectsIn: data.queryKeys)
        self.queryValues.removeAll()
        self.queryValues.append(objectsIn: data.queryValues)
        self.count = data.count
        self.offset = data.offset
        self.deepLink = data.deepLink
        self.paginated = data.paginated
        self.modelType = data.modelType
        self.challengeId = data.challengeId
        self.image = data.image
        self.maxCount = data.maxCount
        
    }
    
    override var hashValue: Int {
        return "\(streamId) \(modelType ?? "NONE")".hashValue
    }
    
    static func ==(lhs: Stream, rhs: Stream) -> Bool {
        return lhs.streamId == rhs.streamId
    }
    
    override static func ignoredProperties() -> [String] {
        return [
            "query","ignoredQueryParams", "count", "offset", "image"
        ]
        
    }
    
    func mapping(map: Map) {
        
        streamId                <- map["streamId"]
        label                   <- map["label"]
        pathname                <- map["url.pathname"]
        host                    <- map["url.host"]
        query                   <- map["url.query"]
        modelType               <- map["modelType"]
        deepLink                <- map["link.deeplink"]
        image                   <- map["image"]
        paginated               <- map["paginated"]
        maxCount                <- map["logic.displayLimit"]
        challengeId             <- map["challengeId"]
        
    }
    
    func getQueryDict() -> [String: Any] {
        
        var dict : [ String : Any ] = [:]
        guard queryKeys.count == queryValues.count else { return dict }
        
        for i in 0 ..< queryKeys.count {
            
            dict[queryKeys[i]] = queryValues[i]
            
        }
        
        if let count = count {
            
            dict["count"] = count
            
        }
        
        if let maxCount = maxCount, !paginated {
            
             dict["count"] = maxCount
            
        }
        
        if let offset = offset {
            
            dict["offset"] = offset
            
        }
        
        return dict
        
    }
    
    func getContentType() -> Constants.FeaturedStreamType {
        
        guard let value = modelType else { return .response }
        
        if(value.caseInsensitiveCompare("challenge") == ComparisonResult.orderedSame){
            
            return .challenge
            
        }
        
        if(value.caseInsensitiveCompare("response") == ComparisonResult.orderedSame){
            
            return .response
            
        }
        
        return .advertisement
        
    }
    
}
