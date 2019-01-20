//
//  ShareDeleteCustomActionSheetItem.swift
//  Maverick
//
//  Created by Chris Garvey on 4/18/18.
//  Copyright © 2018 BeMaverick. All rights reserved.
//

class ShareDeleteCustomActionSheetItem: UIView, CustomMaverickActionSheetItem {
    
    // MARK: - Private Properties
    
    /// The content id for the response related to the action sheet.
    private var response: Response!
    
    /// The services container.
    private weak var services: GlobalServicesContainer!
    
    /// The closure that contains the report functionality.
    private var deleteActionHandleBlock: (() -> Void)?
    
    
    // MARK: - IBActions
    
    /// The share icon button that triggers the report functionality.
    @IBAction func shareIconButton(_ sender: UIButton) {
        
        if let currentParentViewController = self.parentViewControllerForSelf as? MaverickActionSheetVC {
            
            let shareFunctionalityCustomActionSheetItem = ShareFunctionalityCustomActionSheetItem(response: response, services: services)
            
            currentParentViewController.replaceContent(withNewContent: shareFunctionalityCustomActionSheetItem)
            
        }
        
    }
    
    /// The share text button that triggers the report functionality.
    @IBAction func shareTextButton(_ sender: UIButton) {
        
        if let currentParentViewController = self.parentViewControllerForSelf as? MaverickActionSheetVC {
            
            let shareFunctionalityCustomActionSheetItem = ShareFunctionalityCustomActionSheetItem(response: response, services: services)
            
            currentParentViewController.replaceContent(withNewContent: shareFunctionalityCustomActionSheetItem)
            
        }
        
    }
    
    
    /// The report icon button that triggers the report functionality.
    @IBAction func deleteIconButton(_ sender: UIButton) {
        if let action = deleteActionHandleBlock {
            performAction(action: action)
        }
        
    }
    
    /// The report text button that triggers the report functionality.
    @IBAction func deleteTextButton(_ sender: UIButton) {
        if let action = deleteActionHandleBlock {
            performAction(action: action)
        }
        
    }
    
    
    // MARK: - Life Cycle
    
    required init(response: Response, services: GlobalServicesContainer, deleteAction: @escaping () -> Void) {
        super.init(frame: CGRect(x: 16, y: 58, width: 400, height: 200))
        
        self.response = response
        self.services = services
        self.deleteActionHandleBlock = deleteAction
        
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
