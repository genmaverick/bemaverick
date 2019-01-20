//
//  AnalyticsOnboarding.swift
//  BeMaverick
//
//  Created by Garrett Fritz on 2/5/18.
//  Copyright © 2018 BeMaverick. All rights reserved.
//

import Foundation

extension AnalyticsManager {
    
     class Main {
        
        static func trackTabPressed(index: Int) {
            
            let properties = [Constants.Analytics.Main.Properties.TAB_INDEX : index]
            trackEvent(Constants.Analytics.Main.Events.MAIN_TAB_PRESSED, withProperties: properties)
            
        }
        
        static func trackUpperNavTabPressed(source : UIViewController, index: Int) {
            
            var properties : [String : Any] = [Constants.Analytics.Main.Properties.TAB_INDEX : index]
            properties = addLocationProperty (properties, location: source)
            trackEvent(Constants.Analytics.Main.Events.UPPER_TAB_PRESSED, withProperties: properties)
            
        }
        
        static func trackFeedNextPageCalled(source : ViewController, offset : Int) {
            
            var properties : [String : Any] = ["offset" : offset]
            properties = addLocationProperty (properties, location: source)
            trackEvent(Constants.Analytics.Main.Events.FEED_NEXT_PAGE, withProperties: properties)
            
        }
        
        static func trackChallengeDetailsDismmised(source : Constants.Analytics.Main.Properties.DISMISS_TYPE) {
            
            let properties : [String : Any] = [Constants.Analytics.Main.Properties.DISMISS_TYPE.key.rawValue : source.rawValue]
            
            trackEvent(Constants.Analytics.Main.Events.CHALLENGE_DETAILS_DISMISSED, withProperties: properties)
            
        }
        
        
        
        static func trackPageSwiped(source : PagerViewController) {
            
            var properties : [String : Any] = [:]
            properties = addLocationProperty (properties, location: source)
            trackEvent(Constants.Analytics.Main.Events.PAGE_SWIPED, withProperties: properties)
            
        }
        
        static func trackRespondToChallengePressed(challengeId : String, location : UIViewController) {
            
            var props: [String : Any] = [Constants.Analytics.Main.Properties.ID : challengeId ]
            props = addLocationProperty(props, location: location)
            
            FeaturedStreamViewController.hasTappedPostResponseSession = true
            
            trackEvent(Constants.Analytics.Main.Events.CHALLENGE_RESPOND_PRESSED, withProperties: props)
            
        }
        
        
        
    }
 
}
