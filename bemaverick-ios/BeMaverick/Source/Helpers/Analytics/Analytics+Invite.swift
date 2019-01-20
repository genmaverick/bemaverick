//
//  AnalyticsOnboarding.swift
//  BeMaverick
//
//  Created by Garrett Fritz on 2/5/18.
//  Copyright © 2018 BeMaverick. All rights reserved.
//

import Foundation

extension AnalyticsManager {
    
    class Invite {
        
        static private func getSourceProperty(source : Constants.Analytics.Invite.Properties.SOURCE) -> [String : String] {
            
            return [Constants.Analytics.Invite.Properties.SOURCE.key.rawValue : source.rawValue]
        }
        
        
        static func trackSelectorTextPressed(source : Constants.Analytics.Invite.Properties.SOURCE) {
            
            trackEvent(Constants.Analytics.Invite.Events.SELECTOR_TEXT_PRESSED, withProperties: getSourceProperty(source: source))
            
        }
        
        static func trackSelectorEmailPressed(source : Constants.Analytics.Invite.Properties.SOURCE) {
            
            trackEvent(Constants.Analytics.Invite.Events.SELECTOR_EMAIL_PRESSED, withProperties: getSourceProperty(source: source))
            
        }
        
        static func trackSelectorQRPressed(source : Constants.Analytics.Invite.Properties.SOURCE) {
            
            trackEvent(Constants.Analytics.Invite.Events.SELECTOR_QR_PRESSED, withProperties: getSourceProperty(source: source))
            
        }
        
        
        
        static func trackContactCustomizedInviteSent(mode : Constants.ContactMode, source : Constants.Analytics.Invite.Properties.SOURCE, edited : Bool = false) {
            
            var props = getSourceProperty(source: source)
            props[Constants.Analytics.Invite.Properties.CONTACT_TYPE.key.rawValue] = convertMode(mode: mode).rawValue
            
            props[Constants.Analytics.Invite.Properties.EDITIED] = edited ? "true" : "false"
            
            trackEvent(Constants.Analytics.Invite.Events.CONTACTS_CUSTOMIZE_SEND_PRESSED, withProperties: props)
            
        }
        
        static func trackContactSendPressed(mode : Constants.ContactMode, source : Constants.Analytics.Invite.Properties.SOURCE) {
            
            var props = getSourceProperty(source: source)
            props[Constants.Analytics.Invite.Properties.CONTACT_TYPE.key.rawValue] = convertMode(mode: mode).rawValue
            
             trackEvent(Constants.Analytics.Invite.Events.CONTACTS_SEND_PRESSED, withProperties: props)
            
        }
        
        static func trackContactInviteSent(mode : Constants.ContactMode, source : Constants.Analytics.Invite.Properties.SOURCE) {
            
            var props = getSourceProperty(source: source)
            props[Constants.Analytics.Invite.Properties.CONTACT_TYPE.key.rawValue] = convertMode(mode: mode).rawValue
            
            trackEvent(Constants.Analytics.Invite.Events.CONTACTS_INVITE_PRESSED, withProperties: props)
            
        }
        
        static func trackContactInviteAll(mode : Constants.ContactMode, source : Constants.Analytics.Invite.Properties.SOURCE) {
            
            var props = getSourceProperty(source: source)
            props[Constants.Analytics.Invite.Properties.CONTACT_TYPE.key.rawValue] =  convertMode(mode: mode).rawValue
             trackEvent(Constants.Analytics.Invite.Events.CONTACTS_INVITE_ALL_PRESSED, withProperties: props)
            
        }
        
        
        static func trackScanQRPressed( source : Constants.Analytics.Invite.Properties.SOURCE) {
            
            trackEvent(Constants.Analytics.Invite.Events.CONTACTS_QR_SCAN_PRESSED, withProperties: getSourceProperty(source: source))
            
        }
        
        static func trackQRLibraryPressed( source : Constants.Analytics.Invite.Properties.SOURCE) {
            
            trackEvent(Constants.Analytics.Invite.Events.CONTACTS_QR_LIBRARY_PRESSED, withProperties: getSourceProperty(source: source))
            
        }
        
        static func trackShareQRPressed( source : Constants.Analytics.Invite.Properties.SOURCE) {
            
            trackEvent(Constants.Analytics.Invite.Events.CONTACTS_QR_SHARE_PRESSED, withProperties: getSourceProperty(source: source))
            
        }
        
        static func trackSaveQRPressed( source : Constants.Analytics.Invite.Properties.SOURCE) {
            
            trackEvent(Constants.Analytics.Invite.Events.CONTACTS_QR_SAVE_PRESSED, withProperties: getSourceProperty(source: source))
            
        }
        
        
        static func trackQRCameraStarted( source : Constants.Analytics.Invite.Properties.SOURCE) {
            
            trackEvent(Constants.Analytics.Invite.Events.CONTACTS_QR_CAMERA_STARTED, withProperties: getSourceProperty(source: source))
            
        }
        
        
        static func trackQRCameraScanned( source : Constants.Analytics.Invite.Properties.SOURCE) {
            
            trackEvent(Constants.Analytics.Invite.Events.CONTACTS_QR_CAMERA_SCAN, withProperties: getSourceProperty(source: source))
            
        }
        
        static func trackQRLibraryScanned( source : Constants.Analytics.Invite.Properties.SOURCE) {
            
            trackEvent(Constants.Analytics.Invite.Events.CONTACTS_QR_LIBRARY_SCAN, withProperties: getSourceProperty(source: source))
            
        }
        
        
       
        
        static func trackQRTapped( source : Constants.Analytics.Invite.Properties.SOURCE) {
            
            trackEvent(Constants.Analytics.Invite.Events.CONTACTS_QR_TAPPED, withProperties: getSourceProperty(source: source))
            
        }
        
        static func trackQRImageScannedSuccess(userId : String, source : Constants.Analytics.Invite.Properties.SOURCE) {
            
             var props = getSourceProperty(source: source)
            props[Constants.Analytics.Main.Properties.TARGET_USER_ID] =  userId
            trackEvent(Constants.Analytics.Invite.Events.CONTACTS_QR_IMAGE_SCANNED_SUCCESS, withProperties: props)
            
        }
        
        static func trackQRImageScannedFail(reason : Constants.Analytics.Invite.Properties.FAILURE_TYPE ) {
            
             let props = [Constants.Analytics.Invite.Properties.FAILURE_TYPE.key.rawValue : reason.rawValue]
            trackEvent(Constants.Analytics.Invite.Events.CONTACTS_QR_IMAGE_SCANNED_FAIL, withProperties: props)
            
        }
        
        static func trackInviteScreen( viewController : UIViewController , source : Constants.Analytics.Invite.Properties.SOURCE) {
            
            trackScreen(location : viewController, withProperties : getSourceProperty(source: source))
            
            
        }
        
        static func trackContactsScreen(viewController : UIViewController , mode : Constants.ContactMode , source : Constants.Analytics.Invite.Properties.SOURCE) {
            
            let props = [Constants.Analytics.Invite.Properties.CONTACT_TYPE.key.rawValue : convertMode(mode: mode).rawValue]
            
            trackScreen(location : viewController, withProperties: props)
            
        }
        
        private static func convertMode(mode : Constants.ContactMode) -> Constants.Analytics.Invite.Properties.CONTACT_TYPE {
            
            switch mode {
            case .email:
                return .email
            case .phone:
                return .phone
            case .facebook:
                return .facebook
            case .twitter:
                return .twitter
            }
            
        }
    }
    
}
