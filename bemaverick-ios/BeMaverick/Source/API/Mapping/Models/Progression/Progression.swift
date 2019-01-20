//
//  Progression.swift
//  Maverick
//
//  Created by Garrett Fritz on 9/11/18.
//  Copyright © 2018 BeMaverick. All rights reserved.
//

import Foundation
import ObjectMapper
import RealmSwift

@objcMembers
class Progression: Object, Mappable {
    
    dynamic var projectsProgress =  List<ProjectsProgress>()
    dynamic var levelsProgress =  List<LevelProgress>()
    dynamic var rewardsProgress =  List<RewardsProgress>()
    dynamic var currentLevelNumber = 0
    dynamic var nextLevel : Level?
    dynamic var currentLevel : Level?
    dynamic var nextLevelNumber = 0
    dynamic var nextLevelProgress : Float = 0.0
    dynamic var totalPoints : Float = 0.0
    
    var apiProjects :  [ProjectsProgress]?
    var apiLevels :  [LevelProgress]?
    var apiRewards : [RewardsProgress]?
    
    override static func ignoredProperties() -> [String] {
        return [ "apiProjects", "apiLevels", "apiRewards" ]
    }
    
    required convenience init?(map: Map) {
        
        self.init()
        
    }
    
    func update(progression : Progression) {
        
        projectsProgress.removeAll()
        
        if let projectsToAdd = progression.apiProjects {
            projectsProgress.append(objectsIn:  projectsToAdd)
        }
        
        levelsProgress.removeAll()
        if let levelsToAdd = progression.apiLevels {
            levelsProgress.append(objectsIn:  levelsToAdd)
        }
        
        rewardsProgress.removeAll()
        if let rewardsToAdd = progression.apiRewards {
            rewardsProgress.append(objectsIn:  rewardsToAdd)
        }
        
        currentLevelNumber = progression.currentLevelNumber
        nextLevelNumber = progression.nextLevelNumber
        nextLevelProgress = progression.nextLevelProgress
        totalPoints = progression.totalPoints
        nextLevel = progression.nextLevel
        currentLevel = progression.currentLevel
        
    }
    
    
    func mapping(map: Map) {
        
        currentLevelNumber          <- map["currentLevelNumber"]
        currentLevel                <- map["currentLevel"]
        nextLevelNumber             <- map["nextLevelNumber"]
        nextLevelProgress           <- map["nextLevelProgress"]
        totalPoints                 <- map["totalPoints"]
        nextLevel                   <- map["nextLevel"]
        apiProjects                 <- map["projectsProgress"]
        apiRewards                  <- map["rewardsProgress"]
        apiLevels                   <- map["levelsProgress"]
        
    }
    
    func getInProgressProjects() -> [ProjectsProgress] {
       
        return Array( projectsProgress.filter("completed = %@ AND visibility = %@", false, true).sorted(byKeyPath: "progress", ascending: false))
        
    }
    
    
    func hasInProgress() -> Bool {
        
        let availableProgress = getInProgressProjects()
        return availableProgress.count > 0
        
    }
    
    func getCompletedProjects() -> [ProjectsProgress] {
        
          return Array( projectsProgress.filter("completed = %@ AND visibility = %@", true, true).sorted(byKeyPath: "completedDate", ascending: false) )
        
    }
    
    func hasCompleted() -> Bool {
        
        let availableProgress = getCompletedProjects()
        return availableProgress.count > 0
        
    }
    
    func isRewardAvailable( rewardKey : String) -> Reward? {
     
        for progress in rewardsProgress {
            
            if let key = progress.rewardKey, key == rewardKey {
            
                if let reward = progress.reward {
                    
                    reward.completed = progress.completed
                    return reward
                    
                }
                
            }
            
        }
        
        return nil
    
    }
    
}
