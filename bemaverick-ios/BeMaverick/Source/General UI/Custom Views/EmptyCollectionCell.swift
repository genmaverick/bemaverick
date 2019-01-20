//
//  EmptyCollectionCell.swift
//  Maverick
//
//  Created by Garrett Fritz on 3/8/18.
//  Copyright © 2018 BeMaverick. All rights reserved.
//

import Foundation

class EmptyCollectionCell : UICollectionViewCell {
    
    @IBOutlet weak var emptyView: EmptyView!
    
    @IBOutlet weak var loggedInNoChallengesView: LoggedInNoChallengesView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        loggedInNoChallengesView.isHidden = true
        
    }
}
