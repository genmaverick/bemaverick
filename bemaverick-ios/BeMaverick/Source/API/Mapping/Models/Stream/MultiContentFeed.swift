//
//  File.swift
//  Production
//
//  Created by Garrett Fritz on 7/16/18.
//  Copyright © 2018 BeMaverick. All rights reserved.
//

import Foundation

import RealmSwift

@objcMembers
class MultiContentFeed : Object {
    
    dynamic var responses = List<Response>()
    dynamic var challenges = List<Challenge>()
    dynamic var feed =  List<MultiContentObject>()
    dynamic var feedLastUpdated : Int = -1
    
}



