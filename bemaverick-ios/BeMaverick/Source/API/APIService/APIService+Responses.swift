//
//  APIService+Responses.swift
//  BeMaverick
//
//  Created by David McGraw on 10/1/17.
//  Copyright © 2017 BeMaverick. All rights reserved.
//

import Foundation
import Alamofire
import AlamofireObjectMapper

extension APIService {
    
  
    
    /**
     Retrieves  responses for given user
     
     - parameter userId:     The userId to fetch responses for
     - parameter count:     The amount of challenges to fetch
     - parameter offset:    The offset to the fetched amount
     */
    open func getUserCreatedResponses(forUserId userId: String, badgeId : String?, count: Int = 10,
                           offset: Int = 0,
                           completionHandler: @escaping (_ response: ResponsesResponse?) -> Void) {
        
        print("🌟📥 Fetching responses created by user \(userId) (\(count), offset by \(offset))")
        
        Alamofire.request(ResponseRouter.getUserCreatedResponses(userId : userId, badgeId: badgeId, count: count, offset: offset))
            .validate()
            .responseObject { (response: DataResponse<ResponsesResponse>) in
                
                if let error = response.error {
                    log.error("❌ Failed to fetch responses: \(error)")
                }
                
                completionHandler(response.value)
                
        }
        
    }
    
    
    /**
     Retrieves a list of users who badged a response, providing the badges they gave
     
     - parameter id:                The response to delete
     - parameter badgeId:           The badge id to fetch specifically (if any)
     - parameter count:             The amount of challenges to fetch
     - parameter offset:            The offset to the fetched amount
     - parameter completionHandler: The closure called upon completion with the response data
     */
    open func getResponseBadgeUsers(forResponseId id: Int,
                                    badgeId: String?,
                                    count: Int = 25,
                                    offset: Int = 0,
                                    completionHandler: @escaping (_ response: ResponsesResponse?) -> Void) {
        
        log.verbose("📥 Fetching list of users who badged response \(id) with badge id \(badgeId). (\(count), offset by \(offset))")
        
        Alamofire.request(ResponseRouter.getBadgeUsers(responseId: id, badgeId: badgeId, count: count, offset: offset))
            .validate()
            .responseObject { (response: DataResponse<ResponsesResponse>) in
                
                if let error = response.error {
                    log.error("❌ Failed to fetch a list of users who badged response: \(error)")
                }
                
                completionHandler(response.value)
                
        }
        
    }
    
    /**
     Applies a new badge to the provided response id
     
     - parameter id:                The response to delete
     - parameter completionHandler: The closure called upon completion with the response data
     */
    func deleteResponse(forResponseId id: Int,
                        completionHandler: @escaping ResponseRequestCompletedClosure)
    {
        
        log.verbose("📥 Delete response id \(id)")
        
        Alamofire.request(ResponseRouter.deleteResponse(responseId: id))
            .validate()
            .responseObject { (response: DataResponse<ResponsesResponse>) in
                
                if let error = response.error, let data = response.data {
                    log.error("❌ Failed to delete the response: \(error)")
                    return completionHandler(response.value, MaverickError.apiServiceRequestFailed(reason: .dataError(data: data, error: error)))
                }
                
                completionHandler(response.value, nil)
                
        }
        
    }
    
    /**
     Marks a user owned response as publicly available
     
     - parameter id:                The response to share
     - parameter completionHandler: The closure called upon completion with the response data
     */
    func shareResponse(forResponseId id: String,
                        completionHandler: @escaping ResponseRequestCompletedClosure)
    {
        
        log.verbose("📥 Share response id \(id)")
        
        Alamofire.request(ResponseRouter.shareResponse(responseId: id))
            .validate()
            .responseObject { (response: DataResponse<ResponsesResponse>) in
                
                if let error = response.error, let data = response.data {
                    log.error("❌ Failed to share the response: \(error)")
                    return completionHandler(response.value, MaverickError.apiServiceRequestFailed(reason: .dataError(data: data, error: error)))
                }
                
                completionHandler(response.value, nil)
                
        }
        
    }
    
    /**
     Marks a user owned response as publicly available
    
      - parameter type:                The contentType to report
     - parameter id:                The id to report
     - parameter reason:            The reason for reporting
     - parameter completionHandler: The closure called upon completion with the response data
     */
    func reportContent(type : Constants.ContentType, id: String, reason : String,
                       completionHandler: @escaping ResponseRequestCompletedClosure)
    {
        
        log.verbose("📥 Reporting response id \(id)")
        
        let request : URLRequestConvertible = type == .response ? ResponseRouter.reportResponse(responseId: id, reason: reason) : ChallengeRouter.reportChallenge(challengeId: id, reason: reason)
        
        Alamofire.request(request)
            .validate()
            .responseObject { (response: DataResponse<ResponsesResponse>) in
                
                if let error = response.error, let data = response.data {
                    log.error("❌ Failed to Report the response: \(error)")
                    return completionHandler(response.value, MaverickError.apiServiceRequestFailed(reason: .dataError(data: data, error: error)))
                }
                
                completionHandler(response.value, nil)
                
        }
        
    }
    
    
    /**
     Applies a new badge to the provided response id
     
     - parameter id:                The response to apply the badge to
     - parameter badgeId:           The badge id to use
     - parameter completionHandler: The closure called upon completion with the response data
     */
    func addBadge(toResponseId id: Int,
                  withBadgeId badgeId: String,
                  completionHandler: @escaping ResponseRequestCompletedClosure)
    {
        
        log.verbose("📥 Adding badge \(badgeId) to response \(id)")
        
        Alamofire.request(ResponseRouter.addBadge(responseId: id, badgeId: badgeId))
            .validate()
            .responseObject { (response: DataResponse<ResponsesResponse>) in
                
                if let error = response.error, let data = response.data {
                    log.error("❌ Failed to add badge to response: \(error)")
                    return completionHandler(response.value, MaverickError.apiServiceRequestFailed(reason: .dataError(data: data, error: error)))
                }
                
                completionHandler(response.value, nil)
                
        }
        
    }
    
    /**
     Removes a previously awarded badge from a response
     
     - parameter id:                The response to remove the badge from
     - parameter badgeId:           The badge id to use
     - parameter completionHandler: The closure called upon completion with the response data
     */
    func deleteBadge(toResponseId id: Int,
                     withBadgeId badgeId: String,
                     completionHandler: @escaping ResponseRequestCompletedClosure)
    {
        
        log.verbose("📥 Remove badge \(badgeId) from response \(id)")
        
        Alamofire.request(ResponseRouter.deleteBadge(responseId: id, badgeId: badgeId))
            .validate()
            .responseObject { (response: DataResponse<ResponsesResponse>) in
                
                if let error = response.error, let data = response.data {
                    log.error("❌ Failed to remove badge to response: \(error)")
                    return completionHandler(response.value, MaverickError.apiServiceRequestFailed(reason: .dataError(data: data, error: error)))
                }
                
                completionHandler(response.value, nil)
                
        }
        
    }
    
}
