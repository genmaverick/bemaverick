//
//  DeactivateAccountCustomActionSheetItem.swift
//  Maverick
//
//  Created by Chris Garvey on 4/23/18.
//  Copyright © 2018 BeMaverick. All rights reserved.
//

import MessageUI

class DeactivateAccountCustomActionSheetItem: UIView, CustomMaverickActionSheetItem {
    
    // MARK: - Private Properties
    
    /// The closure that contains the deactivation functionality.
    private var continueToDeactivationActionHandleBlock: (() -> ())?
    
    /// The closure that contains the cancel functionality
    private var cancelDeactivationActionHandleBlock: (() -> Void)?
    
    
    // MARK: - IBActions
    
    /// The block user icon button that triggers the deactivation functionality.
    @IBAction func continueIconButton(_ sender: UIButton) {
        if let action = continueToDeactivationActionHandleBlock {
            performAction(action: action)
        }
        
    }
    
    /// The block user text button that triggers the deactivation functionality.
    @IBAction func continueTextButton(_ sender: UIButton) {
        if let action = continueToDeactivationActionHandleBlock {
            performAction(action: action)
        }
    }
    
    
    /// The block user icon button that triggers the nevermind functionality.
    @IBAction func cancelIconButton(_ sender: UIButton) {
        if let action = cancelDeactivationActionHandleBlock {
            performAction(action: action)
        }
        
    }
    
    /// The block user text button that triggers the nevermind functionality.
    @IBAction func cancelTextButton(_ sender: UIButton) {
        if let action = cancelDeactivationActionHandleBlock {
            performAction(action: action)
        }
    }
    
    
    // MARK: - IBOutlets
    
    /// The deactivation message that appears at the top of the action sheet.
    @IBOutlet weak var deactivationMessage: UILabel!
    
    /// The nevermind button that requires word wrapping.
    @IBOutlet weak var nevermindButtonText: UIButton!
    
    
    // MARK: - Life Cycle
    
    required init(continuteToDeactivationAction: @escaping () -> (), cancelDeactivationAction: @escaping () -> Void) {
        super.init(frame: CGRect(x: 16, y: 58, width: 300, height: 300))
        
        self.continueToDeactivationActionHandleBlock = continuteToDeactivationAction
        self.cancelDeactivationActionHandleBlock = cancelDeactivationAction
        
        let view = loadFromNib()
        addSubview(view)
        
        setup()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Public Functions
    
    /**
     Required for CustomMaverickActionSheetItem protocol: Returns the MaverickActionSheetItemType of the object.
     */
    public func myType() -> MaverickActionSheetItemType {
        return .customView
    }
    
    /**
     Required for CustomMaverickActionSheetItem protocol: Returns the height that should be used for the custom view in the xib.
     */
    public func myHeight() -> Double {
        return 300.0
    }
    
    
    // MARK: - Private Functions
    
    /**
     Loads the associated nib for the view.
     */
    private func loadFromNib<T: UIView>() -> T {
        
        let selfType = type(of: self)
        let bundle = Bundle(for: selfType)
        let nibName = String(describing: selfType)
        let nib = UINib(nibName: nibName, bundle: bundle)
        
        guard let view = nib.instantiate(withOwner: self, options: nil).first as? T else {
            fatalError("Error loading nib with name \(nibName)")
        }
        
        return view
        
    }
    
    /**
     Performs a closure after dimissing a parent view controller, if any.
     - parameter action: The closure to be executed.
     */
    private func performAction(action: @escaping (() -> Void)) {
        
        if let currentParentViewController = self.parentViewControllerForSelf {
            currentParentViewController.dismiss(animated: true, completion: {
                action()
            })
        }
        
    }
    
    /**
     Performs additional setup of the view.
     */
    private func setup() {
        
        nevermindButtonText.titleLabel?.numberOfLines = 0
        nevermindButtonText.titleLabel?.lineBreakMode = .byWordWrapping
        
        let plainDeactivationMessage = R.string.maverickStrings.deactivateAccountMessage()
        let linkTextWithColor = "support@bemaverick.com"
        
        let range = (plainDeactivationMessage as NSString).range(of: linkTextWithColor)
        
        let attributedString = NSMutableAttributedString(string: plainDeactivationMessage)
        attributedString.addAttribute(.foregroundColor, value: UIColor.MaverickPrimaryColor, range: range)
        
        deactivationMessage.attributedText = attributedString
    
    }
    
}
