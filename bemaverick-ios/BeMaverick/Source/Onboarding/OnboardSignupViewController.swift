//
//  OnboardSignupViewController.swift
//  BeMaverick
//
//  Created by David McGraw on 9/25/17.
//  Copyright © 2017 BeMaverick. All rights reserved.
//

import Foundation
import UIKit
import Signals

public enum SignupMode: String  {
    
    case initial    = "initial"
    case birthdate  = "birthdate"
    case email      = "email"
    case username   = "username"
    
}

class OnboardSignupViewController: OnboardParentViewController {
    
    // MARK: - IBOutlets
    
    /// An input field for a username
    @IBOutlet weak var usernameField: TextInputLayout!
    
    /// An input field for a username used later in the flow for social
    @IBOutlet weak var secondaryUsernameField: TextInputLayout!
    
    /// An input field for a password
    @IBOutlet weak var passwordField: TextInputLayout!
    
    /// A button to initiate a signup request
    @IBOutlet weak var showPasswordButton: UIButton!
    
    /// Text of the TOS disclaimer - clickable to webview
    @IBOutlet weak var tosTextButton: UIButton!
    
    /// birthday not public label
    @IBOutlet weak var birthdayReassuranceLabel: UILabel!
    
    /// CTA button on birthday mode
    @IBOutlet weak var birthdateCTA: CTAButton!
    
    /// CTA button on email mode
    @IBOutlet weak var emailCTA: CTAButton!
    
    /// CTA button on username mode
    @IBOutlet weak var usernameCTA: CTAButton!
    
    /// The birthday container
    @IBOutlet weak var birthdateContainer: UIView!
    
    /// Extra title shown in the birthday mode
    @IBOutlet weak var birthdateTitle: UILabel!
    
    /// Birth Year entry
    @IBOutlet weak var yearTextInput: TextInputLayout!
    
    /// Birth Day entry
    @IBOutlet weak var dayTextInput: TextInputLayout!
    
    /// Birth Month entry
    @IBOutlet weak var monthTextInput: TextInputLayout!
    
    /// Email entry (parent or self)
    @IBOutlet weak var emailTextInput: TextInputLayout!
    
    /// Container during email mode
    @IBOutlet weak var emailContainer: UIView!
    
    /// Container during username mode
    @IBOutlet weak var usernameContainer: UIView!
    
    /// initial mode container
    @IBOutlet weak var initialContainer: UIView!
    
    // MARK: - IBActions
    
    /**
     SMS Register
     */
    @IBAction func smsButtonTapped(_ sender: Any) {
        AnalyticsManager.Onboarding.trackSignupInitialCTAPressed(channel: .phone)
        beginSocialLogin(forChannel: .sms)
    }
    
    /**
     IG Register
     */
    @IBAction func igButtonTapped(_ sender: Any) {
        
    }
    
    /**
     FB Register
     */
    @IBAction func fbButtonTapped(_ sender: Any) {
        AnalyticsManager.Onboarding.trackSignupInitialCTAPressed(channel: .facebook)
        beginSocialLogin(forChannel: .facebook)
    }
    
    /**
     TWTR Register
     */
    @IBAction func twtrButtonTapped(_ sender: Any) {
        AnalyticsManager.Onboarding.trackSignupInitialCTAPressed(channel: .twitter)
        beginSocialLogin(forChannel: .twitter)
    }
    
    /**
     TOS tapped, send to TOS text
     */
    @IBAction func viewAgreementTapped(_ sender: Any) {
        
        AnalyticsManager.Onboarding.trackTOSPressed()
        let urlToDisplay = URL(string: Constants.termsOfServiceURL)
        let webViewController = NavigationViewController(rootViewController: WebContentViewController(url: urlToDisplay!, webViewTitle: "Terms Of Service"))
        present(webViewController, animated: true, completion: nil)
        
    }
    
    
    /**
     Sign up button pressed, checks for validation before executing
     */
    @IBAction func signUpTapped(_ sender: Any) {
        
        switch signupMode {
        case .initial:
              AnalyticsManager.Onboarding.trackSignupInitialCTAPressed(channel: convert(socialChannel: .generic))
        case .birthdate:
              AnalyticsManager.Onboarding.trackSignupDobCTAPressed(channel: convert(socialChannel: socialChannel))
        case .email:
             AnalyticsManager.Onboarding.trackSignupEmailCTAPressed()
        case .username:
             AnalyticsManager.Onboarding.trackSocialUsernameEntryCTAPressed(channel: convert(socialChannel: socialChannel))
        }
       
        
        dismissKeyboard()
        guard allFieldsValid() else {
            
            if !over13 {
                displayAlert(withMessage: R.string.maverickStrings.under13SocialLoginError())
                resetLogin()
            }
            return
            
        }
        
        switch signupMode {
        case .initial:
            handleAttemptUsername()
            
        case .birthdate:
            
            if socialChannel == .generic {
                signupMode = .email
            } else {
                
                if !isSocialLoginAuthorized {
                    handleSocialLogin()
                    return
                }
                signupMode = .username
                
            }
            
            scrollTo(rect: emailContainer.frame)
            let longHintText = over13 ? R.string.maverickStrings.over13EmailHint() : R.string.maverickStrings.under13EmailHint()
            let shortHintText = over13 ? R.string.maverickStrings.over13EmailShortHint() : R.string.maverickStrings.under13EmailShortHint()
            emailTextInput.setHints(shortHint: shortHintText, fullHint: longHintText)
            
        case .email:
            handleSignupRequest()
        case .username:

            handleAttemptUsername(skipAdvancement: true) { isValid in
                
                if isValid {
                    
                    self.handleSocialSignupRequest()
                
                }
                
            }
            
        }
        
    }
    
    /**
     Navigate through modes when back tapped
     */
    override func backButtonTapped(_ sender: Any) {
        
        dismissKeyboard()
        
        switch signupMode {
        case .initial:
            super.backButtonTapped(sender)
            
        case .birthdate:
            signupMode = .initial
            scrollTo(rect: initialContainer.frame)
            authSelectorViewController?.backButton.isHidden = true
            authSelectorViewController?.showOptionSelector()
            
        case .email:
            signupMode = .birthdate
            scrollTo(rect: birthdateContainer.frame)
            
        case .username:
            signupMode = .birthdate
            scrollTo(rect: birthdateContainer.frame)
            
        }
  
    }
    
    // MARK: - Private Properties
    
    /// current signup mode
    private var signupMode: SignupMode = .initial
    
    /// Reference to the social keys
    private var signupSocialKeys: (key: String?, secret: String?) = (nil, nil)
    
    /// calculated value for over 13
    private var over13 = true
    
    /// has the user gone through the login flow
    private var isSocialLoginAuthorized: Bool {
        
        if let _ = signupSocialKeys.key {
            return true
        } else if (authSelectorViewController?.smsVerificiationCode ?? "") != "" {
            return true
        }
        return false
        
    }
    
    /// entered birthdate
    private var selectedDate : Date?
    
    /// entered username
    private var selectedUsername : String?
    
    /// entered email
    private var selectedEmail : String?
    
    /// entered password
    private var selectedPassword : String?
    
    /// social signin
    private var socialChannel: SocialShareChannels = .generic
    
    // MARK: - Public Properties
    
    /// The `GlobalServicesContainer` that maintains access to global services
    var services: GlobalServicesContainer!
    
    /// The parent auth controller
    weak var authSelectorViewController: OnboardAuthSelectorViewController?
    
    /// When authorizing via Social an account may already exist. Login instead.
    private(set) var didLogin = false
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        configureView()
        configureSignals()
        
    }
    
    override func trackScreen() {
        
        
   
    }
    
    // MARK: - Public Methods
    
    /**
     Initialize Views
     */
    override func configureView() {
        
        super.configureView()
        
        birthdateTitle.text = R.string.maverickStrings.birthdateTitle()
        birthdateCTA.setTitle(R.string.maverickStrings.birthdateCTA(), for: .normal)
        emailCTA.setTitle(R.string.maverickStrings.signupEmailCTA(), for: .normal)
        usernameCTA.setTitle(R.string.maverickStrings.usernameCTA(), for: .normal)
        
        yearTextInput.setHints(shortHint: "YYYY", fullHint: "YYYY")
        dayTextInput.setHints(shortHint: "DD", fullHint: "DD")
        monthTextInput.setHints(shortHint: "MM", fullHint: "MM")
        
        birthdayReassuranceLabel.text = R.string.maverickStrings.birthdayReassurance()
        birthdayReassuranceLabel.textColor = UIColor.MaverickDarkSecondaryTextColor
        
        passwordField.setAccesoryButton(normalText: R.string.maverickStrings.show(), selectedText: R.string.maverickStrings.hide(),  delegate: self)
        
        let boldCopy = R.string.maverickStrings.termsOfServiceMainBold()
        let copy = R.string.maverickStrings.termsOfServiceMainBody(boldCopy)
        let color = UIColor.black.withAlphaComponent(0.6)
        
        let attributedText = copy.boldSubstrings(withColor: color,
                                                 substrings: [ boldCopy ],
                                                 boldFont: R.font.openSansRegular(size: 12.0)!,
                                                 regularFont: R.font.openSansRegular(size: 12.0)!,
                                                 regulardColor:  color)
        
        tosTextButton.setAttributedTitle(attributedText, for: .normal)
        
        usernameField.setHints(shortHint: R.string.maverickStrings.loginUsernameShortHint(), fullHint: R.string.maverickStrings.signupUsernameHint())
        secondaryUsernameField.setHints(shortHint: R.string.maverickStrings.loginUsernameShortHint(), fullHint: R.string.maverickStrings.signupUsernameHint())
        
        passwordField.setHints(shortHint: R.string.maverickStrings.loginPasswordHint(), fullHint: R.string.maverickStrings.signupPasswordHint())
        passwordField.entryTextView.isSecureTextEntry = true
        ctaButton?.setTitle(R.string.maverickStrings.signUpButtonTitle(), for: .normal)
        
        usernameField.charLimit = 15
        secondaryUsernameField.charLimit = 15
        
        usernameField.delegate = self
        passwordField.delegate = self
        secondaryUsernameField.delegate = self
        dayTextInput.delegate = self
        monthTextInput.delegate = self
        yearTextInput.delegate = self
        emailTextInput.delegate = self
        
        usernameField.entryTextView.returnKeyType = .next
        usernameField.entryTextView.autocorrectionType = .no
        secondaryUsernameField.entryTextView.returnKeyType = .go
        secondaryUsernameField.entryTextView.autocorrectionType = .no
        passwordField.entryTextView.autocorrectionType = .no
        passwordField.entryTextView.returnKeyType = .join
        
        monthTextInput.entryTextView.returnKeyType = .next
        dayTextInput.entryTextView.returnKeyType = .next
        yearTextInput.entryTextView.returnKeyType = .next
        
        emailTextInput.entryTextView.returnKeyType = .go
        emailTextInput.entryTextView.autocorrectionType = .no
        emailTextInput.entryTextView.autocapitalizationType = .none
        if #available(iOS 11.0, *) {
            emailTextInput.entryTextView.smartQuotesType = .no
            emailTextInput.entryTextView.smartDashesType = .no
        } else {
            // Fallback on earlier versions
        }
        
        monthTextInput.entryTextView.keyboardType = .numberPad
        dayTextInput.entryTextView.keyboardType = .numberPad
        yearTextInput.entryTextView.keyboardType = .numberPad
        emailTextInput.entryTextView.keyboardType = .emailAddress
        
        scrollView.delegate = self
        
    }
    
    /**
     Dismiss the keyboard
     */
    func dismissKeyboard() {
        
        usernameField.resignFirstResponder()
        secondaryUsernameField.resignFirstResponder()
        passwordField.resignFirstResponder()
        view.endEditing(true)
        
    }
    
    /**
     Reset the login state to the beginning of the flow
     */
    func resetLogin() {
        
        dismissKeyboard()
        
        socialChannel = .generic
        
        emailContainer.isHidden = false
        usernameContainer.isHidden = true
        authSelectorViewController?.backButton.isHidden = true
        authSelectorViewController?.showOptionSelector()
        
        scrollView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0)
        
        signupMode = .initial
        scrollTo(rect: initialContainer.frame)
        
    }
    
    /**
     Begin registration using the user's phone number
     */
    func beginSMSLogin(withPhone phone: String, code: String) {
        
        authSelectorViewController!.smsRequestInputPhoneNumber = phone
        authSelectorViewController!.smsVerificiationCode = code
        
        /// Begin the social login process or advance to the next step
        if socialChannel == .generic {
            beginSocialLogin(forChannel: .sms)
        } else {
            signupMode = .username
            scrollTo(rect: usernameContainer.frame)
        }
        
    }
    
    /**
     Assuming a key already exists this will skip auth and create the account
     */
    func beginFacebookLogin() {
        beginSocialLogin(forChannel: .facebook)
    }
    
    /**
     Assuming a key already exists this will skip auth and create the account
     */
    func beginTwitterLogin() {
        beginSocialLogin(forChannel: .twitter)
    }
    
    /**
     Check for validity of username/password
     */
    fileprivate func allInitialFieldsValid() -> Bool {
        
        var allFieldsValid = true
        var reasonString = "validation: "
        
        let activeUsernameField = socialChannel == .generic ? usernameField : secondaryUsernameField
        
        selectedUsername = activeUsernameField!.entryTextView.text?.trimmingCharacters(in: .whitespaces)
        selectedPassword = passwordField.entryTextView.text
        
        if let usernameInputCount = activeUsernameField!.entryTextView.text?.count, usernameInputCount > 3 {
            
            activeUsernameField!.setValidState(isValid: true)
        
        } else {
            
            activeUsernameField!.setValidState(isValid: false,
                                               validationText: R.string.maverickStrings.fieldRequiredWithQuantity(R.string.maverickStrings.loginUsernameShortHint().lowercased(), 3))
            reasonString = "\(reasonString) Username"
            allFieldsValid = false
            
        }
        
        if socialChannel == .generic {
            
            if let passwordInputCount = passwordField.entryTextView.text?.count, passwordInputCount >= 6 {
                passwordField.setValidState(isValid: true)
            } else {
                
                reasonString = "\(reasonString) Password"
                passwordField.setValidState(isValid: false, validationText: R.string.maverickStrings.fieldRequiredWithQuantity(R.string.maverickStrings.loginPasswordHint().lowercased(), 6))
                allFieldsValid = false
                
            }
            
        }
        
        if !allFieldsValid {
            
            AnalyticsManager.Onboarding.trackSignupFailure(apiFailure: false, reason: reasonString, mode: self.signupMode, channel: convert(socialChannel : socialChannel))
        
        }
        
        return allFieldsValid
        
    }
    
    
    /**
     Fire Sign up Request
     
     - parameter skipAdvancement:   If ture this method will not auto-advance to the birthday container
     */
    fileprivate func handleAttemptUsername(skipAdvancement: Bool = false, completionHandler: ((_ isValid: Bool) -> Void)? = nil) {
        
        if self.services.globalModelsCoordinator.authorizationManager.clientAccessToken == nil {
            services.apiService.getClientAuthorizationToken { response, error in
                guard let accessToken = response?.accessToken, error == nil else {
                    
                    AnalyticsManager.Onboarding.trackSignupFailure(apiFailure: true, reason: "Client Token Fail", mode: self.signupMode, channel: self.convert(socialChannel : self.socialChannel))
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
        services.apiService.validateAvailability(withUsername: selectedUsername ?? "") { (response , error) in
            self.ctaButton?.isEnabled = true
            guard error == nil else {
                
                var message = error?.localizedDescription
                if message == "" {
                    message = R.string.maverickStrings.networkError()
                }
                
                AnalyticsManager.Onboarding.trackSignupFailure(apiFailure: true, reason: message ?? "", mode: self.signupMode, channel: self.convert(socialChannel : self.socialChannel))
                let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                
                completionHandler?(false)
                
                return
                
            }
            
            completionHandler?(true)
            
            self.authSelectorViewController?.hideOptionSelector()
            
            if !skipAdvancement {
                self.authSelectorViewController?.backButton.isHidden = false
                self.signupMode = .birthdate
                self.scrollTo(rect: self.birthdateContainer.frame)
            }
            
        }
        
    }
    
   
    /**
     Complete signup request using social login
    */
    fileprivate func handleSocialSignupRequest() {
        
        
        usernameCTA.isEnabled = false
        secondaryUsernameField.entryTextView.resignFirstResponder()
        
        let formattedBirthdate = (selectedDate ?? Date()).toString(dateFormat: "YYYY-MM-dd")
        
        switch socialChannel {
            
        case .twitter:
            
        services.globalModelsCoordinator.authorizeTwitterUserAccount(withAccessToken: signupSocialKeys.key ?? "",
                                                                     secret: signupSocialKeys.secret ?? "",
                                                                     username: selectedUsername,
                                                                     birthdate: formattedBirthdate)
        { response, error in
            
            self.usernameCTA.isEnabled = true
            
            if let err = error {
                AnalyticsManager.Onboarding.trackSocialSignupFailure(channel: self.convert(socialChannel: self.socialChannel), reason: err.localizedDescription)
                self.displayAlert(withMessage: err.localizedDescription)
                return
                
            }
            
            AnalyticsManager.Onboarding.trackSocialSignupSuccess(channel: self.convert(socialChannel: self.socialChannel))
            Leanplum.forceContentUpdate()
            
        }
            
        case .facebook:
            
            services.globalModelsCoordinator.authorizeFacebookUserAccount(withAccessToken: signupSocialKeys.key ?? "",
                                                                          username: selectedUsername,
                                                                          birthdate: formattedBirthdate)
            { response, error in
                
                self.usernameCTA.isEnabled = true
                
                if let err = error {
                     AnalyticsManager.Onboarding.trackSocialSignupFailure(channel: self.convert(socialChannel: self.socialChannel), reason: err.localizedDescription)
                    
                    self.displayAlert(withMessage: err.localizedDescription)
                    return
                    
                }
                 AnalyticsManager.Onboarding.trackSocialSignupSuccess(channel: self.convert(socialChannel: self.socialChannel))
                Leanplum.forceContentUpdate()
                
            }
            
        case .instagram:
            break
            
        case .sms:
            
            services.globalModelsCoordinator.smsCodeConfirm(withPhoneNumber: authSelectorViewController!.smsRequestInputPhoneNumber,
                                                            code: authSelectorViewController!.smsVerificiationCode,
                                                            username: selectedUsername,
                                                            birthdate: formattedBirthdate)
            { response, error in
                
                self.usernameCTA.isEnabled = true
                
                if let err = error {
                     AnalyticsManager.Onboarding.trackSocialSignupFailure(channel: self.convert(socialChannel: self.socialChannel), reason: err.localizedDescription)
                    self.displayAlert(withMessage: err.localizedDescription)
                    return
                    
                }
                 AnalyticsManager.Onboarding.trackSocialSignupSuccess(channel: self.convert(socialChannel: self.socialChannel))
                Leanplum.forceContentUpdate()
                
            }
                
        default:
            break
            
        }
        
    }
    
    /**
     Fire Sign up Request
     */
    fileprivate func handleSignupRequest() {
        
        
        emailCTA.isEnabled = false
        let myStringafd = (selectedDate ?? Date()).toString(dateFormat: "YYYY-MM-dd")
        emailTextInput.entryTextView.resignFirstResponder()
        services.apiService.registerUserAccount(withAccountType: .maverick,
                                                username: selectedUsername ?? "",
                                                password: selectedPassword ?? "",
                                                dateOfBirth: myStringafd,
                                                kidEmail: over13 ? selectedEmail ?? "" : "",
                                                parentEmail: !over13 ? selectedEmail ?? "" : ""
            )
        { response, error in
            
            self.emailCTA.isEnabled = true
            
           
            
            guard let token = response?.accessToken, let refreshToken = response?.refreshToken, error == nil else {
                
                var message = error?.localizedDescription
                if message == "" {
                    message = R.string.maverickStrings.networkError()
                }
                
                AnalyticsManager.Onboarding.trackSignupFailure(apiFailure: true, reason: message ?? "", mode: self.signupMode, channel: self.convert(socialChannel : self.socialChannel))
                
                let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                return
                
            }
          
            self.authSelectorViewController?.performSegue(withIdentifier: R.segue.onboardAuthSelectorViewController.awaitOnboardCompleteSegue,
                                                          sender: self)
            
            
             // Store token
            self.services.globalModelsCoordinator.authorizationManager.currentAccessToken = (token, refreshToken)
           
           
           print("📷 access token = \(token)")
            self.services.globalModelsCoordinator.reloadLoggedInUser(completionHandler: {
                
                
                Leanplum.forceContentUpdate()
                self.services.globalModelsCoordinator.authorizationManager.onUserAuthorizedSignal.fire(true)
                
            })
           
            
        }
        
    }
    
    /**
     Check for validity of DoB
     */
    fileprivate func allBirthdateValid() -> Bool {
        var allFieldsValid = true
        var reasonString = "validation: "
        
        if let dayValue = Int(dayTextInput.entryTextView.text ?? "100"), dayValue <= 31 && dayValue > 0 {
            
            dayTextInput.setValidState(isValid: true)
            
        } else {
            
            reasonString = "\(reasonString) DOB - day"
            dayTextInput.setValidState(isValid: false)
            allFieldsValid = false
            
        }
        
        if let monthValue = Int(monthTextInput.entryTextView.text ?? "100"), monthValue <= 12 && monthValue > 0 {
            
            monthTextInput.setValidState(isValid: true)
            
        } else {
            
            reasonString = "\(reasonString) DOB - month"
            monthTextInput.setValidState(isValid: false)
            allFieldsValid = false
            
        }
        if let yearValue = Int(yearTextInput.entryTextView.text ?? "100"), yearValue <= 2020 && yearValue > 1900 {
            
            yearTextInput.setValidState(isValid: true)
            
        } else {
            
            reasonString = "\(reasonString) DOB - year"
            yearTextInput.setValidState(isValid: false)
            allFieldsValid = false
            
        }
        
        if allFieldsValid {
            
            if !setSelectedDateAndAge() {
                
                allFieldsValid = false
                reasonString = "\(reasonString) DOB - future"
                dayTextInput.setValidState(isValid: false)
                monthTextInput.setValidState(isValid: false)
                yearTextInput.setValidState(isValid: false)
                
            }
            
        }
        
        if !allFieldsValid {
            AnalyticsManager.Onboarding.trackSignupFailure(apiFailure: false, reason: reasonString, mode: self.signupMode, channel: self.convert(socialChannel : self.socialChannel))
        }
        
        return allFieldsValid
    }
    
    /**
     Validate fields and return date if valid
     */
    public func setSelectedDateAndAge() -> Bool {
        
        let c = NSDateComponents()
        c.year = Int(yearTextInput.entryTextView.text ?? "-1") ?? 0
        c.month = Int(monthTextInput.entryTextView.text ?? "-1") ?? 0
        c.day =  Int(dayTextInput.entryTextView.text ?? "-1") ?? 0
        
        selectedDate = NSCalendar(identifier: NSCalendar.Identifier.gregorian)?.date(from: c as DateComponents)
        
        if let interval =  selectedDate?.timeIntervalSinceNow {
            
            let years = -(interval / 60 / 60 / 24 / 365)
            over13 = years >= 13
            
            return interval < 0
            
        }
        
        return false
        
    }
    
    private func isValidEmail(testStr:String?) -> Bool {
        
        guard let testStr = testStr else { return false }
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }
    
    /**
     Check for validity of email
     */
    fileprivate func allEmailValid() -> Bool {
        
        var allFieldsValid = true
        var reasonString = "validation: "
        
        selectedEmail = emailTextInput.entryTextView.text
        
        if isValidEmail(testStr: emailTextInput.entryTextView.text)
        {
            
            emailTextInput.setValidState(isValid: true)
            
        } else {
            
            allFieldsValid = false
            emailTextInput.setValidState(isValid: false, validationText: R.string.maverickStrings.invalidEmail())
            reasonString = "\(reasonString) Email"
            
        }
        
        
        if !allFieldsValid {
            AnalyticsManager.Onboarding.trackSignupFailure(apiFailure: false, reason: reasonString, mode: self.signupMode, channel: self.convert(socialChannel : self.socialChannel))
            emailTextInput.entryTextView.becomeFirstResponder()
        }
        
        return allFieldsValid
        
    }
    
    /**
     Main validation for all fields
     */
    fileprivate func allFieldsValid() -> Bool {
        
        switch signupMode {
        case .initial:
            return allInitialFieldsValid()
        case .birthdate:
            
            var isValid = allBirthdateValid()
            if (socialChannel == .facebook || socialChannel == .twitter || socialChannel == .instagram || socialChannel == .sms) {
                
                if !over13 {
                    isValid = false
                }
                
            }
            return isValid
            
        case .email:
            return allEmailValid()
        case .username:
            return allInitialFieldsValid()
            
        }
        
    }
    
    /**
     Begin the social login flow
     */
    fileprivate func beginSocialLogin(forChannel channel: SocialShareChannels) {
        
        authSelectorViewController?.backButton.isHidden = false
        
        socialChannel = channel
        
        emailContainer.isHidden = true
        usernameContainer.isHidden = false
        
        authSelectorViewController?.hideOptionSelector()
        
       
       
        if selectedDate != nil && authSelectorViewController!.smsRequestInputPhoneNumber != "" && authSelectorViewController!.smsVerificiationCode != "" {
       
            didLogin = false
            self.signupMode = .username
            self.scrollTo(rect: self.usernameContainer.frame)
        
        } else {
            
            signupMode = .birthdate
            scrollTo(rect: birthdateContainer.frame)
        
        }
        
    }
    
    /**
     Begin the auth flow using the value set on `socialChannel`
    */
    fileprivate func handleSocialLogin() {
        
        switch socialChannel {
        case .facebook:
            handleFacebookAuth()
        case .twitter:
            handleTwitterAuth()
        case .sms:
            handleSMSAuth()
        default:
            break
        }
        
    }
    
    /**
     Facebook Auth
    */
    fileprivate func handleFacebookAuth() {
        
        var tokens = services.shareService.accessTokens(forChannel: .facebook)
        
        let processFacebookHandler = {
            
            self.showLoadingIndicator(fromViewController: self)
            
            // Refresh
            tokens = self.services.shareService.accessTokens(forChannel: .facebook)
            
            guard let key = tokens.key else {
                
                self.hideLoadingIndicator()
                self.displayAlert(withMessage: "Failed to login. No token found.")
                 AnalyticsManager.Onboarding.trackSignupFailure(apiFailure: true, reason: "Failed to login. No token found.", mode: self.signupMode, channel: self.convert(socialChannel : self.socialChannel))
                return
                
            }
            
            // Assume success and flip it back if we did not log in
            self.didLogin = true
            
            // Double check to see if this user isn't already registered
            self.services.globalModelsCoordinator.authorizeFacebookUserAccount(withAccessToken: key)
            { _, error in

                if let _ = error {
            
                    self.didLogin = false
                    self.signupSocialKeys = tokens
                    
                    self.signupMode = .username
                    self.scrollTo(rect: self.usernameContainer.frame)
                    
                }
                
                self.hideLoadingIndicator()

            }
            
        }
        
        // The user may already have a valid token. Immediately process if so.
        if let _ = tokens.key {
            processFacebookHandler()
            return
        }
        
        // Login
        services.shareService.login(fromViewController: self,
                                    channel: .facebook,
                                    readOnly: true)
        { error in
            
            if let err = error {
                 AnalyticsManager.Onboarding.trackSignupFailure(apiFailure: true, reason: err.localizedDescription, mode: self.signupMode, channel: self.convert(socialChannel : self.socialChannel))
                self.hideLoadingIndicator()
                self.displayAlert(withMessage: err.localizedDescription)
                return
            }
            
            processFacebookHandler()
            
        }
        
    }
    
    /**
     Twitter Auth
    */
    fileprivate func handleTwitterAuth() {
        
        var tokens = self.services.shareService.accessTokens(forChannel: .twitter)
        
        let processTwitterHandler = {
        
            self.showLoadingIndicator(fromViewController: self)
            
            tokens = self.services.shareService.accessTokens(forChannel: .twitter)
            guard let key = tokens.key, let secret = tokens.secret else {
                
                self.hideLoadingIndicator()
                 AnalyticsManager.Onboarding.trackSignupFailure(apiFailure: true, reason: "Failed to login. No token found.", mode: self.signupMode, channel: self.convert(socialChannel : self.socialChannel))
                self.displayAlert(withMessage: "Failed to login. No token found.")
                return
                
            }
            
            // Assume success and flip it back if we did not log in
            self.didLogin = true
            
            // Double check to see if this user isn't already registered
            self.services.globalModelsCoordinator.authorizeTwitterUserAccount(withAccessToken: key, secret: secret)
            { _, error in
                
                if let _ = error {
                    
                    self.didLogin = false
                    self.signupSocialKeys = tokens
                    
                    self.signupMode = .username
                    self.scrollTo(rect: self.usernameContainer.frame)
                    
                }
                
                self.hideLoadingIndicator()
                
            }
            
            
        }
        
        // The user may already have valid tokens. Immediately process if so.
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
                 AnalyticsManager.Onboarding.trackSignupFailure(apiFailure: true, reason: err.localizedDescription, mode: self.signupMode, channel: self.convert(socialChannel : self.socialChannel))
                self.hideLoadingIndicator()
                
                let errorMessage: String = {
                    
                    if err.localizedDescription.contains("403") {
                        
                        return R.string.maverickStrings.twitterSignUpErrorAppNotInstalled()
                        
                    } else if err.localizedDescription.contains("cancelled") {
                        
                        return R.string.maverickStrings.twitterSignUpErrorUserCancelled()
                        
                    } else {
                        
                        return err.localizedDescription
                        
                    }
                
                }()
                
                self.displayAlert(withMessage: errorMessage)
                return
                
            }
            
            processTwitterHandler()
            
        }
        
    }
    
    /**
     SMS Auth
    */
    fileprivate func handleSMSAuth() {
        
        // Did the user already auth?
        if authSelectorViewController!.smsRequestInputPhoneNumber != "" && authSelectorViewController!.smsVerificiationCode != "" {
            
            didLogin = false
            authSelectorViewController?.hideOptionSelector()
            
            if !allBirthdateValid() {
              
                signupMode = .birthdate
                scrollTo(rect: birthdateContainer.frame)
                
            } else {
                
                signupMode = .username
                scrollTo(rect: usernameContainer.frame)
                
            }
            
        } else {
            
            didLogin = true
            authSelectorViewController?.performSegue(withIdentifier: R.segue.onboardAuthSelectorViewController.onboardSMSSegueSignup, sender: self)
            
        }
        
    }
    
    private func scrollTo(rect : CGRect) {
        
        AnalyticsManager.Onboarding.screenSignup(mode: signupMode)
        scrollView.scrollRectToVisible(rect, animated: true)
        
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
    
}

extension OnboardSignupViewController : UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField == usernameField.entryTextView || textField == secondaryUsernameField.entryTextView {
            
            passwordField.entryTextView.becomeFirstResponder()
            return false
            
        } else if textField == passwordField.entryTextView {
            
            signUpTapped(textField)
            
            
        } else if textField == monthTextInput.entryTextView {
            
            dayTextInput.entryTextView.becomeFirstResponder()
            return false
            
        } else if textField == dayTextInput.entryTextView {
            
            yearTextInput.entryTextView.becomeFirstResponder()
            return false
            
        } else if textField == yearTextInput.entryTextView {
            
            signUpTapped(textField)
            
        } else if textField == emailTextInput.entryTextView {
            
            signUpTapped(textField)
            
        } else if textField == secondaryUsernameField.entryTextView {
            
            signUpTapped(textField)
            
        }
        
        return true
        
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        UIView.animate(withDuration: 0.225) {
            
            if self.signupMode == .initial {
                self.scrollView.contentInset = UIEdgeInsetsMake(-180, 0, 0, 0)
            } else {
                self.scrollView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0)
            }
            
        }
        
    }
    
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextFieldDidEndEditingReason) {
        
        if textField == usernameField.entryTextView || textField == secondaryUsernameField.entryTextView {
            if var text =  textField.text {
                let components = text.components(separatedBy: NSCharacterSet.whitespacesAndNewlines)
                text = components.filter { !$0.isEmpty }.joined(separator: " ")
                textField.text = text.replacingOccurrences(of: " ", with: "_")
            }
        }
        
        if textField == usernameField.entryTextView {
            UIView.animate(withDuration: 0.225) {
                self.scrollView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0)
            }
        }
        
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if textField == usernameField.entryTextView || textField == secondaryUsernameField.entryTextView {
            
            let aSet = NSCharacterSet(charactersIn:"qwertyuiopasdfghjklzxcvbnmQWERTYUIOPASDFGHJKLMNBVCXZ_-.0123456789 ").inverted
            let compSepByCharInSet = string.components(separatedBy: aSet)
            let numberFiltered = compSepByCharInSet.joined(separator: "")
            if string != numberFiltered {
                
                let activeUsernameField = socialChannel == .generic ? usernameField : secondaryUsernameField
                activeUsernameField!.setValidState(isValid: false, validationText: R.string.maverickStrings.usernameCharacterValidation() )
                
            }
            return string == numberFiltered
        }
        
        var maxLength = 100
        let currentCharacterCount = textField.text?.count ?? 0
        if textField == dayTextInput.entryTextView || textField == monthTextInput.entryTextView {
            
            maxLength = 2
            
            if string.count > 0 && string.count + (textField.text?.count ?? 0) == maxLength {
                if textField == monthTextInput.entryTextView  {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        self.dayTextInput.entryTextView.becomeFirstResponder()
                        
                    }
                } else {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        self.yearTextInput.entryTextView.becomeFirstResponder()
                    }
                }
            }
            
        } else if textField == yearTextInput.entryTextView {
            
            maxLength = 4
            
        }
        
        
        if (range.length + range.location > currentCharacterCount) {
            return false
        }
        let newLength = currentCharacterCount + string.count - range.length
        return newLength <= maxLength
        
    }
    
}

extension OnboardSignupViewController : UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        switch signupMode {
        case .initial:
            scrollView.contentOffset.x = 0.0
        case .birthdate:
            monthTextInput.entryTextView.becomeFirstResponder()
            scrollView.contentOffset.x = birthdateContainer.frame.origin.x
        case .email:
            emailTextInput.entryTextView.becomeFirstResponder()
            scrollView.contentOffset.x = emailContainer.frame.origin.x
        case .username:
            secondaryUsernameField.entryTextView.becomeFirstResponder()
            scrollView.contentOffset.x = usernameContainer.frame.origin.x
        }
        
    }
    
}

extension OnboardSignupViewController : TextInputLayoutDelegate {
    
    func accesoryButtonTapped(_ sender: TextInputLayout) {
        
        sender.entryTextView.isSecureTextEntry = !sender.entryTextView.isSecureTextEntry
        sender.accesoryButton.isSelected = !sender.entryTextView.isSecureTextEntry
        
    }
    
    
}
