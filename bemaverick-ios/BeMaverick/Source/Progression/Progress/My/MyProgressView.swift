//
//  MyProgressView.swift
//  Maverick
//
//  Created by Garrett Fritz on 9/17/18.
//  Copyright © 2018 BeMaverick. All rights reserved.
//

import Foundation
import Kingfisher

class MyProgressView : UIView {
    
    @IBOutlet weak var avatarImage: UIImageView!
    @IBOutlet weak var levelLabel: UILabel!
    @IBOutlet weak var usernameLabel: BadgeLabel!
    @IBOutlet weak var currentLevelLabel: UILabel!
    @IBOutlet weak var nextLevelLabel: UILabel!
    @IBOutlet weak var fullProgressView: UIView!
    @IBOutlet weak var completedProgressView: UIView!
    @IBOutlet weak var completedProgressWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var seeNextLevelButton: UIButton!
    @IBOutlet weak var seeNextLevelLabel: UILabel!
    /// Parent view
    @IBOutlet weak var view: UIView!
    
    @IBAction func seeNextLevelTapped(_ sender: Any) {
        
        delegate?.levelDetailsTapped()
        
    }
    
    weak var delegate : MyProgressViewControllerDelegate?
    private var progress : CGFloat = 0.0
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
        completedProgressView.layer.cornerRadius = completedProgressView.frame.height / 2
        fullProgressView.layer.cornerRadius = fullProgressView.frame.height / 2
        usernameLabel.imageOffset = CGPoint(x: 0.0, y: -2.0)
        
        avatarImage.layer.cornerRadius = avatarImage.frame.height / 2
        avatarImage.clipsToBounds = true
        avatarImage.layer.borderWidth = 0.5
        avatarImage.layer.borderColor = UIColor(rgba: "D3D3D3ff")?.cgColor
        
    }
    
    func instanceFromNib() -> UIView {
        
        return R.nib.myProgressView.firstView(owner: self)!
        
    }
    //Needed here to update the width constraint of the completed bar relative to parent after cell gets sized appropriately
    override func layoutIfNeeded() {
        
        updateProgress()
        super.layoutIfNeeded()
        
    }
    
    func configure(with user : User) {
        
        view.layoutIfNeeded()
        usernameLabel.text = user.username
        let showBadge = user.isVerified
        usernameLabel.image = showBadge ? R.image.verified() : nil
        
        if let imagePath = user.profileImage?.getUrlForSize(size: avatarImage.frame), let url = URL(string: imagePath) {
            
            avatarImage.kf.setImage(with: url, placeholder: R.image.defaultMaverickAvatar(), options: [.transition(.fade(UIImage.fadeInTime))])
            
        } else {
            
            avatarImage.image = R.image.defaultMaverickAvatar()
            
        }
        
        levelLabel.text = "\(user.progression?.currentLevelNumber ?? 0)"
        currentLevelLabel.text = "\(user.progression?.currentLevelNumber ?? 0)"
        nextLevelLabel.text = "\(user.progression?.nextLevel?.levelNumber ?? 0)"
       
        progress = CGFloat(user.progression?.nextLevelProgress ?? 0.0)
        updateProgress()
        
    }
    
    private func updateProgress() {
        
        let fullWidth = fullProgressView.frame.width
        completedProgressWidthConstraint.constant = fullWidth * progress
        
    }
    
}
