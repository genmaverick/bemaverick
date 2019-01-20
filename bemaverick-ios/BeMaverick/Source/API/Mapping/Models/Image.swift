//
//  Video.swift
//  BeMaverick
//
//  Created by David McGraw on 9/18/17.
//  Copyright © 2017 BeMaverick. All rights reserved.
//

import Foundation
import ObjectMapper

struct Image: Mappable {
    
    var imageId:        String = ""
    var url:            String?
    var urlProtocol:    String?
    var urlHost:        String?
    var filename:       String?
    var width:          Int?
    var height:         Int?
    
    var identifier:     Int {
        
        get {
            if let value = Int(imageId) {
                return value
            }
            return hashValue
        }
        
    }
    
    init?(map: Map) { }
    
    mutating func mapping(map: Map) {
        
        imageId         <- map["imageId"]
        url             <- map["url"]
        urlProtocol     <- map["urlProtocol"]
        urlHost         <- map["urlHost"]
        filename        <- map["filename"]
        width           <- map["width"]
        height          <- map["height"]
        
    }
    
}

extension Image: Hashable {
    
    var hashValue: Int {
        return "\(imageId) \(url ?? "NONE")".hashValue
    }
    
    static func ==(lhs: Image, rhs: Image) -> Bool {
        return lhs.imageId == rhs.imageId
    }
    
}
