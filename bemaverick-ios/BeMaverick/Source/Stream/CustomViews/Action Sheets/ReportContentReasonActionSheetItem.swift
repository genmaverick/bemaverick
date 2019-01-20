//
//  ReportResponseReasonActionSheetItem.swift
//  Maverick
//
//  Created by Chris Garvey on 4/19/18.
//  Copyright © 2018 BeMaverick. All rights reserved.
//



class ReportContentReasonActionSheetItem: UIView, CustomMaverickActionSheetItem {
    
    // MARK: - Private Properties
    
    /// The content id for the response related to the action sheet.
    private var responseId: String?
    /// The content id for the challenge related to the action sheet.
    private var challengeId: String?
    
    /// The delegate for the action sheet item that contains the actions to be executed upon user pressing buttons or labels.
    private weak var delegate: UIViewController!
    
    /// The services container.
    private weak var services: GlobalServicesContainer!
    
    
    // MARK: - IBActions
    
    private func report(reason : String ) {
        
        if let id = responseId {
            self.services.globalModelsCoordinator.reportContent(type: .response, id: id, reason: reason)
            
        } else if let id = challengeId {
            self.services.globalModelsCoordinator.reportContent(type: .challenge, id: id, reason: reason)
        }
        
        if let tabBar = UIApplication.shared.keyWindow?.rootViewController as? MainTabBarViewController {
            tabBar.view.makeToast(R.string.maverickStrings.reportConfirmation())
        }
        
    }
    
    /// The button that triggers the reason 1 report functionality.
    @IBAction func reason1Button(_ sender: UIButton) {
        
        performAction { [unowned self] in
            
            self.report(reason: Variables.Features.reportResponseReason1.stringValue())
            
        }
        
    }
    
    /// The button that triggers the reason 2 report functionality.
    @IBAction func reason2Button(_ sender: UIButton) {
    
        performAction { [unowned self] in
            
           self.report(reason: Variables.Features.reportResponseReason2.stringValue())
            
        }
        
    }
    
    /// The button that triggers the reason 3 report functionality.
    @IBAction func reason3Button(_ sender: UIButton) {
        
        performAction { [unowned self] in
            
            self.report(reason: Variables.Features.reportResponseReason3.stringValue())
            
        }
        
    }
    
    /// The button that triggers the copyright request functionality.
    @IBAction func copyrightButton(_ sender: UIButton) {
        
        performAction { [unowned self] in
            
            let urlToDisplay = URL(string: Variables.Features.reportResponseCopyrightURL.stringValue())
            let webViewController = NavigationViewController(rootViewController: WebContentViewController(url: urlToDisplay!, webViewTitle: "Maverick Copyright Policy"))
            self.delegate.present(webViewController, animated: true, completion: nil)
            
        }
        
    }
    
    @IBAction func reason1Circle(_ sender: UIButton) {
        performAction { [unowned self] in
            
            self.report(reason: Variables.Features.reportResponseReason1.stringValue())
        }
    }
    
    @IBAction func reason2Circle(_ sender: UIButton) {
        performAction { [unowned self] in
            
     self.report(reason: Variables.Features.reportResponseReason2.stringValue())
            
        }
    }
    
    @IBAction func reason3Circle(_ sender: UIButton) {
        performAction { [unowned self] in
            
           self.report(reason: Variables.Features.reportResponseReason3.stringValue())
            
        }
    }
    
    @IBOutlet weak private var reason1Circle: UIButton!
    
    @IBOutlet weak private var reason2Circle: UIButton!
    
    @IBOutlet weak private var reason3Circle: UIButton!
    
    
    // MARK: - IBOutlets
    
    /// The message that appears at the top of the item.
    @IBOutlet weak private var topMessage: UILabel!
    
    /// The first reason for reporting for the content.
    @IBOutlet weak private var reason1Button: UIButton!
    
    /// The second reason for reporting for the content.
    @IBOutlet weak private var reason2Button: UIButton!
    
    /// The third reason for reporting for the content.
    @IBOutlet weak private var reason3Button: UIButton!
    
    /// The copyright information that is clickable due to a tap gesture recognizer.
    @IBOutlet weak private var copyrightLabel: UILabel!
    
    
    // MARK: - Life Cycle
    
    convenience init(forResponseId responseId: String, delegate: UIViewController, services: GlobalServicesContainer) {

        self.init( delegate: delegate, services: services)
        self.responseId = responseId
        setup()
        
    }
    
    convenience init(forChallengeId challengeId: String, delegate: UIViewController, services: GlobalServicesContainer) {
        
        self.init( delegate: delegate, services: services)
        self.challengeId = challengeId
        setup()
        
    }
    
    init(delegate: UIViewController, services: GlobalServicesContainer) {
        
        super.init(frame: CGRect(x: 16, y: 58, width: 300, height: delegate.view.bounds.height))
        self.delegate = delegate
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

        return Double((subviews.first?.bounds.height)! + (UIScreen.main.bounds.height == 812 ? 88 : 64))
        
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
     Provides additional setup for the view.
     */
    private func setup() {
        
        topMessage.text = Variables.Features.reportResponseMessage.stringValue()
        reason1Button.setTitle(Variables.Features.reportResponseReason1.stringValue(), for: .normal)
        reason2Button.setTitle(Variables.Features.reportResponseReason2.stringValue(), for: .normal)
        reason3Button.setTitle(Variables.Features.reportResponseReason3.stringValue(), for: .normal)
        
        let circles = [reason1Circle, reason2Circle, reason3Circle]
        circles.forEach { $0?.tintColor = UIColor.MaverickPrimaryColor }
        
        let buttonsToSetup: [UIButton] = [reason1Button, reason2Button, reason3Button]
        buttonsToSetup.forEach { $0.titleLabel?.numberOfLines = 0 }
        buttonsToSetup.forEach { $0.setTitleColor(.black, for: .normal) }
        buttonsToSetup.forEach { $0.titleLabel?.lineBreakMode = .byWordWrapping }
        
        copyrightLabel.isUserInteractionEnabled = true
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(
            target: self, action: #selector(didPressCopyrightLabel(_:)))
        copyrightLabel.addGestureRecognizer(tap)

        
        let plainCopyrightText = Variables.Features.reportResponseCopyrightMessage.stringValue()
        let linkTextWithColor = "these directions"
        
        let range = (plainCopyrightText! as NSString).range(of: linkTextWithColor)

        let attributedString = NSMutableAttributedString(string: plainCopyrightText!)
        attributedString.addAttribute(.foregroundColor, value: UIColor.MaverickPrimaryColor, range: range)

        copyrightLabel.attributedText = attributedString
        
    }
    
    /**
     The action to be executed when the copyright information label is pressed.
     - parameter sender: The user tap on the label.
     */
    @objc
    private func didPressCopyrightLabel(_ sender: UITapGestureRecognizer) {
        
        performAction { [unowned self] in
            
            let urlToDisplay = URL(string: Variables.Features.reportResponseCopyrightURL.stringValue())
            let webViewController = NavigationViewController(rootViewController: WebContentViewController(url: urlToDisplay!, webViewTitle: "Maverick Copyright Policy"))
            self.delegate.present(webViewController, animated: true, completion: nil)
            
        }
        
    }
    
    /**
     Performs a closure after dimissing a parent view controller, if any.
     - parameter action: The closure to be executed.
     */
    func performAction(action: @escaping (() -> Void)) {
        
        if let currentParentViewController = self.parentViewControllerForSelf as? MaverickActionSheetVC {
            
            currentParentViewController.dismiss(animated: true, completion: {
                action()
            })

        }
        
    }
    
}
