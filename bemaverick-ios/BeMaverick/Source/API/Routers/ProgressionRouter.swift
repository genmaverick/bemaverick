//
//  ProgressionRouter.swift
//  BeMaverick
//
//  Created by David McGraw on 1/18/18.
//  Copyright © 2018 BeMaverick. All rights reserved.
//

import Alamofire

enum ProgressionRouter: URLRequestConvertible {
    
    /// Get a stream of content
    case getProjects()
    
    /// delete a of content
    case getUserProgression(id: String)
    
    /// get all rewards
    case getAllRewards()
    
    /// delete a of content
    case getProgressionLeaderboard(id: String)
    
    // MARK: - Method
    
    var method: HTTPMethod {
        
        switch self {
            
        case .getProjects():
            return .get
            
        case .getUserProgression(_):
            return .get
            
        case .getProgressionLeaderboard(_):
            return .get
            
        case .getAllRewards():
            return .get
            
        }
        
    }
    
    // MARK: - Path
    
    var path: String {
        
        switch self {
            
        case .getAllRewards():
            return "progression/rewards"
            
        case .getProjects():
            return "progression/trophies"
            
        case .getUserProgression(let id):
            return "progression/users/\(id)"
            
        case .getProgressionLeaderboard(_):
           return "/user/autocomplete"
            
        }
        
    }
    
    // MARK: - URL
    
    func asURLRequest() throws -> URLRequest {
        
        var urlRequest = baseProgressionURLRequest(with: path, httpMethod: method.rawValue)
        
        switch self {
            
        case .getProgressionLeaderboard(let query):
            urlRequest = baseURLRequest(with: path, httpMethod: method.rawValue)
            return encodedRequestURL(urlRequest, params: ["query":query])
            
        case .getProjects():
            let req = encodedRequestURL(urlRequest, params: [:], addAppKey : false)
            print("🕸 getProjects : \(req.url)")
            return req
            
        case .getAllRewards():
            let req = encodedRequestURL(urlRequest, params: [:], addAppKey : false)
            print("🕸 getRewards : \(req.url)")
            return req
            
        case .getUserProgression(_):
            let req = encodedRequestURL(urlRequest, params: [:], addAppKey : false)
            print("🕸 getUserProgression : \(req.url)")
            return req
            
            
        }
        
    }
    
}
