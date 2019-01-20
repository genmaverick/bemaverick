//
//  TagRouter.swift
//  BeMaverick
//
//  Created by David McGraw on 1/18/18.
//  Copyright © 2018 BeMaverick. All rights reserved.
//

import Alamofire

enum TagRouter: URLRequestConvertible {
    
    /// Get a stream of tags
    case autocompleteHashtag(query : String)
    
    /// Get a stream of tags
    case getChallengesByTag(hashtagName : String, count : Int?, offset : Int?)

    /// Get a stream of tags
    case getResponsesByTag(hashtagName : String, count : Int?, offset : Int?)

    
    // MARK: - Method
    
    var method: HTTPMethod {
        
        switch self {
            
        case .getChallengesByTag(_, _, _):
            return .get
        case .getResponsesByTag(_, _, _):
            return .get
            
        case .autocompleteHashtag(_):
            return .get
            
        }
        
    }
    
    // MARK: - Path
    
    var path: String {
        
        switch self {
            
        case .getChallengesByTag(_):
             return "/hashtags"
        case .getResponsesByTag(_):
            return "/hashtags"
            
        case .autocompleteHashtag(_):
            return "/hashtags/autocomplete"
        }
        
    }
    
    // MARK: - URL
    
    func asURLRequest() throws -> URLRequest {
        
        let urlRequest = baseCommentURLRequest(with: path, httpMethod: method.rawValue)
        
        switch self {
            
        case .autocompleteHashtag( let query):
            let req = encodedRequestURL(urlRequest, params: ["query": query, "sort":"-count"], addAppKey : false)
            
            print("🕸 autocompleteHashtag : \(req.url)")
            return req
            
        case .getResponsesByTag( let tagName, let count, let offset):
            
            var params = ["name": tagName,"sort":"-created","contentType":"response"]
            
            
            if let count = count {
                
                params["limit"] = "\(count)"
                
            }
             
             if let offset = offset {
                
                params["skip"] = "\(offset)"
                
             }
             
             let req = encodedRequestURL(urlRequest, params: params, addAppKey : false)
             
            print("🕸 getResponsesByTag : \(req.url)")
            return req
        
        case .getChallengesByTag( let tagName, let count, let offset):
            var params = ["name": tagName,"sort":"-created","contentType":"challenge"]
            
            
            if let count = count {
                
                params["limit"] = "\(count)"
                
            }
            
            if let offset = offset {
                
                params["skip"] = "\(offset)"
                
            }
            
            let req = encodedRequestURL(urlRequest, params: params, addAppKey : false)
            
            print("🕸 getChallengesByTag : \(req.url)")
            return req
            
        }
        
    }
    
}
