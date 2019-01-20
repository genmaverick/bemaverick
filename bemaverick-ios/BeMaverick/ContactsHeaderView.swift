//
//  ContactsSectionHeaderReusableView.swift
//  Maverick
//
//  Created by Garrett Fritz on 3/5/18.
//  Copyright © 2018 BeMaverick. All rights reserved.
//

import Foundation

protocol ContactsHeaderViewDelegate : class {
    func selectTapped(selectAll : Bool)
}

class ContactsHeaderView : UIView {
    
    @IBOutlet weak var bottomSpaceConstraint: NSLayoutConstraint!
    @IBOutlet weak var leadingSpaceConstraint: NSLayoutConstraint!
    weak var delegate : ContactsHeaderViewDelegate?
    /// title of section
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var selectButton: UIButton!
    @IBAction func buttonTapped(_ sender: Any) {
        
        selectButton.isSelected = !selectButton.isSelected
        delegate?.selectTapped(selectAll: selectButton.isSelected)
    
    }
    override func awakeFromNib() {
        
        super.awakeFromNib()
        backgroundColor = UIColor.white
        label.textColor = UIColor.MaverickDarkTextColor
        label.font = R.font.openSansSemiBold(size: 14.0)
        selectButton.titleLabel?.font = R.font.openSansSemiBold(size: 14.0)
        
        selectButton.isHidden = true
        selectButton.setTitle("Deselect All", for: .selected)
        selectButton.setTitle("Select All", for: .normal)
        selectButton.setTitleColor(UIColor.MaverickPrimaryColor, for: .normal)
        selectButton.setTitleColor(UIColor.MaverickPrimaryColor, for: .selected)
        
        
    }
    
    
}
