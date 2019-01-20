//
//  UploadMessageView.swift
//  BeMaverick
//
//  Created by David McGraw on 2/4/18.
//  Copyright © 2018 BeMaverick. All rights reserved.
//

import SwiftMessages

// FYI -- Clashing with R.swift w/o this https://github.com/SwiftKickMobile/SwiftMessages/issues/70
class InvitesSentMessageView: MessageView {
    
    // MARK: - IBOutlet
    
    
    
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var uploadMessageLabel: UILabel!
    @IBOutlet weak var avatarWidthConstraint: NSLayoutConstraint!
    
    private var messageText = ""
    private var media : MaverickMedia?
    
    
    // MARK: - Public Properties
    
    /// A reference to the global services
    open var services: GlobalServicesContainer = (UIApplication.shared.delegate as! AppDelegate).services
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        avatarImageView.layer.cornerRadius = avatarImageView.frame.height / 2
        avatarImageView.layer.borderWidth = 1
        avatarImageView.layer.borderColor = UIColor.white.cgColor
        avatarImageView.layer.masksToBounds = true
        avatarImageView.clipsToBounds = true
        configureView()
        
    }
    
    func configureView() {
        
        if let path = media?.getUrlForSize(size: avatarImageView.frame), let url = URL(string: path) {
            
            avatarImageView.kf.setImage(with: url, placeholder: R.image.defaultMaverickAvatar(), options: nil, progressBlock: nil, completionHandler: nil)
            uploadMessageLabel.textAlignment = .left
            
        } else {
            
            uploadMessageLabel.textAlignment = .center
            avatarWidthConstraint.constant = 0
            
        }
        uploadMessageLabel.text = messageText
        
    }
    
    
    func configure(with message : String, avatar : MaverickMedia?) {
        
        messageText = message
        media = avatar
        configureView()
    }
    
    // MARK: - Public Methods
    
    open func setErrorMessage(message: String) {
        
        if message.contains("cancelled") {
            titleLabel?.text = "Upload cancelled. Saved to Drafts."
        } else {
            titleLabel?.text = message
        }
        
        
        
    }
    
    
    
}
