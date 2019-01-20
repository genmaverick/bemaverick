//
//  Constants.swift
//  BeMaverick
//
//  Created by David McGraw on 9/7/17.
//  Copyright © 2017 BeMaverick. All rights reserved.
//

import CoreGraphics

public struct Constants {
    
    public static let termsOfServiceURL = "https://genmaverick.com/terms-of-service-and-privacy-policy"
    public static let communityGuidelinesURL = "https://genmaverick.com/community-guidelines"
    /// Support email
    public static let MaverickSupportEmail: String = "support@bemaverick.com"
    
    /// Default date format
    public static let MaverickDateFormat: String = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
    
    /// Total duration for a recording
    public static let CameraManagerMaxRecordDuration: CGFloat = 30
    
    /// The size of the video produced from the recording flow
    /// Other sizes to play with: 414x552,
    public static let CameraManagerExportSize: CGSize = CGSize(width: Constants.MaxContentScreenWidth * UIScreen.main.scale, height: Constants.MaxContentScreenWidth / Variables.Content.maxStreamAspectRatio.cgFloatValue() * UIScreen.main.scale)
    
    /// User Defaults key for saved recording sessions
    public static let KeySavedMaverickRecordingSessions: String = "SavedMaverickRecordingSessions"
    
    /// User Defaults key for saved response asset ids from the user's photo library
    public static let KeySavedMaverickRecordingAssetIdentifiers: String = "KeySavedMaverickRecordingAssetIdentifiers"
    
    /// User Defaults key for saved challenge asset ids from the user's photo library
    public static let KeySavedMaverickChallengeAssetIdentifiers: String = "KeySavedMaverickChallengeAssetIdentifiers"
    
    /// User Defaults key for saved vibes
    public static let KeySavedMaverickRecordingVibes: String = "SavedMaverickRecordingVibes"
    
 
    
    public enum ChallengeFeaturedType : String {
     
        case maverickStream = "maverick-stream"
        case challengeStream = "challenge-stream"
    
    }
    
    /// An enum representing the index of the tab bar items
    public enum MaverickTabs: Int {
        
        case challenges = 1003
        case feed       = 1002
        case profile    = 1001
        
        /// An offset index
        var index: Int {
            return self.rawValue
        }
        
        /// Index adjusting the offset back to 0
        var rawIndex: Int {
            return self.rawValue - 1001
        }
        
    }
    
    public enum APIEnvironmentType: String {
        
        case development = "development"
        
        case staging = "staging"
        
        case production = "production"
        
        case custom = "custom"
        
        var stringValue: String {
            
            switch self {
            case .development:
                return "https://dev-api.bemaverick.com/v1"
            case .staging:
                return "https://stage-api.bemaverick.com/v1"
            case .production:
                return "https://api.bemaverick.com/v1"
            case .custom:
                return "https://127.0.0.1:9000/v1"
            }
            
        }
        
        var commentBaseUrl: String {
            
            switch self {
            case .development:
                return "https://dev-lambda.genmaverick.com"
            case .staging:
                return "https://dev-lambda.genmaverick.com"
            case .production:
                return "https://lambda.genmaverick.com"
            case .custom:
                return "https://127.0.0.1:9000"
            }
            
        }
        
        var webUrlStringValue: String {
            
            switch self {
            case .development:
                return "https://dev.genmaverick.com"
            case .staging:
                return "https://dev.genmaverick.com"
            case .production:
                return "https://www.genmaverick.com"
            case .custom:
                return "https://127.0.0.1:9000/v1"
            }
            
        }
        
    }
    
    /// An enum representing the account type
    public enum AccountType: String {
        
        case none       = "none"
        case mentor     = "mentor"
        case maverick   = "kid"
        case parent     = "parent"
        
    }
    
    /// An enum representing content types
    public enum ContentType: String {
        
        case challenge    = "challenge"
        case response     = "response"
        
        
        var stringValue: String {
            
            switch self {
            case .challenge:
                return "challenge"
            case .response:
                return "response"
            
            }
        }
    }
    
    /// An enum representing content types
    public enum FeaturedStreamType: String {
        
        case challenge    = "challenge"
        case response     = "response"
        case advertisement     = "advertisement"
        
        var stringValue: String {
            
            switch self {
            case .challenge:
                return "challenge"
            case .response:
                return "response"
            case .advertisement:
                return "advertisement"
                
            }
        }
    }
    
    private static var _maxScreenWidth : CGFloat? = nil
   
    public static var MaxContentScreenWidth: CGFloat {
      
        get{
            
            if let width = _maxScreenWidth {
                
                return width
                
            }
            
            switch (UIScreen.main.traitCollection.userInterfaceIdiom) {
            case .pad:
                return 600
            default :
                return UIScreen.main.bounds.width
            }
            
            
        }
        
        set {
        
            _maxScreenWidth = newValue
            
        }
    }
    
    
    
    public enum NotificationSettings: String {
        
        case push = "push"
        case push_follower = "push_follower"
        case push_posts = "push_posts"
        case push_general = "push_general"
        
        var stringValue: String {
            
            switch self {
            case .push:
                return "Push Notifications"
            case .push_follower:
                return "Follower Activity"
            case .push_posts:
                return "My Post Activity"
            case .push_general:
                return "News and Announcements"
                
            }
        }
        
        var description: String {
            
            switch self {
            case .push:
                return ""
            case .push_follower:
                return "Get notified of actions taken by people you follow"
            case .push_posts:
                return "Get notified when others interact with your posts"
            case .push_general:
                return "Keep up to date with the latest on Maverick"
                
            }
        }
    
        
    }
    
    public enum TutorialVersion {
        
        case myFeed
        case challenges
        case featured
        case textPost
        case ugc_swipe
    }
    
    
   public enum blockState : String {
        case revoked = "revoked"
        case deactivated = "deactivated"
        case suggestedUpgrade = "suggestedUpgrade"
        case forecedUpgrade = "forecedUpgrade"
    }
    
    public enum RevokedMode : String {
        
        case admin = "admin"
        case parent = "parent"
        
    }
    
    public enum ContactMode : String {
       
        case phone = "Text"
        case email = "Email"
        case facebook = "Facebook"
        case twitter = "Twitter"
   
    }
    
    public struct DeepLink {
        
        public enum LinkType: String {

            case user = "user"
            case streams = "streams"
            case challenge = "challenge"
            case response = "response"
            case rate = "rate"
            case invite  = "invite"
            case findFriends  = "findfriends"
            case logout  = "logout"
            case feedback  = "feedback"
            case main  = "main"
            case request  = "request"
            case video  = "video"
            
        }
        
        public static let KEY_ID = "id"
        public static let KEY_TYPE = "type"
        public static let KEY_DEEP_LINK_URL = "deepLinkUrl"
        public static let KEY_SOURCE_DEEP_LINK_URL = "sourceDeepLinkUrl"
        public static let INVITE_SOURCE_KEY = "source"
        public static let INVITE_DATE_KEY = "date"
        
        var deepLink = LinkType.user
        var id = ""
        
    }
    
    /// An enum representing draft processing progress
    public enum DraftProcessingState {
        
        case processing
        case cancelled
        case failed
        case success
        
    }
    
    
    /// An enum representing profile cover types
    public enum ProfileCoverType: String {
        
        case preset    = "preset"
        case custom     = "custom"
   
    }
    /// An enum representing media types
    public enum MediaType: String {
        
        case cover    = "cover"
        case image    = "image"
        case video     = "video"
        case text     = "text"
        
        var stringValue: String {
            
            switch self {
            case .cover:
                return "cover"
            case .image:
                return "image"
            case .video:
                return "video"
            case .text:
                return "text"
                
            }
        }
    }
    
    /// An enum representing content sort types
    public enum ContentSortType: String {
        
        case createdTimestamp   = "createdTimestamp"
        case sortOrder          = "sortOrder"
        case title              = "title"
        
    }
    
    /// An enum representing a follower type
    public enum FollowerType: Int {
        
        case following
        case followers
        
    }
    
    
   
    
    /// An enum representing the available sorting orders
    public enum MaverickSortOrder: Int {
        
        case numBadges  = 4001
        case sortOrder  = 4002
        case featuredAndStartTimestamp  = 4006
        case title      = 4003
        case startTime  = 4004
        case endTime    = 4005
        
        var asString: String {
            
            switch self {
            case .numBadges:    return "numBadges"
            case .sortOrder:    return "sortOrder"
            case .title:        return "title"
            case .startTime:    return "startTime"
            case .endTime:      return "endTime"
            case .featuredAndStartTimestamp : return "featuredAndStartTimestamp"
            }
            
        }
        
    }
    
    /// An enum representing the status of a challenge
    public enum MaverickChallengeStatus: Int {
        
        case active
        case closed
        case published
        
        var asString: String {
            
            switch self {
            case .active:       return "active"
            case .closed:       return "closed"
            case .published:    return "published"
            }
            
        }
        
    }
    
    /// An enum representing various button types
    public enum MaverickButtonType: Int {
        
        case responses      = 5001
        case challenges
        case inspirations
        case savedChallenges
        case drafts
        case notifications
        case follow
        case following
        case followedBy
        case editAvatar
        
    }
    
    /// An enum representing brush button types on for drawing
    public enum RecordingBrushType: Int {
        
        case brush          = 6001
        case pencil
        case erase
        
    }
    
    /// An enum representing brush sizes button types on for drawing
    public enum RecordingBrushSize: Int {
        
        case size1          = 7001
        case size2
        case size3
        case size4
        case size5
        case size6
        
    }
    
    /// An enum representing keys used when saving recording state
    public enum RecordingStateKey: String {
        
        case identifier             = "RecordingStateOverlayIdentifier"
        case overlayFilterNameKey   = "RecordingStateOverlayNameKey"
        
        case masterOverlayKey       = "RecordingStateMasterOverlayKey"
        case overlayKey             = "RecordingStateOverlayKey"
        
        case filterKey              = "RecordingStateFilterKey"
        case doodleKey              = "RecordingStateDoodleKey"
        case textKey                = "RecordingStateTextKey"
        case stickerKey             = "RecordingStateStickerKey"
        
        case dataKey                = "RecordingStateDataKey"
        
    }
    
    /// An enum representing filter params
    enum FilterParameter: String {
        
        case inputAngle = "inputAngle"
        case inputSaturation = "inputSaturation"
        case inputBrightness = "inputBrightness"
        
    }
    
    /// The layout mode for the challenges view
    public enum LayoutMode {
        
        /// Cards take up more of the screen
        case expanded
        
        /// Cards take up less of the screen
        case condensed
        
        /// The height of the header cell
        var headerHeight: CGFloat {
            
            switch self {
            case .expanded:
                return 278
            case .condensed:
                return 278
            }
            
        }
        
        /// The height of the content cell(s)
        var contentHeight: CGFloat {
            
            switch self {
            case .expanded:
                return 278
            case .condensed:
                return 278
            }
            
        }
        
    }
    
    /// An enum representing values associated with upload size requirements
    public enum UploadSize: Int {
        
        case profileAvatar
        case profileCoverImage
        
        /// The size the content should be cropped to
        var size: CGSize {
            
            switch self {
            case .profileAvatar:
                return CGSize(width: 256, height: 256)
            case .profileCoverImage:
                return CGSize(width: 480, height: 270)
            }
            
        }
        
    }
    
    /// An enum representing the available response types
    public enum UploadResponseType: String {
        
        case video = "video"
        case image = "image"
        case text = "text"
        
    }
    
}
