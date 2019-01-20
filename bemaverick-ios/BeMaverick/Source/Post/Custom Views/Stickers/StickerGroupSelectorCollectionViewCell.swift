//
//  StickerGroupSelectorCollectionViewCell.swift
//  Maverick
//
//  Created by Chris Garvey on 8/2/18.
//  Copyright © 2018 BeMaverick. All rights reserved.
//

import UIKit

class StickerGroupSelectorCollectionViewCell: UICollectionViewCell {

    // MARK: - Outlets
    
    /// The container view that houses the sticker image.
    @IBOutlet weak var containerView: UIView!
    
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
    
    
    // MARK: - Private Properties
    
    private var bottomBorder: CALayer? = nil
    
    
    // MARK: - Public Functions
    
    /**
     Formats the cell in the selected state.
     */
    public func selectCell() {
        
        containerView.backgroundColor = .white
        
        bottomBorder = CALayer()
        bottomBorder!.backgroundColor = UIColor.red.cgColor
        bottomBorder!.frame = CGRect(x: 0, y: containerView.frame.size.height - 4, width: containerView.frame.size.width, height: 4)
        containerView.layer.addSublayer(bottomBorder!)
        layoutIfNeeded()
        
    }
    
    /**
     Adds a lock to the cell to indicate that the sticker group is not available.
     */
    public func lockCell() {
        lockImage.isHidden = false
    }
    
    
    // MARK: - Private Functions
    
    /**
     Clears the formatting of the cell.
     */
    private func clearCell() {
        
        containerView.backgroundColor = .clear
        lockImage.isHidden = true
        
        if let bottomBorder = bottomBorder {
            bottomBorder.removeFromSuperlayer()
        }
        
        layoutIfNeeded()
        
    }

}
