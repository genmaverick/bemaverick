//
//  EmptyView.swift
//  Maverick
//
//  Created by Garrett Fritz on 3/8/18.
//  Copyright © 2018 BeMaverick. All rights reserved.
//

import Foundation


class EmptyView : UIView {
    /// Parent view
    @IBOutlet weak var view: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var topLabel: UILabel!
    @IBOutlet weak var bottomLabel: UILabel!
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    @IBOutlet weak var widthConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var imageContainerView: UIView!
    
    @IBOutlet weak var rightImage: UIImageView!
    @IBOutlet weak var leftImage: UIImageView!
    @IBOutlet weak var largeImage: UIImageView!
    
    
    override func awakeFromNib() {
       
        super.awakeFromNib()
        widthConstraint.constant = Constants.MaxContentScreenWidth
        heightConstraint.constant = Variables.Content.emptyViewHeight.cgFloatValue()
        imageContainerView.isHidden = true
        
    }
    
    private func setBadgeData(badge: MBadge? = nil, isLoggedInUser : Bool) {
        
        guard let badge = badge else { return }
        
        BadgerView.setBadgeImage(badge: badge, primary: true, imageView: largeImage)
        BadgerView.setBadgeImage(badge: badge, primary: false, imageView: leftImage)
        BadgerView.setBadgeImage(badge: badge, primary: false, imageView: rightImage)
        imageContainerView.isHidden = false
        
        if let badgeName = badge.name {
        
            topLabel.text = isLoggedInUser ? R.string.maverickStrings.badgeBagSelfEmptyTitle() : R.string.maverickStrings.badgeBagOtherUserEmptyTitle()
            bottomLabel.text = isLoggedInUser  ? R.string.maverickStrings.badgeBagSelfEmptySubTitle(badgeName) : R.string.maverickStrings.badgeBagOtherUserEmptySubTitle(badgeName)
            
        } else {
            
            topLabel.text = isLoggedInUser ? R.string.maverickStrings.badgeBagSelfAllEmptyTitle() : R.string.maverickStrings.badgeBagOtherAllEmptyTitle()
            bottomLabel.text = isLoggedInUser  ? R.string.maverickStrings.badgeBagSelfAllEmptySubTitle() : R.string.maverickStrings.badgeBagOtherAllEmptySubTitle()
             imageContainerView.isHidden = true
        }
        
    }
    
    func configure(title: String? = nil, subtitle : String? = nil, dark : Bool, withBadge badge: MBadge? = nil, isLink : Bool = false, isLoggedInUser : Bool = false, emptySaved : Bool = false) {
        
        topLabel.text = title
        bottomLabel.text = subtitle
       
        topLabel.textColor = dark ? .white : UIColor.MaverickDarkTextColor
        bottomLabel.textColor = dark ? .white : UIColor.MaverickDarkTextColor
         imageView.alpha = dark ? 0.15 : 0.05
        imageView.tintColor = dark ? .white : .black
        
        setBadgeData(badge: badge, isLoggedInUser : isLoggedInUser)
        
        if isLink {
            
            bottomLabel.textColor = UIColor.MaverickPrimaryColor
        
        }
        
        if emptySaved {
            
            configureEmptySavedChallenges()
            
        }
        
    }
    
    private func configureEmptySavedChallenges() {
        
        imageContainerView.isHidden = false
        largeImage.image = R.image.saved()
        
        leftImage.image = R.image.nav_challenges()
        leftImage.tintColor = UIColor.MaverickPrimaryColor
        rightImage.image = R.image.nav_challenges()
        rightImage.tintColor = UIColor.MaverickPrimaryColor
        
    }
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        setup()
        
    }
    
    required init?(coder: NSCoder) {
        
        super.init(coder: coder)
        setup()
        
    }
    
    func setup() {
        
        view = instanceFromNib()
        addSubview(view)
        view.frame = self.bounds
        view.backgroundColor = UIColor.clear
        
    }
    
    func instanceFromNib() -> UIView {
        return R.nib.emptyView.firstView(owner: self)!
    }
    
}

