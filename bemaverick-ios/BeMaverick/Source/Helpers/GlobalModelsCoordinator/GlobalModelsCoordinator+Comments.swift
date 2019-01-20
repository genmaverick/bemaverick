//
//  GlobalModelsCoordinator+Responses.swift
//  BeMaverick
//
//  Created by David McGraw on 9/14/17.
//  Copyright © 2017 BeMaverick. All rights reserved.
//

import Foundation
import RealmSwift
import Photos

/**
 Methods responsible for uploading content via the `APIService` instance
 */
extension GlobalModelsCoordinator {
    
 
    /**
     Retrieve the responses for a provided challenge
     */
    open func getComments(contentId id: String, contentType : Constants.ContentType,
                           count: Int = 25,
                           offset: Int = 0,
                            completionHandler: (() -> Void)? = nil) {
        
        apiService.getComments(contentType: contentType, contentId: id, count: count, offset: offset) { response, error in
            
            
            if var data = response?.data {
                data.reverse()
                DBManager.sharedInstance.setComments(contentType: contentType, contentId: id, comments: data, clearPreviousResults: offset == 0)
            }
            
            completionHandler?()
            
        }
        
    }
    
    /**
     Deletes a comment and refreshes the user data
     */
    open func deleteComment(_ id : String, contentType : Constants.ContentType, contentId : String) {
        
        apiService.deleteComment(id: id) { (comment, error) in
            
            //hack to force API to update peek:
            
            if contentType == .response {
                
                _ = self.response(forResponseId: contentId, fetchDetails: true)
                
            } else {
                
                _ = self.challenge(forChallengeId: contentId, fetchDetails: true)
            }
            
        }
        
        DBManager.sharedInstance.deleteComment(byId : id)
      
    }
    
    /**
     Flags a comment and refreshes the user data
     */
    open func flagComment(_ id : String, reason : String, contentType : Constants.ContentType, contentId : String) {
        
        apiService.flagComment(id: id, reason : reason) { (comment, error) in
            
            //hack to force API to update peek:
            
            if contentType == .response {
                
                _ = self.response(forResponseId: contentId, fetchDetails: true)
                
            } else {
                
                _ = self.challenge(forChallengeId: contentId, fetchDetails: true)
            }
            
        }
        
        DBManager.sharedInstance.deleteComment(byId : id)
        
    }
    
    open func addComment(_ message : String, contentId: String, contentType : Constants.ContentType) {
        
        apiService.addComment(contentType: contentType, contentId: contentId, message: message, completionHandler: { (response, error) in
            
            guard let response = response, error == nil, let id = response._id else {
                
                var errorMessage = error?.localizedDescription ?? "Failed to add comment"
                if errorMessage == "" {
                    errorMessage = "Failed to add comment"
                }
                AnalyticsManager.Comments.trackCommentFail(contentType, contentId: contentId, apiFailure: true, reason: errorMessage)
                return
                
            }
            
            let comment = Comment(id: id)
            comment.body = response.body
            comment.contentId = id
            comment.userId = self.loggedInUser?.userId
            comment.created = response.created
            comment.userData = self.loggedInUser
            comment.mentionsArray = response.mentionsArray
            DBManager.sharedInstance.addComment(contentType: contentType, contentId: contentId, comments: [comment])
            
            AnalyticsManager.Comments.trackCommentSuccess(contentType, contentId: contentId)
            if let ids = response.mentionsArray?.compactMap({ $0.userId }) {
                
                AnalyticsManager.Profile.trackMentionSuccess(userIds: ids, contentType: contentType, contentId: contentId, source: Constants.Analytics.Main.Properties.MENTION_LOCATION.comment)
                
            }
            
            //hack to force API to update peek:
            
            if contentType == .response {
               
                _ = self.response(forResponseId: contentId, fetchDetails: true)
            
            } else {
            
                _ = self.challenge(forChallengeId: contentId, fetchDetails: true)
            }
            
            
           
                
                self.getProgression()
                
           
            
        })
        
    }
  
}
