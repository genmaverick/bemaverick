//
//  AnalyticsOnboarding.swift
//  BeMaverick
//
//  Created by Garrett Fritz on 2/5/18.
//  Copyright © 2018 BeMaverick. All rights reserved.
//

import Foundation

extension AnalyticsManager {
    
    class Comments {
        
        static func trackCommentSuccess(_ contentType: Constants.ContentType, contentId : String) {
            
            let properties: [String : Any] = [Constants.Analytics.Main.Properties.CONTENT_TYPE.key.rawValue : contentType.rawValue, Constants.Analytics.Main.Properties.ID : contentId ]
            
            trackEvent(Constants.Analytics.Comment.Events.COMMENT_SEND_SUCCESS, withProperties: properties)
            
        }
        
        static func trackCommentFail(_ contentType: Constants.ContentType, contentId : String, apiFailure : Bool, reason : String) {
            
            var properties: [String : Any] = [Constants.Analytics.Main.Properties.CONTENT_TYPE.key.rawValue : contentType.rawValue, Constants.Analytics.Main.Properties.ID : contentId ]
            
            properties[Constants.Analytics.Main.Properties.FAILURE_REASON] = reason
            properties[Constants.Analytics.Main.Properties.FAILURE_TYPE.key.rawValue] = apiFailure ? Constants.Analytics.Main.Properties.FAILURE_TYPE.api.rawValue : Constants.Analytics.Main.Properties.FAILURE_TYPE.user.rawValue
            
            trackEvent(Constants.Analytics.Comment.Events.COMMENT_SEND_FAIL, withProperties: properties)
            
        }
        
        static func trackCommentSendPressed(_ contentType: Constants.ContentType, contentId : String) {
            
            let properties: [String : Any] = [Constants.Analytics.Main.Properties.CONTENT_TYPE.key.rawValue : contentType.rawValue, Constants.Analytics.Main.Properties.ID : contentId ]
            
            trackEvent(Constants.Analytics.Comment.Events.COMMENT_SEND_PRESSED, withProperties: properties)
            
        }
        
        static func trackCommentEntryStarted(_ contentType: Constants.ContentType, contentId : String) {
            
            let properties: [String : Any] = [Constants.Analytics.Main.Properties.CONTENT_TYPE.key.rawValue : contentType.rawValue, Constants.Analytics.Main.Properties.ID : contentId ]
            
            trackEvent(Constants.Analytics.Comment.Events.COMMENT_ENTRY_STARTED, withProperties: properties)
            
        }
        
        static func trackCommentDeleted(_ contentType: Constants.ContentType, contentId : String) {
            
            let properties: [String : Any] = [Constants.Analytics.Main.Properties.CONTENT_TYPE.key.rawValue : contentType.rawValue, Constants.Analytics.Main.Properties.ID : contentId ]
            
            
            
            trackEvent(Constants.Analytics.Comment.Events.COMMENT_DELEED, withProperties: properties)
            
        }
        
        static func trackCommentReported(_ contentType: Constants.ContentType, contentId : String, rationale : String) {
            
            var properties: [String : Any] = [Constants.Analytics.Main.Properties.CONTENT_TYPE.key.rawValue : contentType.rawValue, Constants.Analytics.Main.Properties.ID : contentId ]
            
            properties[Constants.Analytics.Main.Properties.REPORT_RATIONALE] = rationale
            
            trackEvent(Constants.Analytics.Comment.Events.COMMENT_REPORTED, withProperties: properties)
            
        }
        
        static func trackBlockCommentAuthor(_ contentType: Constants.ContentType, contentId : String, authorId : String) {
            
            var properties: [String : Any] = [Constants.Analytics.Main.Properties.CONTENT_TYPE.key.rawValue : contentType.rawValue, Constants.Analytics.Main.Properties.ID : contentId ]
            
            properties[Constants.Analytics.Main.Properties.AUTHOR_ID] = authorId
            
            trackEvent(Constants.Analytics.Comment.Events.COMMENT_AUTHOR_BLOCKED, withProperties: properties)
            
        }
        
        static func trackCommentItemTapped(_ contentType: Constants.ContentType, contentId : String, authorId : String) {
            
            var properties: [String : Any] = [Constants.Analytics.Main.Properties.CONTENT_TYPE.key.rawValue : contentType.rawValue, Constants.Analytics.Main.Properties.ID : contentId ]
            
            properties[Constants.Analytics.Main.Properties.AUTHOR_ID] = authorId
            
            trackEvent(Constants.Analytics.Comment.Events.COMMENT_TAPPED, withProperties: properties)
            
        }
        
        
    }
    
}
