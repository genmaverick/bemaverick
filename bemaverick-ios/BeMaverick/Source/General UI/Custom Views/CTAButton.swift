//
//  CTAButton.swift
//  Maverick
//
//  Created by Garrett Fritz on 3/12/18.
//  Copyright © 2018 BeMaverick. All rights reserved.
//

import Foundation

class CTAButton : UIButton {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        layer.cornerRadius = frame.height / 2
        layer.borderWidth = 0
        setTitleColor(.white, for: .normal)
        backgroundColor = UIColor(rgba: "f3485a")
    }
    
}
