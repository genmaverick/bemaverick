//
//  CoverCollectionViewCell.swift
//  BeMaverick
//
//  Created by Garrett Fritz on 1/17/18.
//  Copyright © 2018 BeMaverick. All rights reserved.
//

import Foundation
import Kingfisher

class CoverCollectionViewCell: UICollectionViewCell {
    
    // MARK: - Static
    
    @IBOutlet weak var coverImage: UIImageView!
    
    class func instanceFromNib() -> CoverCollectionViewCell {
        return R.nib.coverCollectionViewCell.firstView(owner: nil)! 
}

    public func setCoverImage(coverPath: String) {
        if let url = URL(string: coverPath) {
            coverImage?.kf.setImage(with: url, options: [.transition(.fade(UIImage.fadeInTime))])
        } else {
            coverImage.image = nil
        }
    }

}
