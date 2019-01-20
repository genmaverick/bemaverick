//
//  ChangeCoverPhotoActionSheetItem.swift
//  Maverick
//
//  Created by Chris Garvey on 4/23/18.
//  Copyright © 2018 BeMaverick. All rights reserved.
//


class ChangeCoverPhotoActionSheetItem: UIView, CustomMaverickActionSheetItem {
    
    // MARK: - Private Properties
    
    /// The closure that contains the create new cover functionality.
    private var createNewCoverActionHandleBlock: (() -> Void)?
    
    /// The closure that contains the select Maverick cover functionality.
    private var selectMaverickCoverActionHandleBlock: (() -> Void)?
    
    
    // MARK: - IBActions
    
    /// User has pressed the create new cover button.
    @IBAction func createNewCoverButtonPressed(_ sender: UIButton) {
        if let action = createNewCoverActionHandleBlock {
            performAction(action: action)
        }
        
    }
    
    /// User has pressed the select Maverick cover button.
    @IBAction func selectMaverickCoverIconButton(_ sender: UIButton) {
        if let action = selectMaverickCoverActionHandleBlock {
            performAction(action: action)
        }
        
    }
    
    
    // MARK: - Life Cycle
    
    required init(createNewCoverAction: @escaping () -> Void, selectMaverickCoverAction: @escaping () -> Void) {
        super.init(frame: CGRect(x: 16, y: 58, width: 300, height: 200))
        
        self.createNewCoverActionHandleBlock = createNewCoverAction
        self.selectMaverickCoverActionHandleBlock = selectMaverickCoverAction
        
        let view = loadFromNib()
        addSubview(view)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        log.verbose("💥")
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
