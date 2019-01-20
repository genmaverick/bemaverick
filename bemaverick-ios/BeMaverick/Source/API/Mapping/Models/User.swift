//
//  User.swift
//  BeMaverick
//
//  Created by David McGraw on 9/18/17.
//  Copyright © 2017 BeMaverick. All rights reserved.
//

import Foundation
import ObjectMapper
import RealmSwift

@objcMembers
class User: Object, Mappable, ShareableType  {
    
    dynamic var userId:                     String = ""
    dynamic var userUUID:                   String?
    dynamic var username:                   String?
    dynamic var firstName:                  String?
    dynamic var lastName:               	String?
    
    dynamic var bio:                        String?
    dynamic var progression :               Progression?
    dynamic var emailAddress:               String?
    dynamic var phoneNumber:                String?
    dynamic var parentEmailAddress:         String?
    dynamic var profileCoverTint:           String?
    dynamic var status:                     String?
    dynamic var isBlocked:                  Bool = false
    dynamic var stats:                      Stat?
    dynamic var vpcStatus:                  Bool = false
    dynamic var isVerified:                 Bool = false
    dynamic var isAccountRevoked:           Bool = false
    dynamic var isEmailVerified:            Bool = false
    dynamic var overThirteen:               Bool?
    dynamic var currentLevelNumber:         Int = -1
    dynamic var profileCoverImageId:        String?
    dynamic var profileImage:               MaverickMedia?
    dynamic var profileCover:               MaverickMedia?
    dynamic var badgeStats =                List<BadgeStats>()
    dynamic var createdResponses =          List<Response>()
    dynamic var createdComments =           List<Comment>()
    dynamic var myFeed :                    MultiContentFeed?
    //this is the sorted list of challenges created by user
    dynamic var createdChallenges =         List<Challenge>()
    // this is the source linking challegnes to their creator no matter how we stumble across them
    dynamic var ownedChallenges =         List<Challenge>()
    dynamic var availableChallenges =       List<Challenge>()
    dynamic var availableChallengesLastUpdate : Int = -1
    dynamic var featuredChallenges =        List<Challenge>()
    
    dynamic var badgedResponses =           List<Response>()
    dynamic var suggestedUsers =            List<User>()
    
    dynamic var loggedInUserFollowing =            List<User>()
    
    dynamic var profileCoverPresetImageId:  String?
    dynamic var savedChallenges =           List<Challenge>()
    
    
    dynamic var followingUserIds =          List<String>()
    dynamic var followerUserIds =           List<String>()
    var API_followingUserIds :          [String]?
    var API_followerUserIds :           [String]?
    dynamic var uploadingSessionIds =       List<String>()
    dynamic var profileImageId:             String?
    
    dynamic var features : Features? = Features()
    dynamic var pushEnabled:                  Bool = true
    dynamic var pushGeneralEnabled:           Bool = true
    dynamic var pushPostsEnabled:             Bool = true
    dynamic var pushFollowerEnabled:          Bool = true
        dynamic var isRevoked = false
    
    func myShareableType() -> SocialShareType {
        return SocialShareType.user
    }
    
    
    @objc dynamic private var profileCoverImageTypeRawValue = Constants.ProfileCoverType.custom.rawValue
    var profileCoverImageType: Constants.ProfileCoverType {
        get {
            return Constants.ProfileCoverType(rawValue: profileCoverImageTypeRawValue)!
        }
        set {
            profileCoverImageTypeRawValue = newValue.rawValue
        }
    }
    
    @objc dynamic private var userTypeRawValue = Constants.AccountType.maverick.rawValue
    dynamic var userType: Constants.AccountType {
        get {
            return Constants.AccountType(rawValue: userTypeRawValue)!
        }
        set {
            userTypeRawValue = newValue.rawValue
        }
    }
    
   
    func getCreatedChallenges() -> Results<Challenge> {
        
        return createdChallenges.filter("status != %@", "deleted")
        
    }
    
    func hasBadgedResponses() -> Bool {
        
        var count = 0
        for stat in badgeStats {
            count += stat.numReceived
        }
        return count > 0
        
    }
    override static func ignoredProperties() -> [String] {
        return [
            "profileImageUrls",
            "apiImageObject",
            "profileCoverImageUrls",
            "badges",
            "responses",
            "responseIds",
            "challengeIds",
            "savedChallengeIds",
            "savedContentIds",
            "kid",
            "searchResults",
            "API_followingUserIds",
            "API_followerUserIds",
        ]
    }
    
    var profileImageUrls:           [String: String]?
    var profileCoverImageUrls:      [String: String]?
    var badges:                     [String: BadgeStats]?
    var responses:                  [String: Response]?
    var responseIds:                [String]?
    var challengeIds:               [String]?
   
    var savedChallengeIds:       [String]?
    var savedContentIds:            [String]?
    var apiImageObject: Image?
    
    var searchResults:              SearchResults?

    
    override static func primaryKey() -> String? {
        return "userId"
    }
    
    required convenience init?(map: Map) {
        
        self.init()
        
    }
    
    convenience init(userId: String) {
        
        self.init()
        self.userId = userId
        
    }
    
    func getUnownedBadgedResponses() -> Results<Response> {
        
        return badgedResponses.filter("userId != %@", userId )
        
    }
    
   
    
    func updateLoggedInUserData(_ user : User) {
        
        isAccountRevoked = user.isAccountRevoked
        isEmailVerified = user.isEmailVerified
        vpcStatus = user.vpcStatus
        emailAddress = user.emailAddress
        phoneNumber = user.phoneNumber
        parentEmailAddress = user.parentEmailAddress
     
    }
    
    func updateBasicUserData(_ user : SearchUser) {
    
        self.username = user.username
        self.lastName = user.last_name
        self.firstName = user.first_name
        self.emailAddress = user.email_address
        self.phoneNumber = user.phone_number
        self.isVerified = user.isVerified ?? false
        if let type = user.user_type {
            
            self.userTypeRawValue = type
        
        } 
    
    }
    
    func getRespondedChallenges() -> List<Challenge> {
    
        let challenges = List<Challenge>()
        for response in createdResponses {
            
            guard let challenge = response.challengeOwner.first, !challenges.contains(challenge) else { continue }
           
            challenges.append(challenge)
            
        }
        
        return challenges
        
    }
    
    
    func updateBasicUserData(_ user : User, includeStats: Bool = false) {
        
        guard user.userId != "" else {
            user.username = username
            return
            
        }
        
        isRevoked = false
        userUUID = user.userUUID
        if user.currentLevelNumber > 0 {
        
            currentLevelNumber = user.currentLevelNumber
        
        }
        username = user.username
        userType = user.userType
        firstName = user.firstName
        lastName = user.lastName
        
        if user.bio != nil {
            bio = user.bio
        }
      
        if let email = user.emailAddress {
            emailAddress = email
        }
        if let phone = user.phoneNumber {
            phoneNumber = phone
        }
        
        isVerified = user.isVerified
        status = user.status
        profileCoverTint = user.profileCoverTint
        profileCoverPresetImageId = user.profileCoverPresetImageId
        profileImageId = user.profileImageId
        profileCoverImageId = user.profileCoverImageId
        overThirteen = user.overThirteen
        profileImageUrls = user.profileImageUrls
        profileCoverImageUrls = user.profileCoverImageUrls
        badges = user.badges
        responses = user.responses
        responseIds = user.responseIds
        challengeIds = user.challengeIds
        
        if includeStats {
            
            stats = user.stats
            
        }
        
        savedContentIds = user.savedContentIds
      savedChallengeIds = user.savedChallengeIds
        searchResults = user.searchResults
        features = user.features
        
        profileCoverImageType = user.profileCoverImageTypeRawValue == "preset" ? .preset : .custom
        
    }
    
    func mapping(map: Map) {
        
        status                  <- map["status"]
        userId                  <- map["userId"]
        username                <- map["username"]
        userType                <- map["userType"]
        firstName               <- map["firstName"]
        lastName                <- map["lastName"]
        bio                     <- map["bio"]
        emailAddress            <- map["emailAddress"]
        phoneNumber             <- map["phoneNumber"]
        parentEmailAddress      <- map["parentEmailAddress"]
        profileCoverTint        <- map["profileCoverTint"]
        currentLevelNumber      <- map["currentLevelNumber"]
        overThirteen            <- map["overThirteen"]
        profileImageUrls        <- map["profileImageUrls"]
        profileCoverImageUrls   <- map["profileCoverImageUrls"]
        profileImageId          <- map["profileImageId"]
        profileCoverImageId     <- map["profileCoverImageId"]
        badges                  <- map["badges"]
        isVerified              <- map["isVerified"]
        responses               <- map["responses"]
        responseIds             <- map["responseIds"]
        challengeIds            <- map["challengeIds"]
        stats                   <- map["stats"]
        userUUID                <- map["userUUID"]
        vpcStatus               <- map["vpcStatus"]
        savedContentIds         <- map["savedContentIds"]
        followingUserIds        <- map["followingUserIds"]
        followerUserIds         <- map["followerUserIds"]
        API_followingUserIds        <- map["followingUserIds"]
        API_followerUserIds         <- map["followerUserIds"]
        savedChallengeIds       <- map["savedChallengeIds"]
        searchResults           <- map["searchResults"]
        isAccountRevoked        <- map["isAccountRevoked"]
        isEmailVerified         <- map["isEmailVerified"]
        profileCoverImageTypeRawValue   <- map["profileCoverImageType"]
        profileCoverPresetImageId       <- map["profileCoverPresetImageId"]
        profileCoverImageType           <- map["profileCoverImageType"]
        
        pushEnabled             <- map["preferences.notifications_global"]
        pushGeneralEnabled      <- map["preferences.notifications_general"]
        pushPostsEnabled        <- map["preferences.notifications_post"]
        pushFollowerEnabled     <- map["preferences.notifications_follow"]
        
        apiImageObject          <- map["profileImage"]
        
    }
    
    override var hashValue: Int {
        return "\(userId) \(username ?? "NONE")".hashValue
    }
    
    static func ==(lhs: User, rhs: User) -> Bool {
        return lhs.userId == rhs.userId
    }
    
    
    func shouldShowVPC() -> Bool {
        
        return !vpcStatus && userType == .maverick
        
    }
    
    func getFullName() -> String {
        
        if let firstName = firstName {
            
            if let lastName = lastName {
                
                return "\(firstName) \(lastName)"
                
            }
            
            return firstName
            
        }
        
        return lastName ?? ""
        
    }
    
    func isActive() -> Bool {
        
        if let status = status, status != "active" {
            
            return false
        
        }
        
        return true
        
    }

}


@objcMembers
class BadgedResponse: Object {
    
    dynamic var ID = ""
    dynamic var badgeTypeIds = List<String>()
    dynamic var responseId = ""
    override static func primaryKey() -> String? {
        
        return "ID"
        
    }
    
    convenience init(userId : String, responseId: String, badgeTypeIds: List<String>) {
        
        self.init()
        self.ID = BadgedResponse.getBadgedResponseId(userId: userId, responseId: responseId)
        self.responseId = responseId
        self.badgeTypeIds = badgeTypeIds
        
    }
    
    static func getBadgedResponseId( userId: String, responseId: String) -> String {
        
        return "user_\(userId)_response_\(responseId)"
        
    }
    
}

