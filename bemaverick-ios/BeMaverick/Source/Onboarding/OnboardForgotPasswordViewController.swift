//
//  OnboardForgotPasswordViewController.swift
//  BeMaverick
//
//  Created by David McGraw on 9/27/17.
//  Copyright © 2017 BeMaverick. All rights reserved.
//

import UIKit

class OnboardForgotPasswordViewController: OnboardParentViewController {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var inputField: TextInputLayout!
    
    // MARK: - IBActions
    
    @IBAction func backTapped(_ sender: Any) {
        
        navigationController?.popViewController(animated: false)
    }
    
    @IBAction func ctaButtonTapped(_ sender: Any) {
        AnalyticsManager.Onboarding.trackForgotPasswordCTAPressed()
        if let emailInputCount = inputField.entryTextView.text?.count, (emailInputCount > 0)
        {
            inputField.setValidState(isValid: true)
            handleForgotRequest()
            
            
        } else {
            
            inputField.setValidState(isValid: false, validationText: R.string.maverickStrings.fieldRequired(R.string.maverickStrings.loginUsernameHint()))
        }
        
    }
    
    
    
    // MARK: - Public Properties
    
    /// The `GlobalServicesContainer` that maintains access to global services
    var services: GlobalServicesContainer!
    
    // MARK: - Lifecycle
  
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        configureView()
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let vc = R.segue.onboardForgotPasswordViewController.forgotNameSegue(segue: segue)?.destination {
            vc.services = services
        }
        
    }
    
    override func configureView() {
        super.configureView()
        
        title = R.string.maverickStrings.forgotPasswordTitle()
        inputField.setHints(shortHint: R.string.maverickStrings.forgotPasswordShortHint(), fullHint: R.string.maverickStrings.forgotPasswordHint())
        ctaButton?.setTitle(R.string.maverickStrings.forgotCTA(), for: .normal)
        
        inputField.setAccesoryButton(normalText: R.string.maverickStrings.forgotButton(), delegate: self)
        
        
        inputField.delegate = self
        
    }
    
    // MARK: - Private Methods
    
    fileprivate func handleForgotRequest() {
        
        view.endEditing(true)
        ctaButton?.isEnabled = false
        AnalyticsManager.Onboarding.trackForgotPasswordPressed()
        
        services.apiService.requestForgotPassword(withUsername: inputField.entryTextView.text ?? "") { response, error in
            
            self.ctaButton?.isEnabled = true
            if error != nil {
                
                let alert = UIAlertController(title: nil, message: "Sorry, we couldn't find that user.  Please try another or sign up", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                return
                
            } else {
                
                let alert = UIAlertController(title: "Check Email", message: "Instructions to reset your password have been sent", preferredStyle: .alert)
                
                let done = UIAlertAction(title: "OK", style: .default, handler: { action in
                    self.performSegue(withIdentifier: R.segue.onboardForgotPasswordViewController.unwindSegueToOnboardingLogin,
                                      sender: self)
                })
                alert.addAction(done)
                
                self.present(alert, animated: true, completion: nil)
                
            }
        }
        
    }
    
}

extension OnboardForgotPasswordViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool
    {
        
        
        
        return true
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        view.endEditing(true)
        return true
        
    }
    
}

extension OnboardForgotPasswordViewController : TextInputLayoutDelegate {
    
    func accesoryButtonTapped(_ sender: TextInputLayout) {
        
        AnalyticsManager.Onboarding.trackForgotUsernamePressed()
        performSegue(withIdentifier: R.segue.onboardForgotPasswordViewController.forgotNameSegue, sender: self)
        
    }
    
    
    
    
}
