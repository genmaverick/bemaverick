//
//  OnboardAuthSelectorViewController.swift
//  Maverick
//
//  Created by David McGraw on 5/10/18.
//  Copyright © 2018 BeMaverick. All rights reserved.
//

import Foundation
import TwitterKit
import FBSDKLoginKit

class OnboardAuthSelectorViewController: ViewController {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var contentScrollView: UIScrollView!
    
    @IBOutlet weak var optionSelectorStackView: UIStackView!
    
    @IBOutlet weak var backButton: UIButton!
    
    @IBOutlet weak var showSignUpButton: UIButton!
    
    @IBOutlet weak var showSignInButton: UIButton!
    
    @IBOutlet weak var signUpContainerView: UIView!
    
    @IBOutlet weak var signInContainerView: UIView!
    
    @IBOutlet weak var selectedOptionLayoutConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var optionContainerTopConstraint: NSLayoutConstraint!
    
    // MARK: - IBActions
    
    @IBAction override func backButtonTapped(_ sender: Any) {
        
        if showSignUpButton.isSelected {
            onboardSignupViewController?.backButtonTapped(sender)
        }
        
    }
    
    @IBAction func signUpButtonTapped(_ sender: Any) {
        
        guard !showSignUpButton.isSelected else { return }
        
      
        showSignUpButton.isSelected = true
        showSignInButton.isSelected = false
        
        onboardLoginViewController?.dismissKeyboard()
        
        view.setNeedsUpdateConstraints()
        UIView.animate(withDuration: 0.225) {
        
            self.selectedOptionLayoutConstraint.constant = -(self.showSignUpButton.frame.size.width / 2.0)
            self.contentScrollView.scrollRectToVisible(self.signUpContainerView.frame, animated: true)
            self.view.layoutIfNeeded()
            
        }
        
        onboardSignupViewController?.resetLogin()
        
    }
    
    @IBAction func signInButtonTapped(_ sender: Any) {
        
        guard !showSignInButton.isSelected else { return }
        
        showSignUpButton.isSelected = false
        showSignInButton.isSelected = true
        trackScreen()
        onboardSignupViewController?.dismissKeyboard()
        
        view.setNeedsUpdateConstraints()
        UIView.animate(withDuration: 0.225) {
            
            self.selectedOptionLayoutConstraint.constant = self.showSignUpButton.frame.size.width / 2.0
            self.contentScrollView.scrollRectToVisible(self.signInContainerView.frame, animated: true)
            self.view.layoutIfNeeded()
            
        }
        
        onboardLoginViewController?.resetLogin()
        
    }
    
    // MARK: - Public Properties
    
    /// The `GlobalServicesContainer` that maintains access to global services
    var services: GlobalServicesContainer!
    
    /// The number used to verify SMS auth
    var smsRequestInputPhoneNumber: String = ""
    
    /// The code used for verification
    var smsVerificiationCode: String = ""
    
    // MARK: - Private Properties
    
    weak var onboardSignupViewController: OnboardSignupViewController?
    weak var onboardLoginViewController: OnboardLoginViewController?
    
    // MARK: - Lifecycle
    
    override func trackScreen() {
        
        if showSignUpButton.isSelected {
        
            AnalyticsManager.Onboarding.screenSignup(mode: .initial)
        
        } else if let vc = onboardLoginViewController {
        
            AnalyticsManager.trackScreen(location: vc)
      
        }
    
    }
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        configureView()
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarBackground(image: UIImage())
        navigationController?.setDefaultTitleAttributes()
        navigationController?.navigationBar.tintColor = .white
        navigationItem.hidesBackButton = true
        navigationController?.setNavigationBarHidden(true, animated: false)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let vc = R.segue.onboardAuthSelectorViewController.onboardCompleteSegue(segue: segue)?.destination {
            
            vc.services = services
            
            if !showSignInButton.isSelected && !onboardSignupViewController!.didLogin {
                vc.fromSignup = true
            }
            
        } else if let vc = R.segue.onboardAuthSelectorViewController.awaitOnboardCompleteSegue(segue: segue)?.destination {
            
            vc.services = services
            
            if !showSignInButton.isSelected && !onboardSignupViewController!.didLogin {
                vc.fromSignup = true
            }
            
        } else if let vc = R.segue.onboardAuthSelectorViewController.onboardLoginSegue(segue: segue)?.destination {
            vc.services = services
            vc.authSelectorViewController = self
            onboardLoginViewController = vc
        } else if let vc = R.segue.onboardAuthSelectorViewController.onboardSignupMaverickSegue(segue: segue)?.destination {
            vc.services = services
            vc.authSelectorViewController = self
            onboardSignupViewController = vc
        } else if let vc = R.segue.onboardAuthSelectorViewController.onboardSMSSegueLogin(segue: segue)?.destination {
            vc.services = services
            vc.authSelectorViewController = self
            vc.onboardLoginViewController = onboardLoginViewController
        } else if let vc = R.segue.onboardAuthSelectorViewController.onboardSMSSegueSignup(segue: segue)?.destination {
            vc.services = services
            vc.authSelectorViewController = self
            vc.onboardSignupViewController = onboardSignupViewController
        }
 
    }
    
    // MARK: - Public Methods
    
    func displayCustomNoAccountAlert(forSocialChannel channel: SocialShareChannels) {
        
        guard let vc = R.storyboard.onboarding.onboardMessageControllerId() else {
            return
        }
        
        vc.channel = channel
        vc.delegate = self
        
        self.present(vc, animated: true)
        
    }
    
    func showOptionSelector() {
        
        view.setNeedsUpdateConstraints()
        optionContainerTopConstraint.constant = 0
        view.layoutIfNeeded()
        
    }
    
    func hideOptionSelector() {
        
        view.setNeedsUpdateConstraints()
        optionContainerTopConstraint.constant = -optionSelectorStackView.frame.size.height
        view.layoutIfNeeded()
        
    }
    
    // MARK: - Private Methods
    
    fileprivate func configureView() {
        
        showSignUpButton.setTitleColor(.MaverickPrimaryColor, for: .selected)
        showSignInButton.setTitleColor(.MaverickPrimaryColor, for: .selected)
        selectedOptionLayoutConstraint.constant = -(UIScreen.main.bounds.width / 4.0)
    }
    
}

extension OnboardAuthSelectorViewController: OnboardMessageDelegate {
    
    func shouldCreateAccount(forSocialChannel channel: SocialShareChannels) {
        
        switch channel {
            
        case .facebook:
            signUpButtonTapped(self)
            onboardSignupViewController?.beginFacebookLogin()
            
        case .twitter:
            signUpButtonTapped(self)
            onboardSignupViewController?.beginTwitterLogin()
            
        case .sms:
            
            signUpButtonTapped(self)
            onboardSignupViewController?.beginSMSLogin(withPhone: smsRequestInputPhoneNumber,
                                                       code: smsVerificiationCode)
            dismiss(animated: false, completion: nil)
         
        default:
            break
            
        }
        
        
    }
    
    func shouldRetryVerification(forSocialChannel channel: SocialShareChannels) {
        
        switch channel {
            
        case .facebook:
            
            let fbLoginManager: FBSDKLoginManager = FBSDKLoginManager()
            fbLoginManager.logOut()
            
        case .twitter:
            
            if let userId = TWTRTwitter.sharedInstance().sessionStore.session()?.userID {
                TWTRTwitter.sharedInstance().sessionStore.logOutUserID(userId)
            }
            
        case .sms:
            
            smsRequestInputPhoneNumber = ""
            smsVerificiationCode = ""
            
        default:
            break
            
        }
        
    }
    
}
