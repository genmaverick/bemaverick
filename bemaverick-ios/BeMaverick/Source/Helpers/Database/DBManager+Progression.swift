//
//  DBManager+Content.swift
//  BeMaverick
//
//  Created by Garrett Fritz on 2/14/18.
//  Copyright © 2018 BeMaverick. All rights reserved.
//

import Foundation
import RealmSwift

extension DBManager {
    
    
    /**
     Fetches a project from the realm if it exists.
     If it doesn't, it will create a new object with the id and add it to the realm.
     All subsequent edits to the project object must be made in a write transaction
     */
    func getProject(byId projectId: String) -> Project {
        
        if let project = loggedInUserDataBase.object(ofType: Project.self, forPrimaryKey: projectId) {
            
            return project
            
        } else {
            
            let project = Project(projectId: projectId)
            if loggedInUserDataBase.isInWriteTransaction {
                
                loggedInUserDataBase.add(project, update: true)
                
            } else {
                
                attemptLoggedInDBWrite {
                    
                    loggedInUserDataBase.add(project, update: true)
                    
                }
                
            }
            
            return project
            
        }
        
    }
    
    func  isRewardAvailable( rewardKey : String) -> Reward? {
     
        if let user = getLoggedInUser() {
            
            if let reward = user.progression?.isRewardAvailable(rewardKey: rewardKey) {
                
                return reward
                
            }
            
        }
        
        return loggedInUserDataBase.objects(Reward.self).filter("key = %@", rewardKey).first
        
    }
    
    func getLevel(byId levelId: String) -> Level {
        
        if let level = loggedInUserDataBase.object(ofType: Level.self, forPrimaryKey: levelId) {
            
            return level
            
        } else {
            
            let level = Level(levelId: levelId)
            if loggedInUserDataBase.isInWriteTransaction {
                
                loggedInUserDataBase.add(level, update: true)
                
            } else {
                
                attemptLoggedInDBWrite {
                    
                    loggedInUserDataBase.add(level, update: true)
                    
                }
                
            }
            
            return level
            
        }
        
    }
    
    func getReward(byId rewardId: String) -> Reward {
        
        if let reward = loggedInUserDataBase.object(ofType: Reward.self, forPrimaryKey: rewardId) {
            
            return reward
            
        } else {
            
            let reward = Reward(id: rewardId)
            if loggedInUserDataBase.isInWriteTransaction {
                
                loggedInUserDataBase.add(reward, update: true)
                
            } else {
                
                attemptLoggedInDBWrite {
                    
                    loggedInUserDataBase.add(reward, update: true)
                    
                }
                
            }
            
            return reward
            
        }
        
    }
    
    func process(progression : Progression) -> Progression {
        
        if let projects = progression.apiProjects {
            for progress  in projects {
                
                if let newProject = progress.project {
                    
                    let project = getProject(byId: newProject.projectId)
                    project.update(project: newProject)
                    progress.project = project
                    
                }
                
            }
        }
        
        if let levelProgress = progression.apiLevels {
            for progress  in levelProgress {
                
                if let newLevel = progress.level {
                    
                    let level = getLevel(byId: newLevel.levelId)
                    level.update(level: newLevel)
                    progress.level = level
                    
                }
                
            }
            
        }
        
        if let rewardProgress = progression.apiRewards {
           
            for rewardProgress  in rewardProgress {
                
                if let newReward = rewardProgress.reward {
                    
                    let reward = getReward(byId: newReward._id)
                    reward.update(reward: newReward)
                    rewardProgress.reward = reward
                    
                }
                
            }
            
        }
        
        if let newLevel = progression.nextLevel {
            
            let level = getLevel(byId: newLevel.levelId)
            level.update(level: newLevel)
            progression.nextLevel = level
            
        }
        
        if let newLevel = progression.currentLevel {
            
            let level = getLevel(byId: newLevel.levelId)
            level.update(level: newLevel)
            progression.currentLevel = level
            
        }
        
        return progression
        
    }
    
    
    func addProgression(progression newProgess : Progression, toUserId userId: String) {
        
        attemptLoggedInDBWrite {
            
            let progression = process(progression: newProgess)
            
            let user = getUser(byId: userId)
            if user.progression == nil {
                
                user.progression = progression
                
            }
                
                user.progression?.update(progression: progression)
                
            
            
        }
        
    }
    
    func addProjects(projects : [Project]) {
        
        attemptLoggedInDBWrite {
            
            for projectToAdd in projects {
                
                let project = getProject(byId: projectToAdd.projectId)
                project.update(project: projectToAdd)
                
            }
            
        }
        
    }
    
    func addRewards(rewards rewardsToAdd: [Reward]) -> [Reward] {
        
        var rewards : [Reward] = []
        attemptLoggedInDBWrite {
            
            for rewardToAdd in rewardsToAdd {
                
                let reward = getReward(byId: rewardToAdd._id)
                
                if let newLevel = rewardToAdd.level {
                    
                    let level = getLevel(byId: newLevel.levelId)
                    level.update(level : newLevel)
                    rewardToAdd.level = level
                    
                }
                
                reward.update(reward: rewardToAdd)
                rewards.append(reward)
                
            }
            
        }
        
        return rewards
        
    }
    
    func addLevels(levels : [Level]) {
        
        attemptLoggedInDBWrite {
            
            for levelToAdd in levels {
                
                let level = getLevel(byId: levelToAdd.levelId)
                level.update(level: levelToAdd)
                
            }
            
        }
        
    }
    
}
