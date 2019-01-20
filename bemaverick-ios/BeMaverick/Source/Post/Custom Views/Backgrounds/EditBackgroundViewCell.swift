//
//  EditBackgroundViewCell.swift
//  Maverick
//
//  Created by Garrett Fritz on 6/20/18.
//  Copyright © 2018 BeMaverick. All rights reserved.
//

import Foundation

class EditBackgroundViewCell : UICollectionViewCell {
    
    @IBOutlet weak var maverickBackgroundView: UIView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        maverickBackgroundView.addShadow()
    }
}
