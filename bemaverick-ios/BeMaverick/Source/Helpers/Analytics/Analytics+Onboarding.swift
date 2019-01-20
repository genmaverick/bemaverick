//
//  AnalyticsOnboarding.swift
//  BeMaverick
//
//  Created by Garrett Fritz on 2/5/18.
//  Copyright © 2018 BeMaverick. All rights reserved.
//

import Foundation
import Crashlytics

extension AnalyticsManager {
    
     class Onboarding {
        
        static func trackVPCInfoFailure(apiFailure : Bool, reason : String) {
            
            var props : [String : Any] = [:]
            props[Constants.Analytics.Main.Properties.FAILURE_REASON] = reason
            props[Constants.Analytics.Main.Properties.FAILURE_TYPE.key.rawValue] = apiFailure ? Constants.Analytics.Main.Properties.FAILURE_TYPE.api.rawValue : Constants.Analytics.Main.Properties.FAILURE_TYPE.user.rawValue
            
            trackEvent(Constants.Analytics.Onboarding.Events.VPC_INFO_ENTRY_SUBMIT_FAIL, withProperties: props)
            
        }
        
        static func trackVPCInfoSuccess() {
            
            trackEvent(Constants.Analytics.Onboarding.Events.VPC_INFO_ENTRY_SUBMIT_SUCCESS)
            
        }
        
        
        static func trackVPCPermissionGrantFailure(apiFailure : Bool, reason : String) {
            
            var props : [String : Any] = [:]
            props[Constants.Analytics.Main.Properties.FAILURE_REASON] = reason
            props[Constants.Analytics.Main.Properties.FAILURE_TYPE.key.rawValue] = apiFailure ? Constants.Analytics.Main.Properties.FAILURE_TYPE.api.rawValue : Constants.Analytics.Main.Properties.FAILURE_TYPE.user.rawValue
            
            trackEvent(Constants.Analytics.Onboarding.Events.VPC_VPC_ACCESS_GRANT_SUBMIT_FAIL, withProperties: props)
            
        }
        
        static func trackVPCPermissionGrantSuccess() {
            
            trackEvent(Constants.Analytics.Onboarding.Events.VPC_VPC_ACCESS_GRANT_SUBMIT_SUCCESS)
            
        }
        
        static func trackInviteOpened(_ date : String, source : String) {
            
            var props : [String : Any] = [:]
            props[Constants.Analytics.Main.Properties.INVITE_SOURCE] = source
            props[Constants.Analytics.Main.Properties.INVITE_DATE] = date
            trackEvent(Constants.Analytics.Onboarding.Events.INVITE_OPENED, withProperties: props)
            
        }
        
        static func trackLoginSuccess() {
            
           trackEvent(Constants.Analytics.Onboarding.Events.LOGIN_SUCCESS)
          
        }
        
        static func trackSignupSuccess() {
            
            trackEvent(Constants.Analytics.Onboarding.Events.SIGNUP_SUCCESS)
            
        }
        
        static func trackSplashPageChange(index : Int) {
            
            var props : [String : Any] = [:]
            props[Constants.Analytics.Main.Properties.TAB_INDEX] = index
            trackEvent(Constants.Analytics.Onboarding.Events.SPLASH_PAGE_CHANGED, withProperties: props)
            
        }
        
        static func trackSignupBlocked(email : String, reason : String) {
            
            var props : [String : Any] = [:]
            
            props[Constants.Analytics.Main.Properties.FAILURE_REASON] = reason
            props[Constants.Analytics.Profile.Properties.EMAIL] = email
            trackEvent(Constants.Analytics.Onboarding.Events.SIGNUP_EMAIL_FAIL, withProperties: props)
            
        }
        
        static func trackSignupFailure(apiFailure : Bool, reason : String, mode : SignupMode, channel : Constants.Analytics.Invite.Properties.CONTACT_TYPE) {
            
            var props : [String : Any] = [:]
            props[Constants.Analytics.Main.Properties.FAILURE_REASON] = reason
            
            props[Constants.Analytics.Invite.Properties.CONTACT_TYPE.key.rawValue] = channel.rawValue
            
            var event = Constants.Analytics.Onboarding.Events.SIGNUP_INITIAL_FAIL
            switch mode {
                
            case .initial:
                event = Constants.Analytics.Onboarding.Events.SIGNUP_INITIAL_FAIL
                
            case .birthdate:
                event = Constants.Analytics.Onboarding.Events.SIGNUP_DOB_FAIL
                
            case .email:
                event = Constants.Analytics.Onboarding.Events.SIGNUP_EMAIL_FAIL
                
            case .username:
                return
                
            }
            props[Constants.Analytics.Main.Properties.FAILURE_TYPE.key.rawValue] = apiFailure ? Constants.Analytics.Main.Properties.FAILURE_TYPE.api.rawValue : Constants.Analytics.Main.Properties.FAILURE_TYPE.user.rawValue
            
            trackEvent(event, withProperties: props)
            
        }
        
        static func trackLoginFailure(apiFailure : Bool, reason : String, channel : Constants.Analytics.Invite.Properties.CONTACT_TYPE) {
            
            var props : [String : Any] = [:]
            props[Constants.Analytics.Main.Properties.FAILURE_REASON] = reason
            props[Constants.Analytics.Main.Properties.FAILURE_TYPE.key.rawValue] = apiFailure ? Constants.Analytics.Main.Properties.FAILURE_TYPE.api.rawValue : Constants.Analytics.Main.Properties.FAILURE_TYPE.user.rawValue
            props[Constants.Analytics.Invite.Properties.CONTACT_TYPE.key.rawValue] = channel.rawValue
            
            trackEvent(Constants.Analytics.Onboarding.Events.LOGIN_FAIL, withProperties: props)
            
        }
        
        static func trackSplashCTAPressed() {
            
             trackEvent(Constants.Analytics.Onboarding.Events.SPLASH_CTA_BUTTON_PRESSED)
            
        }
        
        static func trackLoginCTAPressed(channel : Constants.Analytics.Invite.Properties.CONTACT_TYPE) {
            
            var props : [String : Any] = [:]
            
            props[Constants.Analytics.Invite.Properties.CONTACT_TYPE.key.rawValue] = channel.rawValue
            
            trackEvent(Constants.Analytics.Onboarding.Events.LOGIN_CTA_PRESSED, withProperties: props)
            
        }
        
        static func trackSMSRequestPressed(isSignup : Bool) {
            
            if isSignup {
            
                trackEvent(Constants.Analytics.Onboarding.Events.SIGNUP_SOCIAL_SMS_REQUEST_PRESSED)
            
            } else {
                
                trackEvent(Constants.Analytics.Onboarding.Events.LOGIN_SOCIAL_SMS_REQUEST_PRESSED)
                
            }
        
        }
        
        
        
        static func trackSMSValidateSuccess(isSignup : Bool) {
            
            if isSignup {
                
                trackEvent(Constants.Analytics.Onboarding.Events.SIGNUP_SOCIAL_SMS_VALIDATE_SUCCESS)
                
            } else {
                
                trackEvent(Constants.Analytics.Onboarding.Events.LOGIN_SOCIAL_SMS_VALIDATE_SUCCESS)
                
            }
            
        }
        
        static func trackSMSValidateFailure(isSignup : Bool, reason : String) {
            
            let props = [Constants.Analytics.Main.Properties.FAILURE_REASON : reason ]
            if isSignup {
                
                trackEvent(Constants.Analytics.Onboarding.Events.SIGNUP_SOCIAL_SMS_VALIDATE_FAILURE, withProperties: props)
                
            } else {
                
                trackEvent(Constants.Analytics.Onboarding.Events.LOGIN_SOCIAL_SMS_VALIDATE_FAILURE, withProperties: props)
                
            }
            
        }
        
            
            
        
        
        static func trackForgotUsernamePressed() {
            
             trackEvent(Constants.Analytics.Onboarding.Events.FORGOT_USERNAME_PRESSED)
            
        }
        
        static func trackForgotUsernameCTAPressed() {
            
            trackEvent(Constants.Analytics.Onboarding.Events.FORGOT_USERNAME_CTA_PRESSED)
            
        }
        
        static func trackForgotPasswordPressed() {
            
             trackEvent(Constants.Analytics.Onboarding.Events.FORGOT_PASSWORD_PRESSED)
            
        }
        
        static func trackBioBeganEditing() {
            
            trackEvent(Constants.Analytics.Onboarding.Events.COMPLETE_PROFILE_BIO_PRESSED)
            
        }
        
        static func trackSkipVideo() {
            
            trackEvent(Constants.Analytics.Onboarding.Events.ONBOARD_VIDEO_SKIP_PRESSED)
            
        }
        static func trackAvatarSelectionStarted() {
            
            trackEvent(Constants.Analytics.Onboarding.Events.COMPLETE_PROFILE_ADD_PHOTO_PRESSED)
            
        }
        
        
        static func trackForgotPasswordCTAPressed() {
            
            trackEvent(Constants.Analytics.Onboarding.Events.FORGOT_PASSWORD_CTA_PRESSED)
            
        }
        
        
        static func trackSplashSignupPressed() {
            
             trackEvent(Constants.Analytics.Onboarding.Events.SPLASH_SIGNUP_BUTTON_PRESSED)
            
        }
        
        static func trackCompleteProfileNextPressed(hasAvatar : Bool, hasBio : Bool) {
            
            var props : [String : Any] = [:]
            props[Constants.Analytics.Main.Properties.HAS_BIO] = hasBio
            props[Constants.Analytics.Main.Properties.HAS_AVATAR] = hasAvatar
           
            trackEvent(Constants.Analytics.Onboarding.Events.COMPLETE_PROFILE_NEXT_PRESSED, withProperties: props)
            
        }
        
        
        
        static func trackSignupInitialCTAPressed(channel : Constants.Analytics.Invite.Properties.CONTACT_TYPE) {
            
            var props : [String : Any] = [:]
            
            props[Constants.Analytics.Invite.Properties.CONTACT_TYPE.key.rawValue] = channel.rawValue
            
            trackEvent(Constants.Analytics.Onboarding.Events.SIGNUP_INITIAL_CTA_PRESSED, withProperties: props)
            
        }
        
        
        static func trackSignupDobCTAPressed(channel : Constants.Analytics.Invite.Properties.CONTACT_TYPE) {
            var props : [String : Any] = [:]
            
            props[Constants.Analytics.Invite.Properties.CONTACT_TYPE.key.rawValue] = channel.rawValue
            
            trackEvent(Constants.Analytics.Onboarding.Events.SIGNUP_DOB_CTA_PRESSED, withProperties: props)
            
        }
        
        static func trackSignupEmailCTAPressed() {
            
            trackEvent(Constants.Analytics.Onboarding.Events.SIGNUP_EMAIL_CTA_PRESSED)
            
        }
        
        static func trackSocialUsernameEntryCTAPressed(channel : Constants.Analytics.Invite.Properties.CONTACT_TYPE) {
            
            var props : [String : Any] = [:]
            
            props[Constants.Analytics.Invite.Properties.CONTACT_TYPE.key.rawValue] = channel.rawValue
            trackEvent(Constants.Analytics.Onboarding.Events.SIGNUP_SOCIAL_USERNAME_CTA_PRESSED, withProperties: props)
            
        }
        
        static func trackSocialSignupFailure(channel : Constants.Analytics.Invite.Properties.CONTACT_TYPE, reason : String) {
            
            var props : [String : Any] = [:]
            
            props[Constants.Analytics.Invite.Properties.CONTACT_TYPE.key.rawValue] = channel.rawValue
            props[Constants.Analytics.Main.Properties.FAILURE_REASON] = reason
            trackEvent(Constants.Analytics.Onboarding.Events.SIGNUP_SOCIAL_FAILURE, withProperties: props)
            
        }
        
        static func trackSocialSignupSuccess(channel : Constants.Analytics.Invite.Properties.CONTACT_TYPE) {
            
            var props : [String : Any] = [:]
            
            props[Constants.Analytics.Invite.Properties.CONTACT_TYPE.key.rawValue] = channel.rawValue
            trackEvent(Constants.Analytics.Onboarding.Events.SIGNUP_SOCIAL_SUCCESS, withProperties: props)
            
        }
        
        static func trackTOSPressed() {
            
             trackEvent(Constants.Analytics.Onboarding.Events.SIGNUP_TOS_PRESSED)
            
        }
        
        // MARK: - Screen Events
        
        
        static func screenSignup(mode : SignupMode) {
            
            guard isInitialized else { return }
            var locationString = "unknown"
            switch mode {
            case .initial:
                
                locationString = Constants.Analytics.Onboarding.Screens.SIGNUP
            case .birthdate:
                locationString = Constants.Analytics.Onboarding.Screens.SIGNUP_DOB
            case .email:
                locationString = Constants.Analytics.Onboarding.Screens.SIGNUP_EMAIL
                
            case .username:
                return
            }
            
            SEGAnalytics.shared().screen(locationString, properties: nil)
            log.verbose("Tracking Screen 🎉 \(locationString)")
            CLSLogv(locationString,  getVaList([]))
            
        }
        
    }
    
    
    
    
}
