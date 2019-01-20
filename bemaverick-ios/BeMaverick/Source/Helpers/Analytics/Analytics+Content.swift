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
    
    class Content {
        
        private static func createContentProperties(_ contentType: Constants.ContentType, contentId : String, contentStyle : Constants.Analytics.Main
            .Properties.CONTENT_STYLE) -> [String : Any] {
            let properties: [String : Any] = [Constants.Analytics.Main.Properties.CONTENT_TYPE.key.rawValue : contentType.stringValue, Constants.Analytics.Main.Properties.ID : contentId, Constants.Analytics.Main
                .Properties.CONTENT_STYLE.key.rawValue : contentStyle.rawValue ]
            return properties
        }
        
        
        static func trackSmallItemPressed(_ contentType: Constants.ContentType, contentId : String, location : UIViewController) {
            
            var props = createContentProperties(contentType, contentId: contentId, contentStyle: .small)
            props = addLocationProperty(props, location: location)
            trackEvent(Constants.Analytics.Content.Events.MAIN_PRESSED, withProperties: props)
            
        }
        
        
        
        static func trackAuthorPressed(toAuthorId authorId: String, fromContentType contentType: Constants.ContentType, contentId : String, location : UIViewController, contentStyle : Constants.Analytics.Main
            .Properties.CONTENT_STYLE) {
            
            var props = createContentProperties(.response, contentId: contentId, contentStyle: contentStyle)
            props = addLocationProperty(props, location: location)
            
            props[Constants.Analytics.Main.Properties.AUTHOR_ID] = authorId
            trackEvent(Constants.Analytics.Content.Events.AUTHOR_PRESSED, withProperties: props)
            
        }
        
        
        
        static func trackBadgesOpened(_ contentType: Constants.ContentType, contentId : String, contentStyle : Constants.Analytics.Main
            .Properties.CONTENT_STYLE) {
            
            let props = createContentProperties(contentType, contentId: contentId, contentStyle: contentStyle)
            trackEvent(Constants.Analytics.Content.Events.RESPONSE_BADGES_PRESSED, withProperties: props)
            
        }
        
        static func trackMainPressed(_ contentType: Constants.ContentType, contentId : String, location : UIViewController, contentStyle : Constants.Analytics.Main
            .Properties.CONTENT_STYLE) {
            
            var props = createContentProperties(.response, contentId: contentId, contentStyle: contentStyle)
            props = addLocationProperty(props, location: location)
            
            trackEvent(Constants.Analytics.Content.Events.MAIN_PRESSED, withProperties: props)
            
        }
        
        static func trackResponseBadgeBagPressed( contentId : String, location : UIViewController, contentStyle : Constants.Analytics.Main
            .Properties.CONTENT_STYLE) {
            
            var props = createContentProperties(.response, contentId: contentId, contentStyle: contentStyle)
            props = addLocationProperty(props, location: location)
            trackEvent(Constants.Analytics.Content.Events.RESPONSE_BADGE_BAG_PRESSED, withProperties: props)
            
        }
        
        static func trackBadgeTapped(responseId : String, badge : MBadge, location : UIViewController, isBadged : Bool, contentStyle : Constants.Analytics.Main
            .Properties.CONTENT_STYLE) {
            
            var props = createContentProperties(.response, contentId: responseId, contentStyle: contentStyle)
            props = addLocationProperty(props, location: location)
            props = AnalyticsManager.addEventSourceProperties(props)
            props[Constants.Analytics.Main.Properties.BADGE] = badge.badgeId
            
            if isBadged {
                
                FeaturedStreamViewController.hasBadgedThisSession = true
              trackEvent(Constants.Analytics.Content.Events.RESPONSE_BADGE_GIVEN, withProperties: props)
                
            } else {
                trackEvent(Constants.Analytics.Content.Events.RESPONSE_BADGE_REMOVED, withProperties: props)
                
            }
            
        }
        
        
        static func trackShowCommentsPressed(_ contentType: Constants.ContentType, contentId : String, location : UIViewController, contentStyle : Constants.Analytics.Main
            .Properties.CONTENT_STYLE) {
            
            var props = createContentProperties(contentType, contentId: contentId, contentStyle: contentStyle)
            props = addLocationProperty(props, location: location)
            trackEvent(Constants.Analytics.Content.Events.COMMENTS_SHOW_PRESSED, withProperties: props)
            
        }
        
        static func trackAddCommentPressed(_ contentType: Constants.ContentType, contentId : String, location : UIViewController, contentStyle : Constants.Analytics.Main
            .Properties.CONTENT_STYLE) {
            
            var props = createContentProperties(contentType, contentId: contentId, contentStyle: contentStyle)
            props = addLocationProperty(props, location: location)
            
            trackEvent(Constants.Analytics.Content.Events.COMMENTS_ADD_PRESSED, withProperties: props)
            
        }
        
        static func trackFavoriteResponsePressed(_ contentType: Constants.ContentType, contentId : String, location : UIViewController, contentStyle : Constants.Analytics.Main
            .Properties.CONTENT_STYLE, isFavorite : Bool) {
            
            var props = createContentProperties(contentType, contentId: contentId, contentStyle: contentStyle)
            props = addLocationProperty(props, location: location)
            
            if isFavorite {
                
                trackEvent(Constants.Analytics.Content.Events.CATALYST_FAVORITE_PRESSED, withProperties: props)
            
            } else {
            
                trackEvent(Constants.Analytics.Content.Events.CATALYST_UN_FAVORITE_PRESSED, withProperties: props)
                
            }
            
           
            
        }
        
       
        static func trackViewChallengePressed(forChallenge challengeId: String, contentType: Constants.ContentType, contentId : String, location : UIViewController, contentStyle : Constants.Analytics.Main
            .Properties.CONTENT_STYLE) {
            
            var props = createContentProperties(contentType, contentId: contentId, contentStyle: contentStyle)
            props[Constants.Analytics.Main.Properties.CHALLENGE_ID] = challengeId
            props = addLocationProperty(props, location: location)
            
            trackEvent(Constants.Analytics.Content.Events.VIEW_CHALLENGE_PRESSED, withProperties: props)
            
        }
        static func trackChallengeTitlePressed(forChallenge challengeId: String, contentType: Constants.ContentType, contentId : String, location : UIViewController, contentStyle : Constants.Analytics.Main
            .Properties.CONTENT_STYLE) {
            
            var props = createContentProperties(contentType, contentId: contentId, contentStyle: contentStyle)
            props[Constants.Analytics.Main.Properties.CHALLENGE_ID] = challengeId
            props = addLocationProperty(props, location: location)
            
            trackEvent(Constants.Analytics.Content.Events.CHALLENGE_TITLE_PRESSED, withProperties: props)
            
        }
        
        static func trackChallengeExpireTimePressed(forChallenge challengeId: String, contentType: Constants.ContentType, contentId : String, location : UIViewController, contentStyle : Constants.Analytics.Main
            .Properties.CONTENT_STYLE) {
            
            var props = createContentProperties(contentType, contentId: contentId, contentStyle: contentStyle)
            props[Constants.Analytics.Main.Properties.CHALLENGE_ID] = challengeId
            props = addLocationProperty(props, location: location)
            trackEvent(Constants.Analytics.Content.Events.CHALLENGE_EXPIRE_TIME_PRESSED, withProperties: props)
            
        }
        
        static func trackChallengeResponsesPressed(forChallenge challengeId: String, contentType: Constants.ContentType, contentId : String, location : UIViewController, contentStyle : Constants.Analytics.Main
            .Properties.CONTENT_STYLE) {
            
            var props = createContentProperties(contentType, contentId: contentId, contentStyle : contentStyle)
            props[Constants.Analytics.Main.Properties.CHALLENGE_ID] = challengeId
            props = addLocationProperty(props, location: location)
            
            trackEvent(Constants.Analytics.Content.Events.CHALLENGE_RESPONSES_PRESSED, withProperties: props)
            
        }
        
        static func trackPromoPressed(streamId: String, label: String) {
            
            var props = ["ID":streamId, "NAME":label]
            
            trackEvent(Constants.Analytics.Content.Events.PROMO_PRESSED, withProperties: props)
            
        }
        
        
        static func trackSavePressed(_ contentType: Constants.ContentType, contentId : String, location : UIViewController, contentStyle : Constants.Analytics.Main
            .Properties.CONTENT_STYLE, isSaved : Bool) {
            
            var props = createContentProperties(contentType, contentId: contentId, contentStyle: contentStyle)
            props = addLocationProperty(props, location: location)
            
            if isSaved {
                trackEvent(Constants.Analytics.Content.Events.SAVE_PRESSED, withProperties: props)
            } else {
                trackEvent(Constants.Analytics.Content.Events.UN_SAVE_PRESSED, withProperties: props)
                
            }
            
        }
        
        static func trackSharePressed(_ contentType: Constants.ContentType, contentId : String, location : UIViewController, contentStyle : Constants.Analytics.Main
            .Properties.CONTENT_STYLE) {
            
            var props = createContentProperties(contentType, contentId: contentId, contentStyle: contentStyle)
            props = addLocationProperty(props, location: location)
            
            trackEvent(Constants.Analytics.Content.Events.SHARE_PRESSED, withProperties: props)
            
        }
        
        static func trackLinkPressed(_ contentType: Constants.ContentType, contentId : String, location : UIViewController) {
            
            var props: [String : Any] = [Constants.Analytics.Main.Properties.CONTENT_TYPE.key.rawValue : contentType.stringValue, Constants.Analytics.Main.Properties.ID : contentId]
            
            props = addLocationProperty(props, location: location)
            
            trackEvent(Constants.Analytics.Content.Events.LINK_PRESSED, withProperties: props)
            
        }
        
        
        static func trackMutePressed(_ contentType: Constants.ContentType, contentId : String, location : UIViewController, contentStyle : Constants.Analytics.Main
            .Properties.CONTENT_STYLE, isMuted : Bool) {
            
            var props = createContentProperties(contentType, contentId: contentId, contentStyle: contentStyle)
            props = addLocationProperty(props, location: location)
            props["muted"] = isMuted
    
                trackEvent(Constants.Analytics.Content.Events.MUTE_PRESSED, withProperties: props)
            
            
        }
        
        static func trackFeaturedPageHorizontalScrollPosition(rowPositions : [Int : Int]) {
            
            var properties: [String : Any] = [:]
            for rowInfo in rowPositions.keys {
                
                properties[Constants.Analytics.Main.Properties.COLUMN] = rowPositions[rowInfo]
                properties[Constants.Analytics.Main.Properties.ROW] = rowInfo
                 trackEvent(Constants.Analytics.Main.Events.FEATURED_STREAM_HORIZONTAL_SCROLL_POSITION, withProperties: properties)
            }
            
        }
        
        static func trackFeaturedPageVerticalScrollPosition(maxRow : Int){
            var properties: [String : Any] = [Constants.Analytics.Main.Properties.ROW : maxRow]
            
            trackEvent(Constants.Analytics.Main.Events.FEATURED_STREAM_VERTICAL_SCROLL_POSITION, withProperties: properties)
            
        }
        
    }

}
