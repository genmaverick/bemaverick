//
//  ShareHelper.swift
//  Maverick
//
//  Created by Garrett Fritz on 2/20/18.
//  Copyright © 2018 BeMaverick. All rights reserved.
//

import Foundation
import Branch

class ShareHelper {
    
    /**
     Create a share link for a user item
     */
    static func shareUser(user: User) -> BranchUniversalObject? {
       
        var branchUniversalObject: BranchUniversalObject? = nil
        if let username = user.username {
        
            branchUniversalObject = BranchUniversalObject(canonicalIdentifier: "share/user/\(user.userId)")
            
            
            branchUniversalObject?.title = username
            branchUniversalObject?.contentDescription = R.string.maverickStrings.shareOtherUser(username)
            branchUniversalObject?.imageUrl = user.profileImage?.URLOriginal
            branchUniversalObject?.contentMetadata.customMetadata = [Constants.DeepLink.KEY_TYPE : Constants.DeepLink.LinkType.user.rawValue, Constants.DeepLink.KEY_ID : user.userId]
            
        }
      
        return branchUniversalObject
    }
    
    
    /**
     Create a share link for a user item
     */
    static func shareResponse(response : Response) -> BranchUniversalObject? {
        
        var branchUniversalObject: BranchUniversalObject? = nil
        
            
        branchUniversalObject = BranchUniversalObject(canonicalIdentifier: "share/response/\(response.responseId)")
        if let challengeName = response.challengeOwner.first?.title {
            
            branchUniversalObject?.title = challengeName
            branchUniversalObject?.contentDescription = R.string.maverickStrings.shareResponse(challengeName)
            
        } else {
            
            branchUniversalObject?.title = response.getCreator()?.username ?? "Maverick"
            branchUniversalObject?.contentDescription = R.string.maverickStrings.shareContent(response.getCreator()?.username ?? "a Maverick")
            
        }
        
        branchUniversalObject?.imageUrl = response.imageMedia?.URLOriginal
            branchUniversalObject?.contentMetadata.customMetadata = [Constants.DeepLink.KEY_TYPE : Constants.DeepLink.LinkType.response.rawValue, Constants.DeepLink.KEY_ID : response.responseId]
            
        
        
        return branchUniversalObject
        
    }
    
    
    /**
     Create a share link for a challenge item
     */
    static func shareChallenge(challenge : Challenge) -> BranchUniversalObject? {
        
        var branchUniversalObject: BranchUniversalObject? = nil
        let challengeName = challenge.title ?? ""
        
        branchUniversalObject = BranchUniversalObject(canonicalIdentifier: "share/challenge/\(challenge.challengeId)")
        branchUniversalObject?.title = challengeName
        branchUniversalObject?.contentDescription = R.string.maverickStrings.shareChallenge(challengeName)
        branchUniversalObject?.imageUrl = challenge.mainCardMedia?.URLOriginal
        branchUniversalObject?.contentMetadata.customMetadata = [Constants.DeepLink.KEY_TYPE : Constants.DeepLink.LinkType.challenge.rawValue, Constants.DeepLink.KEY_ID : challenge.challengeId]
        
        return branchUniversalObject
    }
    
    
}
