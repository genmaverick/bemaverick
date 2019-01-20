//
//  ChangeProfilePhotoActionSheetItem.swift
//  Maverick
//
//  Created by Chris Garvey on 4/23/18.
//  Copyright © 2018 BeMaverick. All rights reserved.
//

class ChangeProfilePhotoActionSheetItem: UIView, CustomMaverickActionSheetItem {
    
    // MARK: - Private Properties
    
    /// The closure that contains the choose from library functionality.
    private var editAvatarActionHandleBlock: (() -> Void)?
    /// The closure that contains remove photo functionality.
    private var removeCurrentPhotoActionHandleBlock: (() -> Void)?
    
    
    // MARK: - IBActions
    
    /// The block user icon button that triggers the choose from library functionality.
    @IBAction func editAvatarButtonPressed(_ sender: UIButton) {
        if let action = editAvatarActionHandleBlock {
            performAction(action: action)
        }
        
    }
    
    
    /// The block user icon button that triggers the remove photo functionality.
    @IBAction func removeCurrentPhotoButtonPressed(_ sender: UIButton) {
        if let action = removeCurrentPhotoActionHandleBlock {
            performAction(action: action)
        }
        
    }
    
    
    // MARK: - Life Cycle
    
    required init(editAvatarAction: @escaping () -> Void, removeCurrentPhotoAction: @escaping () -> Void) {
        super.init(frame: CGRect(x: 16, y: 58, width: 414, height: 200))
        
        self.editAvatarActionHandleBlock = editAvatarAction
        self.removeCurrentPhotoActionHandleBlock = removeCurrentPhotoAction
        
        let view = loadFromNib()
        addSubview(view)
        
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
        return 200.0
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
    
}
