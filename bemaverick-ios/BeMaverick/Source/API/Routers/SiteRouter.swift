//
//  SiteRouter.swift
//  BeMaverick
//
//  Created by David McGraw on 1/18/18.
//  Copyright © 2018 BeMaverick. All rights reserved.
//

import Alamofire

enum SiteRouter: URLRequestConvertible {
    
    /// Get curated maverick stream content
    case getMaverickStream()
    
    /// Get all badges
    case getMaverickBadges()
    
    /// Moderate
    case moderateText(text : String)
    
    /// Get all badges
    case getThemes()
    
    /// Get curated maverick stream content
    case getConfigurableStream(stream: Stream)
    
    /// Get a stream of content
    case getContentStream(contentType: String, count: Int, offset: Int)
    
    /// Get a token used for Twilio
    case getCommentToken(deviceId: String)
    
    /// Send the user message from the Contact Us Form
    case sendMessage(name: String, email: String, username: String, message: String)
    
    // MARK: - Method
    
    var method: HTTPMethod {
        
        switch self {
        case .getMaverickBadges():
            return .get
            
        case .getThemes():
            return .get
            
        case .getMaverickStream():
            return .get
            
        case .getConfigurableStream(_):
            return .get
            
        case .moderateText(_):
            return .post
            
        case .getContentStream(_, _, _):
            return .get
            
        case .getCommentToken(_):
            return .get
            
        case .sendMessage:
            return .post
       
        }
        
    }
    
    // MARK: - Path
    
    var path: String {
        
        switch self {
            
        case .getMaverickBadges():
            return "/site/badges"
        
        case .moderateText(_):
            return "/moderate/text"
            
        case .getThemes():
            return "/themes"
            
        case .getConfigurableStream(_):
            return ""
            
        case .getMaverickStream():
            return "/site/streams"
            
        case .getContentStream(_, _, _):
            return "/site/contents"
            
        case .getCommentToken(_):
            return "/comment/token"
            
        case .sendMessage(_):
            return "/site/zendesk"
        
        }
        
    }
    
    // MARK: - URL
    
    func asURLRequest() throws -> URLRequest {
        
        var urlRequest = baseURLRequest(with: path, httpMethod: method.rawValue)
        
        switch self {
        
        case .getThemes():
            urlRequest = baseCommentURLRequest(with: path, httpMethod: method.rawValue)
            let dict = [
                "active": "true",
                "sort": "sortOrder"
            ]
            return encodedRequestURL(urlRequest, params: dict, addAppKey : false)
         
        case .moderateText(let text):
            urlRequest = baseCommentURLRequest(with: path, httpMethod: method.rawValue)
            let dict = [
                "text": text
            ]
            return encodedRequestJSON(urlRequest, params: dict, addAppKey: false)
            
            
        case .getMaverickBadges():
            return encodedRequestURL(urlRequest)
            
        case .getMaverickStream():
            return encodedRequestURL(urlRequest)
            
        case .getConfigurableStream(let stream):
            let req =  encodedRequestURL(baseURLRequest(with: stream), params: stream.getQueryDict())
            print("🕸 Requesting Configurable Stream:\(stream.streamId) \(req.url?.absoluteString ?? "N/A")")
           return req
            
        case .getContentStream(let contentType, let count, let offset):
            return encodedRequestURL(urlRequest, params: ["contentType": contentType, "count": count, "offset": offset])
            
        case .getCommentToken(let deviceId):
            return encodedRequestURL(urlRequest, params: ["deviceId": deviceId])
            
        case .sendMessage(let name, let email, let username, let message):
            return encodedRequestURL(urlRequest, params: ["name": name, "email": email, "username": username, "message": message])
            
        }
        
    }
    
}
