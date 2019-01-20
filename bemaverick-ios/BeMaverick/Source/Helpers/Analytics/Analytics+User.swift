//
//  Analytics+Content.swift
//  BeMaverick
//
//  Created by Garrett Fritz on 2/6/18.
//  Copyright © 2018 BeMaverick. All rights reserved.
//
import
Foundation

extension AnalyticsManager {
    
    class Profile {
        
        static func trackFollowTapped(userId : String, isFollowing : Bool, location : UIViewController) {
            
            var properties: [String : Any] = [Constants.Analytics.Main.Properties.TARGET_USER_ID : userId]
            properties = addLocationProperty(properties, location: location)
            properties = AnalyticsManager.addEventSourceProperties(properties)
            
            if isFollowing {
                
                trackEvent(Constants.Analytics.Profile.Events.FOLLOW_PRESSED, withProperties: properties)
                
            } else {
                
                trackEvent(Constants.Analytics.Profile.Events.UN_FOLLOW_PRESSED, withProperties: properties)
            }
            
            
        }
        
        static func trackSettingsPressed() {
            
            trackEvent(Constants.Analytics.Profile.Events.SETTINGS_PRESSED, withProperties: nil)
            
        }
        
        static func trackNotificationsPressed() {
            
            trackEvent(Constants.Analytics.Profile.Events.NOTIFICATIONS_PRESSED, withProperties: nil)
            
        }
        
        static func trackSharePressed() {
            
            trackEvent(Constants.Analytics.Profile.Events.SHARE_PRESSED, withProperties: nil)
            
        }
        
        static func trackFindFriendsPressed() {
            
            trackEvent(Constants.Analytics.Profile.Events.FIND_FRIENDS_PRESSED, withProperties: nil)
            
        }
        
        static func trackQRPressed() {
            
            trackEvent(Constants.Analytics.Profile.Events.QR_PRESSED, withProperties: nil)
            
        }
        
        static func trackOverflowPressed() {
            
            trackEvent(Constants.Analytics.Profile.Events.OVERFLOW_PRESSED, withProperties: nil)
            
        }
        
        static func trackFollowersPressed(userId : String) {
            
            let properties: [String : Any] = [Constants.Analytics.Main.Properties.TARGET_USER_ID : userId]
            trackEvent(Constants.Analytics.Profile.Events.FOLLOWERS_PRESSED, withProperties: properties)
            
        }
        
        static func trackBlockUser(userId : String) {
            
            let properties: [String : Any] = [Constants.Analytics.Main.Properties.TARGET_USER_ID : userId]
            trackEvent(Constants.Analytics.Profile.Events.BLOCK_USER, withProperties: properties)
            
        }
        
        static func trackUnBlockUser(userId : String) {
            
            let properties: [String : Any] = [Constants.Analytics.Main.Properties.TARGET_USER_ID : userId]
            trackEvent(Constants.Analytics.Profile.Events.UN_BLOCK_USER, withProperties: properties)
            
        }
        
        
        static func trackFollowingPressed(userId : String) {
            
            let properties: [String : Any] = [Constants.Analytics.Main.Properties.TARGET_USER_ID : userId]
            trackEvent(Constants.Analytics.Profile.Events.FOLLOWING_PRESSED, withProperties: properties)
            
        }
        
        static func trackDeleteDraftPressed(challengeId : String) {
            
            let properties: [String : Any] = [Constants.Analytics.Main.Properties.CHALLENGE_ID : challengeId]
            trackEvent(Constants.Analytics.Profile.Events.DELETE_DRAFT, withProperties: properties)
            
        }
        
        static func trackMentionSuccess(userIds : [String], contentType: Constants.ContentType?, contentId : String?, source : Constants.Analytics.Main.Properties.MENTION_LOCATION) {
            
           
            var properties: [String : Any] = [Constants.Analytics.Main.Properties.MENTION_LOCATION.key.rawValue : source.rawValue]
            
            if let contentType = contentType, let contentId = contentId {
                
                properties[Constants.Analytics.Main.Properties.CONTENT_TYPE.key.rawValue] = contentType.stringValue
                properties[Constants.Analytics.Main.Properties.ID] = contentId
                
            }
           
            for id in userIds {
                
                properties[Constants.Analytics.Main.Properties.TARGET_USER_ID] = id
                trackEvent(Constants.Analytics.Profile.Events.MENTION_SUCCESS, withProperties: properties)
            
            }
            
        }
        
        static func trackMentionPressed(userId : String, source : Constants.Analytics.Main.Properties.MENTION_LOCATION, contentType: Constants.ContentType? = nil, contentId : String? = nil) {
            
            var properties: [String : Any] = [Constants.Analytics.Main.Properties.TARGET_USER_ID : userId]
            properties[Constants.Analytics.Main.Properties.MENTION_LOCATION.key.rawValue] = source.rawValue
            
            if let contentType = contentType, let contentId = contentId {
                
                properties[Constants.Analytics.Main.Properties.CONTENT_TYPE.key.rawValue] = contentType.stringValue
                properties[Constants.Analytics.Main.Properties.ID] = contentId
            
            }
            
            trackEvent(Constants.Analytics.Profile.Events.MENTION_PRESSED, withProperties: properties)
            
        }
        
        static func trackHashtagPressed(tagName : String, source : Constants.Analytics.Main.Properties.MENTION_LOCATION, contentType: Constants.ContentType? = nil, contentId : String? = nil) {
            
            var properties: [String : Any] = [Constants.Analytics.Main.Properties.HASHTAG_NAME : tagName]
            properties[Constants.Analytics.Main.Properties.MENTION_LOCATION.key.rawValue] = source.rawValue
            
            if let contentType = contentType, let contentId = contentId {
                
                properties[Constants.Analytics.Main.Properties.CONTENT_TYPE.key.rawValue] = contentType.stringValue
                properties[Constants.Analytics.Main.Properties.ID] = contentId
                
            }
            
            trackEvent(Constants.Analytics.Profile.Events.HASHTAG_PRESSED, withProperties: properties)
            
        }
        
        static func trackBadgePressed(userId : String, badge : MBadge) {
            
            var properties: [String : Any] = [Constants.Analytics.Main.Properties.TARGET_USER_ID : userId]
            properties[Constants.Analytics.Main.Properties.BADGE] = badge.badgeId
            trackEvent(Constants.Analytics.Profile.Events.BADGE_PRESSED, withProperties: properties)
            
        }
        
        static func trackTabPressed(index: Int) {
            
            let properties = [Constants.Analytics.Main.Properties.TAB_INDEX : index]
            trackEvent(Constants.Analytics.Profile.Events.TAB_PRESSED, withProperties: properties)
            
        }
        
       
    }
    
}
