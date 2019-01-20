//
//  MaverickModel.swift
//  BeMaverick
//
//  Created by Garrett Fritz on 2/8/18.
//  Copyright © 2018 BeMaverick. All rights reserved.
//

import Foundation
import RealmSwift
import ObjectMapper

@objcMembers
class MaverickFeed: Object {
    
    dynamic var id : String = "FeaturedStream"
    dynamic var lastAPIRequest : Int = -1
    dynamic var streams = List<MultiContentObject>()
    
    override static func primaryKey() -> String? {
     
        return "id"
    
    }
    
}


@objcMembers
class MultiContentObject: Object, Mappable {
 
    convenience init(type: Constants.FeaturedStreamType, id: String) {
        self.init()
        self.type = type
        self.id = id
    }
    
    @objc dynamic private var typeRawValue = Constants.ContentType.response.rawValue
    
    var type: Constants.FeaturedStreamType {
        get {
            return Constants.FeaturedStreamType(rawValue: typeRawValue) ?? .response
        }
        set {
            typeRawValue = newValue.rawValue
        }
    }
    
    
    dynamic var id: String = ""
    
    func mapping(map: Map) {
        
        id                      <- map["contentId"]
        typeRawValue            <- map["contentType"]
        
    }
    
    override var hashValue: Int {
        return id.hashValue
    }
    
    static func ==(lhs: MultiContentObject, rhs: MultiContentObject) -> Bool {
        return lhs.id == rhs.id &&   lhs.typeRawValue == rhs.typeRawValue
    }
    
    
    required convenience init?(map: Map) {
        
        self.init()
        
    }
    
    
}
