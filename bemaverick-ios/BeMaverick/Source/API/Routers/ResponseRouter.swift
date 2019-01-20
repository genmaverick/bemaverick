//
//  ResponseRouter.swift
//  BeMaverick
//
//  Created by David McGraw on 10/1/17.
//  Copyright © 2017 BeMaverick. All rights reserved.
//

import Alamofire

enum ResponseRouter: URLRequestConvertible {
   
    /// Get created user responses
    case getUserCreatedResponses(userId: String, badgeId : String?, count: Int, offset: Int)
    
    /// Get users who badged this response
    case getBadgeUsers(responseId: Int, badgeId: String?, count: Int, offset: Int)
    
    /// Deletes a response tied to the authorized user's account
    case deleteResponse(responseId: Int)
    
    /// Adds a badge to the response
    case addBadge(responseId: Int, badgeId: String)
    
    /// Marks a user owned response as publicly available
    case shareResponse(responseId: String)
    
    /// Marks a user unowned response as reported
    case reportResponse(responseId: String, reason: String)
    
    case getResponseById(responseId: String)
    
    
    /// Removes a previously awarded badge from the response
    case deleteBadge(responseId: Int, badgeId: String)
    
    // MARK: - Method
    
    var method: HTTPMethod {
        
        switch self {
        case .getResponseById:
            return .get
        case .getUserCreatedResponses:
            return .get
        case .getBadgeUsers:
            return .get
        case .deleteResponse:
            return .post
        case .addBadge:
            return .post
        case .shareResponse(_):
            return .post
        case .reportResponse(_,_):
            return .post
        case .deleteBadge:
            return .post
        }
        
    }
    
    // MARK: - Path
    
    var path: String {
        
        switch self {
        case .getResponseById(_):
            return "/response/details"
        case .getUserCreatedResponses(_, _, _, _):
             return "/user/responses"
         case .getBadgeUsers(_, _, _, _):
            return "/response/badgeusers"
        case .shareResponse(_):
            return "/response/share"
        case .reportResponse(_,_):
            return "/response/flag"
        case .deleteResponse(_):
            return "/response/delete"
        case .addBadge(_, _):
            return "/response/addbadge"
        case .deleteBadge(_, _):
            return "/response/deletebadge"
        }
        
    }
    
    // MARK: - URL
    
    func asURLRequest() throws -> URLRequest {
        
        let urlRequest = baseURLRequest(with: path, httpMethod: method.rawValue)
        
        switch self {
        case .getResponseById(let responseId):
            return encodedRequestURL(urlRequest, params: ["responseId": responseId])
            
        case .getUserCreatedResponses(let userId, let badgeId, let count, let offset):
            
            var params :  [String : Any] = ["userId" : userId, "count" : count, "offset" : offset] 
            
            if let badgeId = badgeId {
            
                params["badgeId"] = badgeId
            
            }
            
            let req = encodedRequestURL(urlRequest, params: params)
            
            print("🕸 getUserCreatedResponses: \(req.url?.absoluteURL.absoluteString ?? "N/A")")
            return req
            
           
            
        case .getBadgeUsers(let responseId, let badgeId, let count, let offset):
            
            var params : [String : Any] = ["responseId": responseId, "count": count, "offset": offset]
            if badgeId != nil {
                params["badgeId"] = badgeId
            }
            return encodedRequestURL(urlRequest, params: params)
            
        case .shareResponse(let responseId):
            return encodedRequestURL(urlRequest, params: ["responseId": responseId])
            
        case .reportResponse(let responseId, let reason):
            return encodedRequestURL(urlRequest, params: ["responseId": responseId, "reason" : reason])
            
        case .deleteResponse(let responseId):
            return encodedRequestURL(urlRequest, params: ["responseId": responseId])
            
        case .addBadge(let responseId, let badgeId):
            return encodedRequestURL(urlRequest, params: ["responseId": responseId, "badgeId": badgeId])
        
        case .deleteBadge(let responseId, let badgeId):
            return encodedRequestURL(urlRequest, params: ["responseId": responseId, "badgeId": badgeId])
        
        }
        
    }
        
}
