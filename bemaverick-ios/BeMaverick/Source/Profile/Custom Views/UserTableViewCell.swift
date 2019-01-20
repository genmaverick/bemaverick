//
//  UserTableViewCell.swift
//  BeMaverick
//
//  Created by David McGraw on 1/22/18.
//  Copyright © 2018 BeMaverick. All rights reserved.
//

import UIKit
import RealmSwift

protocol UserTableViewCellDelegate : class {
    
    func didSelectFollowToggleButton(forUserId  id: String, follow : Bool)
    func didSelectProfileButton(forUserId id: String)
    
}
class UserTableViewCell: UITableViewCell {
    
   
    @IBOutlet weak var verifiedBadgerOverlay: BadgeLabel!
    
    // MARK: - IBOutlets
    /// this is an extra iamge view displayed on the avatar (a badge will go there on badge bag VC)
    @IBOutlet weak var auxiliaryImageView: UIImageView!
    /// An image view associated with the user
    @IBOutlet weak var userImageView: UIImageView!
    /// The comment contents
    @IBOutlet weak var commentLabel: MaverickActiveLabel!
    /// The timestamp of the comment
    @IBOutlet weak var timeLabel: UILabel!
    /// The followButton
    @IBOutlet weak var followButton: UIButton!
    /// width constraint to hide/show follow button
    @IBOutlet weak var followButtonWidth: NSLayoutConstraint!
    /// main tap area
    @IBOutlet weak var mainButton: UIButton!
    /// varied to show/hide auxiliary image view
    @IBOutlet weak var avatarLeadingConstraint: NSLayoutConstraint!
    
    @IBOutlet var singleLineConstraint: NSLayoutConstraint!
    /**
     follow button tapped
    */
    @IBAction func followButtonTapped(_ sender: Any) {
        
        followButton.isSelected = !oneWayButton ? !followButton.isSelected : true
        guard let userId = userId else { return }
        delegate?.didSelectFollowToggleButton(forUserId: userId, follow: followButton.isSelected)
        
    }
    
    @IBAction func avatarTapped(_ sender: Any) {
        
        guard let userId = userId else { return }
        delegate?.didSelectProfileButton(forUserId: userId)
        
    }
    
    /**
     Main button tapped
     */
    @IBAction func mainButtonTapped(_ sender: Any) {
        guard let userId = userId else { return }
        delegate?.didSelectProfileButton(forUserId: userId)
    }
    
    /// user id to be displayed
    private var userId : String?
    var oneWayButton = false
    weak var delegate : UserTableViewCellDelegate?
    weak var labelDelegate : MaverickActiveLabelDelegate? {
        
        didSet {
        
            commentLabel.maverickDelegate = labelDelegate
            mainButton.isEnabled = false
            
        }
        
    }
    
    override func prepareForReuse() {
        
        super.prepareForReuse()
        singleLineConstraint.isActive = false
        userImageView.image = R.image.defaultMaverickAvatar()
        
    }
    
    override func awakeFromNib() {
    
        super.awakeFromNib()
        
        
        verifiedBadgerOverlay.imageOffset = CGPoint(x: 0.0, y: -2.5)
        selectionStyle = .none
        verifiedBadgerOverlay.textColor = UIColor.clear
        userImageView.layer.cornerRadius = userImageView.frame.height / 2
        userImageView.clipsToBounds = true
        userImageView.layer.borderWidth = 0.5
        userImageView.layer.borderColor = UIColor.MaverickSecondaryTextColor.cgColor
        followButtonWidth.constant = 0
        
        followButton.setTitle(R.string.maverickStrings.follow(), for: .normal)
        followButton.setTitle(R.string.maverickStrings.unFollow(), for: .selected)
        
        followButton.setTitleColor(UIColor.MaverickDarkSecondaryTextColor, for: .selected)
        followButton.setTitleColor(UIColor.MaverickPrimaryColor, for: .normal)

        auxiliaryImageView.isHidden = true
    
        backgroundColor = .clear
    }
    
    func forceButtonAlwaysOn( ) {
        
        followButton.setTitleColor(UIColor.MaverickPrimaryColor, for: .selected)
        followButton.setTitleColor(UIColor.MaverickPrimaryColor, for: .normal)

        
    }
   
    func overrideButtonTitles(selected : String, unselected : String) {
        
        followButton.setTitle(unselected, for: .normal)
        followButton.setTitle(selected, for: .selected)
        
    }
  
    open func setMentionData(mentions : [Mention]) {
        
       commentLabel.mentions = mentions
        
    }
    /**
     Configure the comment cell using a Twilio message object
     */
    open func configure(withUsername username: String? = nil, userId : String? = nil, content: String? = nil, sublabel: String? = nil, date: Date? = nil, avatar: MaverickMedia? = nil, avatarURL: String? = nil, avatarImage: UIImage? = nil, isFollowing : Bool? = nil, showVerifiedBadge : Bool = false) {
        
        
        
        self.userId = userId
        if let imagePath = avatar?.getUrlForSize(size: userImageView.frame), let url = URL(string: imagePath) {
            userImageView.kf.setImage(with: url, placeholder: R.image.defaultMaverickAvatar(), options: [.transition(.fade(UIImage.fadeInTime))])
        } else if let imagePath = avatarURL, let url = URL(string: imagePath) {
            userImageView.kf.setImage(with: url, placeholder: R.image.defaultMaverickAvatar(), options: [.transition(.fade(UIImage.fadeInTime))])
        } else if let avatarImage = avatarImage {
            userImageView.image = avatarImage
        } else {
            userImageView.image = R.image.defaultMaverickAvatar()
        }
        
        // Set body content
        let author = username ?? ""
        let body = content ?? ""
        
        verifiedBadgerOverlay.image = showVerifiedBadge ? R.image.verified() : nil
        let spacer = showVerifiedBadge ? "     " : " "
        commentLabel.text = "\(author) \(spacer)\(body)"
        verifiedBadgerOverlay.setAsOverlay(first: author, last: body)
        
        if commentLabel.numberOfVisibleLines == 1 {
            
            singleLineConstraint.isActive = true
        
        } else {
            
            singleLineConstraint.isActive = false
            
        }
        
        // Update timestamp
        if let date = date {
            
            let comps = Calendar.current.dateComponents([.month, .day, .hour, .minute, .second], from: date, to: Date())
            timeLabel.text = comps.timeRemainingForComment()
            timeLabel.isHidden = false
            
        } else {
         
            if sublabel != nil {
                
                timeLabel.isHidden = false
            
            }
            timeLabel.text = sublabel
            
        
        }
        
        timeLabel.textColor = UIColor.MaverickDarkSecondaryTextColor
        
        if let isFollowing = isFollowing {
           
            followButtonWidth.constant = 100
            followButton.isSelected = isFollowing
            mainButton.isUserInteractionEnabled = true
            followButton.isUserInteractionEnabled = true
            
        }
        
    }
    
    /**
     add extra image on the avatar (badge)
    */
    func addAuxiliaryImage(auxImage: MBadge?) {
        
        guard let auxImage = auxImage else {
            auxiliaryImageView.isHidden = true
            return
        }
        
        avatarLeadingConstraint.constant = 18
        BadgerView.setBadgeImage(badge: auxImage, primary:false, imageView: auxiliaryImageView)
        
        auxiliaryImageView.contentMode = .scaleAspectFit
        auxiliaryImageView.isHidden = false
    
    }

}


