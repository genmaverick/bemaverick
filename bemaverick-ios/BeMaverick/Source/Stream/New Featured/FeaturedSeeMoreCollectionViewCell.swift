//
//  FeaturedSeeMoreCollectionViewCell.swift
//  Maverick
//
//  Created by Garrett Fritz on 5/23/18.
//  Copyright © 2018 BeMaverick. All rights reserved.
//

import Foundation

protocol FeaturedSeeMoreCollectionViewCellDelegate : class {
    
    func moreTapped(tag : Int)

}

class FeaturedSeeMoreCollectionViewCell : UICollectionViewCell {
    
    
    @IBAction func itemTapped(_ sender: Any) {
        
        delegate?.moreTapped(tag: tag)
        
    }
    
    weak var delegate : FeaturedSeeMoreCollectionViewCellDelegate?
    
    
}
