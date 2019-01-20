//
//  Analytics+Debug.swift
//  Maverick
//
//  Created by Chris Garvey on 7/20/18.
//  Copyright © 2018 BeMaverick. All rights reserved.
//

import Foundation

extension AnalyticsManager {
    
    class DebugMemory {
        
        static func trackReceivedLowMemoryWarning() {
            
            let applicationStatus: String = {
                
                switch UIApplication.shared.applicationState {
                case .active:
                    return Constants.Analytics.Debug.Properties.APPLICATION_STATUS.active.rawValue
                case .inactive:
                    return Constants.Analytics.Debug.Properties.APPLICATION_STATUS.inactive.rawValue
                case .background:
                    return Constants.Analytics.Debug.Properties.APPLICATION_STATUS.background.rawValue
                }
                
            }()
            
            let properties: [String:String] = [
                Constants.Analytics.Debug.Properties.LAST_EVENT_NAME: AnalyticsManager.mostRecentEvent,
                Constants.Analytics.Debug.Properties.LAST_SCREEN_NAME: AnalyticsManager.mostRecentScreen,
                Constants.Analytics.Debug.Properties.APPLICATION_STATUS.key.rawValue:
                applicationStatus
            ]
            
            trackEvent(Constants.Analytics.Debug.Events.RECEIVED_LOW_MEMORY_WARNING, withProperties: properties)
            
        }
        
    }
    
}
