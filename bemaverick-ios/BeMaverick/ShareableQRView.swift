//
//  ShareableQRView.swift
//  Maverick
//
//  Created by Garrett Fritz on 5/10/18.
//  Copyright © 2018 BeMaverick. All rights reserved.
//

import Foundation


class ShareableQRView : UIView {
    
    @IBOutlet weak var view: UIView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var avatarImageView: UIImageView!
    
    @IBOutlet weak var qrImageView: UIImageView!
    
    @IBOutlet weak var inviteLabel: UILabel!
    
    @IBOutlet weak var avatarWidth: NSLayoutConstraint!
    
    private var username : String?
    private var qrImage : UIImage?
    private var avatarImage : MaverickMedia?
    override func awakeFromNib() {
        
        super.awakeFromNib()
        configureView()
    
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
        
        avatarImageView.layer.cornerRadius = avatarImageView.frame.height / 2
        avatarImageView.layer.borderWidth = 1
        avatarImageView.layer.borderColor = UIColor.white.cgColor
        avatarImageView.layer.masksToBounds = true
        avatarImageView.clipsToBounds = true
        
        
    }
    
    func instanceFromNib() -> UIView {
        
        return R.nib.shareableQRView.firstView(owner: self)!
        
    }
    
    
    func configure(withQRImage image: UIImage, username : String, avatarImage : MaverickMedia? = nil) {
        
        qrImage = image
        self.avatarImage = avatarImage
        self.username = username
        if avatarImage == nil {
            avatarWidth.constant = 0
        } else {
            avatarWidth.constant = 120
        }
        configureView()

    }
    
    private func configureView() {
        
        view.backgroundColor = UIColor.MaverickBadgePrimaryColor
        inviteLabel.text = R.string.maverickStrings.inviteFriendMessage(username ?? "")
        qrImageView.image = qrImage
        inviteLabel.textColor = .white
        if let path = avatarImage?.getUrlForSize(size: avatarImageView.frame), let url = URL(string: path) {
            
            avatarImageView.kf.setImage(with: url, placeholder: R.image.defaultMaverickAvatar(), options: nil, progressBlock: nil, completionHandler: nil)
            
        } else {
            
              avatarWidth.constant = 0
            
        }
        
        layoutIfNeeded()
    }
    
}
