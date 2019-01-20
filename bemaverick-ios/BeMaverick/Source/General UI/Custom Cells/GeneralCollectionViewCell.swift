//
//  GeneralCollectionViewCell.swift
//  BeMaverick
//
//  Created by David McGraw on 2/6/18.
//  Copyright © 2018 BeMaverick. All rights reserved.
//

import UIKit

/**
 A general purpose collection view cell
*/
class GeneralCollectionViewCell: UICollectionViewCell {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var imageView: UIImageView?
    
    @IBOutlet weak var titleLabel: UILabel?
    
    // MARK: - Public Properties

    open var stringIdentifier: String = ""
    
    // MARK: - Lifecycle
    
    override func prepareForReuse() {
        
        super.prepareForReuse()
        
        imageView?.image = nil
        titleLabel?.text = ""
        stringIdentifier = ""
        
    }
    
}
