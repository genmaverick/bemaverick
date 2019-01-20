//
//  GlobalModelsCoordinator+Responses.swift
//  BeMaverick
//
//  Created by David McGraw on 9/14/17.
//  Copyright © 2017 BeMaverick. All rights reserved.
//

import Foundation
import RealmSwift

/**
 Methods responsible for uploading content via the `APIService` instance
 */
extension GlobalModelsCoordinator {
    
    /**
     Retrieve the trophies in app
     */
    open func getProjects(completionHandler: (() -> Void)? = nil) {
        
        apiService.getProjects() { response, error in
            
            if let data = response?.data {
                
                DBManager.sharedInstance.addProjects(projects: data)
                
            }
            
            completionHandler?()
            
        }
        
    }
    
    
    
     func  isRewardAvailable( rewardKey : Reward.RewardTypes) -> Reward? {
        
        return isRewardAvailable( rewardKey : rewardKey.rawValue)
        
    }
    
    func  isRewardAvailable( rewardKey : String) -> Reward? {
     
        return DBManager.sharedInstance.isRewardAvailable(rewardKey: rewardKey)
        
    }
    /**
     Retrieve the rewards in app
     */
    open func getAllRewards(completionHandler: (() -> Void)? = nil) {
        
        apiService.getAllRewards() { response, error in
            
            if let data = response?.data {
                
                DBManager.sharedInstance.addRewards(rewards: data)
                
            }
            
            completionHandler?()
            
        }
        
    }
    
    
    /**
     Gets progression state for a user
     */
    open func getProgression() {
        
        guard !isFetchingUserProgress, let id = loggedInUser?.userId else { return }
        
        isFetchingUserProgress = true
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) { [weak self] in
            
            self?.getProgression(for : id) {
                
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) { [weak self] in
                    
                    self?.getProgression(for : id) {
                        
                        self?.isFetchingUserProgress = false
                        
                    }
                    
                }
                
            }
            
        }
        
    }
    
    /**
     Gets progression state for a user
     */
    open func getProgression(for userId : String , completionHandler: (() -> Void)? = nil) {
      
        apiService.getProgressionForUser(userId: userId) { (response, error) in
            
            if let data = response?.progression {
                
                self.checkForMilestones(newProgression: data)
                DBManager.sharedInstance.addProgression(progression: data, toUserId: userId)
                
            }
            
            if let loggedInUser = self.loggedInUser, userId == loggedInUser.userId {
                
                EditStickerOptionsView.getCompletedProjectImages(user:loggedInUser)
                
            }
            
            completionHandler?()
            
        }
        
    }
    
    private func checkForMilestones(newProgression : Progression) {
        
        guard let oldProgression = loggedInUser?.progression, oldProgression.projectsProgress.count > 0 else { return }
        
        guard oldProgression.currentLevelNumber == newProgression.currentLevelNumber else {
         
            if let level = newProgression.currentLevel {
            
                onLevelAchieved.fire(level)
                
            }
          
            return
            
        }
        
        guard let newProjectProgress = newProgression.apiProjects else { return }
        for projectProgress in newProjectProgress {
            
            if projectProgress.completed, let projectId = projectProgress.project?.projectId {
                
                var shouldShowCelebration = projectProgress.project
               
                for oldProjectProgress in oldProgression.projectsProgress {
                    
                    if let oldId = oldProjectProgress.project?.projectId, oldId == projectId {
                        
                        if oldProjectProgress.completed {
                            
                            shouldShowCelebration = nil
                        
                        }
                        
                        break
                        
                    }
                    
                }
                
                if let projectToShow = shouldShowCelebration {
                    
                    onProjectAchieved.fire(projectToShow)
                    return
               
                }
                
            }
            
        }
        
    }
    
    func getProgressionLeaderboard(byType type : ProgressionLeaderboardViewController.LeaderboardType, time : ProgressionLeaderboardViewController.LeaderboardTime,  completionHandler: @escaping ((List<User>?) -> Void)) {
        
       
        var string = "a"
        
        if type == .following {
            if time == .all {
                string = "aa"
            }
            if time == .monthly {
               string = "mm"
            }
        } else {
            
            if time == .all {
                string = "bb"
            }
            if time == .monthly {
                string = "nn"
            }
            
        }
        apiService.getProgressionLeaderboard(byString: string, completionHandler: { response, error in
            
            guard let response = response, error == nil else { return }
            
            let results =  DBManager.sharedInstance.updateUsers(withUsers: response)
            completionHandler(results)
            
        })
        
    }
    
}
