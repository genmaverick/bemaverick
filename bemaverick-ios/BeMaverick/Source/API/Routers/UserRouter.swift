//
//  UserRouter.swift
//  BeMaverick
//
//  Created by David McGraw on 10/1/17.
//  Copyright © 2017 BeMaverick. All rights reserved.
//

import Alamofire

enum UserRouter: URLRequestConvertible {
    
    /// Get a list of site users
    case getUsers(count: Int, offset: Int)
    
    /// Get a list of users by query string
    case searchUsers(query : String)
    
    /// Get details about the authorized user
    case me(basic : Bool)
    
    /// Get a list list of responses based on the authorized user
    case getMyFeed(count: Int, offset: Int)
    
    /// Get a list of responses with the provided badge id
    case getBadgedResponses(badgeId: String?, userId: String, count: Int, offset: Int)
    
    /// Get a list of following and followed
    case getFollowDetails(userId: String)
    
    /// Follow or unfollow a user
    case toggleFollow(id: String, action: String)
    
    /// Remove an existing follower from following you
    case removeFollower(id: String)
    
    /// Get favorite challenges
    case getSavedChallenges(count: Int, offset: Int)
    
    /// Favorite or unfavorite a challenge
    case toggleSaveChallenge(id: String, action: String)
    
    /// Favorite a Response (Catalyst only)
    case catalystFavoriteResponse(id: String, action: String)
    
    /// Favorite or unfavorite a content
    case toggleSaveContent(id: String, action: String)
    
    /// Get favorite content
    case getSavedContent
    
    /// Get user details for the user id
    case getDetails(id: String)
    
    /// Get contacts on maverick
    case getContactsOnMaverick(emails_CSV : String, phoneNumbers_CSV : String)
    
    /// Get facebook contacts on maverick
    case getFacebookContactsOnMaverick(ids: String)
    
    /// Get contacts on maverick
    case inviteContacts(emails_CSV : String, invite_url : String, subject : String, body : String)
    
    /// Edit user profile details
    case editDetails(bio: String, firstName: String, lastName: String, username: String)
    
    /// Edit user NotificationSetting
    case editNotificationSetting(settingKey: String, settingEnabled: String)
    
    /// Upload a new user avatar
    case uploadAvatar(data: Data?)
    
    /// Upload a cover image for the authorized user
    case uploadCoverImage(data: Data)
    
    /// Set preset cover and tint for authorized user
    case uploadPresetCover(profileCoverPresetImageId: Int, profileCoverTint: String)
    
    /// Update the user password for the authorized user
    case updatePassword(current: String, new: String)
    
    case deactivateAccount(deactivate: String)
    // MARK: - Method
    
    var method: HTTPMethod {
        
        switch self {
            
        case .getContactsOnMaverick:
            return .post
        case .getFacebookContactsOnMaverick:
            return .post
        case .searchUsers:
            return .get
        case .inviteContacts:
            return .post
        case .getUsers:
            return .get
        case .me:
            return .get
        case .getMyFeed:
            return .get
        case .getBadgedResponses:
            return .get
        case .getFollowDetails:
            return .get
        case .catalystFavoriteResponse:
            return .get
        case .toggleFollow:
            return .post
        case .removeFollower:
            return .post
        case .getSavedChallenges:
            return .get
        case .getSavedContent:
             return .get
        case .toggleSaveChallenge:
            return .post
        case .toggleSaveContent:
            return .post
        case .getDetails:
            return .get
        case .editDetails:
            return .post
        case .editNotificationSetting:
            return .post
        case .uploadAvatar:
            return .post
        case .uploadCoverImage:
            return .post
        case .updatePassword:
            return .post
        case .uploadPresetCover:
            return .post
        case .deactivateAccount:
            return .post
            
        }
        
    }
    
    // MARK: - Path
    
    var path: String {
        
        switch self {
        case .searchUsers:
            return "/user/autocomplete"
        case .getContactsOnMaverick(_,_):
            return "/user/findmyfriends"
        case .getFacebookContactsOnMaverick(_):
            return "/user/findmyfriends"
        case .inviteContacts(_,_,_,_):
            return "/user/invitemyfriends"
        case .catalystFavoriteResponse(_,_):
            return "/response/favorite"
        case .getUsers(_, _):
            return "/site/users"
        case .me(_):
            return "/user/me"
        case .getMyFeed(_, _):
            return "/user/myfeed"
        case .getBadgedResponses(_, _, _, _):
            return "/user/badgedresponses"
        case .getFollowDetails(_):
            return "/user/followers"
        case .toggleFollow(_, _):
            return "/user/editfollowing"
        case .removeFollower(_):
            return "/user/deletefollower"
        case .getSavedChallenges(_, _):
            return "/user/savedchallenges"
        case .getSavedContent:
            return "/user/savedContents"
        case .toggleSaveChallenge(_, _):
            return "/user/editsavedchallenge"
        case .toggleSaveContent(_, _):
            return "/user/editsavedcontent"
        case .getDetails(_):
            return "/user/details"
        case .editDetails(_):
            return "/user/editprofile"
        case .editNotificationSetting(_,_):
            return "/user/editprofile"
        case .uploadAvatar(_):
            return "/user/editprofile"
        case .uploadCoverImage(_):
            return "/user/editprofile"
        case .uploadPresetCover(_,_):
            return "/user/editprofile"
        case .updatePassword(_, _):
            return "/user/editpassword"
        case .deactivateAccount(_):
            return "/user/deactivateaccount"
        
        }
        
    }
    
    // MARK: - URL
    
    func asURLRequest() throws -> URLRequest {
        
        var urlRequest = baseURLRequest(with: path, httpMethod: method.rawValue)
        
        switch self {
            
        case .searchUsers(let query):
            return encodedRequestURL(urlRequest, params: ["query":query])
            
        case .getContactsOnMaverick(let emails_CSV, let phoneNumbers_CSV):
            
            var params : [String:String] = [:]
            if emails_CSV.count > 0 {
                params["emailAddresses"] =  emails_CSV
            }
            if phoneNumbers_CSV.count > 0 {
                params["phoneNumbers"] =  phoneNumbers_CSV
            }
            return encodedRequestJSON(urlRequest, params: params)
            
        case .me(let basic):
            let req = encodedRequestURL(urlRequest, params: ["basic": basic ? "1" : "0"])
            return req
            
        case .getFacebookContactsOnMaverick(let ids):
            return encodedRequestJSON(urlRequest, params: ["loginProvider": "facebook", "loginProviderUserIds": ids])
            
        case .inviteContacts(let emails_CSV, let invite_url, let subject, let body):
            return encodedRequestJSON(urlRequest, params: ["emailAddresses": emails_CSV, "deepLinkURL": invite_url, "subject" : subject, "body" : body])
            
        case .getUsers(let count, let offset):
            return encodedRequestURL(urlRequest, params: ["count": count, "offset": offset])
            
        case .getMyFeed(let count, let offset):
            return encodedRequestURL(urlRequest, params: ["count": count, "offset": offset])
            
        case .getFollowDetails(let userId):
            return encodedRequestURL(urlRequest, params: ["userId": userId])
            
        case .getBadgedResponses(let badgeId, let userId, let count, let offset):
            
            var params : [String : Any] = ["userId": userId, "count": count, "offset": offset]
             
             if let badgeId = badgeId {
                
                params["badgeId"] = badgeId
             
             }
            
            let req = encodedRequestURL(urlRequest, params: params)
            print("🕸 getBadgedResponses : \(req.url)")
            return req
          
        case .catalystFavoriteResponse(let id, let action):
            let req = encodedRequestURL(urlRequest, params: ["responseId": id, "favoriteAction": action])
             print("🕸 catalystFavoriteResponse : \(req.url)")
            return req
            
        case .toggleFollow(let id, let action):
            let req = encodedRequestURL(urlRequest, params: ["followingUserId": id, "followingAction": action])
               print("🕸 toggleFollow : \(req.url)")
            return req
            
        case .removeFollower(let id):
            return encodedRequestURL(urlRequest, params: ["followerUserId": id])
            
        case .getDetails(let id):
            let req = encodedRequestURL(urlRequest, params: ["userId": id, "basic":"1"])
            print("🕸 get User Details : \(req.url)")
            return encodedRequestURL(urlRequest, params: ["userId": id, "basic":"1"])
            
        case .editDetails(let bio, let first, let last, let username):
            return encodedRequestURL(urlRequest, params: ["bio": bio, "firstName":first, "lastName":last, "username":username])
            
        case .editNotificationSetting(let notificationSetting, let isEnabled):
            return encodedRequestURL(urlRequest, params: [notificationSetting:isEnabled])
            
        case .toggleSaveChallenge(let id, let action):
            let req = encodedRequestURL(urlRequest, params: ["challengeId": id, "saveAction": action])
            print("🕸 toggleSaveChallenge : \(req.url)")
            
            return req
            
        case .getSavedChallenges(let count, let offset):
            let req = encodedRequestURL(urlRequest, params: ["count": count, "offset": offset])
            print("🕸 getSavedChallenges : \(req.url)")
            return req
            
        case .toggleSaveContent(let id, let action):
            return encodedRequestURL(urlRequest, params: ["contentId": id, "saveAction": action])
            
        case .uploadAvatar(let data):

            guard let data = data  else {
    
                // clear profile avatar
                return encodedRequestURL(urlRequest, params: ["profileImage": -1])
        
            }
            
            urlRequest.setValue("multipart/form-data; charset=utf-8; boundary=__IOS_BOUNDARY__", forHTTPHeaderField: "Content-Type")
          
            urlRequest.httpBody = bodyImageDataUploadRequest(withData: data, forParameterName: "profileImage")
            

            if var comps = URLComponents(url: urlRequest.url!, resolvingAgainstBaseURL: false) {
                comps.percentEncodedQuery = "appKey=bemaverick_ios"
                urlRequest.url = comps.url
            }
            return urlRequest
            
        case .uploadCoverImage(let data):
            
            urlRequest.setValue("multipart/form-data; charset=utf-8; boundary=__IOS_BOUNDARY__", forHTTPHeaderField: "Content-Type")
            urlRequest.httpBody = bodyImageDataUploadRequest(withData: data, forParameterName: "profileCoverImage")
            
            if var comps = URLComponents(url: urlRequest.url!, resolvingAgainstBaseURL: false) {
                comps.percentEncodedQuery = "appKey=bemaverick_ios"
                urlRequest.url = comps.url
            }
            return urlRequest
            
        case .uploadPresetCover(let profileCoverPresetImageId, let profileCoverTint):
           return encodedRequestURL(urlRequest, params: ["profileCoverPresetImageId": profileCoverPresetImageId, "profileCoverTint": profileCoverTint])
            
            
        case .updatePassword(let current, let new):
            return encodedRequestURL(urlRequest, params: ["currentPassword": current, "newPassword": new])
            
        case .deactivateAccount(let deactivate):
            return encodedRequestURL(urlRequest, params: ["deactivateAction": deactivate])
            
        default:
            return encodedRequestURL(urlRequest, params: [:])
        }
        
    }
    
    // MARK: - Private Methods
    
    /**
     Generate a multi-part data object that can be applied to a URL request
     
     - parameter data: The image data to use
     - parameter name: The endpoint name for the request
    */
    fileprivate func bodyImageDataUploadRequest(withData data: Data, forParameterName name: String) -> Data {
        
        let randomFilename = "iOS_avatar_" +
            UUID().uuidString + "_" +
            String(Int(Date().timeIntervalSince1970)) + ".jpg"
        
        let contentDispositionString = "Content-Disposition: form-data; name=\"\(name)\"; filename=\"\(randomFilename)\"\r\n"
        let contentTypeString = "Content-Type: image/jpeg\r\n\r\n"
        
        let boundaryStart = "--__IOS_BOUNDARY__\r\n"
        let boundaryEnd = "--__IOS_BOUNDARY__\r\n"
        
        let bodyData: NSMutableData = NSMutableData()
        bodyData.append(boundaryStart.data(using: .utf8)!)
        bodyData.append(contentDispositionString.data(using: .utf8)!)
        bodyData.append(contentTypeString.data(using: .utf8)!)
        bodyData.append(data)
        bodyData.append("\r\n".data(using: .utf8)!)
        bodyData.append(boundaryEnd.data(using: .utf8)!)
        
        return bodyData as Data
        
    }
    
}
