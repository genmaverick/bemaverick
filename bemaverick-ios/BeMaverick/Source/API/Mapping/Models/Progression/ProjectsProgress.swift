//
//  ProjectProgress.swift
//  Maverick
//
//  Created by Garrett Fritz on 9/11/18.
//  Copyright © 2018 BeMaverick. All rights reserved.
//

import Foundation
import ObjectMapper
import RealmSwift

@objcMembers
class ProjectsProgress: Object, Mappable {
    
    dynamic var project : Project?
    dynamic var tasksCompleted = 0
    dynamic var progress : Float = 0.0
    dynamic var completed = false
    dynamic var completedDate  : String?
    dynamic var visibility  : Bool = false
    
    
    required convenience init?(map: Map) {
        
        self.init()
        
    }
  
    func mapping(map: Map) {
        
        project                <- map["project"]
        tasksCompleted         <- map["tasksCompleted"]
        progress                <- map["progress"]
        completed               <- map["completed"]
        completedDate           <- map["completedDate"]
        visibility              <- map["visibility"]
        
    }
    
    func getTimeStamp() -> Date? {
        
        var completedTime : Date?
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        
        if let completedDate = completedDate, let date = dateFormatter.date(from: completedDate) {
            completedTime = date
        }
        return completedTime
        
    }
    
}

