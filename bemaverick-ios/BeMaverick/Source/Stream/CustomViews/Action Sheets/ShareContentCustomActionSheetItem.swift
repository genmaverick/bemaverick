//
//  ShareResponseCustomActionSheetItem.swift
//  Maverick
//
//  Created by Chris Garvey on 4/17/18.
//  Copyright © 2018 BeMaverick. All rights reserved.
//


class ShareContentCustomActionSheetItem: UIView, CustomMaverickActionSheetItem {
    
    // MARK: - Private Properties
    
    /// The response that will be shared.
    private var responseId: String?
    /// The response that will be shared.
    private var challengeId: String?
    
    /// The services container.
    private var services: GlobalServicesContainer!
    
    
    // MARK: - IBActions
    
    /// The share icon button that triggers the share functionality.
    @IBAction func didPressShareIconButton(_ sender: UIButton) {
        
        share()
        
    }
    
   
    
    /// The share text button that triggers the share functionality.
    @IBAction func didPressShareTextButton(_ sender: UIButton) {
        
      share()
        
    }
    
    private func share() {
        
        if let currentParentViewController = self.parentViewControllerForSelf as? MaverickActionSheetVC {
            
            if let id = responseId {
                
                let response = services.globalModelsCoordinator.response(forResponseId: id)
                let shareFunctionalityCustomActionSheetItem = ShareFunctionalityCustomActionSheetItem(response: response, services: services)
                currentParentViewController.replaceContent(withNewContent: shareFunctionalityCustomActionSheetItem)
                
            } else if let id = challengeId {
                
                let challenge = services.globalModelsCoordinator.challenge(forChallengeId: id)
                let shareFunctionalityCustomActionSheetItem = ShareFunctionalityCustomActionSheetItem(challenge: challenge, services: services)
                currentParentViewController.replaceContent(withNewContent: shareFunctionalityCustomActionSheetItem)
                
            }
            
        }
        
    }
    
        
    // MARK: - Life Cycle
    
    required init(forContentType type: Constants.ContentType, id: String, services: GlobalServicesContainer) {
        super.init(frame: CGRect(x: 16, y: 58, width: 300, height: 80))
        
        if type == .response {
        
            self.responseId = id
        
        } else {
          
            self.challengeId = id
        
        }
        self.services = services
        
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
    
}
