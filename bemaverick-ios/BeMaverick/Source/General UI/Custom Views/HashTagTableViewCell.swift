//
//  HashTagTableViewCell.swift
//  Maverick
//
//  Created by Garrett Fritz on 7/25/18.
//  Copyright © 2018 BeMaverick. All rights reserved.
//

import Foundation

class HashTagTableViewCell : UITableViewCell {
    
    
    @IBOutlet var hashImage: UIImageView!
    
    @IBOutlet var hashtagName: UILabel!
    
    @IBOutlet var countLabel: UILabel!
    
    func configure(with tag : Hashtag) {
        
        hashtagName.text = tag.name
        countLabel.text = "\(tag.count ?? 0)"
        
    }
    
}
