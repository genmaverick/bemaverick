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
    
    class CreateChallenge {
        
        static func trackCreateCTA( location : Constants.Analytics.CreateChallenge.Properties.CTA_LOCATION) {
            
            let properties : [String : Any] = [Constants.Analytics.CreateChallenge.Properties.CTA_LOCATION.key.rawValue : location.rawValue]
            
            trackEvent(Constants.Analytics.CreateChallenge.Events.CREATE_CHALLENGE_CTA_PRESSED, withProperties: properties)
            
        }
        
        static func trackCreateBlocked( remainingBadges : Int, remainingResponses: Int) {
            
            let properties: [String : Any] = [
                
                Constants.Analytics.CreateChallenge.Properties.REMAINING_BADGES : remainingBadges,
                Constants.Analytics.CreateChallenge.Properties.REMAINING_RESPONSES : remainingResponses
                
            ]
            
            trackEvent(Constants.Analytics.CreateChallenge.Events.CREATE_CHALLENGE_BLOCKED, withProperties: properties)
            
        }
        
        static func trackCreateLearnMorePressed() {
            
            trackEvent(Constants.Analytics.CreateChallenge.Events.CREATE_CHALLENGE_LEARN_PRESSED)
            
        }
        
        static func trackCameraPressed() {
             trackEvent(Constants.Analytics.CreateChallenge.Events.CREATE_CHALLENGE_CAMERA_TAPPED_PRESSED)
            
        }
        
        static func trackCameraFlipped() {
            trackEvent(Constants.Analytics.CreateChallenge.Events.CREATE_CHALLENGE_CAMERA_FLIPPED_PRESSED)
            
        }
        
        static func trackThemeChanged() {
            trackEvent(Constants.Analytics.CreateChallenge.Events.CREATE_CHALLENGE_THEME_CHANGED)
            
        }
        
        static func trackLockedThemePressed(themeName: String, remainingBadges : Int, remainingResponses: Int) {
            
            let properties: [String : Any] = [
             Constants.Analytics.CreateChallenge.Properties.THEME_NAME : themeName,
                Constants.Analytics.CreateChallenge.Properties.REMAINING_BADGES : remainingBadges,
                Constants.Analytics.CreateChallenge.Properties.REMAINING_RESPONSES : remainingResponses
                
            ]
            
            trackEvent(Constants.Analytics.CreateChallenge.Events.CREATE_CHALLENGE_LOCKED_THEME_PRESSED, withProperties: properties)
            
        }
        
        static func trackCreateFail(apiFailure : Bool, reason : String) {
            
            var properties: [String : Any] = [:]
            
            properties[Constants.Analytics.Main.Properties.FAILURE_REASON] = reason
            properties[Constants.Analytics.Main.Properties.FAILURE_TYPE.key.rawValue] = apiFailure ? Constants.Analytics.Main.Properties.FAILURE_TYPE.api.rawValue : Constants.Analytics.Main.Properties.FAILURE_TYPE.user.rawValue
            
            trackEvent(Constants.Analytics.CreateChallenge.Events.CREATE_CHALLENGE_CREATE_FAILED, withProperties: properties)
            
        }
        
        static func trackCreateThemePressed() {
            trackEvent(Constants.Analytics.CreateChallenge.Events.CREATE_CHALLENGE_CREATE_PRESSED)
            
        }
        
        static func trackCreateChallengeSuccess(challengeId : String, hasPhoto : Bool, themeName: String, charCount : Int, mentions : Int, hasTitle : Bool, hasLink : Bool, hasDescription : Bool) {
           
            var properties: [String : Any] = [:]
            
            properties[Constants.Analytics.CreateChallenge.Properties.THEME_NAME] = themeName
            
            properties[Constants.Analytics.CreateChallenge.Properties.HAS_PHOTO] = hasPhoto ? "true" : "false"
            properties[Constants.Analytics.Main.Properties.ID] = challengeId
            
            properties[Constants.Analytics.CreateChallenge.Properties.CHARACTERS] = charCount
            
            properties[Constants.Analytics.CreateChallenge.Properties.HAS_DESCRIPTION] = hasDescription ? "true" : "false"
            properties[Constants.Analytics.CreateChallenge.Properties.HAS_TITLE] = hasTitle ? "true" : "false"
            properties[Constants.Analytics.CreateChallenge.Properties.HAS_LINK] = hasLink ? "true" : "false"
            properties[Constants.Analytics.CreateChallenge.Properties.MENTION_COUNT] = mentions
            properties[Constants.Analytics.Main.Properties.ID] = challengeId
            
            
            trackEvent(Constants.Analytics.CreateChallenge.Events.CREATE_CHALLENGE_CREATE_SUCCESS, withProperties: properties)
            
        }
        
        static func trackEditChallengeClose() {
            
            trackEvent(Constants.Analytics.CreateChallenge.Events.EDIT_CHALLENGE_CLOSE)
            
        }
        
        static func trackEditChallengeSearchPressed() {
            
            trackEvent(Constants.Analytics.CreateChallenge.Events.EDIT_CHALLENGE_SEARCH_PRESSED)
            
        }
        
      
        static func trackCreateChallengeCommitLinkPressed() {
            
            trackEvent(Constants.Analytics.CreateChallenge.Events.CREATE_CHALLENGE_COMMIT_LINK_PRESSED)
            
        }
        static func trackCreateChallengeCreateLinkPressed() {
            
            trackEvent(Constants.Analytics.CreateChallenge.Events.CREATE_CHALLENGE_CREATE_LINK_PRESSED)
            
        }
        static func trackCreateChallengeClearLinkPressed() {
            
            trackEvent(Constants.Analytics.CreateChallenge.Events.CREATE_CHALLENGE_CLEAR_LINK_PRESSED)
            
        }
        
        static func trackEditChallengeCreateLinkPressed() {
            
            trackEvent(Constants.Analytics.CreateChallenge.Events.EDIT_CHALLENGE_CREATE_LINK_PRESSED)
            
        }
        static func trackEditChallengeClearLinkPressed() {
            
            trackEvent(Constants.Analytics.CreateChallenge.Events.EDIT_CHALLENGE_CLEAR_LINK_PRESSED)
            
        }
        
        static func trackEditChallengeInvitePressed() {
            
            trackEvent(Constants.Analytics.CreateChallenge.Events.EDIT_CHALLENGE_INVITE_PRESSED)
            
        }
        
        static func trackEditChallengeSave(challengeId : String, mentions : Int, hasTitle : Bool, hasLink : Bool, hasDescription : Bool) {
            
            var properties: [String : Any] = [:]
            
            properties[Constants.Analytics.CreateChallenge.Properties.HAS_DESCRIPTION] = hasDescription ? "true" : "false"
              properties[Constants.Analytics.CreateChallenge.Properties.HAS_TITLE] = hasTitle ? "true" : "false"
            properties[Constants.Analytics.CreateChallenge.Properties.HAS_LINK] = hasLink ? "true" : "false"
            properties[Constants.Analytics.CreateChallenge.Properties.MENTION_COUNT] = mentions
            properties[Constants.Analytics.Main.Properties.ID] = challengeId
            
            
            trackEvent(Constants.Analytics.CreateChallenge.Events.EDIT_CHALLENGE_SAVE, withProperties: properties)
            
        }
        
        
    }
    
    
    class Challenge {
        
        static func trackMainPressed( challengeId : String) {
          
            let properties = [Constants.Analytics.Main.Properties.CHALLENGE_ID : challengeId]
            
            trackEvent(Constants.Analytics.Challenge.Events.MAIN_PRESSED, withProperties: properties)
            
        }
        
        static func trackAuthorPressed(challengeId : String, authorId: String) {
            
            let properties = [Constants.Analytics.Main.Properties.CHALLENGE_ID : challengeId,
                              Constants.Analytics.Main.Properties.AUTHOR_ID : authorId]
            
            trackEvent(Constants.Analytics.Challenge.Events.AUTHOR_PRESSED, withProperties: properties)
            
        }
        
        
        static func trackSummaryHeaderPressed(challengeId : String) {
            
            let properties = [Constants.Analytics.Main.Properties.CHALLENGE_ID : challengeId]
            
            trackEvent(Constants.Analytics.Challenge.Events.SUMARY_HEADER_PRESSED, withProperties: properties)
            
        }
        
        
        static func trackEditInvitePressed(challengeId : String) {
            
            let properties = [Constants.Analytics.Main.Properties.CHALLENGE_ID : challengeId]
            
            trackEvent(Constants.Analytics.Challenge.Events.EDIT_INVITE, withProperties: properties)
            
        }
        
        static func trackShowResponsesPressed(challengeId : String) {
            
            let properties = [Constants.Analytics.Main.Properties.CHALLENGE_ID : challengeId]
            
            trackEvent(Constants.Analytics.Challenge.Events.SHOW_RESPONSES, withProperties: properties)
            
        }
        
        static func trackOverflowMenuPressed(challengeId : String) {
            
            let properties = [Constants.Analytics.Main.Properties.CHALLENGE_ID : challengeId]
            
            trackEvent(Constants.Analytics.Challenge.Events.OVERFLOW_PRESSED, withProperties: properties)
            
        }
        
        
        static func trackSavePressed(challengeId : String, isSaved : Bool) {
            
            let properties = [Constants.Analytics.Main.Properties.CHALLENGE_ID : challengeId]
            
            if isSaved {
            trackEvent(Constants.Analytics.Challenge.Events.SAVE_PRESSED, withProperties: properties)
            } else {
                
            
                trackEvent(Constants.Analytics.Challenge.Events.UN_SAVE_PRESSED, withProperties: properties)
                
            }
            
        }
        
        static func trackShowCommentsPressed( challengeId : String) {
            
            let properties = [Constants.Analytics.Main.Properties.CHALLENGE_ID : challengeId]
            
            trackEvent(Constants.Analytics.Challenge.Events.COMMENTS_SHOW_PRESSED, withProperties: properties)
            
        }
        
        static func trackSharePressed( challengeId : String) {
            
            let properties = [Constants.Analytics.Main.Properties.CHALLENGE_ID : challengeId]
            
            trackEvent(Constants.Analytics.Challenge.Events.SHARE_PRESSED, withProperties: properties)
            
        }
        
    }

}
