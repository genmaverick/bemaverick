//
//  OnboardVPCViewController.swift
//  BeMaverick
//
//  Created by David McGraw on 2/16/18.
//  Copyright © 2018 BeMaverick. All rights reserved.
//

import UIKit

class OnboardVPCViewController: ViewController {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var titleContainerView: UIView!
    
    @IBOutlet weak var titleSubtitle: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var firstNameTextInput: TextInputLayout!
    @IBOutlet weak var lastNameTextInput: TextInputLayout!
    @IBOutlet weak var streetAddressTextInput: TextInputLayout!
    @IBOutlet weak var zipcodeTextInput: TextInputLayout!
    @IBOutlet weak var ssnTextInput: TextInputLayout!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    private var submitButton : UIBarButtonItem!
    
    // MARK: - IBActions
    
    private func validateFields() {
        
        if firstNameTextInput.text == nil {
            firstNameTextInput.setValidState(isValid: false, validationText: R.string.maverickStrings.fieldRequired(R.string.maverickStrings.vpcValidateFirstNameHint()))
        }
        if lastNameTextInput.text == nil {
            lastNameTextInput.setValidState(isValid: false, validationText: R.string.maverickStrings.fieldRequired(R.string.maverickStrings.vpcValidateLastNameHint()))
        }
        if streetAddressTextInput.text == nil {
            streetAddressTextInput.setValidState(isValid: false, validationText: R.string.maverickStrings.fieldRequired(R.string.maverickStrings.vpcValidateStreetHint()))
        }
        if zipcodeTextInput.text == nil {
            zipcodeTextInput.setValidState(isValid: false, validationText: R.string.maverickStrings.fieldRequired(R.string.maverickStrings.vpcValidateZipHint()))
        }
        if ssnTextInput.text == nil {
            ssnTextInput.setValidState(isValid: false, validationText: R.string.maverickStrings.fieldRequired(R.string.maverickStrings.vpcValidateSsnHint()))
        }
    }
    
    
    private func validateFields(withCode code : String?) -> String? {
      
        var error = code
        if code == "INPUT_INVALID_FIRST_NAME" {
             error = R.string.maverickStrings.fieldInvalid(R.string.maverickStrings.vpcValidateFirstNameHint())
            firstNameTextInput.setValidState(isValid: false, validationText: error)
        }
        if code == "INPUT_INVALID_LAST_NAME"  {
             error = R.string.maverickStrings.fieldInvalid(R.string.maverickStrings.vpcValidateLastNameHint())
            lastNameTextInput.setValidState(isValid: false, validationText: error)
        }
        if code == "INPUT_INVALID_FIRST_NAME" {
             error = R.string.maverickStrings.fieldInvalid(R.string.maverickStrings.vpcValidateStreetHint())
            streetAddressTextInput.setValidState(isValid: false, validationText: error)
        }
        if code == "INPUT_INVALID_ZIP_CODE" {
             error = R.string.maverickStrings.fieldInvalid(R.string.maverickStrings.vpcValidateZipHint())
            zipcodeTextInput.setValidState(isValid: false, validationText: error)
        }
        if code == "INPUT_INVALID_LAST_FOUR_SSN" {
             error = R.string.maverickStrings.fieldInvalid(R.string.maverickStrings.vpcSsnHint())
            ssnTextInput.setValidState(isValid: false, validationText: error)
        }
        
        return error
    }
    
    
    @objc fileprivate func submitButtonTapped(_ sender: Any) {
        
        guard let firstName = firstNameTextInput.text,
            let lastName = lastNameTextInput.text,
            let address = streetAddressTextInput.text,
            let zipcode = zipcodeTextInput.text,
            let ssn = ssnTextInput.text,
            let userId = services.globalModelsCoordinator.loggedInUser?.userId else
        {
            
            AnalyticsManager.Onboarding.trackVPCInfoFailure(apiFailure : false, reason : "validation")
            validateFields()
            return
                
        }
        
        firstNameTextInput.entryTextView.resignFirstResponder()
        lastNameTextInput.entryTextView.resignFirstResponder()
        streetAddressTextInput.entryTextView.resignFirstResponder()
        zipcodeTextInput.entryTextView.resignFirstResponder()
        ssnTextInput.entryTextView.resignFirstResponder()
        
        submitButton.isEnabled = false
        activityIndicator.startAnimating()
        services.globalModelsCoordinator.verifyParentInfo(withFirstName: firstName,
                                                          lastName: lastName,
                                                          address: address,
                                                          zip: zipcode,
                                                          ssn: ssn,
                                                          childUserId: userId,
                                                          retry: hasAttemptedVerficiation)
        { error in
        
            self.submitButton.isEnabled = true
            self.activityIndicator.stopAnimating()
            if error != nil {

                let message = self.validateFields(withCode: error?.localizedDescription) ?? R.string.maverickStrings.networkError()
                if message == error?.localizedDescription {
                    
                          AnalyticsManager.Onboarding.trackVPCInfoFailure(apiFailure : true, reason : message)
                    
                    self.titleContainerView.backgroundColor =  UIColor.MaverickVPCBackground
                    self.titleContainerView.addShadow(alpha: 0.5)
                    self.titleLabel.font = R.font.openSansBold(size: 14.0)
                    self.titleLabel.textColor = UIColor.white
                    self.titleSubtitle.textColor = UIColor.white
                    self.titleLabel.text = R.string.maverickStrings.vpcFirstErrorTitle()
                    self.titleSubtitle.text = R.string.maverickStrings.vpcFirstErrorSubTitle()
                    if self.hasAttemptedVerficiation == 0  {
                      
                        
                    } else {
                     
                        if let vc = R.storyboard.general.onboardKbaPassId() {
                        
                            vc.success = false
                            self.navigationController?.pushViewController(vc, animated: false)
                            return
                        }
                        
                    }
                
                    self.hasAttemptedVerficiation = 1
               
                } else {
                    
                    self.titleContainerView.backgroundColor =  UIColor.white
               
                }
              
                return

            }
            
             AnalyticsManager.Onboarding.trackVPCInfoSuccess()
            if let vc = R.storyboard.general.onboardKbaPassId() {
               
                vc.success = true
                self.navigationController?.pushViewController(vc, animated: false)
            
            }
            
        }
        
    }
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Public Properties
    
    /// The `GlobalServicesContainer` that maintains access to global services
    var services: GlobalServicesContainer! = (UIApplication.shared.delegate as! AppDelegate).services
    
    // MARK: - Private Properties
    
    private var hasAttemptedVerficiation: Int = 0
    
    /// A reference to the `UIKeyboardWillShow` notification
    private var keyboardWillShowId: NSObjectProtocol?
    
    /// A reference to the `UIKeyboardWillHide` notification
    private var keyboardWillHideId: NSObjectProtocol?
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        hasNavBar = true
        super.viewDidLoad()
        configureView()
        
       
        if let region = Locale.current.regionCode, region != "US" {
         
            if let vc = R.storyboard.general.onboardKbaPassId() {
                
                vc.success = true
                self.navigationController?.pushViewController(vc, animated: false)
                
            }
            
        }
        
    }
    
    // MARK: - Private Methods
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(keyboardWillShowId as Any)
        NotificationCenter.default.removeObserver(keyboardWillHideId as Any)
    }
    
    /**
     Default layout for the content view
    */
    fileprivate func configureView() {
        
        observeKeyboardWillShow()
        observeKeyboardWillHide()
        
        activityIndicator.color = UIColor.MaverickDarkSecondaryTextColor
        
        
        
        view.backgroundColor = .white
        scrollView.backgroundColor = .white
        submitButton = UIBarButtonItem(title: R.string.maverickStrings.submit(), style: .plain, target: self, action: #selector(submitButtonTapped(_:)))
        submitButton.tintColor = UIColor.MaverickPrimaryColor
        navigationItem.rightBarButtonItem = submitButton
        
        
        
        showNavBar(withTitle: R.string.maverickStrings.vpcTitle())
        titleLabel.font = R.font.openSansRegular(size: 14.0)
        titleLabel.textColor = UIColor.MaverickDarkTextColor
        titleSubtitle.text = ""
        titleLabel.textColor = UIColor.MaverickDarkTextColor
        firstNameTextInput.setHints(shortHint: R.string.maverickStrings.vpcFirstNameHint())
        lastNameTextInput.setHints(shortHint: R.string.maverickStrings.vpcLastNameHint())
        streetAddressTextInput.setHints(shortHint: R.string.maverickStrings.vpcStreetHint())
        zipcodeTextInput.setHints(shortHint: R.string.maverickStrings.vpcZipHint())
         ssnTextInput.setHints(shortHint: R.string.maverickStrings.vpcSsnHint())
        
        firstNameTextInput.entryTextView.returnKeyType = .next
        lastNameTextInput.entryTextView.returnKeyType = .next
        streetAddressTextInput.entryTextView.returnKeyType = .next
        
        
        zipcodeTextInput.entryTextView.keyboardType = .default
        ssnTextInput.entryTextView.keyboardType = .numberPad
        ssnTextInput.entryTextView.returnKeyType = .go
        
        firstNameTextInput.delegate = self
        lastNameTextInput.delegate = self
        streetAddressTextInput.delegate = self
        zipcodeTextInput.delegate = self
        ssnTextInput.delegate = self
        
        firstNameTextInput.entryTextView.becomeFirstResponder()
        
        
        let boldCopy1 = R.string.maverickStrings.vpcInitialLabel_1()
        let copy1 = R.string.maverickStrings.vpcInitialLabel_2()
        let boldCopy2 = R.string.maverickStrings.vpcInitialLabel_3()
        let copy2 = R.string.maverickStrings.vpcInitialLabel_4()
        
        let color = UIColor.MaverickDarkTextColor
        
        let attributedText = copy1.boldSubstrings(withColor: UIColor.black,
                                                 substrings: [ boldCopy1 ],
                                                 boldFont: R.font.openSansBold(size: 14.0)!,
                                                 regularFont: R.font.openSansRegular(size: 14.0)!,
                                                 regulardColor:  color)
        
        let attributedText2 = copy2.boldSubstrings(withColor: UIColor.black,
                                                  substrings: [ boldCopy2 ],
                                                  boldFont: R.font.openSansBold(size: 14.0)!,
                                                  regularFont: R.font.openSansRegular(size: 14.0)!,
                                                  regulardColor:  color)
        
        let mutableAttributedString = NSMutableAttributedString()
        mutableAttributedString.append(attributedText)
        mutableAttributedString.append(attributedText2)
        titleLabel.attributedText = mutableAttributedString
        
        
        ssnTextInput.setAccesoryButton(normalText: "Why?", selectedText: nil, delegate: self)
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: R.image.back_purple(),
                                                           style: .plain,
                                                           target: self,
                                                           action: #selector(backButtonTapped(_:)))
        navigationItem.leftBarButtonItem?.tintColor = UIColor.MaverickBadgePrimaryColor
        
    }
    
    /**
     Back button pressed to dismiss view
     */
    override func backButtonTapped(_ sender: Any) {
        
        navigationController?.dismiss(animated: true, completion: nil)
        
    }
    
    
    /**
     Observe when the keyboard becomes visible and adjusts the scroll view inset.
     */
    fileprivate func observeKeyboardWillShow() {
        
        keyboardWillShowId = NotificationCenter.default.addObserver(forName: .UIKeyboardWillShow,
                                                                    object: nil,
                                                                    queue: nil)
        { [weak self] notification in
            
            if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
                self?.scrollView.contentInset = UIEdgeInsetsMake(0, 0, keyboardSize.height, 0)
            }
            
        }
        
    }
    
    /**
     Observe when the keyboard hides and adjusts the scroll view inset.
     */
    fileprivate func observeKeyboardWillHide() {
        
        keyboardWillHideId = NotificationCenter.default.addObserver(forName: .UIKeyboardWillHide,
                                                                    object: nil,
                                                                    queue: nil)
        { [weak self] _ in
            
            self?.scrollView.contentInset = .zero
            
        }
        
    }
    
}

extension OnboardVPCViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField == firstNameTextInput.entryTextView {
            
            lastNameTextInput.entryTextView.becomeFirstResponder()
            return false
            
        } else  if textField == lastNameTextInput.entryTextView {
            
            streetAddressTextInput.entryTextView.becomeFirstResponder()
            return false
            
        } else  if textField == streetAddressTextInput.entryTextView {
            
            zipcodeTextInput.entryTextView.becomeFirstResponder()
            return false
            
        } else  if textField == zipcodeTextInput.entryTextView {
            
            ssnTextInput.entryTextView.becomeFirstResponder()
            return false
            
        }
        return true
        
    }
    
}

extension OnboardVPCViewController : TextInputLayoutDelegate {
  
    func accesoryButtonTapped(_ sender: TextInputLayout) {
        
        let alert = UIAlertController(title: nil, message: R.string.maverickStrings.vpcConvincingText(), preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
        
        
    }
    
}
