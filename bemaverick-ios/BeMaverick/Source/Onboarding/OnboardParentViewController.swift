//
//  OnboardParentViewController.swift
//  BeMaverick
//
//  Created by David McGraw on 9/27/17.
//  Copyright © 2017 BeMaverick. All rights reserved.
//

import UIKit
import PromiseKit

class OnboardParentViewController: ViewController {
    
    // MARK: - IBOutlets
    
    /// A scroll view that maintains the content view
    @IBOutlet weak var scrollView: UIScrollView!
    
    /// The height of the content within the scroll view
    @IBOutlet weak var bottomSpaceConstraint: NSLayoutConstraint?
    
    /// The login button that executes the login request
    @IBOutlet weak var ctaButton: UIButton?
    
    /// Top filler view
    @IBOutlet weak var topView: UIView?
    @IBOutlet weak var maverickImage: UIImageView?
    @IBOutlet weak var MimageView: UIImageView?
    
    // MARK: - Public Properties
    
    /// A loading view
    open private(set) var loadingView: LoadingView?
    
    // MARK: - Private Properties
    
    /// A reference to the `UIKeyboardWillShow` notification
    private var keyboardWillShowId: NSObjectProtocol?
    
    /// A reference to the `UIKeyboardWillHide` notification
    private var keyboardWillHideId: NSObjectProtocol?
    
    // MARK: - Lifecycle
    
   
    override func viewDidLoad() {
        
        super.viewDidLoad()
        configureView()
        navigationController?.interactivePopGestureRecognizer?.delegate = nil
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(keyboardWillShowId as Any)
        NotificationCenter.default.removeObserver(keyboardWillHideId as Any)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        observeKeyboardWillShow()
        observeKeyboardWillHide()
        
    }
    
    // MARK: - Public Methods
    
    func configureView() {
        
        // iOS 10 fix to not have white spacing on top
        automaticallyAdjustsScrollViewInsets = false
        
        view.backgroundColor = UIColor.MaverickPrimaryColor
        topView?.backgroundColor = UIColor.clear
        
        // Observe keyboard visibility
        
        navigationController?.setNavigationBarBackground(image: UIImage())
        navigationController?.setDefaultTitleAttributes()
        navigationController?.navigationBar.tintColor = .white
        navigationItem.hidesBackButton = true
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: R.image.back(),
                                                           style: .plain,
                                                           target: self,
                                                           action: #selector(backButtonTapped(_:)))
        navigationController?.setNavigationBarHidden(false, animated: false)
        
        MimageView?.tintColor = UIColor.white
        maverickImage?.tintColor = UIColor.white
     
    }
    
    /**
     Back button pressed to dismiss view
     */
    @objc override func backButtonTapped(_ sender: Any) {
        
        navigationController?.popViewController(animated: false)
        
    }
    
    
    func updateBottomConstraint( value : CGFloat) {
        self.bottomSpaceConstraint?.constant = value
    }
    
    
    /**
     Utility function to draw border around field
     */
    func styleTextViewBorder(_ inputView: UIView) {
        
        inputView.superview?.layer.borderColor = UIColor.maverickGrey.cgColor
        inputView.superview?.layer.borderWidth = 1.0
        inputView.superview?.layer.cornerRadius = (inputView.superview?.frame.height)! / 2
        
    }
    
    func displayAlert(withMessage message: String) {
        
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
        
    }
    
    /**
     Display an activity indicator
     */
    open func showLoadingIndicator(fromViewController vc: UIViewController?) {
        
        if loadingView == nil && vc != nil {
            loadingView = LoadingView.instanceFromNib()
            vc?.view.addSubview(loadingView!)
            
            loadingView?.autoAlignAxis(toSuperviewAxis: .vertical)
            loadingView?.autoAlignAxis(.horizontal, toSameAxisOf: vc!.view, withOffset: -50)
            loadingView?.autoSetDimension(.width, toSize: 240)
            loadingView?.autoSetDimension(.height, toSize: 128)
            
        }
        
        vc?.view.isUserInteractionEnabled = false
        
        loadingView?.titleLabel.text = "One Moment..."
        loadingView?.startAnimating()
        
    }
    
    /**
     Hide an activity indicator
     */
    open func hideLoadingIndicator() {
        
        loadingView?.superview?.isUserInteractionEnabled = true
        loadingView?.stopAnimating()
        loadingView?.removeFromSuperview()
        loadingView = nil
        
    }
    
    // MARK: - Private Methods
    
    /**
     Observe when the keyboard becomes visible and adjusts the scroll view inset. This
     method will only monitor the notification once.
     */
    fileprivate func observeKeyboardWillShow() {
        
        keyboardWillShowId = NotificationCenter.default.addObserver(forName: .UIKeyboardWillShow,
                                                                    object: nil,
                                                                    queue: nil)
        { [weak self] notification in
            
            if let userInfo = notification.userInfo {
                
                self?.adjustToKeyboard(userInfo: userInfo)
                
            }
            
        }
        
    }
    
    fileprivate func adjustToKeyboard(userInfo: [AnyHashable : Any]) {
        
        if let animationDuration = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue,
            let keyboardEndFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue,
            let animCurve = userInfo[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber
        {
            let convertedKeyboardEndFrame = self.view.convert(keyboardEndFrame, from: self.view.window)
            let rawAnimationCurve = animCurve.uint32Value << 16
            let animationCurve = UIViewAnimationOptions(rawValue: UInt(rawAnimationCurve))
           
            self.updateBottomConstraint(value: self.view.bounds.maxY - convertedKeyboardEndFrame.minY)
            
            
            UIView.animate(withDuration: animationDuration, delay: 0.0, options: [.beginFromCurrentState , animationCurve], animations: {
                self.view.layoutIfNeeded()
            }, completion: nil)
            
        }
        
    }
    
    /**
     Observe when the keyboard hides and adjusts the scroll view inset. This
     method will only monitor the notification once.
     */
    fileprivate func observeKeyboardWillHide() {
        
        keyboardWillHideId = NotificationCenter.default.addObserver(forName: .UIKeyboardWillHide,
                                                                    object: nil,
                                                                    queue: nil)
        { [weak self] notification in
            
            
            if let userInfo = notification.userInfo {
                
                self?.adjustToKeyboard(userInfo: userInfo)
            
            }
            
        }
        
    }
    
    func convert(socialChannel : SocialShareChannels) -> Constants.Analytics.Invite.Properties.CONTACT_TYPE {
        
        switch socialChannel {
        case .facebook:
            return .facebook
        case .twitter:
            return .twitter
        case .sms:
            return .phone
        default:
            return .email
        }
    }
    
    
    // MARK: - Overrides
    
    override var prefersStatusBarHidden: Bool {
        return false
    }
    
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .none
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return  .lightContent
    }
    
}


