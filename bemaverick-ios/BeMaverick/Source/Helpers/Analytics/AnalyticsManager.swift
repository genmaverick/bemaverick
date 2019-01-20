//
//  Analytics.swift
//  BeMaverick
//
//  Created by Garrett Fritz on 2/5/18.
//  Copyright © 2018 BeMaverick. All rights reserved.
//

import Foundation
import Analytics
import Branch
import Crashlytics
import SwiftMessages
import AdSupport


class AnalyticsManager {
    
    static var mostRecentEvent = "None"
    static var mostRecentScreen = "None"
    
    static var isInitialized = false
    private class func identifierForAdvertising() -> String? {
        // Check whether advertising tracking is enabled
        guard ASIdentifierManager.shared().isAdvertisingTrackingEnabled else {
            return nil
        }
        
        // Get and return IDFA
        return ASIdentifierManager.shared().advertisingIdentifier.uuidString
    }
    
    class func initialize() {
        
        Variables.initialize()
        
        if IntegrationConfig.segmentOnlyOnDev && DBManager.sharedInstance.getConfiguration().apiEnvironment == Constants.APIEnvironmentType.production {
            
            var config = SwiftMessages.Config()
            config.presentationContext = .window(windowLevel: UIWindowLevelNormal)
            config.interactiveHide = true
            config.duration = SwiftMessages.Duration.seconds(seconds: 10.0)
            let messageView: InvitesSentMessageView = try! SwiftMessages.viewFromNib(named: "InvitesSentMessageView")
            
            messageView.configure(with: "⚠️ Warning ⚠️ You are using the DEV app on the production environment, analytics events are not being recorded - ALSO MEANS YOUR NOTIFICATIONS ARE GOING TO BE SCREWY!", avatar: nil)
            messageView.configureDropShadow()
            SwiftMessages.show(config: config,
                               view: messageView)
            
            return
            
        }
        
        if let id = identifierForAdvertising() {
            
            Leanplum.setDeviceId(id)
            
        }
        
        
        var key = IntegrationConfig.segmentKey
        if ( (UIApplication.shared.delegate as! AppDelegate).isSimulatorOrTestFlight()) {
            
            key = IntegrationConfig.segmentKeyDev
            
        }
        let configuration = SEGAnalyticsConfiguration(writeKey: key)
        configuration.trackApplicationLifecycleEvents = true
        configuration.recordScreenViews = false
        configuration.use(SEGFirebaseIntegrationFactory.instance())
        configuration.use(BNCBranchIntegrationFactory.instance())
        configuration.use(SEGLeanplumIntegrationFactory.instance())
        configuration.use(SEGAdjustIntegrationFactory.instance())
        
        SEGAnalytics.setup(with: configuration)
        SEGAnalytics.debug(false)
        isInitialized = true
        
    }
    
    static func trackEvent(_ eventName: String, withProperties properties: [String : Any]? = nil) {
        
        guard isInitialized else { return }
        SEGAnalytics.shared().track(eventName, properties: properties)
        CLSLogv(eventName, getVaList([]))
        
        //        log.verbose("📷 \(eventName) \(properties?[Constants.Analytics.Invite.Properties.CONTACT_TYPE.key.rawValue])")
        
        mostRecentEvent = eventName
        
    }
    
    
    static func logError( error : String) {
        
        CLSLogv(error,  getVaList([]))
        
    }
    
    private static func getUserTraits(_ user: User) -> [String : Any]? {
        
        var properties: [String : Any] = [:]
        properties[Constants.Analytics.Profile.Properties.EMAIL] = user.emailAddress
        properties[Constants.Analytics.Profile.Properties.PARENT_EMAIL] = user.parentEmailAddress
        properties[Constants.Analytics.Profile.Properties.OVER_THIRTEEN] = user.overThirteen
        properties[Constants.Analytics.Profile.Properties.USERNAME] = user.username
        properties[Constants.Analytics.Profile.Properties.FIRST_NAME] = user.firstName
        properties[Constants.Analytics.Profile.Properties.LAST_NAME] = user.lastName
        
        properties[Constants.NotificationSettings.push.rawValue] = user.pushEnabled
        properties[Constants.NotificationSettings.push_posts.rawValue] = user.pushPostsEnabled
        properties[Constants.NotificationSettings.push_follower.rawValue] = user.pushFollowerEnabled
        properties[Constants.NotificationSettings.push_general.rawValue] = user.pushGeneralEnabled
        
        if let bio = user.bio {
            properties[Constants.Analytics.Main.Properties.HAS_BIO] = bio.count > 0
        } else {
            properties[Constants.Analytics.Main.Properties.HAS_BIO] = false
        }
        
        if let avatar = user.profileImage {
            properties[Constants.Analytics.Main.Properties.HAS_AVATAR] = avatar.URLOriginal != nil
        } else {
            properties[Constants.Analytics.Main.Properties.HAS_AVATAR] = false
        }
        
        if (UIApplication.shared.delegate as! AppDelegate).branchInitialized, let referral = Branch.getInstance().getFirstReferringBranchLinkProperties() {
            
            properties["REFERRAL_CAMPAIGN"] = referral.campaign
            properties["REFERRAL_ALIAS"] = referral.alias
            properties["REFERRAL_FEATURE"] = referral.feature
            properties["REFERRAL_CHANNEL"] = referral.channel
            
        }
        
        return properties
        
    }
    
    static func identify(loggedInUser me: User) {
        
        guard isInitialized, let props = getUserTraits(me) else { return }
        SEGAnalytics.shared().identify(me.userId, traits: props)
        Crashlytics.sharedInstance().setUserName(me.username)
        Crashlytics.sharedInstance().setUserIdentifier(me.userId)
        Crashlytics.sharedInstance().setUserEmail(me.emailAddress)
        
        
        
    }
    
    static func addEventSourceProperties(_ properties: [String : Any]) -> [String : Any] {
        
        var props = properties
        
        guard let loggedInUser = DBManager.sharedInstance.getLoggedInUser() else { return  props }
        props[Constants.Analytics.Profile.Properties.SOURCE_USERNAME] = loggedInUser.username
        props[Constants.Analytics.Profile.Properties.SOURCE_USER_ID] = loggedInUser.userId
        props[Constants.Analytics.Profile.Properties.AVATAR] = loggedInUser.profileImage?.URLOriginal
        
        return props
    }
    
    static func trackScreen(location : UIViewController, withProperties properties : [String : Any]? = nil) {
        
        guard isInitialized else { return }
        
        if let locationString = locationDictionary[NSStringFromClass(location.classForCoder)] {
            
            SEGAnalytics.shared().screen(locationString, properties: properties)
            //            log.verbose("Tracking Screen 🎉 \(locationString)")
            CLSLogv(locationString,  getVaList([]))
            
            mostRecentScreen = locationString
            
        }
        
    }
    
    static let locationDictionary = [
        
        NSStringFromClass(FeaturedChallengeStreamViewController.self.classForCoder()) : Constants.Analytics.Main.Screens.CHALLENGE_STREAM,
        NSStringFromClass(MyStreamViewController.self.classForCoder()) : Constants.Analytics.Main.Screens.MY_STREAM,
        NSStringFromClass(FeaturedStreamViewController.self.classForCoder()) : Constants.Analytics.Main.Screens.MAVERICK_STREAM,
        NSStringFromClass(ProfileViewController.self.classForCoder()) : Constants.Analytics.Main.Screens.PROFILE,
        NSStringFromClass(UserResponseStreamViewController.self.classForCoder()) : Constants.Analytics.Main.Screens.USER_RESPONSE_STREAM,
        NSStringFromClass(UserInspirationStreamViewController.self.classForCoder()) : Constants.Analytics.Main.Screens.USER_INSPIRATION_STREAM,
        NSStringFromClass(SingleContentItemViewController.self.classForCoder()) : Constants.Analytics.Main.Screens.CONTENT_FULL_SCREEN,
        NSStringFromClass(ChallengeResponseStreamViewController.self.classForCoder()) : Constants.Analytics.Main.Screens.CHALLENGE_RESPONSE_STREAM,
        NSStringFromClass(FollowersViewController.self.classForCoder()) : Constants.Analytics.Main.Screens.FOLLOWERS,
        NSStringFromClass(BadgeBagViewController.self.classForCoder()) : Constants.Analytics.Main.Screens.RESPONSE_BADGES,
        NSStringFromClass(ChallengeDetailsPageViewController.self.classForCoder()) : Constants.Analytics.Main.Screens.CHALLENGE_DETAILS,
        NSStringFromClass(ChallengeDetailsViewController.self.classForCoder()) : Constants.Analytics.Main.Screens.CHALLENGE_DETAILS_PAGER,
        
        NSStringFromClass(InviteSelectorViewController.self.classForCoder()) : Constants.Analytics.Invite.Screens.SELECTOR,
        NSStringFromClass(ContactsViewController.self.classForCoder()) : Constants.Analytics.Invite.Screens.CONTACTS,
        NSStringFromClass(QRViewController.self.classForCoder()) : Constants.Analytics.Invite.Screens.QR,
        NSStringFromClass(MaverickActionSheetVC.self.classForCoder()) : Constants.Analytics.Main.Screens.ACTION_SHEET,
        NSStringFromClass(NotificationViewController.self.classForCoder()) : Constants.Analytics.Main.Screens.NOTIFICATIONS,
        NSStringFromClass(OnboardFirstChallengeViewController.self.classForCoder()) : Constants.Analytics.Onboarding.Screens.SIGNUP_ONBOARD_VIDEO,
        NSStringFromClass(ProfileEditCoverViewController.self.classForCoder()) : Constants.Analytics.Settings.Screens.SETTINGS_COVER_MAVERICK,
        NSStringFromClass(ProfileEditProfileViewController.self.classForCoder()) : Constants.Analytics.Settings.Screens.SETTINGS_PROFILE,
        NSStringFromClass(OnboardLoginViewController.self.classForCoder()) : Constants.Analytics.Onboarding.Screens.LOGIN,
        NSStringFromClass(ProfileEditPasswordViewController.self.classForCoder()) : Constants.Analytics.Settings.Screens.SETTINGS_PASSWORD,
        NSStringFromClass(OnboardForgotPasswordViewController.self.classForCoder()) : Constants.Analytics.Onboarding.Screens.FORGOT_PASSWORD,
        NSStringFromClass(OnboardForgotNameViewController.self.classForCoder()) : Constants.Analytics.Onboarding.Screens.FORGOT_USERNAME,
        NSStringFromClass(OnboardIntroViewController.self.classForCoder()) : Constants.Analytics.Onboarding.Screens.SPLASH,
        NSStringFromClass(OnboardCompleteProfileViewController.self.classForCoder()) : Constants.Analytics.Onboarding.Screens.SIGNUP_COMPLETE_PROFILE,
        NSStringFromClass(ProfileSettingsViewController.self.classForCoder()) : Constants.Analytics.Settings.Screens.SETTINGS,
        NSStringFromClass(NotificationSettingsViewController.self.classForCoder()) : Constants.Analytics.Settings.Screens.SETTINGS_NOTIFICATIONS,
        NSStringFromClass(ProfileContactUsViewController.self.classForCoder()) : Constants.Analytics.Settings.Screens.CONTACT_US,
        NSStringFromClass(OnboardCelebrationViewController.self.classForCoder()) : Constants.Analytics.Onboarding.Screens.SIGNUP_ONBOARD_CELEBRATION,
        NSStringFromClass(OnboardSMSRequestViewController.self.classForCoder()) : Constants.Analytics.Onboarding.Screens.SMS_REQUEST,
        NSStringFromClass(CustomizeEmailViewController.self.classForCoder()) : Constants.Analytics.Invite.Screens.CUSTOMIZE_EMAIL,
        NSStringFromClass(QRScannerViewController.self.classForCoder()) : Constants.Analytics.Invite.Screens.QR_CAMERA,
        NSStringFromClass(InactiveUserViewController.self.classForCoder()) : Constants.Analytics.Main.Screens.INACTIVE_USER,
        
        NSStringFromClass(OnboardKBAPassViewController.self.classForCoder()) : Constants.Analytics.Main.Screens.VPC_ACCESS_GRANT,
        NSStringFromClass(OnboardVPCViewController.self.classForCoder()) : Constants.Analytics.Main.Screens.VPC_INFO_ENTRY,
        NSStringFromClass(CommentsViewController.self.classForCoder()) : Constants.Analytics.Main.Screens.COMMENTS,
        NSStringFromClass(GenericChallengeStreamViewController.self.classForCoder()) : Constants.Analytics.Main.Screens.GENERIC_CHALLENGE_STREAM,
        NSStringFromClass(GenericResponseStreamViewController.self.classForCoder()) : Constants.Analytics.Main.Screens.GENERIC_RESPONSE_STREAM,
        
        NSStringFromClass(CreateChallengeViewController.self.classForCoder()) : Constants.Analytics.Main.Screens.CREATE_CHALLENGE,
        NSStringFromClass(EditChallengeViewController.self.classForCoder()) : Constants.Analytics.Main.Screens.EDIT_CHALLENGE,
        NSStringFromClass(SearchMaverickViewController.self.classForCoder()) : Constants.Analytics.Main.Screens.SEARCH_USERS,
        NSStringFromClass(FullScreenInAppMessageViewController.self.classForCoder()) : Constants.Analytics.Main.Screens.FULL_SCREEN_IN_APP,
        
        NSStringFromClass(ChallengesViewController.self.classForCoder()) : Constants.Analytics.Main.Screens.CHALLENGES_VIEW_CONTROLLER,
        NSStringFromClass(ChallengesPageViewController.self.classForCoder()) : Constants.Analytics.Main.Screens.CHALLENGES_VIEW_CONTROLLER,
        
        NSStringFromClass(PostRecordViewController.self.classForCoder()) : Constants.Analytics.Main.Screens.POST_RECORD_VIEW_CONTROLLER,
        NSStringFromClass(PostCoverSelectorViewController.self.classForCoder()) : Constants.Analytics.Main.Screens.POST_COVER_SELECTOR_VIEW_CONTROLLER,
        NSStringFromClass(PostMetadataViewController.self.classForCoder()) : Constants.Analytics.Main.Screens.POST_METADATA_VIEW_CONTROLLER,
        NSStringFromClass(PostModeConfirmViewController.self.classForCoder()) : Constants.Analytics.Main.Screens.POST_MODE_CONFIRM_VIEW_CONTROLLER,
        NSStringFromClass(AssetPickerViewController.self.classForCoder()) : Constants.Analytics.Main.Screens.ASSET_PICKER_VIEW_CONTROLLER,
        NSStringFromClass(AssetTrimmerViewController.self.classForCoder()) : Constants.Analytics.Main.Screens.ASSET_TRIMMER_VIEW_CONTROLLER,
        
        
        NSStringFromClass(TagChallengesPageViewController.self.classForCoder()) : Constants.Analytics.Main.Screens.CHALLENGES_PAGE_HASHTAG_VIEW_CONTROLLER,
        NSStringFromClass(RecentChallengesPageViewController.self.classForCoder()) : Constants.Analytics.Main.Screens.CHALLENGES_PAGE_RECENT_VIEW_CONTROLLER,
        NSStringFromClass(CompletedChallengesPageViewController.self.classForCoder()) : Constants.Analytics.Main.Screens.CHALLENGES_PAGE_COMPLETED_VIEW_CONTROLLER,
        NSStringFromClass(EmptyChallengesPageViewController.self.classForCoder()) : Constants.Analytics.Main.Screens.CHALLENGES_PAGE_EMPTY_VIEW_CONTROLLER,
        NSStringFromClass(SavedChallengePageViewController.self.classForCoder()) : Constants.Analytics.Main.Screens.CHALLENGES_PAGE_SAVED_VIEW_CONTROLLER,
        NSStringFromClass(TagResponsesPageViewController.self.classForCoder()) : Constants.Analytics.Main.Screens.HASHTAG_RESPONSE_STREAM,
        
        NSStringFromClass(TrendingChallengesPageViewController.self.classForCoder()) : Constants.Analytics.Main.Screens.CHALLENGES_PAGE_TRENDING_VIEW_CONTROLLER,
        
        
        NSStringFromClass(ChallengesPagerViewController.self.classForCoder()) : Constants.Analytics.Main.Screens.CHALLENGES_PAGER_CONTROLLER,
        
        
        NSStringFromClass(ChallengeDetailsPagerViewController.self.classForCoder()) : Constants.Analytics.Main.Screens.CHALLENGES_DETAILS_PAGER_CONTROLLER,
        NSStringFromClass(CreateChallengePageViewController.self.classForCoder()) : Constants.Analytics.Main.Screens.CREATE_CHALLENGE_PAGER_CONTROLLER,
        NSStringFromClass(HashtagPagerViewController.self.classForCoder()) : Constants.Analytics.Main.Screens.HASHTAG_PAGER_CONTROLLER,
        NSStringFromClass(OnboardPaginatedViewController.self.classForCoder()) : Constants.Analytics.Main.Screens.ONBOARD_SPLASH_PAGER_CONTROLLER,
        NSStringFromClass(InvitedChallengesPageViewController.self.classForCoder()) : Constants.Analytics.Main.Screens.CHALLENGES_PAGE_INVITED,
        
        NSStringFromClass(HashtagGroupViewController.self.classForCoder()) : Constants.Analytics.Main.Screens.HASHTAG_CHANNEL,
        NSStringFromClass(LinkChallengesPageViewController.self.classForCoder()) : Constants.Analytics.Main.Screens.CHALLENGES_PAGE_LINK,
        
        
        NSStringFromClass(MyProgressViewController.self.classForCoder()) : Constants.Analytics.Progression.Screens.MY_PROGRESS,
        
        NSStringFromClass(ProgressionLeaderboardViewController.self.classForCoder()) : Constants.Analytics.Progression.Screens.LEADERBOARD,
        
        NSStringFromClass(BadgesReceivedPageViewController.self.classForCoder()) : Constants.Analytics.Progression.Screens.BADGES_RECEIVED,
        
        NSStringFromClass(ProjectDetailsViewController.self.classForCoder()) : Constants.Analytics.Progression.Screens.PROJECT_DETAILS,
        
        NSStringFromClass(ProjectsPageViewController.self.classForCoder()) : Constants.Analytics.Progression.Screens.PROJECT_PROGRESS,
        
        NSStringFromClass(LevelDetailsViewController.self.classForCoder()) : Constants.Analytics.Progression.Screens.LEVEL_DETAILS,
        
        NSStringFromClass(BadgesReceivedPagerViewController.self.classForCoder()) : Constants.Analytics.Progression.Screens.BADGES_RECEIVED_PAGER,
        
        NSStringFromClass(ProjectsPagerViewController.self.classForCoder()) : Constants.Analytics.Progression.Screens.PROJECT_PROGRESS_PAGER,
        ]
    
    static func addLocationProperty(_ properties: [String : Any], location : UIViewController) -> [String : Any] {
        
        var props = properties
        let locationString = locationDictionary[NSStringFromClass(location.classForCoder)] ?? "unknown"
        
        props[Constants.Analytics.Main.Properties.LOCATION] = locationString
        
        return props
    }
    
    
}
