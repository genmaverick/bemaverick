//
//  MySreamEmptyHeaderCell.swift
//  Maverick
//
//  Created by Garrett Fritz on 7/11/18.
//  Copyright © 2018 BeMaverick. All rights reserved.
//

import Foundation

protocol MySreamEmptyHeaderCellDelegate : class {
    
    func searchTapped()
    func inviteTapped()
    
}

class MySreamEmptyHeaderCell : UITableViewCell {
    
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var homeImage: UIImageView!
    
    @IBOutlet weak var homeLabel: UILabel!
    @IBOutlet weak var emptyLabel: UILabel!
    
    @IBOutlet weak var inviteButton: UIButton!
    
    weak var delegate : MySreamEmptyHeaderCellDelegate?
    
    @IBAction func searchBarTapped(_ sender: Any) {
        
        delegate?.searchTapped()
        
    }
    
    
    @IBAction func inviteTapped(_ sender: Any) {
        
        delegate?.inviteTapped()
        
    }
    
    override func awakeFromNib() {
      
        super.awakeFromNib()
        homeImage.tintColor = UIColor.MaverickPrimaryColor
        homeLabel.textColor = UIColor.MaverickPrimaryColor
        
        inviteButton.addShadow()
        
        searchBar.setImage(R.image.search(), for: .search, state: .normal)
             searchBar.tintColor = UIColor.MaverickBadgePrimaryColor
        searchBar.setImage(R.image.close_purple(), for: .clear, state: .normal)
    }
    
}
