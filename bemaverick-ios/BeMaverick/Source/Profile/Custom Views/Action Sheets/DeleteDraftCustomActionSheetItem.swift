//
//  DeleteDraftCustomActionSheetItem.swift
//  Maverick
//
//  Created by Chris Garvey on 4/18/18.
//  Copyright © 2018 BeMaverick. All rights reserved.
//

class DeleteDraftCustomActionSheetItem: UIView, CustomMaverickActionSheetItem {
    
    // MARK: - Private Properties
    
    /// The closure that contains the report functionality.
    private var deleteActionHandleBlock: (() -> Void)?

    
    // MARK: - IBActions
    
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
    
    required init(deleteAction: @escaping () -> Void) {
        super.init(frame: CGRect(x: 16, y: 58, width: 300, height: 80))

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
        return 80.0
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
