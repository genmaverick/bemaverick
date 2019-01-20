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
     Fetches the challenge details for the given id
     
     - parameter completionHandler: The closure called upon completion with the response data
     - parameter completionHandler: The closure called upon completion with the response data
     */
    func getComments(contentType : Constants.ContentType, contentId : String,  count: Int = 30,
                     offset: Int = 0, completionHandler: @escaping CommentListClosure) {
        
        log.verbose("📥 Fetching comments for \(contentType) \(contentId)")
        
        Alamofire.request(CommentRouter.getComments(contentType: contentType, contentId: contentId, count: count, offset: offset))
            .validate()
            .responseObject { (response: DataResponse<CommentResponse>) in
                
                if let error = response.error, let data = response.data {
                    log.error("❌ Fetching comments for \(contentType) \(contentId): \(error)")
                    return completionHandler(response.value, MaverickError.apiServiceRequestFailed(reason: .dataError(data: data, error: error)))
                }
                
                completionHandler(response.value, nil)
                
        }
        
    }
    
    
   
    /**
     Retrieves the response for a given id
     
     - parameter id:        The id of a response to fetch
     
     
     */
    open func addComment(contentType : Constants.ContentType, contentId : String, message : String, completionHandler: @escaping CommentListClosure) {
        
        log.verbose("📥 addComment for \(contentType) \(contentId)")
        
        Alamofire.request(CommentRouter.sendComment(contentType: contentType, contentId: contentId, message: message))
            .validate()
            .responseObject { (response: DataResponse<CommentResponse>) in
                
                if let _ = response.error, let _ = response.data {
                    
                    Alamofire.request(CommentRouter.sendComment(contentType: contentType, contentId: contentId, message: message))
                        .validate()
                        .responseObject { (response: DataResponse<CommentResponse>) in
                            
                            if let error = response.error, let data = response.data {
                            
                                log.error("❌ Failed to addComment for \(contentType) \(contentId): \(error)")
                                completionHandler(response.value, MaverickError.apiServiceRequestFailed(reason: .dataError(data: data, error: error)))
                                return
                            
                            }
                            
                            completionHandler(response.value, nil)
                    
                    }
                    
                    return
                
                }
                
                completionHandler(response.value, nil)
                
        }
        
    }
    
    /**
     flags a comment with reason
     
     - parameter id:        The id of a comment to flag
     - parameter reason:     The reason for flagging
     */
    open func flagComment(id : String, reason : String, completionHandler: @escaping CommentListClosure) {
        
        log.verbose("📥 flag comment  \(id) : \(reason)")
        
        Alamofire.request(CommentRouter.flagComment(id: id, reason: reason))
            .validate().response(completionHandler: { (response) in
                if let error = response.error {
                    log.error("❌ Failed to flag comment  \(id): \(error)")
                }
                
                completionHandler(nil, nil)
            })
        
        
    }
    
    
    /**
     deletes a comment
     
     - parameter id:        The id of a comment to delete
     
     
     */
    open func deleteComment(id : String, completionHandler: @escaping CommentListClosure) {
    
        log.verbose("📥 delete comment  \(id)")
        
        Alamofire.request(CommentRouter.deleteComment(id: id))
            .validate()
            .response { (response) in
                
                if let error = response.error {
                    log.error("❌ Failed to delete comment  \(id): \(error)")
                }
                
                completionHandler(nil, nil)
                
        }
        
    }
    
   
    
}
