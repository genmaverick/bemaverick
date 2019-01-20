//
//  APIService+Challenges.swift
//  BeMaverick
//
//  Created by David McGraw on 9/14/17.
//  Copyright © 2017 BeMaverick. All rights reserved.
//

import Foundation
import Alamofire
import AlamofireObjectMapper

/**
 Methods responsible for interacting with challenges
 */
extension APIService {
    
    /**
     Fetches the challenge details for the given id
     
     - parameter completionHandler: The closure called upon completion with the response data
     - parameter completionHandler: The closure called upon completion with the response data
     */
    func getChallengeDetails(challengeId : String, completionHandler: @escaping ResponseRequestCompletedClosure) {
        
        log.verbose("📥 Fetching challenge details for \(challengeId)")
        
        Alamofire.request(ChallengeRouter.getChallengeById(challengeId: challengeId))
            .validate()
            .responseObject { (response: DataResponse<ResponsesResponse>) in
                
                if let error = response.error, let data = response.data {
                    log.error("❌ Failed to Fetch challenge details for \(challengeId): \(error)")
                   return completionHandler(response.value, MaverickError.apiServiceRequestFailed(reason: .dataError(data: data, error: error)))
                }
                
                completionHandler(response.value, nil)
                
        }
        
    }
    
    /**
     Retrieves  responses for given user
     
     - parameter userId:     The userId to fetch responses for
     - parameter count:     The amount of challenges to fetch
     - parameter offset:    The offset to the fetched amount
     */
    open func getUserCreatedChallenges(forUserId userId: String, count: Int = 10,
                                      offset: Int = 0,
                                      completionHandler: @escaping (_ response: ResponsesResponse?) -> Void) {
        
        print("🌟📥 Fetching challenges created by user \(userId) (\(count), offset by \(offset))")
        
        Alamofire.request(ChallengeRouter.getUserCreatedChallenges(userId : userId, count: count, offset: offset))
            .validate()
            .responseObject { (response: DataResponse<ResponsesResponse>) in
                
                if let error = response.error {
                    log.error("❌ Failed to fetch challenges: \(error)")
                }
                
                completionHandler(response.value)
                
        }
        
    }
    
    /**
     Retrieves the active challenges
     
     - parameter count:     The amount of challenges to fetch
     - parameter offset:    The offset to the fetched amount
     - parameter status:    The current status of the challenges
     - parameter sort:      The sorting behavior
     
     */
    open func getChallenges(withCount count: Int = 20,
                            offset: Int = 0,
                            status: Constants.MaverickChallengeStatus = .active,
                            featuredType: Constants.ChallengeFeaturedType,
                            completionHandler: @escaping (_ response: ChallengesResponse?, _ error: MaverickError?) -> Void) {
        
        log.verbose("📥 Fetching\(featuredType.rawValue) \(status.asString) challenges (\(count), offset by \(offset)) ")
        
        Alamofire.request(ChallengeRouter.getChallenges(count: count, offset: offset, status: status.asString, sort: Constants.MaverickSortOrder.featuredAndStartTimestamp.asString, featuredType: featuredType))
            .validate()
            .responseObject { (response: DataResponse<ChallengesResponse>) in
                
                if let error = response.error, let data = response.data {
                    log.error("❌ Failed to fetch challenges: \(error)")
                    
                    return completionHandler(response.value, MaverickError.apiServiceRequestFailed(reason: .dataError(data: data, error: error)))
                    
                    
                }
                
                completionHandler(response.value, nil)
                
        }
        
    }
    
    /**
     Retrieves the active challenges without any responses
     
     - parameter count:     The amount of challenges to fetch
     - parameter offset:    The offset to the fetched amount
     - parameter status:    The current status of the challenges
     - parameter sort:      The sorting behavior
     
     */
    open func getChallengesNoResponse(withCount count: Int = 20,
                            offset: Int = 0,
                            completionHandler: @escaping (_ response: ChallengesResponse?, _ error: MaverickError?) -> Void) {
        
        log.verbose("📥 Fetching getChallengesNoResponse \(count), offset by \(offset) ")
        
        Alamofire.request(ChallengeRouter.getNoResponseChallenges(minHours: 12, count: count, offset: offset))
            .validate()
            .responseObject { (response: DataResponse<ChallengesResponse>) in
                
                if let error = response.error, let data = response.data {
                    log.error("❌ Failed to fetch getChallengesNoResponse: \(error)")
                    
                    return completionHandler(response.value, MaverickError.apiServiceRequestFailed(reason: .dataError(data: data, error: error)))
                    
                    
                }
                
                completionHandler(response.value, nil)
                
        }
        
    }
    
    open func getMyRespondedChallenges(withCount count: Int = 20,
                                      offset: Int = 0,
                                      completionHandler: @escaping (_ response: ChallengesResponse?, _ error: MaverickError?) -> Void) {
        
        log.verbose("📥 Fetching getMyRespondedChallenges \(count), offset by \(offset) ")
        
        Alamofire.request(ChallengeRouter.getMyRespondedChallenges(count: count, offset: offset))
            .validate()
            .responseObject { (response: DataResponse<ChallengesResponse>) in
                
                if let error = response.error, let data = response.data {
                    log.error("❌ Failed to fetch getMyRespondedChallenges: \(error)")
                    
                    return completionHandler(response.value, MaverickError.apiServiceRequestFailed(reason: .dataError(data: data, error: error)))
                    
                    
                }
                
                completionHandler(response.value, nil)
                
        }
        
    }
    
    open func getLinkChallenges(withCount count: Int = 20,
                                     offset: Int = 0,
                                     completionHandler: @escaping (_ response: ChallengesResponse?, _ error: MaverickError?) -> Void) {
        
        log.verbose("📥 Fetching getLinkChallenges \(count), offset by \(offset) ")
        
        Alamofire.request(ChallengeRouter.getLinkChallenges(count: count, offset: offset))
            .validate()
            .responseObject { (response: DataResponse<ChallengesResponse>) in
                
                if let error = response.error, let data = response.data {
                    log.error("❌ Failed to fetch getLinkChallenges: \(error)")
                    
                    return completionHandler(response.value, MaverickError.apiServiceRequestFailed(reason: .dataError(data: data, error: error)))
                    
                    
                }
                
                completionHandler(response.value, nil)
                
        }
        
    }
    
    open func getMyInvitedChallenges(withCount count: Int = 20,
                                       offset: Int = 0,
                                       completionHandler: @escaping (_ response: ChallengesResponse?, _ error: MaverickError?) -> Void) {
        
        log.verbose("📥 Fetching getMyInvitedChallenges \(count), offset by \(offset) ")
        
        Alamofire.request(ChallengeRouter.getMyInvitedChallenges(count: count, offset: offset))
            .validate()
            .responseObject { (response: DataResponse<ChallengesResponse>) in
                
                if let error = response.error, let data = response.data {
                    log.error("❌ Failed to fetch getMyRespondedChallenges: \(error)")
                    
                    return completionHandler(response.value, MaverickError.apiServiceRequestFailed(reason: .dataError(data: data, error: error)))
                    
                    
                }
                
                completionHandler(response.value, nil)
                
        }
        
    }
    
    open func getTrendingChallenges(versionNumber: Int,
                                    withCount count: Int = 20,
                                       offset: Int = 0,
                                       
                                       completionHandler: @escaping (_ response: ChallengesResponse?, _ error: MaverickError?) -> Void) {
        
        log.verbose("📥 Fetching getTrendingChallenges \(count), offset by \(offset) ")
        
        Alamofire.request(ChallengeRouter.getTrendingChallenges(versionNumber: versionNumber, count: count, offset: offset))
            .validate()
            .responseObject { (response: DataResponse<ChallengesResponse>) in
                
                if let error = response.error, let data = response.data {
                    log.error("❌ Failed to fetch getTrendingChallenges: \(error)")
                    
                    return completionHandler(response.value, MaverickError.apiServiceRequestFailed(reason: .dataError(data: data, error: error)))
                    
                    
                }
                
                completionHandler(response.value, nil)
                
        }
        
    }
    
    /**
     Retrieves the response for a given id
     
     - parameter id:        The id of a response to fetch
     
     
     */
    open func getResponseDetails(id: String,
                           completionHandler: @escaping (_ response: ResponsesResponse?) -> Void) {
        
        log.verbose("📥 Fetching responses for the challenge with id \(id)")
        
        Alamofire.request(ResponseRouter.getResponseById(responseId: id))
            .validate()
            .responseObject { (response: DataResponse<ResponsesResponse>) in
                
                if let error = response.error {
                    log.error("❌ Failed to fetch responses for challenge: \(error)")
                }
                
                completionHandler(response.value)
                
        }
        
    }
    
    
    
    /**
     Retrieves the responses for a given challenge
     
     - parameter id:        The id of a challenge to fetch responses for
     - parameter count:     The amount to request
     - parameter offset:    The offset to the fetched amount

     */
    open func getResponses(forChallengeId id: String,
                           count: Int = 30,
                           offset: Int = 0,
                           completionHandler: @escaping (_ response: ResponsesResponse?) -> Void) {
        
        log.verbose("📥 Fetching responses for the challenge with id \(id)")
        
        Alamofire.request(ChallengeRouter.getResponses(id: id, count: count, offset: offset))
            .validate()
            .responseObject { (response: DataResponse<ResponsesResponse>) in
                
                if let error = response.error {
                    log.error("❌ Failed to fetch responses for challenge: \(error)")
                }
                
                completionHandler(response.value)
                
        }
        
    }
    
    private func interpretPostResponseRequest(request : URLRequest?, urlResponse : HTTPURLResponse, data : Data?) -> DataRequest.ValidationResult {
        
        if urlResponse.statusCode == 400 {
            var isModerated = false
           
            do {
                
                if let json = try JSONSerialization.jsonObject(with: data!, options: []) as? [String : Any], let array = json["errors"] as? [Any] , let errors = array[safe: 0] as? [String:Any] , let id = errors["id"] as? String, let message = errors["message"] as? String {
                    
                    if id == "inAppropriateResponse" {
                        
                        
                        isModerated = true
                        
                    } else if message == "RESPONSE_FAILED_MODERATION_CHECK" {
                        
                         isModerated = true
                        
                        
                    }
                }
                
            }  catch {
                
            }
            
            if isModerated {
                
                return .failure( NSError(domain:"", code:444, userInfo:nil) )
            }
            
            return .failure( NSError(domain:"", code:urlResponse.statusCode, userInfo:nil) )
            
        }
        return .success
        
    }
    
    
    /**
     Adds an uploaded video or image response to an existing challenge.
     
     - parameter id:    The id of a challenge to add the video/image to
     - parameter name:  The filename used when uploading to S3
     */
    open func addResponse(withChallengeId id: String?,
                                   filename name: String,
                                   description: String,
                                   coverImage: UIImage?,
                                   responseType: Constants.UploadResponseType,
                                   completionHandler: @escaping (_ response: ResponsesResponse?, _ error: MaverickError?) -> Void)
    {
        
        log.verbose("📥 Adding a response \(name) to challenge id \(id ?? "NA").")
        
        
        
        var data: Data? = nil
        if coverImage != nil {
            data = UIImageJPEGRepresentation(coverImage!, 1.0)!
        }
        
        if let id = id {

            Alamofire.request(ChallengeRouter.submitResponse(id: id, type: responseType == .video ? responseType.rawValue : Constants.UploadResponseType.image.rawValue, filename: name,  description: description, coverImageData: data, coverImageFileName: nil))
                .validate({ (urlRequest, urlResponse, data) -> Request.ValidationResult in
                    
                    return self.interpretPostResponseRequest(request: urlRequest, urlResponse: urlResponse, data: data)
                    
                }).validate()
                .responseObject { (response: DataResponse<ResponsesResponse>) in
                    
                    if let error = response.error {
                        
                        log.error("Failed to apply the challenge : \(error.localizedDescription)")
                        completionHandler(nil, MaverickError.recordingUploadFailureReason(reason: error.code == 444 ? .moderationFail() : .associateVideoError(message: error.localizedDescription)))
                        return
                        
                    }
                    
                    completionHandler(response.value, nil)
                    
            }
            
        } else {
            
            Alamofire.request(ChallengeRouter.submitPost(type: responseType == .video ? responseType.rawValue : Constants.UploadResponseType.image.rawValue, filename: name, description: description, coverImageData: data, coverImageFileName: nil))
                .validate({ (urlRequest, urlResponse, data) -> Request.ValidationResult in
                    
                    return self.interpretPostResponseRequest(request: urlRequest, urlResponse: urlResponse, data: data)
                    
                }).validate()
                .responseObject { (response: DataResponse<ResponsesResponse>) in
                    
                    if let error = response.error {
                        
                        log.error("Failed to apply the challenge : \(error.localizedDescription)")
                        completionHandler(nil, MaverickError.recordingUploadFailureReason(reason: error.code == 444 ? .moderationFail() : .associateVideoError(message: error.localizedDescription)))
                        return
                        
                    }
                    completionHandler(response.value, nil)
                    
            }
            
        }
        
    }
    
    
   
    
    
    /**
     Adds an uploaded video or image challenge.
     
     - parameter name:  The filename used when uploading to S3
     */
    open func addChallenge(filename name: String,
                          title: String?,
                          description: String?,
                          mentions: String?,
                          coverImage: UIImage?,
                          imageText: String?,
                          linkUrl: String?,
                          responseType: Constants.UploadResponseType,
                          completionHandler: @escaping (_ response: ResponsesResponse?, _ error: MaverickError?) -> Void)
    {
        
        log.verbose("📥 Adding a challenge \(name)")
        
        var data: Data? = nil
        if coverImage != nil {
            data = UIImageJPEGRepresentation(coverImage!, 1.0)!
        }
        
        Alamofire.request(ChallengeRouter.submitChallenge(type: responseType.rawValue, filename: name, title: title, description: description, mentions: mentions, coverImageData: data, imageText: imageText, linkUrl: linkUrl))
            .validate({ (urlRequest, urlResponse, data) -> Request.ValidationResult in
                
                return self.interpretPostResponseRequest(request: urlRequest, urlResponse: urlResponse, data: data)
                
            }).validate()
            .responseObject { (response: DataResponse<ResponsesResponse>) in
                
                if let error = response.error {
                    
                    log.error("Failed to apply the challenge : \(error.localizedDescription)")
                    completionHandler(nil, MaverickError.recordingUploadFailureReason(reason: error.code == 444 ? .moderationFail() : .associateVideoError(message: error.localizedDescription)))
                    return
                    
                }
                completionHandler(response.value, nil)
                
        }
        
    }
    
    /**
     Deletes a challenge
     
     - parameter id:                The challenge to delete
     - parameter completionHandler: The closure called upon completion with the response data
     */
    open func deleteChallenge(forChallengeId id: Int,
                        completionHandler: @escaping ResponseRequestCompletedClosure)
    {
        
        log.verbose("📥 Delete challenge id \(id)")
        
        Alamofire.request(ChallengeRouter.deleteChallenge(challengeId: id))
            .validate()
            .responseObject { (response: DataResponse<ResponsesResponse>) in
                
                if let error = response.error, let data = response.data {
                    log.error("❌ Failed to delete the challenge: \(error)")
                    return completionHandler(response.value, MaverickError.apiServiceRequestFailed(reason: .dataError(data: data, error: error)))
                }

                completionHandler(response.value, nil)
        }
    }
                
     /**
     Edits an existing challenge
     */
    open func editChallenge(challengeId id: String,
                           title: String?,
                           mentions: String?,
                           description: String?,
                           linkUrl : String?,
                           completionHandler: @escaping (_ challenge: ResponsesResponse?, _ error: MaverickError?) -> Void)
    {
        
        log.verbose("📥 Editting a challenge \(id) ")
        
        Alamofire.request(ChallengeRouter.editChallenge(challengeId: id, title: title, description: description,  mentions: mentions, linkUrl: linkUrl))
            .validate()
            .responseObject { (response: DataResponse<ResponsesResponse>) in
                
                if let error = response.error {
                    
                    log.error("Failed to apply the edit to challenge : \(error.localizedDescription)")
                    completionHandler(nil, MaverickError.recordingUploadFailureReason(reason: .associateVideoError(message: error.localizedDescription)))
                    return
                    
                }
                completionHandler(response.value, nil)
                
        }
        
    }
        
    
}

extension Error {
    
    var code: Int { return (self as NSError).code }
    var domain: String { return (self as NSError).domain }
    
}
