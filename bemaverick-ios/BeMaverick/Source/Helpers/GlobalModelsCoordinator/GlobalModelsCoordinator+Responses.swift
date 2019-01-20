//
//  GlobalModelsCoordinator+Responses.swift
//  BeMaverick
//
//  Created by David McGraw on 9/14/17.
//  Copyright © 2017 BeMaverick. All rights reserved.
//

import Foundation
import RealmSwift
import Photos

/**
 Methods responsible for uploading content via the `APIService` instance
 */
extension GlobalModelsCoordinator {
    
    // MARK: - Public Methods
    
    /**
     Look for an existing response with the provided response id
     */
    open func response(forResponseId id: String, fetchDetails : Bool = false) -> Response {
        
        if fetchDetails {
            
            apiService.getResponseDetails(id: id) { response in
                
                let videos = response?.videos?.map { $0.value } ?? []
                let images = response?.images?.map { $0.value } ?? []
               
                let responses = response?.responses?.map { $0.value } ?? []
                let challenges = response?.challenges?.map { $0.value } ?? []
                let owners = response?.users ?? [:]
                
                DBManager.sharedInstance.attemptLoggedInDBWrite {
                    
                    if let responseChallengeId = response?.responses?[id]?.challengeId {
                        
                        DBManager.sharedInstance.addChallenges(owners: owners, videos: videos, images: images, challenges: challenges)
                        DBManager.sharedInstance.addResponsesToChallenge(withId: responseChallengeId, owners: owners, challenges: challenges, responses: responses, videos: videos, images: images)
                        
                    } else {
                        
                        _ = DBManager.sharedInstance.addResponsesToUsers(owners: owners, responses: responses, videos: videos, images: images)
                    }
                }
                
            }
            
        }
        
        return DBManager.sharedInstance.getResponse(byId: id)
        
    }
    
    
    
    
    /**
     Retrieve the responses for a provided challenge
     */
    open func getResponses(forChallengeId id: String,
                           count: Int = 25,
                           offset: Int = 0,
                           completionHandler: ((_ responseIds: [String]) -> Void)? = nil) {
        
        apiService.getResponses(forChallengeId: id, count: count, offset: offset) { response in
            
            var responses : [Response] = []
            let responseIds = response?.challenges?[id]?.searchResults?.responses?.responseIds  ?? []
            
            for responseId in  responseIds {
                
                if let response =  response?.responses?[responseId] {
                    
                    responses.append(response)
                    
                }
                
            }
            
            let challenges = response?.challenges?.map { $0.value } ?? []
            
            let videos = response?.videos?.map { $0.value } ?? []
            let images = response?.images?.map { $0.value } ?? []
          
            let owners = response?.users ?? [:]
            
            DBManager.sharedInstance.addResponsesToChallenge(withId: id,owners : owners, challenges: challenges, responses: responses, videos: videos, images: images, clearPreviousResults: offset == 0 )
            
            completionHandler?(responseIds)
            
        }
        
    }
    
    

    /**
     Retrieve the responses for a provided userID
     */
    open func getUserCreatedResponses(forUserID id: String,
                                      count: Int = 25,
                                      offset: Int = 0,
                                      completionHandler: (() -> Void)? = nil) {
        
        apiService.getUserCreatedResponses(forUserId: id, badgeId: nil, count: count, offset: offset) { response in
            
            guard let creator = response?.users?[id] else {
                
                completionHandler?()
                return
                
            }
            var responses : [Response] = []
            let responseIds = response?.users?[id]?.searchResults?.responses?.responseIds  ?? []
            
            for responseId in  responseIds {
                
                if let response =  response?.responses?[responseId] {
                    
                    responses.append(response)
                    
                }
                
            }
            
            let challenges = response?.challenges?.map { $0.value } ?? []
            let videos = response?.videos?.map { $0.value } ?? []
            let images = response?.images?.map { $0.value } ?? []
            let owners = response?.users ?? [:]
            
            DBManager.sharedInstance.attemptLoggedInDBWrite {
                
                
                let _ = DBManager.sharedInstance.addUser(userObject: creator, images: images)
                if let Mavechallenges = DBManager.sharedInstance.addChallenges(owners: owners, videos: videos, images: images,  challenges: challenges) {
                  
                    let Maveresponses = DBManager.sharedInstance.addResponsesToUser(withId: id, responses: responses, videos: videos, images: images,  clearPreviousResults: offset == 0)
                    
                    DBManager.sharedInstance.linkResponsesToChallenges(challenges: Mavechallenges, responses: Maveresponses)
                
                }
            
            }
            completionHandler?()
            
        }
        
    }
    
    /**
     Deletes a response and refreshes the user data
     */
    open func deleteResponse(forResponse response: Response) {
        
        guard let intId = Int(response.responseId) else { return }
        
        apiService.deleteResponse(forResponseId: intId) { _, _ in
            
        }
        
        DBManager.sharedInstance.deleteResponse(response: response)
        
    }
    
    /**
     Marks a user owned response as publicly available
     */
    open func shareResponse(forResponseId id: String) {
        
        apiService.shareResponse(forResponseId: id) { _, _ in
            
        }
        
    }
    
    /**
     Marks a piece of content as flagged
     */
    open func reportContent(type: Constants.ContentType, id: String, reason : String) {
        
        apiService.reportContent(type: type, id: id, reason: reason) { _, _ in
            
        }
        
    }
    
    
    
    /**
     Applies a badge to the provided response
     
     - parameter id:        The response id to apply the badge to
     - parameter badge:     The badge to apply
     */
    open func addBadgeToResponse(withResponseId id: String,
                                 badgeId: String, realmNotificationToken : [NotificationToken]? = nil,
                                 completionHandler: @escaping (_ success: Bool) -> Void)
    {
        
        removeNonSelectedBadges(withResponseId: id, badgeId: badgeId)
        guard let intIndex = Int(id) else { return }
        apiService.addBadge(toResponseId: intIndex, withBadgeId: badgeId) { (response, error) in
            
            
            if error == nil {
                
                self.getProgression()
                
            }
            completionHandler((error == nil))
            
        }
        
        DBManager.sharedInstance.addBadgeToResponse(responseId: id, badgeId: badgeId, realmNotificationToken : realmNotificationToken)
        
    }
    
    private func removeNonSelectedBadges(withResponseId id: String,
                                         badgeId: String) {
        var availableBadges = ["1",
                               "2",
                               "3",
                               "4",
                               "5"]
        
        if let index = availableBadges.index(of: badgeId) {
            availableBadges.remove(at: index)
        }
        
        for badgeToRemove in availableBadges {
            deleteBadgeFromResponse(withResponseId: id, badgeId: badgeToRemove) { success in }
        }
    }
    /**
     Removes a badge from the provided response
     
     - parameter id:        The response id to apply the badge to
     - parameter badge:     The badge to apply
     */
    open func deleteBadgeFromResponse(withResponseId id: String,
                                      badgeId: String, realmNotificationToken : [NotificationToken]? = nil,
                                      completionHandler: @escaping (_ success: Bool) -> Void)
    {
        
        guard let intId = Int(id) else { return }
        apiService.deleteBadge(toResponseId: intId, withBadgeId: badgeId) { (response, error) in
            
            
            completionHandler((error == nil))
            
        }
        
        
        if realmNotificationToken != nil {
            
            DBManager.sharedInstance.deleteBadgeFromResponse(responseId: id, badgeId: badgeId, realmNotificationToken : realmNotificationToken)
            
        }
        
    }
    
    /**
     Retrieves a list of users who badged a response, providing the badges they gave
     
     - parameter id:                The response to delete
     - parameter badgeId:           The badge id to fetch specifically (if any)
     - parameter count:             The amount of challenges to fetch
     - parameter offset:            The offset to the fetched amount
     
     - parameter completionHandler: Returns a list of users that have badged the response
     */
    open func getResponseBadgeUsers(forResponseId id: String,
                                    badgeId: String? = nil,
                                    count: Int = 25,
                                    offset: Int = 0,
                                    completionHandler: @escaping (_ users: [User]) -> Void) {
        
        guard let intId = Int(id) else { return }
        apiService.getResponseBadgeUsers(forResponseId: intId, badgeId: badgeId, count: count, offset: offset) { responses in
            
            guard let response = responses?.responses?[id], let userDictionary = responses?.users else { return }
            
            // Parse results
            var users: [User] = []
            let imageArray = responses?.images?.map { $0.value } ?? []
            let videoArray = responses?.videos?.map { $0.value } ?? []
        
            if let userIds = response.searchResults?.badgeUsers?.userIds {
                
                for i in 0 ..< userIds.count {
                    
                    if let user = userDictionary[userIds[i]] {
                        
                        users.append(user)
                        
                    }
                    
                }
                
            }
            
            completionHandler( DBManager.sharedInstance.addUsersWhoBadgedResponse(response: response, users: users, images: imageArray, videos: videoArray, clearPreviousResults: offset == 0))
            
            
        }
        
    }
    
    /**
     Save the provided file URL to the user's photo library and provide the path
     to the newly created asset via the `completionHandler`
     
     Requires photo library authorization.
     */
    open func saveFileToAssetLibrary(withFileURL url: URL,
                                     responseType: Constants.UploadResponseType,
                                     completionHandler: @escaping (_ localIdentifier: String?, _ err: String?) -> Void)
    {
        
        /// The user could be sharing before entering the post flow
        PHPhotoLibrary.requestAuthorization({ (authorizationStatus: PHAuthorizationStatus) -> Void in
            
            if authorizationStatus == .authorized {
                
                PHPhotoLibrary.shared().performChanges({
                    
                    if responseType == .video {
                        PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: url)
                    } else {
                        PHAssetChangeRequest.creationRequestForAssetFromImage(atFileURL: url)
                    }
                    
                }) { saved, error in
                    
                    DispatchQueue.main.async {
                        
                        if !saved {
                            completionHandler(nil, "Failed to save. \(error?.localizedDescription ?? "")")
                            return
                        }
                        
                        // Fetch the created asset
                        let options = PHFetchOptions()
                        options.sortDescriptors = [ NSSortDescriptor(key: "creationDate", ascending: true) ]
                        
                        let type: PHAssetMediaType = responseType == .video ? .video : .image
                        if let result = PHAsset.fetchAssets(with: type, options: options).lastObject {
                            completionHandler(result.localIdentifier, nil)
                        } else {
                            completionHandler(nil, "Couldn't locate saved file.")
                        }
                        
                    }
                    
                }
                
            } else {
                DispatchQueue.main.async {
                    completionHandler(nil, "Enable photo library permission.")
                }
            }
            
        })
        
    }
    
    
    /**
     Uploads a file to S3 and notifies the platform
     
     - parameter url:   The local file path to upload
     - parameter id:    The identifier of the challenge to link the upload with
     
     */
    open func uploadContentResponse(withFileURL url: URL,
                                    forChallengeId id: String?,
                                    description: String,
                                    coverImage: URL?,
                                    responseType: Constants.UploadResponseType,
                                    sessionId: String,
                                    shareChannels: [SocialShareChannels] = [])
    {
        
        
        DBManager.sharedInstance.setUploadingSession(sessionId: sessionId)
        
        let env = self.authorizationManager.environment
        
        DispatchQueue.global(qos: .background).async {
            
            var filename    = ""
            var contentType = ""
            var bucket      = ""
            
            if responseType == .video {
                
                filename = "iOS_video_" + UUID().uuidString + "_" + String(Int(Date().timeIntervalSince1970)) + ".mp4"
                contentType = "video/mp4"
                if env == .production {
                    bucket = "bemaverick-input-videos"
                } else if env == .staging {
                    bucket = "stage-bemaverick-input-videos"
                } else {
                    bucket = "dev-bemaverick-input-videos"
                }
                
            } else {
                
                filename = "iOS_image_" + UUID().uuidString + "_" + String(Int(Date().timeIntervalSince1970)) + ".jpg"
                contentType = "image/jpeg"
                if env == .production {
                    bucket = "bemaverick-images"
                } else if env == .staging {
                    bucket = "stage-bemaverick-images"
                } else {
                    bucket = "dev-bemaverick-images"
                }
                
            }
            
            /// Upload Video
            
            self.apiService.performUpload(withFileURL: url,
                                          fileName: filename,
                                          bucket: bucket,
                                          contentType: contentType)
            { errorDescription in
                
                
                if let err = errorDescription {
                    
                    AnalyticsManager.Post.trackPostFail(responseType: responseType,
                                                        challengeId: id,
                                                        postFailureError: .serverUploadFailure,
                                                        errorMesssage: err.localizedDescription)
                    
                    DispatchQueue.main.async {
                        
                        DBManager.sharedInstance.removeUploadingSession(sessionId: sessionId)
                        self.onResponsesUploadCompletedSignal.fire((err.localizedDescription, nil, nil, []))
                        
                    }
                    return
                }
                
                
                var image: UIImage? = nil
                
                
                if coverImage != nil {
                    image = UIImage(contentsOfFile: coverImage!.path)
                } else {
                    image = UIImage(contentsOfFile: url.path)
                }
                
                // Must bounce back to perform this op due to the realm setup
                // (TODO: Can't share realm instances across threads...)
                DispatchQueue.main.async {
                    
                    self.onResponsesUploadProgressSignal.fire(60)
                    
                    self.saveFileToAssetLibrary(withFileURL: url, responseType: responseType) { localIdentifier, err in
                        
                        self.onResponsesUploadProgressSignal.fire(75)
                        
                        /// Inform the platform that a file was added to the challenge
                        self.apiService.addResponse(withChallengeId: id,
                                                    filename: filename,
                                                    description: description,
                                                    coverImage: responseType == .video ? image : nil,
                                                    responseType: responseType)
                        { response, error in
                            
                            self.onResponsesUploadProgressSignal.fire(95)
                            
                            guard response != nil else {
                                
                                DispatchQueue.main.async {
                                
                                    
                                    DBManager.sharedInstance.removeUploadingSession(sessionId: sessionId)
                                
                                }
                                self.onResponsesUploadCompletedSignal.fire(("Upload issue! \(error?.localizedDescription ?? "")", nil, nil, []))
                                return
                            }
                            /// Save content to the user's library for sharing
                            
                            // Good to clear saved content
                            CameraManager.removeSavedData(forSessionId: sessionId)
                            
                            if responseType == .image {
                                
                                do {
                                    
                                    try FileManager.default.removeItem(at: url)
                                
                                } catch { }
                                
                            }
                            
                            DispatchQueue.main.async {
                                
                                let responseArray = response?.responses?.map { $0.value } ?? []
                                let videoArray = response?.videos?.map { $0.value } ?? []
                                let imageArray = response?.images?.map { $0.value } ?? []
                             
                                
                                if responseArray[safe : 0] != nil {
                                    
                                    /// this is temporary until api stops returning int for id (tomorrowish)
                                    if let firstId = response?.responses?.keys.first {
                                        
                                        responseArray[0].responseId = firstId
                                        AnalyticsManager.Post.trackPostSuccess(responseId: firstId,
                                                                               responseType: responseType,
                                                                               challengeId: responseArray[safe: 0]?.challengeId ?? "")
                                        
                                    }
                                    
                                    DBManager.sharedInstance.addNewCreatedResponse(response: responseArray, video: videoArray, image: imageArray)
                                    
                                    
                                }
                                
                                let responseId = responseArray[0].responseId
                                let response = self.response(forResponseId: responseId)
                                DBManager.sharedInstance.removeUploadingSession(sessionId: sessionId)
                                self.saveLocalIdentifier(forResponseId: responseId, identifier: localIdentifier)
                                
                                self.onResponsesUploadProgressSignal.fire(100)
                                self.onResponsesUploadCompletedSignal.fire((nil, response, localIdentifier, shareChannels))
                                
                                
                              
                                    
                                    self.getProgression()
                                    
                              
                            }
                            
                        }
                        
                    }
                    
                }
                
            }
            
        }
        
    }
    
    /**
     Uploads a file to S3 and notifies the platform
     
     - parameter url:   The local file path to upload
     - parameter id:    The identifier of the challenge to link the upload with
     
     */
    open func uploadChallenge(withFileURL url: URL,
                              title: String?,
                              description: String?,
                              mentions: [String]?,
                              coverImage: URL?,
                              imageText : String?,
                              linkUrl: String?,
                              type: Constants.UploadResponseType,
                              sessionId: String,
                              shareChannels: [SocialShareChannels] = []){
        
        DBManager.sharedInstance.setUploadingSession(sessionId: sessionId)
        
        let env = self.authorizationManager.environment
        
        DispatchQueue.global(qos: .background).async {
            
            var filename    = ""
            var contentType = ""
            var bucket      = ""
            
            if type == .video {
                
                filename = "iOS_video_" + UUID().uuidString + "_" + String(Int(Date().timeIntervalSince1970)) + ".mp4"
                contentType = "video/mp4"
                if env == .production {
                    bucket = "bemaverick-input-videos"
                } else if env == .staging {
                    bucket = "stage-bemaverick-input-videos"
                } else {
                    bucket = "dev-bemaverick-input-videos"
                }
                
            } else {
                
                filename = "iOS_image_" + UUID().uuidString + "_" + String(Int(Date().timeIntervalSince1970)) + ".jpg"
                contentType = "image/jpeg"
                if env == .production {
                    bucket = "bemaverick-images"
                } else if env == .staging {
                    bucket = "stage-bemaverick-images"
                } else {
                    bucket = "dev-bemaverick-images"
                }
                
            }
            self.onChallengeUploadProgressSignal.fire(5)
            /// Upload Video
            
            self.apiService.performUpload(withFileURL: url,
                                          fileName: filename,
                                          bucket: bucket,
                                          contentType: contentType,
                                          isChallengeUpload: true
                )
            { errorDescription in
                
                
                if let err = errorDescription {
                    
                    AnalyticsManager.Post.trackPostFail(responseType: type,
                                                        challengeId: nil,
                                                        postFailureError: .serverUploadFailure,
                                                        errorMesssage: err.localizedDescription)
                    
                    DispatchQueue.main.async {
                        
                        DBManager.sharedInstance.removeUploadingSession(sessionId: sessionId)
                        self.onChallengeUploadCompletedSignal.fire((err.localizedDescription, nil, nil, []))
                        
                    }
                    return
                }
                
                
                // Must bounce back to perform this op due to the realm setup
                // (TODO: Can't share realm instances across threads...)
                DispatchQueue.main.async {
                    
                    self.onChallengeUploadProgressSignal.fire(75)
                    var mentionsASV : String? = nil
                    if let mentions = mentions {
                    
                        mentionsASV = "@\(mentions.joined(separator: "@"))"
                    
                    }
                    /// Inform the platform that a file was added to the challenge
                    self.apiService.addChallenge(filename: filename,
                                                 title : title,
                                                 description: description,
                                                 mentions: mentionsASV,
                                                 coverImage: nil, imageText: imageText,
                                                 linkUrl: linkUrl,
                                                 responseType: type)
                    { response, error in
                        
                        self.onChallengeUploadProgressSignal.fire(95)
                        
                        guard response != nil else {
                            
                            DispatchQueue.main.async {
                                DBManager.sharedInstance.removeUploadingSession(sessionId: sessionId)
                                
                            }
                            self.onChallengeUploadCompletedSignal.fire(("Upload issue! \(error?.localizedDescription ?? "")", nil, nil, []))
                            return
                        }
                        /// Save content to the user's library for sharing
                        
                        // Good to clear saved content
                        CameraManager.removeSavedData(forSessionId: sessionId)
                        
                        if type == .image {
                            
                            do {
                                
                                try FileManager.default.removeItem(at: url)
                                
                            } catch { }
                            
                        }
                        
                        DispatchQueue.main.async {
                            
                            let challengeArray = response?.challenges?.map { $0.value } ?? []
                            let videoArray = response?.videos?.map { $0.value } ?? []
                            let imageArray = response?.images?.map { $0.value } ?? []
                           
                            
                            if let newChallenge = challengeArray[safe : 0] {
                                
                                newChallenge.linkURL = linkUrl
                                DBManager.sharedInstance.addNewCreatedChallenge(challenge: challengeArray, video: videoArray, image: imageArray)
                                
                                
                            }
                            
                            
                            
                            if let challengeId = challengeArray.first?.challengeId {
                                
                                let challenge = self.challenge(forChallengeId: challengeId)
                                DBManager.sharedInstance.removeUploadingSession(sessionId: sessionId)
                                //                                    self.saveLocalIdentifier(forResponseId: responseId, identifier: localIdentifier)
                                
                                self.onChallengeUploadProgressSignal.fire(100)
                                self.onChallengeUploadCompletedSignal.fire((nil, challenge, "localIdentifier", shareChannels))
                                
                                
                                
                                    
                                    self.getProgression()
                                    
                                
                                
                            }
                            
                        }
                        
                        
                        
                    }
                    
                }
                
            }
            
        }
        
    }
    
    
    
    /**
     Retrieve an asset identifier for the provided response id
     */
    open func responseLocalIdentifier(forResponseId id: String) -> String? {
        
        var assetIds: [String: String] = [:]
        
        if let dict = UserDefaults.standard.object(forKey: Constants.KeySavedMaverickRecordingAssetIdentifiers) as? [String: String] {
            assetIds = dict
        }
        
        guard let id = assetIds[id] else {
            return nil
        }
        
        let assets = PHAsset.fetchAssets(withLocalIdentifiers: [id], options: nil)
        if assets.count == 0 {
            saveLocalIdentifier(forResponseId: id, identifier: nil)
            return nil
        }
        return id
        
    }
    
    /**
     Retrieve an asset identifier for the provided challenge id
     */
    open func challengeLocalIdentifier(forChallengeId id: String) -> String? {
        
        var assetIds: [String: String] = [:]
        
        if let dict = UserDefaults.standard.object(forKey: Constants.KeySavedMaverickChallengeAssetIdentifiers) as? [String: String] {
            assetIds = dict
        }
        
        guard let id = assetIds[id] else {
            return nil
        }
        
        let assets = PHAsset.fetchAssets(withLocalIdentifiers: [id], options: nil)
        if assets.count == 0 {
            saveLocalIdentifier(forChallengeId: id, identifier: nil)
            return nil
        }
        return id
        
    }
    
    /**
     Simple tracking for uploaded responses.
     
     We're doing this until we can reliably download video assets from the platform
     and store them in the user's library.
     */
    open func saveLocalIdentifier(forChallengeId id: String, identifier: String?) {
        
        guard let assetId = identifier else { return }
        
        var assetIds: [String: String] = [:]
        
        if let dict = UserDefaults.standard.object(forKey: Constants.KeySavedMaverickChallengeAssetIdentifiers) as? [String: String] {
            assetIds = dict
        }
        
        assetIds[id] = assetId
        
        UserDefaults.standard.set(assetIds, forKey: Constants.KeySavedMaverickChallengeAssetIdentifiers)
        UserDefaults.standard.synchronize()
        
    }
    
    /**
     Simple tracking for uploaded responses.
     
     We're doing this until we can reliably download video assets from the platform
     and store them in the user's library.
     */
    open func saveLocalIdentifier(forResponseId id: String, identifier: String?) {
        
        guard let assetId = identifier else { return }
        
        var assetIds: [String: String] = [:]
        
        if let dict = UserDefaults.standard.object(forKey: Constants.KeySavedMaverickRecordingAssetIdentifiers) as? [String: String] {
            assetIds = dict
        }
        
        assetIds[id] = assetId
        
        UserDefaults.standard.set(assetIds, forKey: Constants.KeySavedMaverickRecordingAssetIdentifiers)
        UserDefaults.standard.synchronize()
        
    }
    
}
