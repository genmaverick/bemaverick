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
class ConfigurableResponseStream: Stream {

    dynamic var items = List<Response>()
    dynamic var challenge : Challenge?
    
    required convenience init?(map: Map) {
        
        self.init()
        
    }
    
    convenience init(streamId : String, challenge : Challenge) {
        
        self.init()
        self.streamId = streamId
        self.challenge = challenge
    
    }
    
    convenience init(streamId: String) {
        
        self.init()
        self.streamId = streamId
        
    }
   
}
