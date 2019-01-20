//
//  MaverickActionSheetMessage.swift
//  Maverick
//
//  Created by Chris Garvey on 4/6/18.
//  Copyright © 2018 BeMaverick. All rights reserved.
//

import UIKit

class MaverickActionSheetMessage: UILabel, StandardMaverickActionSheetItem {
    
    // MARK: - Life Cycle
    
    required init(text: String, font: UIFont, textColor: UIColor) {
        super.init(frame: .zero)
        
        self.text = text
        self.font = font
        self.textColor = textColor
        self.numberOfLines = 0
        self.lineBreakMode = .byWordWrapping
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Public Function
    
    /**
     Required for MaverickActionSheetItem protocol: Returns the MaverickActionSheetItemType of the object.
     */
    func myType() -> MaverickActionSheetItemType {
        return .message
    }
    
}
