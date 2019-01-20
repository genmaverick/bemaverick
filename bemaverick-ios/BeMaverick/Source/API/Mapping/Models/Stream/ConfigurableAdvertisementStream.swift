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
class ConfigurableAdvertisementStream: Stream {

    
    
    required convenience init?(map: Map) {
        
        self.init()
        
    }
    
    convenience init(streamId: String) {
        
        self.init()
        self.streamId = streamId
        
    }
   
    override func mapping(map: Map) {
        
        super.mapping(map: map)
       
        
    }
    
}
