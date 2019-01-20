//
//  Variables.swift
//  Maverick
//
//  Created by Garrett Fritz on 3/2/18.
//  Copyright © 2018 BeMaverick. All rights reserved.
//

import Foundation

struct Variables {
    
    static func initialize() {
        
        Colors.initialize()
        Content.initialize()
        Profile.initialize()
        Features.initialize()
        
    }
    
    struct Features {
        
        static var reportResponseActionSheetTitle = LPVar()
        static var reportResponseMessage = LPVar()
        static var reportResponseReason1 = LPVar()
        static var reportResponseReason2 = LPVar()
        static var reportResponseReason3 = LPVar()
        static var reportResponseCopyrightMessage = LPVar()
        static var reportResponseCopyrightURL = LPVar()
        
        static var reportCommentReason1 = LPVar()
        static var reportCommentReason2 = LPVar()
        static var reportCommentReason3 = LPVar()
        
        static var onboardCelebration_label1 = LPVar()
        static var onboardCelebration_label2 = LPVar()
        static var onboardCelebration_label3 = LPVar()
        static var onboardCelebration_signature = LPVar()
        static var onboardCelebration_name = LPVar()
        static var onboardCelebration_image = LPVar()
        static var onboardCelebration_backgroundColor = LPVar()
        
        static var homeTabIndex = LPVar()
        static var postFlowHomeTabIndex = LPVar()
        
        static var suggestedUpgradeVersion = LPVar()
        static var suggestedUpgradeTitle = LPVar()
        static var suggestedUpgradeDescription = LPVar()
        
        static var forcedUpgradeVersion = LPVar()
        static var forcedUpgradeTitle = LPVar()
        static var forcedUpgradeDescription = LPVar()
        
        static var enableFindFriendsOnboarding = LPVar()
        static var enableCompleteProfileCelebration = LPVar()
        static var facebookFriendsEnabled = LPVar()
        static var enableOnboardingIntroVideo = LPVar()
        
        static var parentRevokedTitle = LPVar()
        static var parentRevokedSubTitle = LPVar()
        
        static var adminRevokedTitle = LPVar()
        static var adminRevokedSubTitle = LPVar()
        static var ctaBounceSpace_s = LPVar()
        
        
        static var createChallengeBadgeRequirement = LPVar()
        static var createChallengeResponseRequirement = LPVar()
        static var createChallengeBlockedRationale = LPVar()
        static var createChallengeThemeLockedRationale = LPVar()
        
        static var onboardVideoPath = LPVar()
        static var createChallengeTutorialPath = LPVar()
        
        static var allowGridAutoplay = LPVar()
        
        
        
        static func initialize() {
            
            
            
            allowGridAutoplay = LPVar.define("Features.AllowGridAutoplay", with : false)
           onboardVideoPath = LPVar.define("Features.Tutorials.onboarding", with: "https://d32424o5gwcij1.cloudfront.net/response-a49a3db0-c20c-44e0-9422-d64a804cc623-1bfc81170b41c34b17f3e765ae7bb040.mov")
            
            createChallengeTutorialPath = LPVar.define("Features.Tutorials.createChallenge", with: "https://d32424o5gwcij1.cloudfront.net/response-715dec1d-0c9d-433f-a16e-b8d2da0f7988-70b2f116d7d42fb61cdf93ec357984a9.mp4")
            
            parentRevokedTitle = LPVar.define("Features.Revoked.ParentRevokedTitle", with: "⛔️  Access Blocked  ⛔️")
            parentRevokedSubTitle = LPVar.define("Features.Revoked.ParentRevokedSubTitle", with: "Oh no! Your parent or guardian has deactivated your account. Please speak with them if you’d like to rejoin Maverick.")
         
            adminRevokedTitle = LPVar.define("Features.Revoked.AdminRevokedTitle", with: "⛔️  Access Blocked  ⛔️")
            adminRevokedSubTitle = LPVar.define("Features.Revoked.AdminRevokedSubTitle", with: "Oh no! Your account has been temporarily disabled. If you’d like to rejoin Maverick please contact support.")
            
           facebookFriendsEnabled = LPVar.define("Features.FindFriends.FacebookEnabled", with: false)
             suggestedUpgradeVersion = LPVar.define("Features.Upgrade.SuggestedUpgradeVersion", with: "1.1.1")
            suggestedUpgradeTitle = LPVar.define("Features.Upgrade.SuggestedUpgradeTitle", with: "🎉 New Update Available! 🎉")
            suggestedUpgradeDescription = LPVar.define("Features.Upgrade.SuggestedUpgradeDescription", with: "We've been working hard on a new update, check it out now to get the latest and greatest to help you shine!")
            
            
            forcedUpgradeVersion = LPVar.define("Features.Upgrade.ForcedUpgradeVersion", with: "1.0.0")
            forcedUpgradeTitle = LPVar.define("Features.Upgrade.ForcedUpgradeTitle", with: "🎉 New Update Available! 🎉")
            forcedUpgradeDescription = LPVar.define("Features.Upgrade.ForcedUpgradeDescription", with: "We've been working hard on a new update, check it out now to get the latest and greatest to help you shine!")
            
        ctaBounceSpace_s = LPVar.define("Features.CTABounceSpace_s", with: 10.0)
            
            homeTabIndex = LPVar.define("Features.HomeTabIndex", with: 2)
            postFlowHomeTabIndex = LPVar.define("Features.Post.PostFlowHomeTabIndex", with: 0)

            reportResponseActionSheetTitle = LPVar.define("Features.Report.ActionSheetTitle", with: "REPORT RESPONSE")
            reportResponseMessage = LPVar.define("Features.Report.Message", with: "Why are you reporting this content?")
            reportResponseReason1 = LPVar.define("Features.Report.Response1", with: "Spam or scam")
            reportResponseReason2 = LPVar.define("Features.Report.Response2", with: "Abusive content")
            reportResponseReason3 = LPVar.define("Features.Report.Response3", with: "Content doesn't adhere to community guidelines")
            reportResponseCopyrightMessage = LPVar.define("Features.Report.CopyrightMessage", with: "If you are the copyright owner of this content and believe it has been uploaded without your permission, please follow these directions to submit a copyright infringement notice.")
            reportResponseCopyrightURL = LPVar.define("Features.Report.CopyrightURL", with: "http://www.genmaverick.com/copyright")
            
            reportCommentReason1 = LPVar.define("Features.Report.Comment1", with: "Mean")
            reportCommentReason2 = LPVar.define("Features.Report.Comment2", with: "Annoying")
            reportCommentReason3 = LPVar.define("Features.Report.Comment3", with: "Inappropriate")
            
            
                enableOnboardingIntroVideo = LPVar.define("Features.Onboarding.IntroVideo", with: false)
            
            enableFindFriendsOnboarding = LPVar.define("Features.Onboarding.FindFriends", with: true)
            enableCompleteProfileCelebration = LPVar.define("Features.Onboarding.Celebration.enabled", with: true)
            
            onboardCelebration_label1 = LPVar.define("Features.Onboarding.Celebration.Label1", with: "Hey, %s!")
            onboardCelebration_label2 = LPVar.define("Features.Onboarding.Celebration.Label2", with: "Yes, yes,")
            onboardCelebration_label3 = LPVar.define("Features.Onboarding.Celebration.Label3", with: "and all the yes to this!")
            onboardCelebration_signature = LPVar.define("Features.Onboarding.Celebration.Signature", with: "Love")
            onboardCelebration_name = LPVar.define("Features.Onboarding.Celebration.Name", with: "Brooklyn & Bailey")
            onboardCelebration_image = LPVar.define("Features.Onboarding.Celebration.image", with: "url override")
            onboardCelebration_backgroundColor = LPVar.define("Features.Onboarding.Celebration.background", with : UIColor.MaverickBadgePrimaryColor)
            
            
            createChallengeBadgeRequirement = LPVar.define("Features.UGC.badgeRequirement", with: 5)
            createChallengeResponseRequirement = LPVar.define("Features.UGC.responseRequirement", with: 1)
            createChallengeBlockedRationale = LPVar.define("Features.UGC.blockedRationale", with: "Only Mavericks who have completed these tasks are ready to post a Challenge . You’re soooo close, so get to it!")
            
            createChallengeThemeLockedRationale = LPVar.define("Features.UGC.lockedThemeRationale", with: "This theme is exclusive to our power challengers! You are so close!")
            
            
            
        }
        
    }
    
    struct Colors {
        
        static var colorsInitialized = true
        
        static func initialize() {
            
            colorsInitialized = false
            
            
            
            BadgePrimaryColor = LPVar.define("Colors.BadgePrimaryColor", with : UIColor.MaverickBadgePrimaryColor)
            PrimaryColor = LPVar.define("Colors.PrimaryColor", with : UIColor.MaverickPrimaryColor)
            BackgroundColor = LPVar.define("Colors.BackgroundColor", with : UIColor.MaverickBackgroundColor)
            UnselectedBadgeButton = LPVar.define("Colors.UnselectedBadgeButton", with : UIColor.MaverickUnselectedBadgeButton)
            TabBarBackgroundColor = LPVar.define("Colors.TabBarBackgroundColor", with : UIColor.MaverickTabBarBackgroundColor)
            TextColor = LPVar.define("Colors.TextColor", with : UIColor.MaverickTextColor)
            BadgePrimaryColor = LPVar.define("Colors.BadgePrimaryColor", with : UIColor.MaverickBadgePrimaryColor)
            SecondaryTextColor = LPVar.define("Colors.SecondaryTextColor", with : UIColor.MaverickSecondaryTextColor)
            DarkTextColor = LPVar.define("Colors.DarkTextColor", with : UIColor.MaverickDarkTextColor)
            DarkSecondaryTextColor = LPVar.define("Colors.DarkSecondaryTextColor", with : UIColor.MaverickDarkSecondaryTextColor)
            ProfilePowerBackgroundColor = LPVar.define("Colors.ProfilePowerBackgroundColor", with : UIColor.MaverickProfilePowerBackgroundColor)
            
            colorsInitialized = true
            
        }
        
        
        static var BadgePrimaryColor = LPVar()
        static var PrimaryColor = LPVar()
        static var BackgroundColor = LPVar()
        static var UnselectedBadgeButton = LPVar()
        static var TabBarBackgroundColor = LPVar()
        static var TextColor = LPVar()
        static var SecondaryTextColor = LPVar()
        static var DarkTextColor = LPVar()
        static var DarkSecondaryTextColor = LPVar()
        static var ProfilePowerBackgroundColor = LPVar()
        
    }
    
    
    struct Content {
        
        static var maxStreamAspectRatio = LPVar()
        static var gridAspectRatio = LPVar()
        static var gridItemSpacing = LPVar()
        static var gridColumnCount = LPVar()
        static var emptyViewHeight = LPVar()
        
        static var featuredRowPercentWidth = LPVar()
        static var featuredRowMaxItemCount = LPVar()
        static var featuredStreamOrderOverride = LPVar()
        
        static var challengeTabCategories = LPVar()
        static var challengeTabNames = LPVar()
        
        static private var postTextFontColors = LPVar()
        
        static private var postTextBackgroundColors = LPVar()
        
        static func getPostTextFontColors() -> [UIColor] {
        
            var colors : [UIColor] = []
            for i in 0 ..< Variables.Content.postTextFontColors.count() {
                
                guard let colorString = Variables.Content.postTextFontColors.object(at: i) as? String, let color = UIColor(rgba: colorString) else { continue }
            
                colors.append(color)
            }
            
            return colors
        
        }
        
        static func getPostTextBackgroundColors() -> [UIColor] {
            
            var colors : [UIColor] = []
            for i in 0 ..< Variables.Content.postTextBackgroundColors.count() {
                
                guard let colorString = Variables.Content.postTextBackgroundColors.object(at: i) as? String, let color = UIColor(rgba: colorString) else { continue }
                
                colors.append(color)
            }
            
            return colors
            
        }
        
        static func initialize() {
            
            Challenge.initialize()
            Response.initialize()
            emptyViewHeight = LPVar.define("Content.EmptyViewHeight", with: 300)
            maxStreamAspectRatio = LPVar.define("Content.MaxStreamAspectRatio", with: 0.75)
            gridAspectRatio = LPVar.define("Content.GridAspectRatio", with: 0.75)
            gridColumnCount = LPVar.define("Content.GridColumnCount", with: 3)
            featuredRowMaxItemCount = LPVar.define("Content.FeaturedPage.featuredRowMaxItemCount", with: 10)
            gridItemSpacing = LPVar.define("Content.GridItemSpacing", with: 4)
            featuredRowPercentWidth = LPVar.define("Content.FeaturedPage.FeaturedPercentWidth", with: 0.75)
    
            
            featuredStreamOrderOverride = LPVar.define("Content.FeaturedPage.featuredStreamOrderOverride", with: ["500","500","500","500","500","500","500"])
            
            postTextFontColors = LPVar.define("Features.Post.TextAndDoodleColors", with:  ["454C88","397E99", "66CCCC","763F9E","2D7C5F","191919","FFFFFF","FC91B6","454C88","397E99", "66CCCC","763F9E","2D7C5F","191919","FFFFFF","FC91B6"])
            postTextBackgroundColors = LPVar.define("Features.Post.TextBackgroundColors", with:  ["454C88","397E99", "66CCCC","763F9E","2D7C5F","191919","FFFFFF","FC91B6","454C88","397E99", "66CCCC","763F9E","2D7C5F","191919","FFFFFF","FC91B6"])
            
            challengeTabNames = LPVar.define("Content.Challenges.challengeTabTitles", with: ["Trending","Latest","Respond First","Saved","Completed","Hashtag Cool","Hashtag Bar", "", "", "", "", "" , ""])
            challengeTabCategories = LPVar.define("Content.Challenges.challengeTabCategories", with: ["trending","recent","first","saved","completed","#cool","#bar", "", "", "", "", "" , ""])

        }
        
        struct Challenge {
            
            static var challengeDetailsCardAspectRatio = LPVar()
            
            static func initialize() {
                
                challengeDetailsCardAspectRatio = LPVar.define("Content.Challenge.ChallengeDetailsCardAspectRatio", with: 1.5)
                   
            }
            
        }
        
    }
    
    struct Profile {
        
        static var profileCoverHeight = LPVar()
        
        static func initialize() {
            
            profileCoverHeight = LPVar.define("Profile.ProfileCoverHeight", with: 175)
            
        }
        
    }
    
}
