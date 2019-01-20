//
//  MaverickActionSheetButton.swift
//  Maverick
//
//  Created by Chris Garvey on 4/6/18.
//  Copyright © 2018 BeMaverick. All rights reserved.
//

import UIKit

class MaverickActionSheetButton: UIButton, StandardMaverickActionSheetItem {

    // MARK: - Private Properties
    
    /// The closure that will be performed when the button's target action is called.
    private var actionHandleBlock: (() -> Void)?
    
    
    // MARK: - Life Cycle
    
    required init(text: String, font: UIFont, action: @escaping () -> Void, textColor: UIColor) {
        super.init(frame: .zero)
        
        self.setTitle(text, for: .normal)
        self.titleLabel?.font = font
        self.actionHandleBlock = action
        self.addTarget(self, action: #selector(performAction(_:)), for: .touchUpInside)
        self.setTitleColor(textColor, for: .normal)
        self.titleLabel?.adjustsFontSizeToFitWidth = true
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Public Function
    
    /**
     Required for MaverickActionSheetItem protocol: Returns the MaverickActionSheetItemType of the object.
     */
    public func myType() -> MaverickActionSheetItemType {
        return .button
    }
    
    
    // MARK: - Private Function
    
    /**
     Dismisses the parent view controller before performing the closure that is passed in.
     - parameter sender: The button that triggers the action.
     */
    @objc
    private func performAction(_ sender: UIButton) {
        if let currentParentViewController = self.parentViewControllerForSelf, let actionToExecute = actionHandleBlock {
            currentParentViewController.dismiss(animated: true, completion: {
                actionToExecute()
            })
        }
    }

}
