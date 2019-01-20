//
//  OnboardSMSRequestViewController.swift
//  Maverick
//
//  Created by David McGraw on 5/10/18.
//  Copyright © 2018 BeMaverick. All rights reserved.
//

import Foundation
import CTKFlagPhoneNumber

class OnboardSMSRequestViewController: OnboardParentViewController {
    
    // MARK: - IBOutlets
    
    /// Input for the user's phone number
    @IBOutlet weak var phoneNumberTextField: CTKFlagPhoneNumberTextField!
    
    /// The confirm code title that includes the number that the code was sent to
    @IBOutlet weak var confirmTitleLabel: UILabel!
    
    /// Text associated with the phone number entry
    @IBOutlet weak var phoneNumberValidationLabel: UILabel!
    
    /// A stack view containing input values
    @IBOutlet weak var inputCodeStackView: UIStackView!
    
    /// Phone number input
    @IBOutlet weak var requestCodeContainer: UIView!
    
    /// Code input
    @IBOutlet weak var confirmCodeContainer: UIView!
    
    /// Request an SMS auth code
    @IBOutlet weak var requestCodeButton: CTAButton!
    
    /// Confirm code
    @IBOutlet weak var confirmCodeButton: CTAButton!
    
    /// Return to Request SMS
    @IBOutlet weak var editNumberButton: CTAButton!
    
    /// Resend code
    @IBOutlet weak var resendCodeButton: CTAButton!
    
    // MARK: - IBActions
    
    @IBAction func requestCodeButtonTapped(_ sender: Any) {
        
      

        guard let phone = phoneNumberTextField.getFormattedPhoneNumber() else {
            requestCodeButton.isEnabled = true
            phoneNumberValidationLabel.isHidden = false
            return
        }
        
         AnalyticsManager.Onboarding.trackSMSRequestPressed(isSignup: onboardSignupViewController != nil)
        
        requestCodeButton.isEnabled = false
        phoneNumberValidationLabel.isHidden = true
        authSelectorViewController!.smsRequestInputPhoneNumber = phone
        confirmTitleLabel.text = R.string.maverickStrings.smsVerifyConfirmCode(phone)

        services.globalModelsCoordinator.smsCodeRequest(withPhoneNumber: phone) { response, error in

            self.requestCodeButton.isEnabled = true

            if let err = error {

                self.displayAlert(withMessage: err.localizedDescription)
                return

            }

            if let il = self.inputCodeStackView.arrangedSubviews.first as? TextInputLayout  {
                il.entryTextView.becomeFirstResponder()
            }
            self.isEditingCode = true
            self.scrollView.scrollRectToVisible(self.confirmCodeContainer.frame, animated: true)

        }
        
    }
    
    @IBAction func confirmCodeButtonTapped(_ sender: Any) {
        
    
        
        guard let code = getInputCode(),
            let phone = phoneNumberTextField.getFormattedPhoneNumber() else
        {
            setValidationVisualForInvalidCode()
            return
        }

        
        confirmCodeButton.isEnabled = false
        authSelectorViewController!.smsRequestInputPhoneNumber = phone
        authSelectorViewController!.smsVerificiationCode = code

        dismissKeyboard()
        
        /**
         On registration we simply confirm that the code is correct. The account
         will be created at the end of the registration flow.
         */
        services.globalModelsCoordinator.smsCodeVerify(withPhoneNumber: phone,
                                                       code: code)
        { response, error in

            self.confirmCodeButton.isEnabled = true

            if let err = error {
                self.setValidationVisualForInvalidCode(forAllFields: true)
                self.displayAlert(withMessage: err.localizedDescription)
                AnalyticsManager.Onboarding.trackSMSValidateFailure(isSignup: self.onboardSignupViewController != nil, reason: err.localizedDescription)
                return
            }
             AnalyticsManager.Onboarding.trackSMSValidateSuccess(isSignup: self.onboardSignupViewController != nil)
            /// Perform a login check
            self.services.globalModelsCoordinator.smsCodeConfirm(withPhoneNumber: phone,
                                                                 code: code)
            { _, error in

                if let err = error {
                    
                    

                    if let _ = self.onboardSignupViewController {

                        /// Begin SMS registration flow
                        self.onboardSignupViewController?.beginSMSLogin(withPhone: phone,
                                                                        code: code)

                    } else if let _ = self.onboardLoginViewController {
                        
                        AnalyticsManager.Onboarding.trackSMSValidateFailure(isSignup: self.onboardSignupViewController != nil, reason: err.localizedDescription)

                        // There is no account for this credential
                        if err.localizedDescription.contains("username is not allowed") {
                            
                            guard let vc = R.storyboard.onboarding.onboardMessageControllerId() else {
                                return
                            }
                            vc.delegate = self
                            self.present(vc, animated: true)
                            
                        } else {
                            self.displayAlert(withMessage: err.localizedDescription)
                        }
                        return

                    }

                }
                
                
               

                self.dismiss(animated: false, completion: nil)

            }
            
        }
        
    }
    
    @IBAction func editNumberButtonTapped(_ sender: Any) {
        isEditingCode = true
        scrollView.scrollRectToVisible(requestCodeContainer.frame, animated: true)
    }
    
    @IBAction func resendCodeButtonTapped(_ sender: Any) {
        requestCodeButtonTapped(sender)
    }
    
    @IBAction override func backButtonTapped(_ sender: Any) {
        
        if isEditingCode {
            isEditingCode = false
            scrollView.scrollRectToVisible(requestCodeContainer.frame, animated: true)
        } else {
            dismiss(animated: false, completion: nil)
        }
        
    }
    
    // MARK: - Public Properties
    
    /// The `GlobalServicesContainer` that maintains access to global services
    var services: GlobalServicesContainer!
    
    var isEditingCode: Bool = false
    
    weak var authSelectorViewController: OnboardAuthSelectorViewController?
    
    weak var onboardSignupViewController: OnboardSignupViewController?
    
    weak var onboardLoginViewController: OnboardLoginViewController?
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        configureView()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        confirmTitleLabel.text = R.string.maverickStrings.smsVerifyConfirmCode(authSelectorViewController?.smsRequestInputPhoneNumber ?? "")
        
        if let _ = onboardSignupViewController {
            confirmCodeButton.setTitle(R.string.maverickStrings.signUpButtonTitle(), for: .normal)
        } else if let _ = onboardLoginViewController {
            confirmCodeButton.setTitle(R.string.maverickStrings.loginButtonTitle(), for: .normal)
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        
        phoneNumberTextField.becomeFirstResponder()
        
    }
    
    // MARK: - Public Methods
    
    override func configureView() {
        
        phoneNumberTextField.setFlag(for: "US")
        phoneNumberTextField.borderStyle = .none
        phoneNumberTextField.placeholder = "Enter your mobile number"
        
        editNumberButton.backgroundColor = .clear
        editNumberButton.setTitleColor(UIColor.MaverickPrimaryColor, for: .normal)
        resendCodeButton.backgroundColor = .clear
        resendCodeButton.setTitleColor(UIColor.MaverickPrimaryColor, for: .normal)
        
        // Style input
        for iv in inputCodeStackView.arrangedSubviews {
            
            if let il = iv as? TextInputLayout {
                il.underlineView.backgroundColor = .black
                il.entryTextView.textAlignment = .center
                il.entryTextView.font = R.font.openSansRegular(size: 34.0)
                il.entryTextView.delegate = self
                il.entryTextView.keyboardType = .numberPad
                il.entryTextView.text = "\u{200B}"
                il.hintLabel.isHidden = true
            }
            
        }
        
    }
    
    /**
     Dismiss the keyboard
     */
    func dismissKeyboard() {
        
        for iv in inputCodeStackView.arrangedSubviews {
            
            if let il = iv as? TextInputLayout {
                il.entryTextView.resignFirstResponder()
            }
            
        }
        view.endEditing(true)
        
    }
    
    // MARK: - Private Methods
    
    /**
     Get the code based on the input. Returns nil if the code is not valid.
    */
    fileprivate func getInputCode() -> String? {
        
        var code = ""
        for iv in inputCodeStackView.arrangedSubviews {
            
            if let il = iv as? TextInputLayout, let text = il.entryTextView.text {
                code += text.replacingOccurrences(of: "\u{200B}", with: "")
            }
            
        }
        
        if code.count == 4 {
            return code
        }
        return nil
        
    }
    
    /**
     Set invalid state for the input fields
    */
    fileprivate func setValidationVisualForInvalidCode(forAllFields: Bool = false) {
        
        for iv in inputCodeStackView.arrangedSubviews {
            
            if let il = iv as? TextInputLayout, let text = il.entryTextView.text {
                
                if forAllFields {
                    il.setValidState(isValid: false)
                } else {
                    
                    if text.count == 1 {
                        il.setValidState(isValid: false)
                    } else {
                        il.setValidState(isValid: true)
                    }
                    
                }
                
            }
            
        }
        
    }
    
}

extension OnboardSMSRequestViewController: UITextFieldDelegate {
    
    /**
     Move to the next or previous code input field
    */
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {

        if range.location == 0 && range.length == 1 {
            selectPreviousInputField(fromTextField: textField)
        } else if range.location >= 2 || string == " " {
            return false
        } else {
        
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.05) {
                
                if string != "" {
                    self.selectNextInputField(fromTextField: textField)
                }
                
            }
        
        }
        return true
        
    }
    
    /**
     Move to the next field
    */
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if isEditingCode {
            requestCodeButtonTapped(self)
        } else {
            selectNextInputField(fromTextField: textField)
        }
        return true
        
    }
    
    /**
     Select the next code input field that comes after the field provided
    */
    fileprivate func selectNextInputField(fromTextField textField: UITextField) {
        
        var focusNext = false
        for iv in inputCodeStackView.arrangedSubviews {
            
            if let inputLayout = iv as? TextInputLayout {
                
                if focusNext {
                    inputLayout.entryTextView.becomeFirstResponder()
                    break
                } else if inputLayout.entryTextView == textField {
                    focusNext = true
                }
                
            }
            
        }
        
        if let _ = getInputCode() {
            confirmCodeButtonTapped(self)
        }
        
    }
    
    /**
     Select the previous code input field that comes before the field provided
     */
    fileprivate func selectPreviousInputField(fromTextField textField: UITextField) {
        
        var focusNext = false
        for iv in inputCodeStackView.arrangedSubviews.reversed() {
            
            if let inputLayout = iv as? TextInputLayout {
                
                if focusNext {
                    inputLayout.entryTextView.becomeFirstResponder()
                    break
                } else if inputLayout.entryTextView == textField {
                    focusNext = true
                }
                
            }
            
        }
        
    }
    
}

extension OnboardSMSRequestViewController: OnboardMessageDelegate {
    
    func shouldCreateAccount(forSocialChannel channel: SocialShareChannels) {
        
        /// Begin SMS registration flow
        authSelectorViewController!.signUpButtonTapped(self)
        authSelectorViewController!.onboardSignupViewController?.beginSMSLogin(withPhone: authSelectorViewController!.smsRequestInputPhoneNumber,
                                                                               code: authSelectorViewController!.smsVerificiationCode)
        authSelectorViewController!.dismiss(animated: false, completion: nil)
        
    }
    
    func shouldRetryVerification(forSocialChannel channel: SocialShareChannels) {
        
        for iv in inputCodeStackView.arrangedSubviews.reversed() {
            
            if let inputLayout = iv as? TextInputLayout {
                inputLayout.entryTextView.text = ""
            }
            
        }
        
    }
    
}


