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
     Fetches the trophies available on the app
   
     */
    func getProjects(completionHandler: @escaping ProjectClosure) {
        
        log.verbose("📥 Fetching trophies ")
        
        Alamofire.request(ProgressionRouter.getProjects())
            .validate()
            .responseObject { (response: DataResponse<ProjectResponse>) in
                
                if let error = response.error, let data = response.data {
                    log.error("❌ Fetching trophies: \(error)")
                    return completionHandler(response.value, MaverickError.apiServiceRequestFailed(reason: .dataError(data: data, error: error)))
                }
                
                completionHandler(response.value, nil)
                
        }
        
    }
    
    /**
     Fetches the reWARDS available on the app
     
     */
    func getAllRewards(completionHandler: @escaping RewardClosure) {
        
        log.verbose("📥 Fetching rewards ")
        
        Alamofire.request(ProgressionRouter.getAllRewards())
            .validate()
            .responseObject { (response: DataResponse<RewardResponse>) in
                
                if let error = response.error, let data = response.data {
                    log.error("❌ Fetching trophies: \(error)")
                    return completionHandler(response.value, MaverickError.apiServiceRequestFailed(reason: .dataError(data: data, error: error)))
                }
                
                completionHandler(response.value, nil)
                
        }
        
    }
    
   
    /**
     Retrieves the progression state for a given user id
     
     - parameter userid:        The id of the user
     
     */
    open func getProgressionForUser(userId : String, completionHandler: @escaping ProgressionClosure) {
        
        log.verbose("📥 getProgressionForUser for \(userId)")
        
        Alamofire.request(ProgressionRouter.getUserProgression(id: userId))
            .validate()
            .responseObject { (response: DataResponse<ProgressionResponse>) in
                
                completionHandler(response.value, nil)
                
        }
        
    }
    
    open func getProgressionLeaderboard(byString string : String, completionHandler: @escaping UserSearchRequestCompletedClosure) {
        
        log.verbose("📥 getProgressionLeaderboard for \(string)")
        Alamofire.request(ProgressionRouter.getProgressionLeaderboard(id: string))
            .validate()
            .responseArray { (response: DataResponse<[SearchUser]>) -> Void in
                
                completionHandler(response.value, nil)
                
        }
        
    }
    
}
