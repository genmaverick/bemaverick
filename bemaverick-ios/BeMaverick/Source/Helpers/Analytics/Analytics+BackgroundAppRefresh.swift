//
//  Analytics+BackgroundAppRefresh.swift
//  Maverick
//
//  Created by Chris Garvey on 7/3/18.
//  Copyright © 2018 BeMaverick. All rights reserved.
//

import Foundation

extension AnalyticsManager {
    
    class BackgroundAppRefresh {
        
        static func backgroundAppRefreshStarted() {
            
            trackEvent(Constants.Analytics.BackgroundAppRefresh.Events.BACKGROUND_APP_REFRESH_STARTED)
            
        }
        
        static func backgroundAppRefreshEnded(completionState: Constants.Analytics.BackgroundAppRefresh.Properties.COMPLETION_STATE, refreshDuration: Int) {
            
            let properties: [String:String] = [Constants.Analytics.BackgroundAppRefresh.Properties.COMPLETION_STATE.key.rawValue: completionState.rawValue, Constants.Analytics.BackgroundAppRefresh.Properties.REFRESH_DURATION: String(refreshDuration)]
            
            trackEvent(Constants.Analytics.BackgroundAppRefresh.Events.BACKGROUND_APP_REFRESH_ENDED, withProperties: properties)
            
        }
        
    }
            
}
