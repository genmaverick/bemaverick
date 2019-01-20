//
//  ShareReportBlockUserCustomActionSheetItem.swift
//  Maverick
//
//  Created by Chris Garvey on 4/16/18.
//  Copyright © 2018 BeMaverick. All rights reserved.
//

class ShareReportBlockUserCustomActionSheetItem: UIView, CustomMaverickActionSheetItem {
    
    // MARK: - Private Properties
    
    /// The content id for the response related to the action sheet.
    private var responseId: String?
    
    /// The content id for the challenge related to the action sheet.
    private var challengeId: String?
    
    /// The delegate for the action sheet item that contains the actions to be executed upon user pressing buttons or labels.
    private weak var delegate: ContentViewController!
    
    /// The services container.
    private weak var services: GlobalServicesContainer!
    
    /// The user associated with the response.
    private var user: User!
    
    
    // MARK: - IBOutlet
    @IBOutlet weak var blockUserLabel: UILabel!
    
    
    // MARK: - IBActions
    
    /// The report button that triggers the report functionality
    @IBAction func didPressReportButton(_ sender: UIButton) {
        
        if let currentParentViewController = self.parentViewControllerForSelf as? MaverickActionSheetVC {
            
            var reportResponseReasonActionSheetItem : ReportContentReasonActionSheetItem?
            if let id = responseId {
                
                reportResponseReasonActionSheetItem = ReportContentReasonActionSheetItem(forResponseId: id, delegate: delegate, services: services)
                
            } else if let id = challengeId {
                
                reportResponseReasonActionSheetItem = ReportContentReasonActionSheetItem(forChallengeId: id, delegate: delegate, services: services)
                
            }
            
            if let action = reportResponseReasonActionSheetItem {
                
                currentParentViewController.replaceContent(withNewContent: action)
                
            }
            
        }
        
    }
    
    /// The share button that triggers the share functionality.
    @IBAction func didPressShareButton(_ sender: UIButton) {
        
        if let currentParentViewController = self.parentViewControllerForSelf as? MaverickActionSheetVC {
            
            if let id = challengeId {
                
                let challenge = services.globalModelsCoordinator.challenge(forChallengeId: id)
                
                let shareFunctionalityCustomActionSheetItem = ShareFunctionalityCustomActionSheetItem(challenge: challenge, services: services)
                
                currentParentViewController.replaceContent(withNewContent: shareFunctionalityCustomActionSheetItem)
                
            } else if let id = responseId {
                
                let response = services.globalModelsCoordinator.response(forResponseId: id)
                
                let shareFunctionalityCustomActionSheetItem = ShareFunctionalityCustomActionSheetItem(response: response, services: services)
                
                currentParentViewController.replaceContent(withNewContent: shareFunctionalityCustomActionSheetItem)
                
            }
            
        }
        
    }
    
    
    /// The block user icon button that triggers the block user functionality.
    @IBAction func didPressblockUserButton(_ sender: UIButton) {
        
        performAction {
            
            self.delegate.services.globalModelsCoordinator.blockUser(withId: self.user.userId, isBlocked : true)
            
            if let tabBar = UIApplication.shared.keyWindow?.rootViewController as? MainTabBarViewController {
                tabBar.view.makeToast("Blocked \(self.user.username ?? "User")")
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
//                self.delegate.refresh()
            }
            
        }
        
    }
    
    
    // MARK: - Life Cycle
    
    
    convenience init(forResponseId responseId: String, delegate: ContentViewController, services: GlobalServicesContainer, user: User) {
        
        self.init(delegate: delegate, services: services, user: user)
         self.responseId = responseId
    }
    
    convenience init(forChallengeId challengeId: String, delegate: ContentViewController, services: GlobalServicesContainer, user: User) {
        self.init(delegate: delegate, services: services, user: user)
        
        self.challengeId = challengeId
        
        
    }
    
     init(delegate: ContentViewController, services: GlobalServicesContainer, user: User) {
        super.init(frame: CGRect(x: 16, y: 58, width: 300, height: 220))
        
        self.delegate = delegate
        self.services = services
        self.user = user
        
        let view = loadFromNib()
        addSubview(view)
        
        blockUserLabel.text = "Block \(user.username ?? "User")"
        
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
        return 220.0
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
        
        if let currentParentViewController = parentViewControllerForSelf as? MaverickActionSheetVC {
            
            currentParentViewController.dismiss(animated: true, completion: {
                action()
            })
            
        }
        
    }
    
}
