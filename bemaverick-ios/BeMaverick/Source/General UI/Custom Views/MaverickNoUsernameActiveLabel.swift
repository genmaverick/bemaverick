//
//  MaverickActiveLabel.swift
//  Maverick
//
//  Created by Garrett Fritz on 5/4/18.
//  Copyright © 2018 BeMaverick. All rights reserved.
//

import Foundation
import ActiveLabel


class MaverickNoUsernameActiveLabel : MaverickActiveLabel {
    

    
    override func awakeFromNib() {
        
        customType = ActiveType.custom(pattern: "")
        super.awakeFromNib()
        
    }

}
