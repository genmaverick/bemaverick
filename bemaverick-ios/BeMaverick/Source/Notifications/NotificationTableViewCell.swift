//
//  NotificationTableViewCell.swift
//  Maverick
//
//  Created by Garrett Fritz on 3/7/18.
//  Copyright © 2018 BeMaverick. All rights reserved.
//

import Foundation
import Kingfisher

protocol NotificationTableViewCellDelegate : class {
    
    func targetAreaPressed(message: LPInboxMessage)
    func sourceAreaPressed(message: LPInboxMessage)
    
    
}

class NotificationTableViewCell : UITableViewCell {
    
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var leftImage: UIImageView!
    @IBOutlet weak var subtitle: UILabel!
    @IBOutlet weak var unreadView: UIView!
    @IBOutlet weak var notificationImage: UIImageView!
    @IBOutlet weak var leftImageLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var leftImageWidthConstraint: NSLayoutConstraint!
   
    @IBAction func sourceAreaPressed(_ sender: Any) {
        
        if let message = message {
        
            delegate?.sourceAreaPressed(message: message)
        
        }
        
    }
    
    @IBAction func targetAreaPressed(_ sender: Any) {
        
        if let message = message {
            
            delegate?.targetAreaPressed(message: message)
        
        }
        
    }
    
    private var message : LPInboxMessage?
    weak var delegate : NotificationTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        title.textColor = UIColor.MaverickDarkTextColor
        subtitle.textColor = UIColor.MaverickDarkSecondaryTextColor
        unreadView.backgroundColor = UIColor.MaverickBadgePrimaryColor
        unreadView.layer.cornerRadius = unreadView.frame.height / 2
        unreadView.clipsToBounds = true
    }
    
    func configure(with message: LPInboxMessage) {
     
        self.message = message
        unreadView.isHidden = message.isRead()
        title.text = message.title()
        subtitle.text = message.subtitle()
        if let data = message.data() {
           
            if let path = data["image"] as? String, let url = URL(string: path) {
                
                notificationImage.kf.setImage(with: url, options: [.transition(.fade(UIImage.fadeInTime))])
                
            } else {
                
                notificationImage.kf.setImage(with: message.imageURL(), options: [.transition(.fade(UIImage.fadeInTime))])
                
            }
        }
        
        if let data = message.data(), let path = data["sourceImage"] as? String, path != "none", let url = URL(string: path), UIApplication.shared.canOpenURL(url) {
            
            leftImage.kf.setImage(with: url, options: [.transition(.fade(UIImage.fadeInTime))])
            leftImage.isHidden = false
            leftImageWidthConstraint.constant = 40
            leftImageLeadingConstraint.constant = 10
            
        } else {
            
           leftImage.isHidden = true
           leftImageWidthConstraint.constant = 0
        leftImageLeadingConstraint.constant = 0
            
        }
        
        if  message.subtitle() != nil && message.subtitle() != "" {
           
            subtitle.text = message.subtitle()
        
        } else if let date = message.deliveryTimestamp() {
            
            let comps = Calendar.current.dateComponents([.month, .day, .hour, .minute, .second], from: date, to: Date())
            subtitle.text = comps.timeRemainingForComment()
            
        }
        
        
    }
    
    
}
