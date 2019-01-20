//
//  APIService+Tags.swift
//  BeMaverick
//
//  Created by David McGraw on 10/7/17.
//  Copyright © 2017 BeMaverick. All rights reserved.
//

import Foundation
import Alamofire
import AlamofireObjectMapper

extension APIService {
    
    /**
     Fetches a list of tags from the platform
     
     - parameter completionHandler: The closure called upon completion with the response data
     */
    func getTags(withQuery query: String = "",
                 completionHandler: @escaping TagsRequestCompletedClosure)
    {

        log.verbose("📥 Fetching tags with query \(query) ")
        
        Alamofire.request(TagRouter.autocompleteHashtag(query: query))
            .validate()
            .responseArray { (response: DataResponse<[Hashtag]>) in


                if let error = response.error, let data = response.data {
                    log.error("❌ Failed to fetch tags: \(error)")
                    return completionHandler(response.value, MaverickError.apiServiceRequestFailed(reason: .dataError(data: data, error: error)))
                }

                completionHandler(response.value, nil)

        }

    }
    
    
    /**
     Fetches a list of tags from the platform
     
     - parameter completionHandler: The closure called upon completion with the response data
     */
    func getTagContent(contentType: Constants.ContentType, tagName: String, count : Int? = 25, offset : Int? = 0,
                 completionHandler: @escaping TagContentRequestCompletedClosure)
    {
        
        log.verbose("📥 Fetching getTagContent with query \(tagName) ")
        
        var request = TagRouter.getChallengesByTag(hashtagName: tagName, count : count, offset : offset)
        
        if contentType == .response {
            
            request = TagRouter.getResponsesByTag(hashtagName: tagName, count : count, offset : offset)
            
        }
        
        Alamofire.request(request)
            .validate()
            .responseObject { (response: DataResponse<TagContentResponse>) in
                
                
                if let error = response.error, let data = response.data {
                    log.error("❌ Failed to fetch tags: \(error)")
                    return completionHandler(response.value, MaverickError.apiServiceRequestFailed(reason: .dataError(data: data, error: error)))
                }
                
                completionHandler(response.value, nil)
                
        }
        
    }

}
