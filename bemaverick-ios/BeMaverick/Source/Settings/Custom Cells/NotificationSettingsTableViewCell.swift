//
//  ProfileSettingTableViewCell.swift
//  BeMaverick
//
//  Created by David McGraw on 11/28/17.
//  Copyright © 2017 BeMaverick. All rights reserved.
//

import UIKit

protocol NotificationSettingsTableViewCellDelegate : class {
    
    func switchFlipped(selected : Bool, cell : UITableViewCell)
    
}

class NotificationSettingsTableViewCell: UITableViewCell {
    
    // MARK: - IBOutlets
    
    /// The title of the setting
    @IBOutlet weak var titleLabel: UILabel!
    /// Divider line
    @IBOutlet weak var divider: UIView!
    // Switch
    @IBOutlet weak var onOffToggle: UISwitch!
    
    @IBOutlet weak var descriptionLabel: UILabel!
    weak var delegate : NotificationSettingsTableViewCellDelegate?
    
    func on(isOn : Bool ) {
        
        onOffToggle.isOn = isOn
        
    }
    /**
     Switch toggled, fire delegate
    */
    @IBAction func switchTapper(_ sender: Any) {
        
        delegate?.switchFlipped(selected: onOffToggle.isOn, cell: self)
    }
    
    // MARK: - Lifecycle
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        onOffToggle.onTintColor = UIColor.MaverickPrimaryColor
        divider.backgroundColor = UIColor.MaverickDarkTerciaryTextColor
        descriptionLabel.textColor = UIColor.MaverickDarkSecondaryTextColor
        
    }
    
}
