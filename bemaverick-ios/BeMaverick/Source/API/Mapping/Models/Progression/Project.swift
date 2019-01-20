//
//  Project.swift
//  Maverick
//
//  Created by Garrett Fritz on 9/11/18.
//  Copyright © 2018 BeMaverick. All rights reserved.
//

import Foundation
import ObjectMapper
import RealmSwift
import Kingfisher

@objcMembers
class Project: Object, Mappable {
    
    dynamic var projectId = ""
    dynamic var name : String?
    dynamic var taskType : String?
    dynamic var projectGroup : String?
    
    dynamic var tasksRequired = 0
    dynamic var minLevel = 0
    dynamic var reward: Float = 0.0
    dynamic var color : String?
    dynamic var requirementDescription: String?
    dynamic var achievedDescription:  String?
    dynamic var achievedDescriptionSecondary:  String?
    @objc private dynamic var imageUrl : String?
    
    override static func primaryKey() -> String? {
        
        return "projectId"
        
    }
    
    required convenience init?(map: Map) {
        
        self.init()
        
    }
    
    func getImageUrl() -> URL? {
        
        guard let imageUrl = imageUrl else { return nil }
        let result = CacheManager.shared.getFileWith(stringUrl: imageUrl, ignoreMax: true, permanent: true)
        
        switch result {
            
        case .success(let cacheUrl):
            return cacheUrl
            
        case .downloading:
            return URL(string: imageUrl)
            
        }
            
    }
    func update(project: Project) {
        
        name = project.name
        taskType = project.taskType
        tasksRequired = project.tasksRequired
        minLevel = project.minLevel
        achievedDescription = project.achievedDescription
        achievedDescriptionSecondary = project.achievedDescriptionSecondary
        requirementDescription = project.requirementDescription
        reward = project.reward
        imageUrl = project.imageUrl
        color = project.color
        projectGroup = project.projectGroup
        
    }
    
    convenience init(projectId : String) {
        
        self.init()
        self.projectId = projectId
        
    }
    
    func mapping(map: Map) {
        
        projectId                   <- map["_id"]
        
        if projectId == "" {
      
            projectId               <- map["projectId"]
      
        }
        
        name                            <- map["name"]
        imageUrl                        <- map["imageUrl"]
        taskType                        <- map["taskType"]
        tasksRequired                   <- map["tasksRequired"]
        minLevel                        <- map["minLevel"]
        achievedDescription             <- map["achievedDescription"]
        achievedDescriptionSecondary    <- map["achievedDescriptionSecondary"]
        requirementDescription          <- map["requirementDescription"]
        reward                          <- map["pointsAwarded"]
        color                           <- map["color"]
        projectGroup                    <- map["projectGroup"]
        
    }
    
}
