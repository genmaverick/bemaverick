//
//  AnalyticsConstants.swift
//  BeMaverick
//
//  Created by Garrett Fritz on 2/5/18.
//  Copyright © 2018 BeMaverick. All rights reserved.
//

import Foundation

extension Constants {
    
    public struct Analytics {
        
        public struct Debug {
            
            public struct Events {
                
                public static let RECEIVED_LOW_MEMORY_WARNING = "DEBUG:RECEIVED_LOW_MEMORY_WARNING"
                
            }
            
            public struct Properties {
                
                public static let LAST_EVENT_NAME = "LAST_EVENT_NAME"
                public static let LAST_SCREEN_NAME = "LAST_SCREEN_NAME"
                
                public enum APPLICATION_STATUS: String {
                    
                    case key = "APPLICATION_STATUS"
                    case active = "ACTIVE"
                    case inactive = "INACTIVE"
                    case background = "BACKGROUND"
                    
                }
                
            }
            
        }
        
        public struct BackgroundAppRefresh {
            
            public struct Events {
                
                public static let BACKGROUND_APP_REFRESH_STARTED = "BACKGROUND_APP_REFRESH:STARTED"
                
                public static let BACKGROUND_APP_REFRESH_ENDED = "BACKGROUND_APP_REFRESH:ENDED"
                
            }
            
            public struct Properties {
                
                public static let REFRESH_DURATION = "REFRESH_DURATION"
                
                public enum COMPLETION_STATE: String {
                    
                    case key = "COMPLETION_STATE"
                    case failed = "FAILED"
                    case noData = "NO_DATA"
                    case newData = "NEW_DATA"
                    
                }
                
            }
            
        }
        
        public struct Onboarding {
            
            public  struct Events {
                
                public static let SPLASH_CTA_BUTTON_PRESSED = "ONBOARDING:SPLASH:CTA:PRESSED"
                public static let SPLASH_SIGNUP_BUTTON_PRESSED = "ONBOARDING:SPLASH:SIGNUP:PRESSED"
                public static let SPLASH_PAGE_CHANGED = "ONBOARDING:SPLASH:PAGE_CHANGED"
                public static let SIGNUP_INITIAL_CTA_PRESSED = "ONBOARDING:SIGNUP_INITIAL:CTA:PRESSED"
                public static let SIGNUP_INITIAL_FAIL = "ONBOARDING:SIGNUP_INITIAL:FAIL"
                
                public static let SIGNUP_TOS_PRESSED = "ONBOARDING:SIGNUP:TOS:PRESSED"
                
                public static let SIGNUP_DOB_CTA_PRESSED = "ONBOARDING:SIGNUP_DOB:CTA:PRESSED"
                public static let SIGNUP_DOB_FAIL = "ONBOARDING:SIGNUP_DOB:FAIL"
                
                public static let SIGNUP_EMAIL_CTA_PRESSED = "ONBOARDING:SIGNUP_EMAIL:CTA:PRESSED"
                public static let SIGNUP_SOCIAL_USERNAME_CTA_PRESSED = "ONBOARDING:SIGNUP:SOCIAL:USERNAME:CTA:PRESSED"
                
                
                 public static let SIGNUP_SOCIAL_FAILURE = "ONBOARDING:SIGNUP:SOCIAL:FAILURE"
                public static let SIGNUP_SOCIAL_SUCCESS = "ONBOARDING:SIGNUP:SOCIAL:SUCCESS"
   
                
                
                public static let SIGNUP_EMAIL_FAIL = "ONBOARDING:SIGNUP_EMAIL:FAIL"
                
                public static let COMPLETE_PROFILE_ADD_PHOTO_PRESSED = "ONBOARDING:COMPLETE_PROFILE:ADD_PHOTO:PRESSED"
                public static let COMPLETE_PROFILE_BIO_PRESSED = "ONBOARDING:COMPLETE_PROFILE:BIO:PRESSED"
                public static let COMPLETE_PROFILE_NEXT_PRESSED = "ONBOARDING:COMPLETE_PROFILE:NEXT:PRESSED"
                
                public static let ONBOARD_VIDEO_SKIP_PRESSED = "ONBOARDING:ONBOARD_VIDEO:SKIP:PRESSED"
                
                public static let SIGNUP_SUCCESS = "SIGNUP:SUCCESS"
                
                public static let LOGIN_CTA_PRESSED = "ONBOARDING:LOGIN:CTA:PRESSED"
                public static let FORGOT_PASSWORD_PRESSED = "ONBOARDING:LOGIN:FORGOT_PASSWORD:PRESSED"
                public static let LOGIN_FAIL = "ONBOARDING:LOGIN:FAIL"
                public static let LOGIN_SUCCESS = "LOGIN:SUCCESS"
                
                public static let LOGIN_SOCIAL_SMS_REQUEST_PRESSED = "ONBOARDING:LOGIN:SOCIAL:SMS_REQUEST:PRESSED"
                  public static let LOGIN_SOCIAL_SMS_VALIDATE_SUCCESS = "ONBOARDING:LOGIN:SOCIAL:SMS_VALIDATE:SUCCESS"
                public static let LOGIN_SOCIAL_SMS_VALIDATE_FAILURE = "ONBOARDING:LOGIN:SOCIAL:SMS_VALIDATE:FAILURE"
                
                public static let SIGNUP_SOCIAL_SMS_REQUEST_PRESSED = "ONBOARDING:SIGNUP:SOCIAL:SMS_REQUEST:PRESSED"
                
                 public static let SIGNUP_SOCIAL_SMS_VALIDATE_SUCCESS = "ONBOARDING:SIGNUP:SOCIAL:SMS_VALIDATE:SUCCESS"
                    public static let SIGNUP_SOCIAL_SMS_VALIDATE_FAILURE = "ONBOARDING:SIGNUP:SOCIAL:SMS_VALIDATE:FAILURE"
                
                public static let FORGOT_PASSWORD_CTA_PRESSED = "ONBOARDING:FORGOT_PASSWORD:CTA:PRESSED"
                public static let FORGOT_USERNAME_PRESSED = "ONBOARDING:FORGOT_PASSWORD:FORGOT_USERNAME:PRESSED"
                public static let FORGOT_USERNAME_CTA_PRESSED = "ONBOARDING:FORGOT_USERNAME:CTA:PRESSED"
                
                public static let INVITE_OPENED = "INVITE:OPENED"
                
                public static let VPC_INFO_ENTRY_SUBMIT_SUCCESS = "VPC_INFO_ENTRY:SUBMIT:SUCCESS"
                public static let VPC_INFO_ENTRY_SUBMIT_FAIL = "VPC_INFO_ENTRY:SUBMIT:FAIL"
                
                public static let VPC_VPC_ACCESS_GRANT_SUBMIT_SUCCESS = "VPC_ACCESS_GRANT:SUBMIT:SUCCESS"
                public static let VPC_VPC_ACCESS_GRANT_SUBMIT_FAIL = "VPC_ACCESS_GRANT:SUBMIT:FAIL"
                
                
            }
            
            public  struct Screens {
                
                public static let SPLASH = "ONBOARDING:SPLASH"
                public static let SIGNUP = "ONBOARDING:SIGNUP_INITIAL"
                public static let SIGNUP_DOB = "ONBOARDING:SIGNUP_DOB"
                public static let SIGNUP_EMAIL = "ONBOARDING:SIGNUP_EMAIL"
                public static let SIGNUP_COMPLETE_PROFILE = "ONBOARDING:COMPLETE_PROFILE"
                public static let SIGNUP_ONBOARD_CELEBRATION = "ONBOARDING:COMPLETE_PROFILE:CELEBRATION"
                public static let SIGNUP_ONBOARD_VIDEO = "ONBOARDING:ONBOARD_VIDEO"
                public static let LOGIN = "ONBOARDING:LOGIN"
                public static let FORGOT_PASSWORD = "ONBOARDING:FORGOT_PASSWORD"
                public static let FORGOT_USERNAME = "ONBOARDING:FORGOT_USERNAME"
                public static let TOS = "ONBOARDING:TOS"
                public static let SMS_REQUEST = "ONBOARDING:SMS_REQUEST"
                
            }
            
        }
        
        
        public struct Viewing {
            
            public struct Events {
                
                public static let VIDEO_START = "VIEWING:VIDEO:START"
                public static let VIDEO_STOP = "VIEWING:VIDEO:STOP"
                public static let VIDEO_RESUME = "VIEWING:VIDEO:RESUME"
                public static let VIDEO_REPLAY = "VIEWING:VIDEO:REPLAY"
                public static let VIDEO_COMPLETE = "VIEWING:VIDEO:COMPLETE"
                public static let VIDEO_PROGRESS_25 = "VIEWING:VIDEO:PROGRESS:25"
                public static let VIDEO_PROGRESS_50 = "VIEWING:VIDEO:PROGRESS:50"
                public static let VIDEO_PROGRESS_75 = "VIEWING:VIDEO:PROGRESS:75"
                
            }
            
            public struct Properties {
                
                public static let BUFFER_TIME_MS = "BUFFER_TIME_MS"
                public static let IS_MUTED = "IS_MUTED"
                public static let START_TIME = "START_TIME"
                public static let VIEWING_DURATION = "VIEWING_DURATION"
                public static let STOP_TIME = "STOP_TIME"
                public static let LOCATION = "LOCATION"
                
            }
            
        }
        
        public struct Post {
            
            public struct Events {
                
                public static let UPLOAD_PRESSED = "POST:UPLOAD:PRESSED"
                public static let POST_SERVER_CALL_STARTED = "POST:SERVER:CALL:STARTED"
                public static let POST_SERVER_CALL_RETURNED = "POST:SERVER:CALL:RETURNED"
                public static let POST_FAIL = "POST:FAIL"
                public static let POST_SUCCESS = "POST:SUCCESS"
                
                public static let CAMERA_FLASH_PRESSED = "POST:CAMERA:FLASH:PRESSED"
                public static let CAMERA_FLIP_PRESSED = "POST:CAMERA:FLIP:PRESSED"
                public static let CAMERA_TIMER_PRESSED = "POST:CAMERA:TIMER:PRESSED"
                public static let CAMERA_CANCEL_TIMER_PRESSED = "POST:CAMERA:CANCEL_TIMER:PRESSED"
                public static let CAMERA_TAB_PRESSED = "POST:CAMERA:TAB:PRESSED"
                public static let CAMERA_LIBRARY_PRESSED = "POST:CAMERA:LIBRARY:PRESSED"
                public static let CAMERA_RECORD_PRESSED = "POST:CAMERA:RECORD:PRESSED"
                public static let CAMERA_STOP_PRESSED = "POST:CAMERA:STOP:PRESSED"
                public static let CAMERA_NEXT_PRESSED = "POST:CAMERA:NEXT:PRESSED"
                public static let CAMERA_BACK_PRESSED = "POST:CAMERA:BACK:PRESSED"
                public static let CAMERA_SAVE_DRAFT_PRESSED = "POST:CAMERA:SAVE_DRAFT:PRESSED"
                public static let CAMERA_START_OVER_PRESSED = "POST:CAMERA:START_OVER:PRESSED"
                public static let CAMERA_CANCEL_PRESSED = "POST:CAMERA:CANCEL:PRESSED"
                
                public static let ASSET_PICKER_BACK_PRESSED = "POST:ASSET_PICKER:BACK:PRESSED"
                public static let ASSET_PICKER_ASSET_SELECTED = "POST:ASSET_PICKER:ASSET:SELECTED"
                
                public static let EDIT_TAB_PRESSED = "POST:EDIT:TAB:PRESSED"
                public static let EDIT_UNDO_PRESSED = "POST:EDIT:UNDO:PRESSED"
                public static let EDIT_PLAY_PRESSED = "POST:EDIT:PLAY:PRESSED"
                public static let EDIT_PAUSE_PRESSED = "POST:EDIT:PAUSE:PRESSED"
                public static let EDIT_FILTER_SELECTED = "POST:EDIT:FILTER:SELECTED"
                public static let EDIT_STICKER_SELECTED = "POST:EDIT:STICKER:SELECTED"
                public static let EDIT_PEN_SELECTED = "POST:EDIT:PEN:SELECTED"
                public static let EDIT_TEXT_SELECTED = "POST:EDIT:TEXT:SELECTED"
                public static let EDIT_NEXT_PRESSED = "POST:EDIT:NEXT:PRESSED"
                public static let EDIT_BACK_PRESSED = "POST:EDIT:BACK:PRESSED"
                
                public static let TRIMMER_BACK_PRESSED = "POST:TRIMMER:BACK:PRESSED"
                public static let TRIMMER_DONE_PRESSED = "POST:TRIMMER:DONE:PRESSED"
                public static let TRIMMER_PLAY_PRESSED = "POST:TRIMMER:PLAY:PRESSED"
                public static let TRIMMER_PAUSE_PRESSED = "POST:TRIMMER:PAUSE:PRESSED"
                public static let TRIMMER_NEXT_PRESSED = "POST:TRIMMER:NEXT:PRESSED"
                public static let TRIMMER_PREVIOUS_PRESSED = "POST:TRIMMER:PREVIOUS:PRESSED"
                public static let TRIMMER_DELETE_PRESSED = "POST:TRIMMER:DELETE:PRESSED"
                public static let TRIMMER_REPLAY_PRESSED = "POST:TRIMMER:REPLAY:PRESSED"
                
                public static let DETAILS_BACK_PRESSED = "POST:DETAILS:BACK:PRESSED"
                public static let DETAILS_CHANGE_COVER_PRESSED = "POST:DETAILS:CHANGE_COVER:PRESSED"
                public static let DETAILS_DESCRIPTION_ENTRY_STARTED = "POST:DETAILS:DESCRIPTION_ENTRY:STARTED"
                public static let DETAILS_SAVE_PRESSED = "POST:DETAILS:SAVE:PRESSED"
                
                public static let COVER_SELECTOR_BACK_PRESSED = "POST:COVER_SELECTOR:BACK:PRESSED"
                public static let COVER_SELECTOR_SAVE_PRESSED = "POST:COVER_SELECTOR:SAVE:PRESSED"
                
            }
            
            public struct Properties {
                
                public static let FILTER_NAME = "FILTER_NAME"
                public static let STICKER_NAME = "STICKER_NAME"
                public static let FONT_NAME = "FONT_NAME"
                public static let FONT_COLOR = "FONT_COLOR"
                public static let BRUSH_COLOR = "BRUSH_COLOR"
                public static let SAVE_DRAFT_DETAILS_STATE = "SAVE_DRAFT_DETAILS_STATE"
                public static let UPLOAD_DETAILS_STATE = "UPLOAD_DETAILS_STATE"
                public static let HAS_MULTIPLE_SEGMENTS = "HAS_MULTIPLE_SEGMENTS"
                public static let UPLOAD_VIDEO_LENGTH = "UPLOAD_VIDEO_LENGTH"
                public static let HAS_STICKERS = "HAS_STICKERS"
                public static let STICKER_NAMES = "STICKER_NAMES"
                public static let HAS_TEXT = "HAS_TEXT"
                public static let HAS_DOODLE = "HAS_DOODLE"
                public static let HAS_FILTER = "HAS_FILTER"
                public static let HAS_TAGS = "HAS_TAGS"
                public static let HAS_DESCRIPTION = "HAS_DESCRIPTION"
                
                public enum CAPTURE_DEVICE_POSITION: String {
                    
                    case key = "CAPTURE_DEVICE_POSITION"
                    case front = "FRONT"
                    case back = "BACK"
                    
                }
                
                public enum TIMER_STATE: String {
                    
                    case key = "TIMER_SELECTION_STATE"
                    case none = "NONE"
                    case five = "FIVE_SECONDS"
                    case ten = "TEN_SECONDS"
                    
                }
                
                public enum FLASH_STATE: String {
                    
                    case key = "FLASH_SELECTION_STATE"
                    case on = "ON"
                    case off = "OFF"
                    
                }
                
                public enum EDIT_TAB_SELECTION_STATE: String {
                    
                    case key = "EDIT_TAB_SELECTION_STATE"
                    case filter = "FILTER"
                    case background = "BACKGROUND"
                    case sticker = "STICKER"
                    case text = "TEXT"
                    case drawing = "DRAWING"
                    
                }
                
                public enum EDIT_BRUSH_TYPE: String {
                    
                    case key = "EDIT_BRUSH_TYPE"
                    case brush = "BRUSH"
                    case pencil = "PENCIL"
                    case erase = "ERASE"
                    
                }
                
                public enum EDIT_BRUSH_SIZE: String {
                    
                    case key = "EDIT_BRUSH_SIZE"
                    case size1 = "Size 1"
                    case size2 = "Size 2"
                    case size3 = "Size 3"
                    case size4 = "Size 4"
                    case size5 = "Size 5"
                    case size6 = "Size 6"
                    
                }
                
                public enum COVER_SELECTOR_TOUCHED_PREVIEW_STATE: String {
                    
                    case key = "COVER_SELECTOR_TOUCHED_PREVIEW_STATE"
                    case hasTouchedPreviewImage = "HAS_TOUCHED_PREVIEW_IMAGE"
                    case hasNotTouchedPreviewImage = "HAS_NOT_TOUCHED_PREVIEW_IMAGE"
                    
                }
                
                public enum ASSET_RETRIEVAL: String {
                    
                    case key = "ASSET_RETRIEVAL"
                    case success = "SUCCESS"
                    case failure = "FAILURE"
                    
                }
                
                public enum SESSION_STATE: String {
                    
                    case key = "SESSION_STATE"
                    case yes = "YES"
                    case no = "NO"
                    
                }
                
                public enum POST_FAILURE_REASON: String {
                    
                    case key = "POST_FAILURE_REASON"
                    case assetLoadingFailure = "ASSET_LOADING_FAILURE"
                    case serverUploadFailure = "SERVER_UPLOAD_FAILURE"
                
                }
                
            }
            
        }
        
        public struct Comment {
            
            public struct Events {
                
                public static let COMMENT_SEND_PRESSED = "COMMENT:SEND:PRESSED"
                public static let COMMENT_SEND_SUCCESS = "COMMENT:SEND:SUCCESS"
                public static let COMMENT_SEND_FAIL = "COMMENT:SEND:FAIL"
                public static let COMMENT_ENTRY_STARTED = "COMMENT:ENTRY:STARTED"
                public static let COMMENT_DELEED = "COMMENT:ITEM:DELETED"
                public static let COMMENT_REPORTED = "COMMENT:ITEM:REPORED"
                public static let COMMENT_AUTHOR_BLOCKED = "COMMENT:ITEM:AUTHOR:BLOCKED"
                public static let COMMENT_TAPPED = "COMMENT:ITEM:TAPPED"
                
                
            }
        }
        
        public struct Progression {
            
            public struct Events {
                
                public static let PROJECT_ACCOMPLISHED = "PROGRESSION:PROJECT:ACCOMPLISHED"
                public static let LEVEL_ACCOMPLISHED = "PROGRESSION:LEVEL:ACCOMPLISHED"
                public static let REWARD_LOCKED = "PROGRESSION:REWARD:LOCKED"
                public static let BADGE_PRESSED = "MY_PROGRESS:BADGE:PRESSED"
                public static let PROJECT_PRESSED = "MY_PROGRESS:PROJECT:PRESSED"
                public static let PROJECT_SEE_ALL_PRESSED = "MY_PROGRESS:PROJECT_SEE_ALL:PRESSED"
                public static let NEXT_LEVEL_PRESSED = "MY_PROGRESS:NEXT_LEVEL:PRESSED"
                
            }
            
            public struct Screens {
               
                public static let MY_PROGRESS = "MY_PROGRESS"
                public static let LEADERBOARD = "LEADERBOARD"
                public static let BADGES_RECEIVED = "BADGES_RECEIVED"
                public static let BADGES_RECEIVED_PAGER = "BADGES_RECEIVED_PAGER"
                public static let PROJECT_PROGRESS_PAGER = "PROJECT_PROGRESS_PAGER"
                public static let PROJECT_PROGRESS = "PROJECT_PROGRESS"
                public static let PROJECT_DETAILS = "PROJECT_DETAILS"
                public static let LEVEL_DETAILS = "LEVEL_DETAILS"
                
            }
            
            public struct Properties {
                
                public static let PROJECT_ID = "PROJECT_ID"
                public static let REWARD_KEY = "REWARD_KEY"
                public static let LEVEL_NUMBER = "LEVEL_NUMBER"
                public static let BADGE_ID = "BADGE_ID"
                public static let PROGRESS_FILTER = "PROGRESS_FILTER"
                
            }
            
        }
       
        public struct Main {
            
            public struct Events {
                
                public static let CHALLENGE_RESPOND_PRESSED = "CHALLENGE:RESPOND:PRESSED"
                public static let BACK_PRESSED = "BACK:PRESSED"
                public static let MAIN_TAB_PRESSED = "MAIN_TAB:PRESSED"
                public static let UPPER_TAB_PRESSED = "UPPER_TAB:PRESSED"
                public static let FEED_NEXT_PAGE = "FEED:NEXT_PAGE"
                public static let PAGE_SWIPED = "PAGE_SWIPED"
                public static let PAGE_SWIPED_DISMISS = "PAGE_SWIPED:DISMISS"
                public static let FEATURED_STREAM_HORIZONTAL_SCROLL_POSITION = "FEATURED_STREAM:HORIZONTAL_SCROLL:POSITION"
                public static let FEATURED_STREAM_VERTICAL_SCROLL_POSITION = "FEATURED_STREAM:VERTICAL_SCROLL:POSITION"
                
                public static let CHALLENGE_DETAILS_DISMISSED = "CHALLENGE_DETAILS:DISMISSED"

                
            }
            
            public struct Properties {
                
                public static let ROW = "ROW"
                public static let COLUMN = "COLUMN"
                
                public enum DISMISS_TYPE:  String {
                    
                    case key = "DISMISS_TYPE"
                    case PULL = "PULL"
                    case SWIPE = "SWIPE"
                    case BUTTON = "BUTTON"
                    
                }
                
                public enum CONTENT_TYPE: String {
                    
                    case key = "CONTENT_TYPE"
                    case content = "CONTENT"
                    case response = "RESPONSE"
                    case challenge = "CHALLENGE"
                    
                }
                
                public enum CONTENT_STYLE: String {
                    
                    case key = "CONTENT_STYLE"
                    case small = "SMALL"
                    case large = "LARGE"
                    case full = "FULL"
                    
                    
                }
                
                public enum FAILURE_TYPE: String {
                    
                    case key = "FAILURE_TYPE"
                    case api = "API"
                    case user = "USER"
                    
                }
                
                public static let REPORT_RATIONALE = "REPORT_RATIONALE"
                public static let LOCATION = "LOCATION"
                public static let TAB_INDEX = "TAB_INDEX"
                public static let FAILURE_REASON = "FAILURE_DESCRIPTION"
                public static let HAS_AVATAR = "HAS_AVATAR"
                public static let HAS_BIO = "HAS_BIO"
                public static let SIGNUP_MODE = "SIGNUP_MODE"
                public static let ID = "ID"
                public static let SELECTED = "SELECTED"
                public static let BADGE = "BADGE"
                public static let TARGET_USER_ID = "TARGET_USER_ID"
                public static let HASHTAG_NAME = "HASHTAG_NAME"
                public static let AUTHOR_ID = "AUTHOR_ID"
                public static let CHALLENGE_ID = "CHALLENGE_ID"
                public static let CHALLENGE_TITLE = "CHALLENGE_TITLE"
                
                public enum MEDIA_TYPE: String {
                    
                    case key = "MEDIA_TYPE"
                    case video = "VIDEO"
                    case image = "IMAGE"
                    case text = "TEXT"
                    
                }
                
                public enum MENTION_LOCATION: String {
                    
                    case key = "LOCATION"
                    case comment = "COMMENT"
                    case bio = "USER_BIO"
                    case contentDescription = "CONTENT_DESCRIPTION"
                    
                }
                
                
                public static let INVITE_DATE = "INVITE_DATE"
                public static let INVITE_SOURCE = "INVITE_SOURCE"
                
            }
            
            public struct Screens {
                
                public static let PROFILE = "PROFILE"
                public static let FOLLOWERS = "FOLLOWERS"
                public static let CHALLENGE_STREAM = "CHALLENGE_STREAM"
                public static let CHALLENGE_DETAILS = "CHALLENGE_DETAILS"
                public static let CHALLENGE_DETAILS_PAGER = "CHALLENGE_DETAILS_PAGER"
                public static let BADGE_COACHMARK = "BADGE_COACHMARK"
                public static let RESPONSE_BADGES = "RESPONSE_BADGES"
                public static let MAVERICK_STREAM = "MAVERICK_STREAM"
                public static let MY_STREAM = "MY_STREAM"
                public static let USER_RESPONSE_STREAM = "USER_RESPONSE_STREAM"
                 public static let HASHTAG_RESPONSE_STREAM = "HASHTAG_RESPONSE_STREAM"
                public static let CHALLENGE_RESPONSE_STREAM = "CHALLENGE_RESPONSE_STREAM"
                public static let USER_INSPIRATION_STREAM = "USER_INSPIRATION_STREAM"
                public static let CONTENT_FULL_SCREEN = "CONTENT_FULL_SCREEN"
                public static let NOTIFICATIONS = "NOTIFICATIONS"
                public static let ACTION_SHEET = "ACTION_SHEET"
                public static let INACTIVE_USER = "INACTIVE_USER"
                
                public static let VPC_INFO_ENTRY = "VPC_INFO_ENTRY"
                public static let VPC_ACCESS_GRANT = "VPC_ACCESS_GRANT"
                public static let COMMENTS = "COMMENTS"
                public static let GENERIC_CHALLENGE_STREAM = "GENERIC_CHALLENGE_STREAM"
                public static let GENERIC_RESPONSE_STREAM = "GENERIC_RESPONSE_STREAM"
                
                public static let CREATE_CHALLENGE = "CREATE_CHALLENGE"
                public static let EDIT_CHALLENGE = "EDIT_CHALLENGE"
                public static let SEARCH_USERS = "SEARCH_USERS"
                
                public static let FULL_SCREEN_IN_APP = "FullScreenInAppMessageViewController"
                
                public static let CHALLENGES_VIEW_CONTROLLER = "CHALLENGES"
                
                public static let POST_RECORD_VIEW_CONTROLLER = "POST_RECORD"
                public static let POST_COVER_SELECTOR_VIEW_CONTROLLER = "POST_COVER_SELECTOR"
                public static let POST_METADATA_VIEW_CONTROLLER = "POST_METADATA"
                public static let POST_MODE_CONFIRM_VIEW_CONTROLLER = "POST_MODE_CONFIRM"
                public static let ASSET_PICKER_VIEW_CONTROLLER = "ASSET_PICKER"
                public static let ASSET_TRIMMER_VIEW_CONTROLLER = "ASSET_TRIMMER"
                
                  public static let CHALLENGES_PAGE_HASHTAG_VIEW_CONTROLLER = "CHALLENGES_PAGE_HASHTAG"
                  public static let CHALLENGES_PAGE_RECENT_VIEW_CONTROLLER = "CHALLENGES_PAGE_RECENT"
                  public static let CHALLENGES_PAGE_COMPLETED_VIEW_CONTROLLER = "CHALLENGES_PAGE_COMPLETED"
                  public static let CHALLENGES_PAGE_SAVED_VIEW_CONTROLLER = "CHALLENGES_PAGE_SAVED"
                  public static let CHALLENGES_PAGE_EMPTY_VIEW_CONTROLLER = "CHALLENGES_PAGE_EMPTY"
               public static let CHALLENGES_PAGE_TRENDING_VIEW_CONTROLLER = "CHALLENGES_PAGE_TRENDING"
                
                
                public static let CHALLENGES_PAGE_INVITED = "CHALLENGES_PAGE_INVITED"
                public static let HASHTAG_CHANNEL = "HASHTAG_CHANNEL"
                
                public static let CHALLENGES_PAGER_CONTROLLER = "CHALLENGES_PAGER_CONTROLLER"
                
                public static let CHALLENGES_DETAILS_PAGER_CONTROLLER = "CHALLENGES_DETAILS_PAGER_CONTROLLER"
                public static let HASHTAG_PAGER_CONTROLLER = "HASHTAG_PAGER_CONTROLLER"
                public static let ONBOARD_SPLASH_PAGER_CONTROLLER = "ONBOARD_SPLASH_PAGER_CONTROLLER"
                public static let CREATE_CHALLENGE_PAGER_CONTROLLER = "CREATE_CHALLENGE_PAGER_CONTROLLER"
                 public static let CHALLENGES_PAGE_LINK = "CHALLENGES_PAGE_LINK"
            }
            
        }
        
        public struct Profile {
            
            public struct Events {
                
                public static let OVERFLOW_PRESSED = "PROFILE:OVERFLOW:PRESSED"
                public static let SETTINGS_PRESSED = "PROFILE:SETTINGS:PRESSED"
                public static let NOTIFICATIONS_PRESSED = "PROFILE:NOTIFICATIONS:PRESSED"
                public static let SHARE_PRESSED = "PROFILE:SHARE:PRESSED"
                public static let FIND_FRIENDS_PRESSED = "PROFILE:FIND_FRIENDS:PRESSED"
                public static let QR_PRESSED = "PROFILE:QR:PRESSED"
                public static let FOLLOWING_PRESSED = "PROFILE:FOLLOWING:PRESSED"
                public static let FOLLOWERS_PRESSED = "PROFILE:FOLLOWERS:PRESSED"
                public static let FOLLOW_PRESSED = "PROFILE:FOLLOW:PRESSED"
                public static let UN_FOLLOW_PRESSED = "PROFILE:UNFOLLOW:PRESSED"
                public static let BADGE_PRESSED = "PROFILE:BADGE:PRESSED"
                public static let TAB_PRESSED = "PROFILE:TAB:PRESSED"
                public static let DELETE_DRAFT = "PROFILE:DELETE_DRAFT:PRESSED"
                public static let MENTION_PRESSED = "MENTION:PRESSED"
                public static let HASHTAG_PRESSED = "HASHTAG:PRESSED"
                public static let MENTION_SUCCESS = "MENTION:SUCCESS"
                public static let BLOCK_USER = "PROFILE:BLOCK_USER"
                public static let UN_BLOCK_USER = "PROFILE:UN_BLOCK_USER"
                
            }
            
            public struct Properties {
                
                public static let EMAIL = "email"
                public static let PARENT_EMAIL = "parentEmail"
                public static let OVER_THIRTEEN = "overThirteen"
                public static let USERNAME = "username"
                public static let SOURCE_USERNAME = "sourceUsername"
                public static let SOURCE_USER_ID = "sourceUserId"
                public static let FIRST_NAME = "firstName"
                public static let AVATAR = "avatar"
                public static let BADGED_RESPONSES = "BADGED_RESPONSES"
                public static let FOLLOWING_USERS = "FOLLOWING_USERS"
                public static let LAST_NAME = "lastName"
                
            }
            
        }
        
        public struct CreateChallenge {
            
            public struct Properties {
                
                public enum CTA_LOCATION: String {
                    
                    case key = "LOCATION"
                    case challenges = "CHALLENGES"
                    case profile = "PROFILE"
                    
                }
                 public static let THEME_NAME = "THEME_NAME"
                public static let HAS_PHOTO = "HAS_PHOTO"
                public static let CHARACTERS = "CHARACTERS"
                public static let HAS_TITLE = "HAS_TITLE"
                public static let HAS_LINK = "HAS_LINK"
                public static let MENTION_COUNT = "MENTION_COUNT"
                public static let HAS_DESCRIPTION = "HAS_DESCRIPTION"
                public static let REMAINING_BADGES = "REMAINING_BADGES"
                public static let REMAINING_RESPONSES = "REMAINING_RESPONSES"
            }
            public struct Events {
                
                public static let CREATE_CHALLENGE_CTA_PRESSED = "CREATE_CHALLENGE:CTA:PRESSED"
                public static let CREATE_CHALLENGE_BLOCKED = "CREATE_CHALLENGE:BLOCKED"
                public static let CREATE_CHALLENGE_LEARN_PRESSED = "CREATE_CHALLENGE:LEARN_MORE:PRESSED"
                public static let CREATE_CHALLENGE_CAMERA_TAPPED_PRESSED = "CREATE_CHALLENGE:CAMERA_TAPPED:PRESSED"
                public static let CREATE_CHALLENGE_CAMERA_FLIPPED_PRESSED = "CREATE_CHALLENGE:CAMERA_FLIPPED:PRESSED"
                public static let CREATE_CHALLENGE_THEME_CHANGED = "CREATE_CHALLENGE:THEME:CHANGED"
                public static let CREATE_CHALLENGE_LOCKED_THEME_PRESSED = "CREATE_CHALLENGE:LOCKED_THEME:PRESSED"
                
                public static let CREATE_CHALLENGE_CREATE_LINK_PRESSED = "CREATE_CHALLENGE:CREATE_LINK:PRESSED"
                public static let CREATE_CHALLENGE_COMMIT_LINK_PRESSED = "CREATE_CHALLENGE:COMMIT_LINK:PRESSED"
                public static let CREATE_CHALLENGE_CLEAR_LINK_PRESSED = "CREATE_CHALLENGE:CLEAR_LINK:PRESSED"
                
                public static let CREATE_CHALLENGE_CREATE_FAILED = "CREATE_CHALLENGE:CREATE:FAILED"
                public static let CREATE_CHALLENGE_CREATE_PRESSED = "CREATE_CHALLENGE:CREATE:PRESSED"
                public static let CREATE_CHALLENGE_CREATE_SUCCESS = "CREATE_CHALLENGE:CREATE:SUCCESS"
                
                public static let EDIT_CHALLENGE_CLOSE = "EDIT_CHALLENGE:CLOSE"
                public static let EDIT_CHALLENGE_SAVE = "EDIT_CHALLENGE:SAVE"
                public static let EDIT_CHALLENGE_SEARCH_PRESSED = "EDIT_CHALLENGE:SEARCH:PRESSED"
                public static let EDIT_CHALLENGE_INVITE_PRESSED = "EDIT_CHALLENGE:INVITE:PRESSED"
                
                public static let EDIT_CHALLENGE_CREATE_LINK_PRESSED = "EDIT_CHALLENGE:CREATE_LINK:PRESSED"
                public static let EDIT_CHALLENGE_CLEAR_LINK_PRESSED = "EDIT_CHALLENGE:CLEAR_LINK:PRESSED"
                
            }
            
        }
        
        public struct Challenge {
            
            public struct Events {
                
                public static let AUTHOR_PRESSED = "CHALLENGE_DETAILS:AUTHOR:PRESSED"
                public static let MAIN_PRESSED = "CHALLENGE_DETAILS:MAIN:PRESSED"
                public static let SAVE_PRESSED = "CHALLENGE_DETAILS:SAVE:PRESSED"
                public static let SUMARY_HEADER_PRESSED = "CHALLENGE_DETAILS:SUMARY_HEADER:PRESSED"
                public static let EDIT_INVITE = "CHALLENGE_DETAILS:EDIT_INVITE:PRESSED"
                public static let SHOW_RESPONSES = "CHALLENGE_DETAILS:SHOW_RESPONSES:PRESSED"
                public static let UN_SAVE_PRESSED = "CHALLENGE_DETAILS:UN_SAVE:PRESSED"
                public static let SHARE_PRESSED = "CHALLENGE_DETAILS:SHARE:PRESSED"
                public static let HASHTAG_PRESSED = "CHALLENGE_DETAILS:HASHTAG:PRESSED"
                public static let COMMENTS_SHOW_PRESSED = "CHALLENGE_DETAILS:SHOW_COMMENTS:PRESSED"
                
                             public static let OVERFLOW_PRESSED = "CHALLENGE_DETAILS:OVERFLOW:PRESSED"
                
                
                
            }
            
        }
        
        public struct Invite {
            
            public struct Events {
                
                public static let SELECTOR_TEXT_PRESSED = "INVITE:SELECTOR:TEXT:PRESSED"
                public static let SELECTOR_EMAIL_PRESSED = "INVITE:SELECTOR:EMAIL:PRESSED"
                public static let SELECTOR_QR_PRESSED = "INVITE:SELECTOR:QR:PRESSED"
                public static let CONTACTS_INVITE_PRESSED = "INVITE:CONTACTS:INVITE:PRESSED"
                public static let CONTACTS_SEND_PRESSED = "INVITE:CONTACTS:SEND:PRESSED"
                public static let CONTACTS_CUSTOMIZE_SEND_PRESSED = "INVITE:CONTACTS:CUSTOMIZE:SEND:PRESSED"
                public static let CONTACTS_INVITE_ALL_PRESSED = "INVITE:CONTACTS:INVITE_ALL:PRESSED"
                public static let CONTACTS_QR_SHARE_PRESSED = "INVITE:QR:SHARE:PRESSED"
                public static let CONTACTS_QR_SCAN_PRESSED = "INVITE:QR:SCAN:PRESSED"
                public static let CONTACTS_QR_SAVE_PRESSED = "INVITE:QR:SAVE:PRESSED"
                public static let CONTACTS_QR_LIBRARY_SCAN = "INVITE:QR:LIBRARY:SCAN"
                public static let CONTACTS_QR_TAPPED = "INVITE:QR:TAPPED"
                public static let CONTACTS_QR_CAMERA_STARTED = "INVITE:QR:CAMERA:STARTED"
                public static let CONTACTS_QR_CAMERA_SCAN = "INVITE:QR:CAMERA:SCAN"
                public static let CONTACTS_QR_IMAGE_SCANNED_SUCCESS = "INVITE:QR:IMAGE:SCANNED:SUCCESS"
                public static let CONTACTS_QR_IMAGE_SCANNED_FAIL = "INVITE:QR:IMAGE:SCANNED:FAIL"
                public static let CONTACTS_QR_LIBRARY_PRESSED = "INVITE:QR:CAMERA:LIBRARY:PRESSED"
                
                
            }
            
            
            public struct Screens {
                
                public static let SELECTOR = "INVITE_SELECTOR"
                public static let QR = "INVITE_QR"
                public static let QR_CAMERA = "INVITE_QR:CAMERA"
                public static let CONTACTS = "INVITE_CONTACTS"
                public static let CUSTOMIZE_EMAIL = "INVITE_CONTACTS:CUSTOMIZE"
                
            }
            
            public struct Properties {
                
                public enum CONTACT_TYPE: String {
                    
                    case key = "CONTACT_TYPE"
                    case phone = "PHONE"
                    case email = "EMAIL"
                    case twitter = "TWITTER"
                    case facebook = "FACEBOOK"
                    
                }
                
                public enum SOURCE: String {
                    
                    case key = "SOURCE"
                    case deepLink = "DEEP_LINK"
                    case onboarding = "ONBOARDING"
                    case profile = "PROFILE"
                    case editChallenge = "EDIT_CHALLENGE"
                    
                }
                
                public enum FAILURE_TYPE: String {
                    
                    case key = "FAILURE_TYPE"
                    case noQR = "NOT_QR"
                    case invalidQR = "NOT_MAVERICK_QR"
                    case notUser = "NOT_MAVERICK_USER"
                    
                }
                
                public static let EDITIED = "EDITED"
                
                
            }
            
        }
        
        public struct Content {
            
            public struct Events {
                
                public static let AUTHOR_PRESSED = "CONTENT:AUTHOR:PRESSED"
                
                 public static let LINK_PRESSED = "CONTENT:LINK:PRESSED"
                
                public static let PROMO_PRESSED = "CONTENT:PROMO:PRESSED"
                
                
                public static let MAIN_PRESSED = "CONTENT:MAIN:PRESSED"
                
                public static let RESPONSE_BADGE_BAG_PRESSED = "CONTENT:BADGE_BAG:PRESSED"
                public static let RESPONSE_BADGE_GIVEN = "CONTENT:BADGE:GIVEN"
                public static let RESPONSE_BADGE_REMOVED = "CONTENT:BADGE:REMOVED"
                public static let RESPONSE_BADGES_PRESSED = "CONTENT:BADGES:PRESSED"
                public static let COMMENTS_ADD_PRESSED = "CONTENT:ADD_COMMENT:PRESSED"
                public static let CATALYST_FAVORITE_PRESSED = "CONTENT:CATALYST_FAVORITE:PRESSED"
                public static let CATALYST_UN_FAVORITE_PRESSED = "CONTENT:CATALYST_UN_FAVORITE:PRESSED"
                public static let COMMENTS_SHOW_PRESSED = "CONTENT:SHOW_COMMENTS:PRESSED"
                
                public static let CHALLENGE_EXPIRE_TIME_PRESSED = "CONTENT:CHALLENGE_EXPIRE_TIME:PRESSED"
                public static let CHALLENGE_RESPONSES_PRESSED = "CONTENT:CHALLENGE_RESPONSES:PRESSED"
                
                public static let CHALLENGE_TITLE_PRESSED = "CONTENT:CHALLENGE_TITLE:PRESSED"
                public static let VIEW_CHALLENGE_PRESSED = "CONTENT:VIEW_CHALLENGE:PRESSED"
                public static let CHALLENGE_HASHTAG_PRESSED = "CONTENT:HASHTAG:PRESSED"
                
                public static let SHARE_PRESSED = "CONTENT:SHARE:PRESSED"
                public static let SAVE_PRESSED = "CONTENT:SAVE:PRESSED"
                public static let MUTE_PRESSED = "CONTENT:MUTE:PRESSED"
                public static let UN_SAVE_PRESSED = "CONTENT:UN_SAVE:PRESSED"
                public static let OVERFLOW_PRESSED = "CONTENT:OVERFLOW:PRESSED"
                
                public static let SWIPED = "CONTENT:SWIPED"
        
            }
            
        }
        
        public struct Settings {
            
            public  struct Events {
                
                public static let SETTINGS_PROFILE_LOGOUT = "SETTINGS:LOGOUT:PRESSED"
                public static let SETTINGS_PROFILE_EDIT_COVER_PRESSED = "SETTINGS:PROFILE:EDIT_COVER:PRESSED"
                public static let SETTINGS_PROFILE_EMAIL_PRESSED = "SETTINGS:PROFILE:EMAIL:PRESSED"
                public static let SETTINGS_PROFILE_USERNAME_PRESSED = "SETTINGS:PROFILE:USERNAME:PRESSED"
                public static let SETTINGS_PROFILE_SAVE_PRESSED = "SETTINGS:PROFILE:SAVE:PRESSED"
                public static let SETTINGS_PROFILE_CANCEL_PRESSED = "SETTINGS:PROFILE:CANEL:PRESSED"
                public static let SETTINGS_PROFILE_DEACTIVATE_PRESSED = "SETTINGS:PROFILE:DEACTIVATE:PRESSED"
                public static let SETTINGS_PROFILE_DEACTIVATE_CONFIRMED = "SETTINGS:PROFILE:DEACTIVATE:CONFIRMED"
                public static let SETTINGS_COVER_SAVE_PRESSED = "SETTINGS:PROFILE:COVER:SAVE:PRESSED"
                public static let SETTINGS_COVER_CANCEL_PRESSED = "SETTINGS:PROFILE:COVER:CANCEL:PRESSED"
                public static let SETTINGS_PASSWORD_SAVE_PRESSED = "SETTINGS:PASSWORD_SAVE:PRESSED"
                public static let SETTINGS_PASSWORD_CANCEL_PRESSED = "SETTINGS:PASSWORD_CANCEL:PRESSED"
                public static let API_SAVE_PROFILE_FAIL = "SETTINGS:SAVE_PROFILE:FAIL"
                public static let API_UPLOAD_AVATAR_FAIL = "SETTINGS:UPLOAD_AVATAR:FAIL"
                
            }
            
            public  struct Screens {
                
                public static let SETTINGS = "SETTINGS"
                public static let SETTINGS_PROFILE = "SETTINGS:PROFILE"
                public static let SETTINGS_COVER_MAVERICK = "SETTINGS:PROFILE:COVER:MAVERICK"
                public static let SETTINGS_COVER_LIBRARY = "SETTINGS:PROFILE:COVER:LIBRARY"
                public static let SETTINGS_COVER_CAMERA = "SETTINGS:PROFILE:COVER:CAMERA"
                public static let SETTINGS_NOTIFICATIONS = "SETTINGS:NOTIFICATIONS"
                public static let SETTINGS_PASSWORD = "SETTINGS:PASSWORD"
                public static let CONTACT_US = "SETTINGS:CONTACT_US"
                
            }
      
        }
    
    }

}



