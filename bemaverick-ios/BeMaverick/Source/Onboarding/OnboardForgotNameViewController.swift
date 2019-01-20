//
//  OnboardForgotNameViewController.swift
//  BeMaverick
//
//  Created by David McGraw on 10/20/17.
//  Copyright © 2017 BeMaverick. All rights reserved.
//

import UIKit

class OnboardForgotNameViewController: OnboardParentViewController {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var inputField: TextInputLayout!
    
    // MARK: - IBActions
    
    @IBAction func backTapped(_ sender: Any) {
        
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func forgotButtonTapped(_ sender: Any) {
        
        AnalyticsManager.Onboarding.trackForgotUsernameCTAPressed()
        if let emailInputCount = inputField.entryTextView.text?.count, (emailInputCount > 0)
        {
            inputField.setValidState(isValid: true)
            handleForgotRequest()
            
        } else {
            inputField.setValidState(isValid: false, validationText: R.string.maverickStrings.fieldRequired(R.string.maverickStrings.emailAddress()))
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
    
   
    
    override func configureView() {
        
        super.configureView()
        title = R.string.maverickStrings.forgotUsernameTitle()
        inputField.setHints(shortHint: R.string.maverickStrings.forgotUsernameShortHint(), fullHint: R.string.maverickStrings.forgotUsernameHint())
        ctaButton?.setTitle(R.string.maverickStrings.forgotCTA(), for: .normal)
        inputField.delegate = self
        
    }
    
    // MARK: - Private Methods
    
    fileprivate func handleForgotRequest() {
        
        view.endEditing(true)
        
        ctaButton?.isEnabled = false
        
        services.apiService.requestForgotUsername(withEmailAddress: inputField.entryTextView.text ?? "") { response, error in
            
            self.ctaButton?.isEnabled = true
            
            if error != nil {
                
                let alert = UIAlertController(title: nil, message: error!.localizedDescription, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                return
                
            } else {
                
                let alert = UIAlertController(title: "Check Email", message: "Your username has been sent", preferredStyle: .alert)
                
                let done = UIAlertAction(title: "OK", style: .default, handler: { action in
                    self.performSegue(withIdentifier: R.segue.onboardForgotNameViewController.unwindSegueToOnboardingLogin,
                                      sender: self)
                })
                alert.addAction(done)
                
                self.present(alert, animated: true, completion: nil)
                
            }
        }
        
    }
    
    
}

extension OnboardForgotNameViewController: UITextFieldDelegate {
    
     func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        view.endEditing(true)
        return true
        
    }
    
}
