//
//  HorizontalUserView.swift
//  Maverick
//
//  Created by Garrett Fritz on 2/21/18.
//  Copyright © 2018 BeMaverick. All rights reserved.
//

import Foundation
import Kingfisher

class HorizontalUserView : UICollectionViewCell {
    
    /// Avatar image for user
    @IBOutlet weak var avatarImageView: UIImageView!
    /// Users' username
    @IBOutlet weak var usernameLabel: BadgeLabel!
    
    @IBOutlet weak var selectedButton: UIButton!
    
    // MARK: - Lifecycle
    
    var user : User?
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        usernameLabel.imageOffset = CGPoint(x: 0.0, y: -3.0)
    
    }
    /**
     Configre view with user
     */
    func configureView(with user : User?, selected : Bool? = nil) {
        
        
        self.user = user
        if let user = user {
        
            usernameLabel.image = user.isVerified ? R.image.verified() : nil
            usernameLabel.text = user.username
            avatarImageView.layer.cornerRadius = avatarImageView.frame.height / 2
            avatarImageView.clipsToBounds = true
            avatarImageView.layer.borderWidth = 0
            usernameLabel.numberOfLines = 1
            if let imagePath = user.profileImage?.getUrlForSize(size: avatarImageView.frame), let url = URL(string: imagePath) {
                
                avatarImageView.kf.setImage(with: url, placeholder: R.image.defaultMaverickAvatar(), options: [.transition(.fade(UIImage.fadeInTime))], progressBlock: nil)
                
            } else {
                
                avatarImageView.image = R.image.defaultMaverickAvatar()
                avatarImageView.layer.borderWidth = 2
                avatarImageView.layer.borderColor = UIColor.MaverickSecondaryTextColor.cgColor
                
            }
            
        } else {
            
            avatarImageView.layer.borderWidth = 0
            avatarImageView.image = R.image.searchFriendCTA()
            usernameLabel.text = "Invite More"
            usernameLabel.numberOfLines = 0
       
        }
        
        if let selected = selected {
            
            selectedButton.isHidden = false
            selectedButton.isSelected = selected
            avatarImageView.alpha = selected ? 0.5 : 1.0
            
        } else {
            
            selectedButton.isHidden = true
            
        }
    }
    
    func setSelected(selected : Bool) {
        
         selectedButton.isSelected = selected
         selectedButton.isHidden = false
         avatarImageView.alpha = selected ? 0.5 : 1.0
        
    }
    
}
