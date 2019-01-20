//
//  AnalyticsOnboarding.swift
//  BeMaverick
//
//  Created by Garrett Fritz on 2/5/18.
//  Copyright © 2018 BeMaverick. All rights reserved.
//

import Foundation

extension AnalyticsManager {
    
    class Settings {
        
        static func trackUpdateSettings() {
            
        }
        
        static func trackLogoutPressed() {
            
            trackEvent(Constants.Analytics.Settings.Events.SETTINGS_PROFILE_LOGOUT)
            
        }
        
        static func trackEditProfileSavePressed() {
            
            trackEvent(Constants.Analytics.Settings.Events.SETTINGS_PROFILE_SAVE_PRESSED)
            
        }
        
        static func trackEditCoverBackPressed() {
            
            let properties = [Constants.Analytics.Main.Properties.LOCATION : Constants.Analytics.Settings.Screens.SETTINGS_COVER_MAVERICK]
            trackEvent(Constants.Analytics.Main.Events.BACK_PRESSED, withProperties: properties)
            
        }
        
        static func trackEditProfileBackPressed() {
            
            let properties = [Constants.Analytics.Main.Properties.LOCATION : Constants.Analytics.Settings.Screens.SETTINGS_PROFILE]
            trackEvent(Constants.Analytics.Main.Events.BACK_PRESSED, withProperties: properties)
            
        }
        
        static func trackEditProfileCancelPressed() {
            
            trackEvent(Constants.Analytics.Settings.Events.SETTINGS_PROFILE_CANCEL_PRESSED)
            
        }
        
        static func trackDeactivateProfilePressed() {
            
            trackEvent(Constants.Analytics.Settings.Events.SETTINGS_PROFILE_DEACTIVATE_PRESSED)
            
        }
        
        static func trackEditCoverPressed() {
            
            trackEvent(Constants.Analytics.Settings.Events.SETTINGS_PROFILE_EDIT_COVER_PRESSED)
            
        }
        
        static func trackSaveCoverPressed() {
            
            trackEvent(Constants.Analytics.Settings.Events.SETTINGS_COVER_SAVE_PRESSED)
            
        }
        
        static func trackCancelCoverPressed() {
            
            trackEvent(Constants.Analytics.Settings.Events.SETTINGS_COVER_CANCEL_PRESSED)
            
        }
        
        static func trackSavePasswordPressed() {
            
            trackEvent(Constants.Analytics.Settings.Events.SETTINGS_PASSWORD_SAVE_PRESSED)
            
        }
        
        static func trackEditEmailPressed() {
            
            trackEvent(Constants.Analytics.Settings.Events.SETTINGS_PROFILE_EMAIL_PRESSED)
            
        }
        
        static func trackEditUserNamePressed() {
            
            trackEvent(Constants.Analytics.Settings.Events.SETTINGS_PROFILE_USERNAME_PRESSED)
            
        }
        
        static func trackUpdatePasswordBackPressed() {
            
            let properties = [Constants.Analytics.Main.Properties.LOCATION : Constants.Analytics.Settings.Screens.SETTINGS_PASSWORD]
            trackEvent(Constants.Analytics.Main.Events.BACK_PRESSED, withProperties: properties)
            
        }
        
        static func trackCancelPasswordPressed() {
            
            trackEvent(Constants.Analytics.Settings.Events.SETTINGS_PASSWORD_CANCEL_PRESSED)
            
        }
        
       
        
    }
    
}
