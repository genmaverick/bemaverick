//
//  SiteRouter.swift
//  BeMaverick
//
//  Created by David McGraw on 1/18/18.
//  Copyright © 2018 BeMaverick. All rights reserved.
//

import Alamofire

enum CommentRouter: URLRequestConvertible {
    
    /// Get a stream of content
    case getComments(contentType: Constants.ContentType, contentId: String, count: Int, offset: Int)
    
    /// delete a of content
    case deleteComment(id: String)
    
    /// flag a  of content
    case flagComment(id: String, reason: String)
    
    
    /// Send the user message from the Contact Us Form
    case sendComment(contentType: Constants.ContentType, contentId: String, message: String)
    
    // MARK: - Method
    
    var method: HTTPMethod {
        
        switch self {
      
        case .getComments(_, _, _, _):
            return .get
            
        case .deleteComment(_):
            return .delete
        
        case .flagComment(_,_):
            return .post
            
            
        case .sendComment(_, _, _):
            return .post
      
        }
        
    }
    
    // MARK: - Path
    
    var path: String {
        
        switch self {
        
        case .getComments(_, _, _, _):
            return "/comments"
            
        case .deleteComment(let id):
            return "/comments/\(id)"
        
        case .flagComment(let id, _):
            return "/comments/\(id)/flag"
            
        case .sendComment(_, _, _):
            return "/comments"
        
        }
        
    }
    
    // MARK: - URL
    
    func asURLRequest() throws -> URLRequest {
        
        let urlRequest = baseCommentURLRequest(with: path, httpMethod: method.rawValue)
        
        switch self {
        
        case .getComments(let contentType, let contentId, let count, let offset):
            return encodedRequestURL(urlRequest, params: ["parentType": contentType.stringValue, "parentId": contentId, "limit": count, "skip": offset], addAppKey : false)
       
        case .deleteComment(_):
            return encodedRequestURL(urlRequest, addAppKey : false)
        
        case .flagComment(_ , let reason):
            return encodedRequestJSON(urlRequest, params: ["reason": reason], addAppKey : false)
            
            
        case .sendComment(let contentType, let contentId, let message):
            
            let dict = [
                "body": message,
                "parentType": contentType.stringValue,
                "parentId": contentId
            ]
            
            let req = encodedRequestJSON(urlRequest, params: dict, addAppKey : false)
            
            print("🕸 sendComment : \(req.url)")
            return req
            
        }
        
    }
    
}
