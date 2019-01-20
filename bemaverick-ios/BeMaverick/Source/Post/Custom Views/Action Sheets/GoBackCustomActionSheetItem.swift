//
//  GoBackCustomActionSheetItem.swift
//  Maverick
//
//  Created by Chris Garvey on 4/24/18.
//  Copyright © 2018 BeMaverick. All rights reserved.
//


class GoBackCustomActionSheetItem: UIView, CustomMaverickActionSheetItem {
    
    // MARK: - Private Properties
    
    /// The closure that contains the save draft functionality.
    private var saveDraftActionHandleBlock: (() -> Void)?
    
    /// The closure that contains the start over functionality.
    private var startOverActionHandleBlock: (() -> Void)?
    
    /// The closure that contains the cancel functionality.
    private var cancelActionHandleBlock: (() -> Void)?
    
    
    // MARK: - IBOutlets
    
    /**
     The container for the save draft functionality that can be added or removed at runtime depending on whether the user is or isn't within the post flow.
     */
    @IBOutlet weak var saveDraftContainerView: UIView!
    
    /// The label for the save draft functionality
    @IBOutlet weak var saveDraftLabel: UILabel!
    
    /// The label for the start over functionality
    @IBOutlet weak var startOverLabel: UILabel!
    
    /// The label for the cancel functionality
    @IBOutlet weak var cancelLabel: UILabel!
    
    
    // MARK: - IBActions
    
    /// Executes the save draft functionality
    @IBAction func saveDraftTapped(_ sender: Any) {
        
        if let action = saveDraftActionHandleBlock {
            performAction(action: action)
        }
        
    }
    
    /// Executes the start over functionality
    @IBAction func startOverTapped(_ sender: Any) {
        if let action = startOverActionHandleBlock {
            performAction(action: action)
        }
    }
    
    /// Executes the cancel functionality
    @IBAction func cancelTapped(_ sender: Any) {
        if let action = cancelActionHandleBlock {
            performAction(action: action)
        }
    }
    
    
    // MARK: - Life Cycle
    
    required init(saveDraftAction: (()->())? = nil, startOverAction: @escaping () -> Void, cancelAction: @escaping () -> Void) {
        super.init(frame: CGRect(x: 16, y: 58, width: 414, height: 200))
        
        self.saveDraftActionHandleBlock = saveDraftAction
        self.startOverActionHandleBlock = startOverAction
        self.cancelActionHandleBlock = cancelAction
        
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
        
        if let currentParentViewController = parentViewControllerForSelf as? MaverickActionSheetVC {
            
            currentParentViewController.dismiss(animated: true, completion: {
                action()
            })
            
        }
        
    }
    
    /**
     Provides additional setup for the text buttons.
     */
    private func setup() {
        
        if saveDraftActionHandleBlock != nil {
            saveDraftLabel.text =  R.string.maverickStrings.recordFlowGoBackActionSheetButtonSaveDraft()
        } else {
            saveDraftContainerView.isHidden = true
        }
        
        startOverLabel.text = R.string.maverickStrings.recordFlowGoBackActionSheetButtonStartOver()
        cancelLabel.text = R.string.maverickStrings.recordFlowGoBackActionSheetButtonCancel()
        
    }
    
}
