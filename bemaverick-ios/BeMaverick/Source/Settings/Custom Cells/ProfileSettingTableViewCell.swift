//
//  ProfileSettingTableViewCell.swift
//  BeMaverick
//
//  Created by David McGraw on 11/28/17.
//  Copyright © 2017 BeMaverick. All rights reserved.
//

import UIKit

class ProfileSettingTableViewCell: UITableViewCell {
    
    // MARK: - IBOutlets
    
    /// The title of the setting
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var divider: UIView!
    
    /// A field to capture input
    @IBOutlet weak var rightImageView: UIImageView!
    
    // MARK: - Lifecycle
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        divider.backgroundColor = UIColor.MaverickDarkTerciaryTextColor
     
        
    }
    
}
