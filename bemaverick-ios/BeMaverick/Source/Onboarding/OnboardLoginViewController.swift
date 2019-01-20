//
//  OnboardLoginViewController.swift
//  BeMaverick
//
//  Created by David McGraw on 9/25/17.
//  Copyright © 2017 BeMaverick. All rights reserved.
//

import UIKit
import Signals

class OnboardLoginViewController: OnboardParentViewController {
    
    // MARK: - IBOutlets
    
    /// An input field for a username
    @IBOutlet weak var usernameField: TextInputLayout!
    
    /// An input field for a password
    @IBOutlet weak var passwordField: TextInputLayout!
 
    // MARK: - IBActions
    
    /**
     SMS Login
     */
    @IBAction func smsButtonTapped(_ sender: Any) {
        
        socialChannel = .sms
        AnalyticsManager.Onboarding.trackLoginCTAPressed(channel: .phone)
        authSelectorViewController?.performSegue(withIdentifier: R.segue.onboardAuthSelectorViewController.onboardSMSSegueLogin, sender: self)
   
    }
    
    /**
     IG Login
     */
    @IBAction func igButtonTapped(_ sender: Any) {
        
    }
    
    /**
     FB Login
     */
    @IBAction func fbButtonTapped(_ sender: Any) {
        
        socialChannel = .facebook
        AnalyticsManager.Onboarding.trackLoginCTAPressed(channel: .facebook)
        let processFacebookHandler = {
            
            guard let token = self.services.shareService.accessTokens(forChannel: .facebook).key else {
                
                 AnalyticsManager.Onboarding.trackLoginFailure(apiFailure: true, reason: "Failed to login. No token found.", channel: self.convert(socialChannel : self.socialChannel))
                self.displayAlert(withMessage: "Failed to login. No token found.")
                return
                
            }
            
            self.services.globalModelsCoordinator.authorizeFacebookUserAccount(withAccessToken: token)
            { _, error in
                
                if let err = error {
                    
                    if err.localizedDescription.contains("username is not allowed") {
                        self.authSelectorViewController?.displayCustomNoAccountAlert(forSocialChannel: .facebook)
                    } else {
                        
                         AnalyticsManager.Onboarding.trackLoginFailure(apiFailure: true, reason: err.localizedDescription, channel: self.convert(socialChannel : self.socialChannel))
                        self.displayAlert(withMessage: err.localizedDescription)
                    }
                    
                }
                
            }
            
        }
        
        // The user may already have a valid token. Immediately process if so.
        if let _ = services.shareService.accessTokens(forChannel: .facebook).key {
            processFacebookHandler()
            return
        }
        
        // Login
        services.shareService.login(fromViewController: self,
                                    channel: .facebook,
                                    readOnly: true)
        { error in
            
            if let err = error {
                AnalyticsManager.Onboarding.trackLoginFailure(apiFailure: true, reason: err.localizedDescription, channel: self.convert(socialChannel : self.socialChannel))
                self.displayAlert(withMessage: err.localizedDescription)
                return
            }
            
            processFacebookHandler()
            
        }
        
    }
    
    /**
     Configure signals
     */
    fileprivate func configureSignals() {
        
        
        services.globalModelsCoordinator.authorizationManager.onUserAuthorizedSignal.subscribe(with: self) { [weak self] _ in
            
            guard let socialChannel = self?.socialChannel, socialChannel != .generic else { return }
            log.verbose("🔔 Received user authorized signal")
            self?.authSelectorViewController?.performSegue(withIdentifier: R.segue.onboardAuthSelectorViewController.onboardCompleteSegue, sender: self)
            
        }
        
    }
    
    override func trackScreen() {
        
    }
    /**
     TWTR Login
     */
    @IBAction func twtrButtonTapped(_ sender: Any) {
        
        socialChannel = .twitter
        AnalyticsManager.Onboarding.trackLoginCTAPressed(channel: .twitter)
        var tokens = services.shareService.accessTokens(forChannel: .twitter)
        
        let processTwitterHandler = {
            
            tokens = self.services.shareService.accessTokens(forChannel: .twitter)
            guard let key = tokens.key, let secret = tokens.secret else {
                 AnalyticsManager.Onboarding.trackLoginFailure(apiFailure: true, reason: "Failed to login. No token found.", channel: self.convert(socialChannel : self.socialChannel))
                self.displayAlert(withMessage: "Failed to login. No token found.")
                return
                
            }
            
            self.services.globalModelsCoordinator.authorizeTwitterUserAccount(withAccessToken: key,
                                                                              secret: secret)
            {  _, error in
                
                if let err = error {
                    
                    if err.localizedDescription.contains("username is not allowed") {
                        self.authSelectorViewController?.displayCustomNoAccountAlert(forSocialChannel: .twitter)
                    } else {
                        
                         AnalyticsManager.Onboarding.trackLoginFailure(apiFailure: true, reason: err.localizedDescription, channel: self.convert(socialChannel : self.socialChannel))
                        
                        self.displayAlert(withMessage: err.localizedDescription)
                    }
                    return
                    
                }
                
            }
            
        }
        
        // User already authorized?
        if let _ = tokens.key, let _ = tokens.secret {
            processTwitterHandler()
            return
        }
        
        // Login
        services.shareService.login(fromViewController: self,
                                    channel: .twitter,
                                    readOnly: true)
        { error in
            
            if let err = error {
                AnalyticsManager.Onboarding.trackLoginFailure(apiFailure: true, reason: err.localizedDescription, channel: self.convert(socialChannel : self.socialChannel))
                
                self.displayAlert(withMessage: err.localizedDescription)
                return
                
            }
            
            processTwitterHandler()
            
        }
        
    }
    
    /**
     CTA pressed
     */
    @IBAction func loginButtonTapped(_ sender: Any) {
        
        socialChannel = .generic
        AnalyticsManager.Onboarding.trackLoginCTAPressed(channel: .email)
        guard validateAllFields() else { return }
        handleLoginRequest()
        
    }
    
    // MARK: - Public Properties
    
    /// The `GlobalServicesContainer` that maintains access to global services
    var services: GlobalServicesContainer!
    
    /// The parent auth controller
    weak var authSelectorViewController: OnboardAuthSelectorViewController?
    /// social signin
    private var socialChannel: SocialShareChannels = .generic
    
    // MARK: - Lifecycle
   
    override func viewDidLoad() {
        
        super.viewDidLoad()
       
        configureSignals()
        
    }
    
   
    
    /**
     Back button pressed to dismiss view
     */
    @objc func forgotPressed(_ sender: Any) {
        performSegue(withIdentifier: R.segue.onboardLoginViewController.forgotPasswordSegue, sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let vc = R.segue.onboardLoginViewController.forgotPasswordSegue(segue: segue)?.destination {
            vc.services = services
        } 
        
    }
    
    // MARK: - Public Methods
    
    override func configureView() {
        super.configureView()
        
        usernameField.setHints(shortHint: R.string.maverickStrings.loginUsernameShortHint(), fullHint: R.string.maverickStrings.loginUsernameShortHint())
        
        passwordField.setHints(shortHint: R.string.maverickStrings.loginPasswordHint(), fullHint: R.string.maverickStrings.loginPasswordHint())
        
        ctaButton?.setTitle(R.string.maverickStrings.logInButton(), for: .normal)
        title = nil
        passwordField.entryTextView.isSecureTextEntry = true
        
        passwordField.setAccesoryButton(normalText: R.string.maverickStrings.forgotButton(), delegate: self)
        
        
        passwordField.delegate = self
        usernameField.delegate = self
        usernameField.entryTextView.returnKeyType = .next
        passwordField.entryTextView.returnKeyType = .go
        usernameField.entryTextView.autocorrectionType = .no
        passwordField.entryTextView.autocorrectionType = .no
        
    }
    
    /**
     Dismiss the keyboard
     */
    func dismissKeyboard() {
        
        usernameField.resignFirstResponder()
        passwordField.resignFirstResponder()
        view.endEditing(true)
        
    }
    
    /**
     Reset the login state to the beginning of the flow
     */
    func resetLogin() {
        
        dismissKeyboard()
        
        authSelectorViewController?.showOptionSelector()
        scrollView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0)
        
    }
    
    // MARK: - Private Methods
    
    /**
     Fire API Request
     */
    fileprivate func handleLoginRequest() {
        
        view.endEditing(true)
        if self.services.globalModelsCoordinator.authorizationManager.clientAccessToken == nil {
            services.apiService.getClientAuthorizationToken { response, error in
                
                guard let accessToken = response?.accessToken, error == nil else {
                    
                    AnalyticsManager.Onboarding.trackLoginFailure(apiFailure: true, reason: "Client Token Fail", channel: self.convert(socialChannel : self.socialChannel))
                    let alert = UIAlertController(title: nil, message: R.string.maverickStrings.networkError(), preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                    return
                    
                }
                
                self.services.globalModelsCoordinator.authorizationManager.clientAccessToken = accessToken
            
            }
            
            return
        
        }
        
        ctaButton?.isEnabled = false
        let username = usernameField.entryTextView.text ?? ""
        services.apiService.getUserAuthorizationToken(withUsername: username.trimmingCharacters(in: .whitespaces),
                                                      password: passwordField.entryTextView.text ?? "")
        { response, error in
            
            self.ctaButton?.isEnabled = true
            guard let token = response?.accessToken, let refreshToken = response?.refreshToken, error == nil else {
                
                let errorMessage = error?.localizedDescription ?? R.string.maverickStrings.networkError()
                let alert = UIAlertController(title: nil, message: errorMessage, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                AnalyticsManager.Onboarding.trackLoginFailure(apiFailure: true, reason: errorMessage, channel: self.convert(socialChannel : self.socialChannel))
                self.present(alert, animated: true, completion: nil)
                return
                
            }
            
            
            self.authSelectorViewController?.performSegue(withIdentifier: R.segue.onboardAuthSelectorViewController.awaitOnboardCompleteSegue,
                                                           sender: self)
            
            AnalyticsManager.Onboarding.trackLoginSuccess()
            
            
            // Store token
            self.services.globalModelsCoordinator.authorizationManager.currentAccessToken = (token, refreshToken)
            
            self.services.globalModelsCoordinator.reloadLoggedInUser(completionHandler: {
                
                self.services.globalModelsCoordinator.authorizationManager.onUserAuthorizedSignal.fire(true)
          
            })
                
           
            
        }
        
    }
    
    /**
     Local validation before sending API Request
     */
    fileprivate func validateAllFields() -> Bool {
        
        var allfieldsValid = true;
        var failureString = "validation: "
        if usernameField.entryTextView.text?.count ?? 0 == 0 {
            
            allfieldsValid = false
            usernameField.setValidState(isValid : false, validationText : R.string.maverickStrings.fieldRequired(R.string.maverickStrings.loginUsernameShortHint().lowercased()))
            failureString = "\(failureString) Username"
          
            
        } else {
            
            usernameField.setValidState(isValid : true)
            
        }
        
        if passwordField.entryTextView.text?.count ?? 0 == 0 {
            
            allfieldsValid = false
            passwordField.setValidState(isValid : false, validationText : R.string.maverickStrings.fieldRequired(R.string.maverickStrings.loginPasswordHint()))
            
              failureString = "\(failureString) Password"
            
        } else {
            
            passwordField.setValidState(isValid : true)
            
        }
        
        if !allfieldsValid {
              AnalyticsManager.Onboarding.trackLoginFailure(apiFailure: false, reason: failureString, channel: self.convert(socialChannel : self.socialChannel))
        }
        return allfieldsValid
        
    }
    
    
    
    
}

extension OnboardLoginViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField == usernameField.entryTextView {
            
            passwordField.entryTextView.becomeFirstResponder()
            return false
            
        } else {
            
            passwordField.entryTextView.resignFirstResponder()
            loginButtonTapped(textField)
            
        }
        return true
        
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        UIView.animate(withDuration: 0.225) {
            self.scrollView.contentInset = UIEdgeInsetsMake(-180, 0, 0, 0)
        }
        
    }
    
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextFieldDidEndEditingReason) {
        
        UIView.animate(withDuration: 0.225) {
            self.scrollView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0)
        }
        
    }
    
}

extension OnboardLoginViewController : TextInputLayoutDelegate {
   
    /**
     Forgot password tapped
     */
    func accesoryButtonTapped(_ sender: TextInputLayout) {
      
        AnalyticsManager.Onboarding.trackForgotPasswordPressed()
        performSegue(withIdentifier: R.segue.onboardLoginViewController.forgotPasswordSegue, sender: self)
        
    }

}
