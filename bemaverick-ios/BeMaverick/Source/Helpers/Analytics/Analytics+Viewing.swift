//
//  Analytics+Viewing.swift
//  Maverick
//
//  Created by Chris Garvey on 6/6/18.
//  Copyright © 2018 BeMaverick. All rights reserved.
//

extension AnalyticsManager {
    
    class Viewing {
        
        static func trackVideoStart(contentType: Constants.Analytics.Main.Properties.CONTENT_TYPE, contentID: String, challengeID: String? = nil, isMuted: Bool, startTime: Float64 = 0, bufferTime: UInt64) {
            
            var properties = createBasicPropertyDictionary(contentType: contentType, contentID: contentID, challengeID: challengeID, isMuted: isMuted)
            
            properties[Constants.Analytics.Viewing.Properties.START_TIME] = startTime == 0 ? "0" : String(format: "%.2f", startTime)
            
            properties[Constants.Analytics.Viewing.Properties.BUFFER_TIME_MS] = String(bufferTime)
            
            trackEvent(Constants.Analytics.Viewing.Events.VIDEO_START, withProperties: properties)
            
        }
        
        static func trackVideoStop(contentType: Constants.Analytics.Main.Properties.CONTENT_TYPE, contentID: String, challengeID: String? = nil, isMuted: Bool, stopTime: Float64, viewingDuration: Float64) {
            
            var properties = createBasicPropertyDictionary(contentType: contentType, contentID: contentID, challengeID: challengeID, isMuted: isMuted)
            
            properties[Constants.Analytics.Viewing.Properties.STOP_TIME] = String(format: "%.2f", stopTime)
            
            properties[Constants.Analytics.Viewing.Properties.VIEWING_DURATION] = String(format: "%.2f", viewingDuration)
            
            trackEvent(Constants.Analytics.Viewing.Events.VIDEO_STOP, withProperties: properties)
            
        }
        
        static func trackVideoResume(contentType: Constants.Analytics.Main.Properties.CONTENT_TYPE, contentID: String, challengeID: String? = nil, isMuted: Bool, startTime: Float64) {
            
            var properties = createBasicPropertyDictionary(contentType: contentType, contentID: contentID, challengeID: challengeID, isMuted: isMuted)
            
            properties[Constants.Analytics.Viewing.Properties.START_TIME] = String(format: "%.2f", startTime)
            
            trackEvent(Constants.Analytics.Viewing.Events.VIDEO_RESUME, withProperties: properties)
            
        }
        
        static func trackVideoReplay(contentType: Constants.Analytics.Main.Properties.CONTENT_TYPE, contentID: String, challengeID: String? = nil, isMuted: Bool) {
            
            let properties = createBasicPropertyDictionary(contentType: contentType, contentID: contentID, challengeID: challengeID, isMuted: isMuted)
            
            trackEvent(Constants.Analytics.Viewing.Events.VIDEO_REPLAY, withProperties: properties)
            
        }
        
        static func trackVideoComplete(contentType: Constants.Analytics.Main.Properties.CONTENT_TYPE, contentID: String, challengeID: String? = nil, isMuted: Bool) {
            
            let properties = createBasicPropertyDictionary(contentType: contentType, contentID: contentID, challengeID: challengeID, isMuted: isMuted)
            
            trackEvent(Constants.Analytics.Viewing.Events.VIDEO_COMPLETE, withProperties: properties)
            
        }
        
        static func trackVideoProgress25(contentType: Constants.Analytics.Main.Properties.CONTENT_TYPE, contentID: String, challengeID: String? = nil, isMuted: Bool) {
            
            let properties = createBasicPropertyDictionary(contentType: contentType, contentID: contentID, challengeID: challengeID, isMuted: isMuted)
            
            trackEvent(Constants.Analytics.Viewing.Events.VIDEO_PROGRESS_25, withProperties: properties)
            
        }
        
        static func trackVideoProgress50(contentType: Constants.Analytics.Main.Properties.CONTENT_TYPE, contentID: String, challengeID: String? = nil, isMuted: Bool) {
            
            let properties = createBasicPropertyDictionary(contentType: contentType, contentID: contentID, challengeID: challengeID, isMuted: isMuted)
            
            trackEvent(Constants.Analytics.Viewing.Events.VIDEO_PROGRESS_50, withProperties: properties)
            
        }
        
        static func trackVideoProgress75(contentType: Constants.Analytics.Main.Properties.CONTENT_TYPE, contentID: String, challengeID: String? = nil, isMuted: Bool) {
            
            let properties = createBasicPropertyDictionary(contentType: contentType, contentID: contentID, challengeID: challengeID, isMuted: isMuted)
            
            trackEvent(Constants.Analytics.Viewing.Events.VIDEO_PROGRESS_75, withProperties: properties)
            
        }
        
    }
    
}

fileprivate func createBasicPropertyDictionary(contentType: Constants.Analytics.Main.Properties.CONTENT_TYPE, contentID: String, challengeID: String?, isMuted: Bool) -> [String:Any] {
    
    var properties: [String:Any] =
        [Constants.Analytics.Main.Properties.CONTENT_TYPE.key.rawValue: contentType.rawValue,
         Constants.Analytics.Main.Properties.ID: contentID,
         Constants.Analytics.Viewing.Properties.IS_MUTED: isMuted ? "TRUE" : "FALSE",
         Constants.Analytics.Viewing.Properties.LOCATION: AnalyticsManager.mostRecentScreen
         ]
    
    if let id = challengeID {
        properties[Constants.Analytics.Main.Properties.CHALLENGE_ID] = id
    }
    
    return properties
    
}
