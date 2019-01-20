//
//  MaverickButton.swift
//  BeMaverick
//
//  Created by David McGraw on 9/28/17.
//  Copyright © 2017 BeMaverick. All rights reserved.
//

import UIKit

class MaverickButton: UIButton {
    
    // MARK: - Private Properties
    
    /// A custom gradient that can be applied to the button
    private var gradient: CAGradientLayer? = nil
    
    // MARK: - Lifecycle
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        gradient = applyGradient()
        
    }
    
    override func layoutSublayers(of layer: CALayer) {
        
        super.layoutSublayers(of: layer)
        
        gradient?.frame = bounds
        
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}
