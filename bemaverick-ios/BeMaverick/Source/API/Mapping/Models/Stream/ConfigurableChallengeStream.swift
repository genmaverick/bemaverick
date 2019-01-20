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
class ConfigurableChallengeStream: Stream {
    
    static let MyInvitedChallengesStreamId =
    "MyInvitedChallengesStreamId"
    static let LinkChallengesStreamId =
    "LinkChallengesStreamId"
    static let NoResponseStreamId = "NoResponseStreamId"
    static let MyRespondedChallengesStreamId = "MyRespondedChallengesStreamId"
    static let TrendingChallengesStreamId = "TrendingChallengesStreamId"
    
    dynamic var items = List<Challenge>()
    
    required convenience init?(map: Map) {
        
        self.init()
        
    }
    
    convenience init(streamId: String) {
        
        self.init()
        self.streamId = streamId
        
    }
    
}
