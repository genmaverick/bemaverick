//
//  DBManager.swift
//  BeMaverick
//
//  Created by Garrett Fritz on 2/8/18.
//  Copyright © 2018 BeMaverick. All rights reserved.
//

import Foundation

import RealmSwift
import Realm

class DBManager {
    
    var loggedInUserDataBase: Realm
    var loggedInUserId = "anon"
    private static var dbVersion = 112
    private var seenMystream = false
    private var seenChallenge = false
    private var seenFeatured = false
    static let sharedInstance = DBManager()
    var database: Realm
    
    /**
     Initialize the app wide DB for configuration type data
     */
    internal init() {
        
        var config = Realm.Configuration(
            // Set the new schema version. This must be greater than the previously used
            // version (if you've never set a schema version before, the version is 0).
            schemaVersion: UInt64(DBManager.dbVersion),
            
            // Set the block which will be called automatically when opening a Realm with
            // a schema version lower than the one set above
            migrationBlock: { migration, oldSchemaVersion in
                // We haven’t migrated anything yet, so oldSchemaVersion == 0
                if (oldSchemaVersion < 52) {
                    // Nothing to do!
                    // Realm will automatically detect new properties and removed properties
                    // And will update the schema on disk automatically
                    migration.deleteData(forType: MaverickMedia.className())
                    migration.deleteData(forType: Comment.className())
                    
                }
                
                if (oldSchemaVersion < 68) {
                    migration.deleteData(forType: Response.className())
                    migration.deleteData(forType: User.className())
                }
                if (oldSchemaVersion < 77) {
                    
                    
                }
                
                
        }
            
        )
        
        // Use the default directory, but replace the filename with the username
        config.fileURL = config.fileURL!.deletingLastPathComponent()
            .appendingPathComponent("base.realm")
        do {
            
            database =  try Realm(configuration: config)
            
        } catch {
            
            AnalyticsManager.logError(error : error.localizedDescription)
            log.verbose(error.localizedDescription)
            database = try! Realm()
            
        }
        
        config.fileURL = config.fileURL!.deletingLastPathComponent()
            .appendingPathComponent("anon.realm")
        
        do {
            
            loggedInUserDataBase = try Realm(configuration: config)
            
        } catch {
            
            AnalyticsManager.logError(error : error.localizedDescription)
            log.verbose(error.localizedDescription)
            loggedInUserDataBase = try! Realm()
            
        }
        
    }
    
    
    func shouldSeeTutorial(tutorialVersion : Constants.TutorialVersion) -> Bool {
        
        switch tutorialVersion {
        case .myFeed:
            if !getConfiguration().tutorial_seen_myfeed {
                
                attemptDBWrite {
                    
                    getConfiguration().tutorial_seen_myfeed = true
                    
                }
                
                return true
                
            }
            
            return false
            
        case .featured:
            if !getConfiguration().tutorial_seen_featured {
                
                attemptDBWrite {
                    
                    getConfiguration().tutorial_seen_featured = true
                    
                }
                
                return true
                
            }
            
            return false
            
        case .challenges:
            if !getConfiguration().tutorial_seen_challenges {
                
                attemptDBWrite {
                    
                    getConfiguration().tutorial_seen_challenges = true
                    
                }
                
                return true
                
            }
            
            return false
            
        case .textPost:
            //disable coach mark since it isn't new anymore
            return false
            if !getConfiguration().hasSeenTextPostCoachMark {
                
                attemptDBWrite {
                    
                    getConfiguration().hasSeenTextPostCoachMark = true
                    
                }
                
                return true
                
            }
            
            return false
            
        case .ugc_swipe:
            if getConfiguration().tutorial_seen_ugc_swipe < 3 {
                
                attemptDBWrite {
                    
                    getConfiguration().tutorial_seen_ugc_swipe += 1
                    
                }
                
                return true
                
            }
            
            return false
            
        default:
            break
        }
        
        
        return false
        
    }
    
    func logout() {
        
        attemptLoggedInDBWrite {
            
            let user = getUser(byId: loggedInUserId)
            let stream = getChallengeStream(byId: ConfigurableChallengeStream.MyRespondedChallengesStreamId)
            stream.lastAPIUpdate = -1
            stream.items.removeAll()
            user.myFeed?.feedLastUpdated = -1
            
        }
        
    }
    
    func isInvited(id : String, mode : Constants.ContactMode) -> Bool {
        
        switch mode {
        case .email:
            return getConfiguration().invitedEmails.contains(id)
        case .phone:
            return getConfiguration().invitedPhones.contains(id)
        case .facebook:
            return getConfiguration().invitedFacebookIds.contains(id)
        case .twitter:
            return true
        }
        
    }
    
    func setInvited(id : [String], mode : Constants.ContactMode,email : String? = nil) {
        
        try! database.write {
            
            switch mode {
            case .email:
                getConfiguration().invitedEmails.append(objectsIn: id)
            case .phone:
                getConfiguration().invitedPhones.append(objectsIn: id)
            case .facebook:
                getConfiguration().invitedFacebookIds.append(objectsIn: id)
            case .twitter:
                return 
                
            }
            
        }
        
    }
    
    /**
     This is the harder working of the two DB's linked to the logged in user, so if two users log in their data stays seperate but equal
     */
    func initializeLoggedInUserDB(_ userId: String) {
        
        var config = Realm.Configuration(
            // Set the new schema version. This must be greater than the previously used
            // version (if you've never set a schema version before, the version is 0).
            schemaVersion: UInt64(DBManager.dbVersion),
            
            // Set the block which will be called automatically when opening a Realm with
            // a schema version lower than the one set above
            migrationBlock: { migration, oldSchemaVersion in
                // We haven’t migrated anything yet, so oldSchemaVersion == 0
                if (oldSchemaVersion < 52) {
                    
                    migration.deleteData(forType: MaverickMedia.className())
                    migration.deleteData(forType: Comment.className())
                    
                }
                if (oldSchemaVersion < 68) {
                    migration.deleteData(forType: Response.className())
                    migration.deleteData(forType: User.className())
                }
                
        }
            
        )
        
        // Use the default directory, but replace the filename with the username
        config.fileURL = config.fileURL!.deletingLastPathComponent()
            .appendingPathComponent("anon.realm")
        do {
            
            loggedInUserDataBase =  try Realm(configuration: config)
            
        } catch {
            
            AnalyticsManager.logError(error : error.localizedDescription)
            log.verbose(error.localizedDescription)
            loggedInUserDataBase = try! Realm()
            
        }
        
    }
    
    func hasSeenSuggestedUpgrade( versionNumber : String) -> Bool {
        
        if getConfiguration().suggestedUpgradeVersionNumber != versionNumber  {
            try! database.write {
                
                getConfiguration().suggestedUpgradeVersionNumber = versionNumber
                
            }
            return false
        }
        
        
        return true
    }
    
    
    func attemptLoggedInDBWrite(completion : ()->Void){
        
        if loggedInUserDataBase.isInWriteTransaction {
            
            completion()
            
        } else {
            
            do {
                
                try loggedInUserDataBase.write {
                    
                    completion()
                    
                }
                
            } catch {
                print ("⛔️⛔️⛔️⛔️⛔️⛔️⛔️⛔️\n⛔️⛔️⛔️⛔️⛔️\n⛔️⛔️⛔️⛔️⛔️\nFAILED TO WRITE LOGGED IN DB\n⛔️⛔️⛔️⛔️⛔️⛔️\n⛔️⛔️⛔️⛔️⛔️⛔️\n⛔️⛔️⛔️⛔️⛔️")
                print("Error info: \(error)")
                print ("⛔️⛔️⛔️⛔️⛔️⛔️⛔️⛔️\n⛔️⛔️⛔️⛔️⛔️\n⛔️⛔️⛔️⛔️⛔️\nFAILED TO WRITE LOGGED IN DB\n⛔️⛔️⛔️⛔️⛔️⛔️\n⛔️⛔️⛔️⛔️⛔️⛔️\n⛔️⛔️⛔️⛔️⛔️")
            }
        }
        
    }
    
    
    func attemptDBWrite(completion : ()->Void){
        
        if database.isInWriteTransaction {
            
            completion()
            
        } else {
            
            do {
                
                try database.write {
                    
                    completion()
                    
                }
                
            } catch {
                
            }
        }
        
    }
    
    /**
     Save the API environment to the general realm
     */
    func setAPIEnvironment(_ env : Constants.APIEnvironmentType, customURL: String? = nil) {
        
        attemptLoggedInDBWrite {
            
            loggedInUserDataBase.deleteAll()
            
        }
        
        try! database.write {
            
            database.deleteAll()
            getConfiguration().apiEnvironment = env
            getConfiguration().apiCustomURL = customURL
            
        }
        
    }
    
    
    /**
     Shortcut function to get the app wide configuration file
     */
    func getConfiguration() -> MaverickConfiguration {
        
        var configuration = database.objects(MaverickConfiguration.self).first
        if configuration == nil {
            
            configuration = MaverickConfiguration()
            
            #if DEVELOPMENT
            configuration?.apiEnvironment = .development
            #else
            configuration?.apiEnvironment = .production
            #endif
            
            if database.isInWriteTransaction {
                
                database.add(configuration!, update: true)
                
            } else { try! database.write {
                
                database.add(configuration!, update: true)
                
                }
                
            }
            
        }
        
        if let salt = configuration?.getImageSalt() {
            
            MaverickMedia.salt = salt
            
        }
        
        return configuration!
        
    }
    
    /**
     Sets the app wide configuration file
     */
    func setMaverickBadges(sortOrder: [String], badges: [MBadge]) {
        
        attemptLoggedInDBWrite {
            
            for newBadge in badges {
                
                if let badge = loggedInUserDataBase.object(ofType: MBadge.self, forPrimaryKey: newBadge.badgeId) {
                    
                    badge.update(badge:newBadge)
                    
                } else {
                    
                    let badge = MBadge(badgeId: newBadge.badgeId)
                    badge.update(badge: newBadge)
                    loggedInUserDataBase.add(badge, update: true)
                    
                }
                
            }
            
        }
        
        attemptDBWrite {
            
            if sortOrder.count > 0 {
                
                getConfiguration().badgeOrder.removeAll()
                getConfiguration().badgeOrder.append(objectsIn: sortOrder)
                
            }
            
        }
        
    }
    
    
    /**
     Sets the app wide configuration file
     */
    func setUserChallengeThemes(sortOrder: [String]?, themes: [Theme]) {
        
        attemptLoggedInDBWrite {
            
            for newTheme in themes {
                
                if let theme = loggedInUserDataBase.object(ofType: Theme.self, forPrimaryKey: newTheme._id) {
                    
                    theme.update(newTheme)
                    
                } else {
                    
                    let theme = Theme(id: newTheme._id)
                    theme.update(newTheme)
                    loggedInUserDataBase.add(theme, update: true)
                    
                }
                
            }
            
        }
        
        attemptDBWrite {
            
            getConfiguration().ugcThemes.removeAll()
            
            if let sort = sortOrder, sort.count > 0 {
                
                getConfiguration().ugcThemes.append(objectsIn: sort)
                
            } else {
                
                for theme in themes {
                    
                    getConfiguration().ugcThemes.append(theme._id)
                    
                }
                
            }
            
        }
        
    }
    
    func getUserChallengeThemes() -> [Theme] {
        
        var themes : [Theme] = []
        for themeId in getConfiguration().ugcThemes {
            
            if let themeToAdd = loggedInUserDataBase.object(ofType: Theme.self, forPrimaryKey: themeId) {
                
                themes.append(themeToAdd)
                
            }
            
        }
        
        return themes
        
    }
    
    
    func getMaverickBadges() -> [MBadge] {
        
        var badges : [MBadge] = []
        for badgeId in getConfiguration().badgeOrder {
            
            if let badgeToAdd = loggedInUserDataBase.object(ofType: MBadge.self, forPrimaryKey: badgeId) {
                
                badges.append(badgeToAdd)
                
            }
            
        }
        
        return badges
        
    }
    
    /**
     Sets the app wide configuration file
     */
    func setConfiguration(profileCoverUrls: [String: [String:String]]) {
        
        attemptLoggedInDBWrite {
            
            for key in profileCoverUrls.keys {
                
                guard let urls = profileCoverUrls[key] else { continue }
                let media = getMaverickMedia(byId: key, type: .cover)
                media.update(urls: urls)
                
            }
            
        }
        
    }
    
    /**
     Function to see if logged in user has saved the given content or challenge
     */
    func isSaved(contentType: Constants.ContentType, withId id: String) -> Bool {
        
        if let me = getLoggedInUser() {
            
            switch contentType {
                
            case .challenge:
                
                return me.savedChallenges.contains(getChallenge(byId: id))
                
            case .response:
                
                return false
                
            }
            
        }
        return false
        
    }
    
    /**
     Toggles the state of whether or not the logged in user has saved the content or challenge
     */
    func toggleSaved(contentType: Constants.ContentType, withId id: String, shouldSave: Bool) {
        
        guard let me = getLoggedInUser() else { return }
        attemptLoggedInDBWrite {
            switch contentType {
                
            case .challenge:
                if shouldSave {
                    
                    
                    me.savedChallenges.insert( getChallenge(byId: id), at: 0)
                    
                } else {
                    
                    if let index = me.savedChallenges.index(of: getChallenge(byId: id)) {
                        
                        me.savedChallenges.remove(at: index)
                        
                    }
                    
                }
                
            case .response:
                return
                
            }
            
        }
        
    }
    
    /**
     Utility function to link the realm challenge and response objects
     */
    func linkResponsesToChallenges(challenges : List<Challenge>, responses : List<Response>) {
        
        var challengeDictionary : [String: Challenge] = [:]
        
        for challenge in challenges {
            
            challengeDictionary[challenge.challengeId] = challenge
            
        }
        
        for response in responses {
            
            if let challengeId = response.challengeId, let challengeOwner = challengeDictionary[challengeId] {
                
                if let index = challengeOwner.responses.index(of: response) {
                    
                    challengeOwner.responses[index] = response
                    
                } else {
                    
                    challengeOwner.responses.append(response)
                    
                }
            }
            
        }
    }
    
    /**
     Shortcut function to get the maverick/featured stream/feed
     */
    func getMaverickStream() -> MaverickFeed {
        
        if let feed = loggedInUserDataBase.object(ofType: MaverickFeed.self, forPrimaryKey: "FeaturedStream") {
            
            return feed
            
        } else {
            let feed = MaverickFeed()
            attemptLoggedInDBWrite {
                
                
                loggedInUserDataBase.add(feed, update: true)
                
                
            }
            return feed
        }
        
    }
    
    
    
    
    /**
     Utility function to break out video into a dictionary to make parsing a bit easier
     */
    func processVideos(videos: [Video]) -> [String : MaverickMedia] {
        
        var maverickMedia : [String:MaverickMedia] = [:]
        for video in videos {
            
            if let id = video.videoId {
                
                maverickMedia[id] = getMaverickMedia(byId: id, type: .video)
                maverickMedia[id]?.update(video: video)
                
            }
            
        }
        
        return maverickMedia
        
    }
    
    /**
     Utility function to break out image into a dictionary to make parsing a bit easier
     */
    func processImages(images: [Image]) -> [String : MaverickMedia] {
        
        var maverickMedia : [String:MaverickMedia] = [:]
        for image in images {
            
            
            maverickMedia[image.imageId] = getMaverickMedia(byId: image.imageId, type: .image)
            maverickMedia[image.imageId]?.update(image: image)
            
            
        }
        
        return maverickMedia
        
    }
    
    
    /**
     Fetches a MaverickMedia from the realm if it exists.
     If it doesn't, it will create a new object with the id and type and add it to the realm.
     All subsequent edits to the object must be made in a write transaction
     */
    func getMaverickMedia(byId mediaId: String, type: Constants.MediaType) -> MaverickMedia {
        
        if let media = loggedInUserDataBase.object(ofType: MaverickMedia.self, forPrimaryKey: MaverickMedia.getMaverickMediaId(id: mediaId, type: type)) {
            
            return media
            
        } else {
            
            let media = MaverickMedia(id: mediaId, type: type)
            if loggedInUserDataBase.isInWriteTransaction {
                
                loggedInUserDataBase.add(media, update: true)
                
            } else {
                
                attemptLoggedInDBWrite {
                    
                    loggedInUserDataBase.add(media, update: true)
                    
                }
            }
            return media
        }
    }
    
    func getWeightedUserSearch(byQuery query : String, contentType : Constants.ContentType?, contentId : String?, apiUsers : [SearchUser]) -> List<User> {
        
        let finalList = List<User>()
        let originalUsers = updateUsers(withUsers: apiUsers)
        let commentors = List<User>()
        if let contentType = contentType, let contentId = contentId {
            
            if contentType == .challenge {
                let challenge = getChallenge(byId: contentId)
                let array = Array(challenge.comments)
                
                var allCommentors =  Array(Set( array.compactMap { $0.creator.first } ))
                if let creator = challenge.getCreator() {
                    
                    allCommentors.insert(creator, at: 0)
                    
                }
                for preferredUser in allCommentors {
                    
                    if preferredUser.username?.contains(query) ?? false || preferredUser.firstName?.contains(query) ?? false || preferredUser.lastName?.contains(query) ?? false {
                        
                        commentors.append(preferredUser)
                        
                    }
                    
                }
                
            }
            
            if contentType == .response {
                let response = getResponse(byId: contentId)
                let array = Array(response.comments)
                
                var allCommentors =  Array(Set( array.compactMap { $0.creator.first } ))
                
                if let creator = response.getCreator() {
                    
                    allCommentors.insert(creator, at: 0)
                    
                }
                
                for preferredUser in allCommentors {
                    
                    if preferredUser.username?.contains(query) ?? false || preferredUser.firstName?.contains(query) ?? false || preferredUser.lastName?.contains(query) ?? false {
                        
                        commentors.append(preferredUser)
                        
                    }
                    
                }
                
            }
            
        }
        
        if let filteredFollowing = getLoggedInUser()?.loggedInUserFollowing.filter("username CONTAINS[cd] %@ OR firstName BEGINSWITH[cd] %@ OR lastName BEGINSWITH[cd] %@", query, query, query) {
            
            for prefferedUser in filteredFollowing {
                
                finalList.append(prefferedUser)
                
            }
            
        }
        
        for prefferedUser in commentors {
            
            if !finalList.contains(prefferedUser) {
                
                finalList.append(prefferedUser)
                
            }
            
        }
        
        for prefferedUser in originalUsers {
            
            if !finalList.contains(prefferedUser) {
                
                finalList.append(prefferedUser)
                
            }
            
        }
        
        return finalList
        
    }
    
}
