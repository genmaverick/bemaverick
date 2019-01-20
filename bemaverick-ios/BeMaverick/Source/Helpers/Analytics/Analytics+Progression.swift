//
//  AnalyticsOnboarding.swift
//  BeMaverick
//
//  Created by Garrett Fritz on 2/5/18.
//  Copyright © 2018 BeMaverick. All rights reserved.
//

import Foundation

extension AnalyticsManager {
    
    class Progression {
        
        static func trackProjectAccomplished(projectId : String) {
           
            let properties: [String : Any] = [Constants.Analytics.Progression.Properties.PROJECT_ID : projectId ]
            
            trackEvent(Constants.Analytics.Progression.Events.PROJECT_ACCOMPLISHED, withProperties: properties)
            
        }
        
        static func trackLevelAccomplished(levelNumber : String) {
            
            let properties: [String : Any] = [Constants.Analytics.Progression.Properties.LEVEL_NUMBER : levelNumber ]
            
            trackEvent(Constants.Analytics.Progression.Events.LEVEL_ACCOMPLISHED, withProperties: properties)
            
        }
        
        static func trackRewardLocked(rewardKey : String) {
            
            let properties: [String : Any] = [Constants.Analytics.Progression.Properties.REWARD_KEY : rewardKey ]
            
            trackEvent(Constants.Analytics.Progression.Events.REWARD_LOCKED, withProperties: properties)
            
        }
        
        static func trackBadgePressed(badgeId : String) {
            
            let properties: [String : Any] = [Constants.Analytics.Progression.Properties.BADGE_ID : badgeId ]
            
            trackEvent(Constants.Analytics.Progression.Events.BADGE_PRESSED, withProperties: properties)
            
        }
        
        static func trackProjectPressed(projectId : String) {
            
            let properties: [String : Any] = [Constants.Analytics.Progression.Properties.PROJECT_ID : projectId ]
            
            trackEvent(Constants.Analytics.Progression.Events.PROJECT_PRESSED, withProperties: properties)
            
        }
        
        static func trackProjectSeeAllPressed(filter : ProjectProgressTableViewCell.ProjectProgressViewFilter) {
            
            let properties: [String : Any] = [Constants.Analytics.Progression.Properties.PROGRESS_FILTER : filter.rawValue ]
            
            trackEvent(Constants.Analytics.Progression.Events.PROJECT_SEE_ALL_PRESSED, withProperties: properties)
            
        }
        
        static func trackNextLevelPressed() {
             trackEvent(Constants.Analytics.Progression.Events.NEXT_LEVEL_PRESSED)
            
        }
        
    }
    
}
