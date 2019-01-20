//
//  BadgeProgressTableViewCell.swift
//  Maverick
//
//  Created by Garrett Fritz on 9/18/18.
//  Copyright © 2018 BeMaverick. All rights reserved.
//

import Foundation

class BadgeProgressTableViewCell : UITableViewCell {
    
    @IBOutlet weak var itemStackView: UIStackView!
    @IBOutlet weak var containerView: UIView!
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        containerView.addShadow(color: .black, alpha: 0.06, x: 0.0, y: 0.4, blur: 6.0, spread: 0)
        
    }
    
    func configure(with user : User, delegate : MyProgressViewControllerDelegate?) {
        
        for subview in itemStackView.subviews {
            
            subview.removeFromSuperview()
            
        }
        
        for stats in user.badgeStats {
            
            guard stats.numReceived > 0 else { continue }
            let badgeView = BadgeVerticalProgressItem()
            itemStackView.addArrangedSubview(badgeView)
            itemStackView.layoutIfNeeded()
            badgeView.delegate = delegate
            badgeView.configure(with : stats)
            
        }
        
    }
    
}
