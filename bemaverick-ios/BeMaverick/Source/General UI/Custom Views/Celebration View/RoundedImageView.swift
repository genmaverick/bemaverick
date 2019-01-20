//
//  RoundedImageView.swift
//  Maverick
//
//  Created by Chris Garvey on 3/20/18.
//  Copyright © 2018 BeMaverick. All rights reserved.
//

import UIKit

class RoundedImageView: UIImageView {

    // MARK: - Overrides
    
    override func layoutSubviews() {
        
        super.layoutSubviews()
        
        let radius: CGFloat = self.bounds.size.width / 2.0
        
        self.layer.cornerRadius = radius
        self.clipsToBounds = true
        
    }
    
}
