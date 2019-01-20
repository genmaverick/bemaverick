//
//  FollowCustomActionSheetItem.swift
//  Maverick
//
//  Created by Chris Garvey on 5/10/18.
//  Copyright © 2018 BeMaverick. All rights reserved.
//

import Foundation

class FollowCustomActionSheetItem: UIView, CustomMaverickActionSheetItem {
    
    // MARK: - Private Properties
    
    /// The services container.
    private weak var services: GlobalServicesContainer!
    
    /// The user that will be followed
    private var user: User?
    private var isFollowing = false
    
    // MARK: - IBActions
    
    /// The button that follows a user.
    @IBAction func didPressFollowButton(_ sender: CTAButton) {
        
        
        guard let user = user else { return }
        if !isFollowing {
            isFollowing = true
            if let vc = parentViewControllerForSelf {
                
                AnalyticsManager.Profile.trackFollowTapped(userId: user.userId, isFollowing: true, location: vc)
            
            }
        }
        services.apiService.followUser(withId: user.userId) { _,_ in
            self.updateButtonToBeFollowing()
        }
        
    }
    
    
    // MARK: - IBOutlets
    /// Main stack view containing top portion of action sheet
    @IBOutlet weak var mainStackViewContainer: UIStackView!
    /// Activity indicator
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    /// The username for the user that will be followed
    @IBOutlet weak var username: UILabel!
    /// The fullname for the user that will be followed
    @IBOutlet weak var fullName: UILabel!
    /// The bio for the user that will be followed
    @IBOutlet weak var bio: UILabel!
    /// The profile picture for the user that will be followed
    @IBOutlet weak var avatarImageView: UIImageView!
    /// The follow button
    @IBOutlet weak var followButton: CTAButton!
    /// Leading constraint for the user info section
    @IBOutlet weak var userInfoLeadingConstraint: NSLayoutConstraint!
    /// Leading constraint for the bio info section
    @IBOutlet weak var bioLeadingConstraint: NSLayoutConstraint!
    /// Leading constraint for the button
    @IBOutlet weak var buttonLeadingConstraint: NSLayoutConstraint!
    /// Trailing constraint for the user info section
    @IBOutlet weak var userInfoTrailingConstraint: NSLayoutConstraint!
    /// Trailing constraint for the bio info section
    @IBOutlet weak var bioTrailingConstraint: NSLayoutConstraint!
    /// Trailing constraint for the button 
    @IBOutlet weak var buttonTrailingConstraint: NSLayoutConstraint!
    /// Leading constraint for the activity indicator
    @IBOutlet weak var activityIndicatorLeadingConstraint: NSLayoutConstraint!
    
    // MARK: - Life Cycle
    
    required init(services: GlobalServicesContainer, user: User?, width: CGFloat) {
        super.init(frame: CGRect(x: 16, y: 58, width: (width - 32), height: 300))
        
        self.services = services
        self.user = user
        
        let view = loadFromNib()
        addSubview(view)
        
        setup()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Public Functions
    /**
     Configures the user once it is returned to the action sheet.
     - parameter user: The user to be configured.
     */
    public func configure(withUser user: User) {
      
        self.user = user
         setup()
        
    }
    
    /**
     Required for CustomMaverickActionSheetItem protocol: Returns the MaverickActionSheetItemType of the object.
     */
    public func myType() -> MaverickActionSheetItemType {
        return .customView
    }
    
    /**
     Required for CustomMaverickActionSheetItem protocol: Returns the height that should be used for the custom view in the xib.
     */
    public func myHeight() -> Double {
        return 300.0
    }
    
    /**
     Dismiss the action sheet through the action sheet's parent view controller
     */
    public func dismissActionSheet() {
        parentViewControllerForSelf?.dismiss(animated: true, completion: nil)
    }
    
    
    // MARK: - Private Functions
    
    /**
     Loads the associated nib for the view.
     */
    private func loadFromNib<T: UIView>() -> T {
        
        let selfType = type(of: self)
        let bundle = Bundle(for: selfType)
        let nibName = String(describing: selfType)
        let nib = UINib(nibName: nibName, bundle: bundle)
        
        guard let view = nib.instantiate(withOwner: self, options: nil).first as? T else {
            fatalError("Error loading nib with name \(nibName)")
        }
        
        return view
        
    }
    
    /**
     Performs additional setup of the view.
     */
    private func setup() {
        
        guard let user = user else {
            
            activityIndicatorLeadingConstraint.constant = ( (UIScreen.main.bounds.width / 2) - activityIndicator.bounds.width )

            activityIndicator.startAnimating()
        
            mainStackViewContainer.isHidden = true
            followButton.isHidden = true
            bio.isHidden = true
            return
            
        }
        
        
        activityIndicator.stopAnimating()
        
        mainStackViewContainer.isHidden = false
        followButton.isHidden = false
        bio.isHidden = false
        
        followButton.setTitle("FOLLOW", for: .normal)
        followButton.backgroundColor = UIColor.MaverickPrimaryColor
        followButton.setTitleColor(.white, for: .normal)
        
        if services.globalModelsCoordinator.isFollowingUser(userId: user.userId) {
            followButton.setTitle("ALREADY FOLLOWING", for: .normal)
            followButton.isEnabled = false
            isFollowing = true
        } else if services.globalModelsCoordinator.loggedInUser == user {
            followButton.setTitle("THIS IS YOU!", for: .normal)
            followButton.isEnabled = false
            isFollowing = true
        }
        
        username.text = user.username

        let userFullName = user.getFullName()
        if userFullName == "" {
            fullName.isHidden = true
        } else {
            fullName.text = userFullName
        }
        
        if let userBio = user.bio {
            bio.text = userBio
        } else {
            bio.text = ""
        }

        avatarImageView.layer.cornerRadius = avatarImageView.frame.height / 2
        avatarImageView.layer.borderWidth = 1
        avatarImageView.layer.borderColor = UIColor.white.cgColor
        avatarImageView.layer.masksToBounds = true
        avatarImageView.clipsToBounds = true
        
        if let container = avatarImageView.superview {
            
            container.addShadow()
            container.layer.shadowPath = UIBezierPath(roundedRect: container.bounds, cornerRadius: container.frame.height).cgPath
            
        }
        
        if let path = user.profileImage?.getUrlForSize(size: avatarImageView.frame), let url = URL(string: path) {
            
            avatarImageView.kf.setImage(with: url, placeholder: R.image.defaultMaverickAvatar(), options: [.transition(.fade(UIImage.fadeInTime))], progressBlock: nil, completionHandler: nil)
            
        } else {
            
            avatarImageView.image = R.image.defaultMaverickAvatar()
            
        }
        
        let leadingConstraints = [userInfoLeadingConstraint, bioLeadingConstraint, buttonLeadingConstraint]
        let trailingConstraints = [userInfoTrailingConstraint, bioTrailingConstraint, buttonTrailingConstraint]
        
        if bounds.width <= 320 {
            
            trailingConstraints.forEach { $0?.constant = 146 }
            
        } else if bounds.width <= 375 {
            
            trailingConstraints.forEach { $0?.constant = 94 }
            
        } else {
            
            leadingConstraints.forEach { $0?.constant *= 2 }
            trailingConstraints.forEach { $0?.constant = 78 }
            
        }
        
        layoutIfNeeded()
        
    }
    
    /**
     Updates the bottom to indicate that the user is now being followed.
     */
    private func updateButtonToBeFollowing() {
        
        followButton.setTitle("FOLLOWING", for: .normal)
        followButton.isEnabled = false
        
    }
    
}
