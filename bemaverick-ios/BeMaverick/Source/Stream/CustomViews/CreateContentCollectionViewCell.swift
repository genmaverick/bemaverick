//
//  FeaturedContentSmallCollectionViewCell.swift
//  Maverick
//
//  Created by Garrett Fritz on 3/2/18.
//  Copyright © 2018 BeMaverick. All rights reserved.
//

import Foundation


class CreateContentCollectionViewCell : SmallContentCollectionViewCell {
    
    @IBOutlet weak var text: UILabel!
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var container: UIView!
    
    
    override func awakeFromNib() {
        
        container.addShadow(color: .black, alpha: 0.24, x: 0, y: 0.5, blur: 4, spread: 0)
        container.clipsToBounds = false
        clipsToBounds = false
        container.layer.cornerRadius = 2
        contentView.clipsToBounds = false
        
    }
    
    override func prepareForReuse() {
        
        text.text = "Add a new post"
        image.image = R.image.respond()
        
    }
    
    override func stopPlayback() {
        
    }
    
    func configureViewForCreateChallenge() {
        
        text.text = "Create a Challenge!"
        image.image = R.image.create_challenge()
        
    }
    
    
    
}
