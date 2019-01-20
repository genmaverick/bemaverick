//
//  MaverickActiveLabel.swift
//  Maverick
//
//  Created by Garrett Fritz on 5/4/18.
//  Copyright © 2018 BeMaverick. All rights reserved.
//

import Foundation
import ActiveLabel

protocol MaverickActiveLabelDelegate : class {
    
    func userTapped(user : User)
    func hashtagTapped(tag : Hashtag)
    func linkTapped(url : URL)
    
}


class MaverickActiveLabel : ActiveLabel {
    
    weak var maverickDelegate : MaverickActiveLabelDelegate?
    var mentions : [Mention] = []
    var customType = ActiveType.custom(pattern: "(^[^ ]+)")
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        customColor[customType] = UIColor(rgba: "#303030ff")
        customSelectedColor[customType] = UIColor(rgba: "#303030ff")
        
        enabledTypes = [.mention, .hashtag, .url, customType]
        hashtagColor = UIColor.MaverickPrimaryColor
        mentionColor = UIColor.MaverickPrimaryColor
        URLColor = UIColor.MaverickUnstoppable
        urlMaximumLength = 20
        handleHashtagTap { [weak self] hashtag in
            
            self?.maverickDelegate?.hashtagTapped(tag: Hashtag(tagName : hashtag))
            
        }
       
        handleMentionTap {[weak self] username in
           
            if let userId = self?.getUserId(fromName: username) {
            
                let user = DBManager.sharedInstance.getUser(byId: userId)
                self?.maverickDelegate?.userTapped(user: user)
            
            }
                
        }
        
        handleURLTap {[weak self] url in
            
              if UIApplication.shared.canOpenURL(url) {
            
                self?.maverickDelegate?.linkTapped(url: url)
            
            }
        
        }
        
        filterMention {[weak self] (mentionName) -> Bool in
            
            return self?.getUserId(fromName: mentionName) != nil
            
        }
        
        handleCustomTap(for: customType) { [weak self] username in
            
            if let userId = self?.getUserId(fromName: username) {
                
                let user = DBManager.sharedInstance.getUser(byId: userId)
                self?.maverickDelegate?.userTapped(user: user)
                
            }
            
        }
        
        configureLinkAttribute = {[weak self] (type, attributes, isSelected) in
            
            guard let custom = self?.customType else { return attributes }
            var atts = attributes
            switch type {
                
            case .mention:
                  atts[NSAttributedStringKey.font] = R.font.openSansRegular(size: 13.0)
                
            case .hashtag:
                 atts[NSAttributedStringKey.font] = R.font.openSansRegular(size: 13.0)
                
            case custom:
                atts[NSAttributedStringKey.font] = R.font.openSansBold(size: 13.0)
                
            default:
                atts[NSAttributedStringKey.font] = R.font.openSansRegular(size: 13.0)
            
            }
            
            return atts
        }
        
    }
    
    private func getUserId(fromName username : String) -> String? {
        
        for mention in mentions {
            
            if username == mention.username {
               
                return mention.userId
                
            }
            
        }
        // fallback to searching db for user
        return DBManager.sharedInstance.getUser(byUsername: username)?.userId
        
    }

}
