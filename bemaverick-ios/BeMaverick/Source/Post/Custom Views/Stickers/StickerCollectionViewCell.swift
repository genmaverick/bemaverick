//
//  StickerCollectionViewCell.swift
//  Maverick
//
//  Created by Garrett Fritz on 5/3/18.
//  Copyright © 2018 BeMaverick. All rights reserved.
//

import Foundation
import Kingfisher

class StickerCollectionViewCell: UICollectionViewCell {
    
    /// The sticker image.
    @IBOutlet weak var coverImage: UIImageView!
    
    /// The lock image.
    @IBOutlet weak var lockImage: UIImageView!
    
    
    // MARK: - Lifecycle
    
    override func awakeFromNib() {
        clearCell()
    }
    
    override func prepareForReuse() {
        clearCell()
    }
    
    
    // MARK: - Public Function
    
    /**
     Adds a lock to the cell to indicate that the sticker group is not available.
     */
    public func lockCell() {
        lockImage.isHidden = false
    }
    
    
    // MARK: - Private Function
    
    /**
     Clears the formatting of the cell.
     */
    private func clearCell() {
        lockImage.isHidden = true
    }
    
}
