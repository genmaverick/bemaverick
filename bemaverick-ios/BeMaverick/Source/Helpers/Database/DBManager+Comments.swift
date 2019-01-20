//
//  DBManager+Content.swift
//  BeMaverick
//
//  Created by Garrett Fritz on 2/14/18.
//  Copyright © 2018 BeMaverick. All rights reserved.
//

import Foundation
import RealmSwift

extension DBManager {
    
    
    func deleteComment(byId id : String) {
        
        attemptLoggedInDBWrite {
            loggedInUserDataBase.delete(getComment(byId: id))
        }
        
        
    }
    
    
    func getComment(byId commentId: String) -> Comment {
        
        if let comment = loggedInUserDataBase.object(ofType: Comment.self, forPrimaryKey: commentId) {
            
            return comment
            
        } else {
            
            
            let comment = Comment(id: commentId)
            
            attemptLoggedInDBWrite {
                
                loggedInUserDataBase.add(comment, update: true)
            }
            
            return comment
            
        }
        
    }
    
    
    func addComment(contentType : Constants.ContentType, contentId : String, comments : [Comment]) {
        
        attemptLoggedInDBWrite {
            
            switch contentType {
                
            case .challenge:
                let challenge = getChallenge(byId: contentId)
                let commentsToAdd = addCommentsToRealm(comments: comments)
                if challenge.commentDescriptor == nil  {
                    challenge.commentDescriptor = CommentDescriptor()
                }
                challenge.commentDescriptor?.peekedComments.insert(contentsOf: commentsToAdd, at: 0)
                challenge.comments.append(objectsIn: commentsToAdd)
                
            case .response:
                let response = getResponse(byId: contentId)
                let commentsToAdd = addCommentsToRealm(comments: comments)
                if response.commentDescriptor == nil  {
                    response.commentDescriptor = CommentDescriptor()
                }
                response.commentDescriptor?.peekedComments.insert(contentsOf: commentsToAdd, at: 0)
                response.comments.append(objectsIn: commentsToAdd)
                
            }
        }
        
    }
    func setComments(contentType : Constants.ContentType, contentId : String, comments : [Comment], clearPreviousResults: Bool = true ) {
        
        attemptLoggedInDBWrite {
            
            switch contentType {
                
            case .challenge:
                let challenge = getChallenge(byId: contentId)
                let commentsToAdd = addCommentsToRealm(comments: comments)
                
                if clearPreviousResults {
                    challenge.comments.removeAll()
                }
                
                challenge.comments.insert(contentsOf: commentsToAdd, at: 0)
                
            case .response:
                let response = getResponse(byId: contentId)
                let commentsToAdd = addCommentsToRealm(comments: comments)
                
                if clearPreviousResults {
                    response.comments.removeAll()
                }
                
                response.comments.insert(contentsOf: commentsToAdd, at: 0)
                
            }
        }
    }
    
    func addCommentsToRealm(comments : [Comment]) -> List<Comment> {
        
        let maverickComments = List<Comment>()
        var userDictionary : [String : User] = [:]
        let blockedUsers = getBlockedUsers()
        attemptLoggedInDBWrite {
            
            for commentToAdd in comments {
                
                
                if let userId = commentToAdd.userId, let userData = commentToAdd.userData {
                    
                    if  blockedUsers.contains( getUser(byId: userId) ) {
                        continue
                    }
                    
                    let maverickComment = getComment(byId: commentToAdd._id)
                    maverickComment.updateBasicData(commentToAdd)
                    let user = getUser(byId: userId)
                    
                    if user.profileImage == nil, let imageData = maverickComment.userImageData {
                        
                        let image = processImages(images: [imageData])
                        user.profileImage = image[imageData.imageId]
                        
                    }
                    
                    if user.username == nil {
                        
                        user.updateBasicUserData(userData)
                        
                    }
                    if !user.createdComments.contains(maverickComment) {
                        
                        user.createdComments.append(maverickComment)
                        
                    }
                    userDictionary[userId] = user
                    
                    maverickComments.append(maverickComment)
                    
                }
                
            }
            
        }
        
        return maverickComments
        
    }
    
}
