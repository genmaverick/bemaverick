//
//  ProfileHeader.swift
//  Maverick
//
//  Created by Garrett Fritz on 3/4/18.
//  Copyright © 2018 BeMaverick. All rights reserved.
//

import Foundation

protocol ProfileHeaderDelegate : class {
    
    func didTapSettingsButton()
    func didTapOverflowButton()
    func didTapShareButton()
    func didTapBackButton()
    func didTapEditProfile()
    func didTapQRButton()
    func didTapFollowerButton()
    func didTapFollowingButton()
    func didTapFollowButton(isFollowing : Bool)
    func didTapBadgeButton(badge : MBadge)
    
}

class ProfileHeader : UICollectionViewCell {
    
    @IBOutlet weak var levelContainer: UIView!
    @IBOutlet weak var levelCounter: UILabel!
    @IBOutlet weak var qrButton: UIButton!
    /// overflow button
    @IBOutlet weak var overflowButton: UIButton!
    /// view width, set to screen width
    @IBOutlet var actionStackView: UIStackView!
    /// view width, set to screen width
    @IBOutlet var coverWidthConstraint: NSLayoutConstraint!
    /// profile cover height
    @IBOutlet weak var coverHeightConstraint: NSLayoutConstraint!
    /// back button
    @IBOutlet weak var backButton: UIButton!
    /// user profile cover image view
    @IBOutlet weak var coverImage: UIImageView!
    /// user bio container - add shadow to this
    @IBOutlet weak var descriptionContainer: UIView!
    
    /// save button, only on logged in user profile
    @IBOutlet weak var settingsButton: UIButton?
    /// share button, only on logged in user profile
    @IBOutlet weak var shareButton: UIButton?
    
    /// users' following list
    @IBOutlet weak var followingButton: UIButton!
    /// users' followers list
    @IBOutlet weak var followerButton: UIButton!
    /// Users 'flashy title' not yet implemented
    @IBOutlet weak var firstAndLastNameLabel: UILabel!
    /// Users username
    @IBOutlet weak var usernameLabel: BadgeLabel!
    /// Users avatar
    @IBOutlet weak var avatarImageView: UIImageView!
    /// user bio label
    @IBOutlet var profileDescriptionLabel: MaverickActiveLabel!
    /// edit avatar button
    @IBOutlet weak var editProfileButton: UIButton!
    /// follow button
    @IBOutlet weak var followButton: UIButton?
    
    
    
    /**
     Edit avatar tapped
     */
    @IBAction func editProfileTapped(_ sender: Any) {
        
        delegate?.didTapEditProfile()
        
    }
    
    @IBAction func followButtonTapped(_ sender: Any) {
        
        guard let followButton = followButton else { return }
        
        followButton.isSelected = !followButton.isSelected
        delegate?.didTapFollowButton(isFollowing: followButton.isSelected)
        
    }
    
    /**
     Back Button tapped
     */
    @IBAction func backButtonTapped(_ sender: Any) {
        
        delegate?.didTapBackButton()
        
    }
    
    /**
     Settings Button tapped
     */
    @IBAction func settingsTapped(_ sender: Any) {
        
        delegate?.didTapSettingsButton()
        
    }
    
    
    
    @IBAction func qrButtonTapped(_ sender: Any) {
        
        delegate?.didTapQRButton()
        
    }
    
    
    
    /**
     Followers list Button tapped
     */
    @IBAction func followersTapped(_ sender: Any) {
        
        delegate?.didTapFollowerButton()
        
    }
    
    /**
     Following List Button tapped
     */
    @IBAction func followingTapped(_ sender: Any) {
        
        delegate?.didTapFollowingButton()
        
    }
    
    /**
     Share Button tapped
     */
    @IBAction func overflowButtonTapped(_ sender: Any) {
        
        delegate?.didTapOverflowButton()
        
    }
    
    @IBAction func shareButtonTapped(_ sender: UIButton) {
        
        delegate?.didTapShareButton()
        
    }
    
    
    /// tap delegate
    weak var delegate : ProfileHeaderDelegate?
    
    weak var labelDelegate : MaverickActiveLabelDelegate? {
        
        didSet {
            
            profileDescriptionLabel.maverickDelegate = labelDelegate
            
        }
        
    }
    /// user to display
    private var user : User?
    private var isLoggedInUser = false
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        contentView.backgroundColor = UIColor.MaverickProfilePowerBackgroundColor
        avatarImageView.layer.cornerRadius = avatarImageView.frame.height / 2
        avatarImageView.layer.borderWidth = 1
        avatarImageView.layer.borderColor = UIColor.white.cgColor
        avatarImageView.layer.masksToBounds = true
        avatarImageView.clipsToBounds = true
        coverWidthConstraint.constant = Constants.MaxContentScreenWidth
        coverHeightConstraint.constant = Variables.Profile.profileCoverHeight.cgFloatValue()
        usernameLabel.textColor = .white
        firstAndLastNameLabel.textColor = .white
        profileDescriptionLabel.textColor = UIColor.MaverickDarkSecondaryTextColor
        followerButton.setTitleColor(UIColor.MaverickPrimaryColor, for: .normal)
        followingButton.setTitleColor(UIColor.MaverickPrimaryColor, for: .normal)
        firstAndLastNameLabel.addShadow()
        usernameLabel.addShadow()
        settingsButton?.addShadow()
        editProfileButton?.addShadow()
        qrButton?.addShadow()
        overflowButton?.addShadow()
        shareButton?.addShadow()
        if let container = avatarImageView.superview {
            
            container.addShadow()
            container.layer.shadowPath = UIBezierPath(roundedRect: container.bounds, cornerRadius: container.frame.height).cgPath
            
        }
        
    }
    
    func clear() {
        
        avatarImageView.image = nil
        coverImage?.image = nil
        usernameLabel.text = ""
        profileDescriptionLabel.text = ""
        firstAndLastNameLabel.text = ""
        
    }
    /**
     Setup view to show given user
     */
    func configure(withUser user: User, hideBackButton : Bool, userMode : ProfileUserMode, isFollowing : Bool, isLoggedInUser : Bool) {
        
        self.user = user
        self.isLoggedInUser = isLoggedInUser
        backButton.isHidden = hideBackButton
        
        
        if let path = user.profileCover?.getUrlForSize(size: coverImage.frame), let url = URL(string: path) {
            
            if let tint = user.profileCoverTint {
                
                coverImage.backgroundColor = UIColor(rgba: tint)
                
            } else {
                
                coverImage.backgroundColor = UIColor.MaverickDarkSecondaryTextColor
                
            }
            
            coverImage.kf.setImage(with: url, placeholder: R.image.defaultCover(), options: [.transition(.fade(UIImage.fadeInTime))], progressBlock: nil, completionHandler: nil)
            
        }
        
        if let path = user.profileImage?.getUrlForSize(size: avatarImageView.frame), let url = URL(string: path) {
            
            avatarImageView.kf.setImage(with: url, placeholder: R.image.defaultMaverickAvatar(), options: [.transition(.fade(UIImage.fadeInTime))], progressBlock: nil, completionHandler: nil)
            
        } else {
            
            avatarImageView.image = R.image.defaultMaverickAvatar()
            
        }
        
        usernameLabel.image = user.isVerified ? R.image.verified() : nil
        usernameLabel.text = user.username
        
        let firstname = user.firstName ?? ""
        let lastname = user.lastName ?? ""
        firstAndLastNameLabel.text = "\(firstname) \(lastname)"
        
        if let bio = user.bio, !bio.isEmpty {
            
            profileDescriptionLabel.text = user.bio
            profileDescriptionLabel.isHidden = false
            
        } else {
            
            profileDescriptionLabel.isHidden = true
            
        }
        
        followerButton.setTitle(R.string.maverickStrings.followers(), for: .normal)
        followingButton.setTitle(R.string.maverickStrings.following(), for: .normal)
        actionStackView.isHidden = !isLoggedInUser
        overflowButton.isHidden = isLoggedInUser || user.userType == .mentor
        
        if isLoggedInUser {
            
            followButton?.isHidden = true
            
            if var followerNumber = user.stats?.numFollowerUsers {
                
                
                if followerNumber < 0 {
                    
                    followerNumber = 0
                    
                }
                
                followerButton.setTitle(R.string.maverickStrings.selfFollowers(followerNumber), for: .normal)
                followerButton.isEnabled = followerNumber > 0
                
            }
            
            if var followingNumber = user.stats?.numFollowingUsers {
                
                if followingNumber < 0 {
                    
                    followingNumber = 0
                    
                }
                
                followingButton.setTitle(R.string.maverickStrings.selfFollowing(followingNumber), for: .normal)
                followingButton.isEnabled = followingNumber > 0
                
            }
            
        } 
        
        followButton?.isSelected = isFollowing
        
        levelContainer.isHidden = false
        
        if let levelNum = user.progression?.currentLevel?.levelNumber {
            
            levelCounter.text = "\(levelNum)"
            
        } else if user.currentLevelNumber > 0 {
           
            levelCounter.text = "\(user.currentLevelNumber)"
        
        } else {
            
          levelContainer.isHidden = true
            
        }
        
        
    }
    
}

extension ProfileHeader :  TwoSectionStreamCollectionViewControllerHeaderDelegate {
    
    func getFrame() -> CGRect {
        
        return frame
        
    }
    
    func preferredLayoutSizeFittingSize(targetSize:CGSize) -> CGSize {
        
        let originalFrame = self.frame
        var frame = self.frame
        frame.size = targetSize
        self.frame = frame
        
        self.setNeedsLayout()
        self.layoutIfNeeded()
        let computedSize = self.systemLayoutSizeFitting(UILayoutFittingCompressedSize)
        let newSize = CGSize(width:targetSize.width,height:computedSize.height)
        
        self.frame = originalFrame
        
        return newSize
        
    }
    
}

