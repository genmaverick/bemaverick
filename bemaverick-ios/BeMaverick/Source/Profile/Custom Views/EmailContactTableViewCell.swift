//
//  UserTableViewCell.swift
//  BeMaverick
//
//  Created by David McGraw on 1/22/18.
//  Copyright © 2018 BeMaverick. All rights reserved.
//

import UIKit
import RealmSwift

protocol EmailContactTableViewCellDelegate : class {
    
    func didSelect(forUserId  id: String, selected : Bool)
    
}

class EmailContactTableViewCell: UITableViewCell {
    
   
    
    // MARK: - IBOutlets
   

    @IBOutlet weak var username: MaverickActiveLabel!
    /// The followButton
    @IBOutlet weak var selectedButton: UIButton!
    
    @IBOutlet weak var invitedIndicator: UILabel!
    /**
     follow button tapped
    */
    @IBAction func selectButtonTapped(_ sender: Any) {
        
        selectedButton.isSelected = !selectedButton.isSelected
        guard let userId = userId else { return }
        delegate?.didSelect(forUserId: userId, selected: selectedButton.isSelected)
        
    }
    
   
    
    /// user id to be displayed
    private var userId : String?
    
    weak var delegate : EmailContactTableViewCellDelegate?
    
    override func awakeFromNib() {
    
        super.awakeFromNib()
        
        backgroundColor = .clear
    
        invitedIndicator.text = "INVITED"
        invitedIndicator.textColor =  UIColor.MaverickDarkSecondaryTextColor
       invitedIndicator.isHidden = true
    }
    
    func configure(userId : String, username: String, selected : Bool, isInvited : Bool) {
        
        self.userId = userId
        self.username.text = username
        self.selectedButton.isSelected = selected
        invitedIndicator.isHidden = !isInvited
        
    }


}


