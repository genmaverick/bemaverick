//
//  EditShareChallengeCustomActionSheetItem.swift
//  Maverick
//
//  Created by Chris Garvey on 6/21/18.
//  Copyright © 2018 BeMaverick. All rights reserved.
//



class EditShareChallengeCustomActionSheetItem: UIView, CustomMaverickActionSheetItem {
    
    // MARK: - Private Properties
    
    /// The content id for the response related to the action sheet.
    private var challenge: Challenge!
    
    /// The services container.
    private weak var services: GlobalServicesContainer!
    
    /// The closure that contains the edit functionality.
    private var editActionHandleBlock: (() -> Void)?
    
    // MARK: - IBActions
    
    /// The edit button that triggers the edit functionality.
    @IBAction func didPressEditButton(_ sender: UIButton) {
        if let action = editActionHandleBlock {
            performAction(action: action)
        }
        
    }
    
    /// The share button that triggers the share functionality.
    @IBAction func didPressShareButton(_ sender: UIButton) {
        
        if let currentParentViewController = self.parentViewControllerForSelf as? MaverickActionSheetVC {
            
            let shareFunctionalityCustomActionSheetItem = ShareFunctionalityCustomActionSheetItem(challenge: challenge, services: services)
            
            currentParentViewController.replaceContent(withNewContent: shareFunctionalityCustomActionSheetItem)
            
        }
        
    }
    
    
    // MARK: - Life Cycle
    
    required init(challenge: Challenge, services: GlobalServicesContainer, editAction: @escaping () -> Void) {
        super.init(frame: CGRect(x: 16, y: 58, width: 400, height: 200))
        
        self.challenge = challenge
        self.services = services
        self.editActionHandleBlock = editAction
        
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
    func loadFromNib<T: UIView>() -> T {
        
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
    func performAction(action: @escaping (() -> Void)) {
        
        if let currentParentViewController = self.parentViewControllerForSelf {
            currentParentViewController.dismiss(animated: true, completion: {
                action()
            })
        }
        
    }
    
}
