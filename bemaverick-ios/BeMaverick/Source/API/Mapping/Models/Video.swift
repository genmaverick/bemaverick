//
//  Video.swift
//  BeMaverick
//
//  Created by David McGraw on 9/18/17.
//  Copyright © 2017 BeMaverick. All rights reserved.
//

import Foundation
import ObjectMapper

class Video: Mappable {
    
    static var appUserMuted : Bool = true
    
    var videoId:        String?
    var videoUrl:       String?
    var videoHlsUrl:       String?
    var thumbnailUrl:   String?
    var width:          Int?
    var height:         Int?
    
    var identifier:     Int {
        
        get {
            if let id = videoId, let value = Int(id) {
                return value
            }
            return hashValue
        }
        
    }
    
    required init?(map: Map) { }
    
    func mapping(map: Map) {
        
        videoId         <- map["videoId"]
        videoUrl        <- map["videoUrl"]
        thumbnailUrl    <- map["thumbnailUrl"]
        width           <- map["width"]
        height          <- map["height"]
        videoHlsUrl     <- map["videoHLSUrl"]
    }
    
}

extension Video: Hashable {
    
    var hashValue: Int {
        return "\(videoId ?? "NONE") \(videoUrl ?? "NONE")".hashValue
    }
    
    static func ==(lhs: Video, rhs: Video) -> Bool {
        return lhs.videoId == rhs.videoId
    }
    
}
