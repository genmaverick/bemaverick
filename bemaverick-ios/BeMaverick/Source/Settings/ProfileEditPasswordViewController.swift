//
//  ProfileEditPasswordViewController.swift
//  BeMaverick
//
//  Created by David McGraw on 11/29/17.
//  Copyright © 2017 BeMaverick. All rights reserved.
//

import UIKit

class ProfileEditPasswordViewController: ViewController {
    
    // MARK: - IBOutlets
    /// Current password field
    @IBOutlet weak var currentPassword: TextInputLayout!
    /// New password field
    @IBOutlet weak var newPassword: TextInputLayout!
    
    @IBOutlet weak var showOldPasswordButton: UIButton!
    @IBOutlet weak var showNewPasswordButton: UIButton!
    
    
    @IBAction func showPasswordTapped(_ sender: Any) {
        
        if let button = sender as? UIButton {
            if let textInput = button.superview as? TextInputLayout {
                
                textInput.entryTextView.isSecureTextEntry = !textInput.entryTextView.isSecureTextEntry
                button.isSelected = !textInput.entryTextView.isSecureTextEntry
            }
        }
        
    }
    

    // MARK: - Public Properties
    
    /// The `GlobalServicesContainer` that maintains access to global services
    var services: GlobalServicesContainer!
    
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        
        hasNavBar = true
        super.viewDidLoad()
        configureView()
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
    
        currentPassword.bringSubview(toFront: showOldPasswordButton)
        newPassword.bringSubview(toFront: showNewPasswordButton)
        
        currentPassword.entryTextView.isSecureTextEntry = true
        newPassword.entryTextView.isSecureTextEntry = true
        
    }
   
    // MARK: - Private Methods
    
    

    
    /**
     Back button pressed, dismiss VC
     */
    @objc fileprivate func saveButtonTapped(_ sender: Any) {
        
        AnalyticsManager.Settings.trackSavePasswordPressed()
        guard let current = currentPassword.entryTextView.text,
            let new = newPassword.entryTextView.text else { return }
        
        if new.count < 6 {
            self.newPassword.setValidState(isValid: false, validationText: R.string.maverickStrings.fieldRequiredWithQuantity(R.string.maverickStrings.loginPasswordHint(), 6))
            return
        }
    
        
        services.globalModelsCoordinator.updateUserPassword(withCurrentPassword: current, newPassword: new) { error in
            
            guard error == nil else {
                
                var errorMessage = error!.localizedDescription
                if errorMessage == "" {
                    errorMessage = R.string.maverickStrings.networkError()
                }
                if errorMessage == "USER_PASSWORD_INVALID" {
                    errorMessage = R.string.maverickStrings.incorrectPassword()
                }
                let alert = UIAlertController(title: nil, message: errorMessage, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                return
                
            }
            
            let alert = UIAlertController(title: R.string.maverickStrings.success(), message:R.string.maverickStrings.passwordChangedSuccess(), preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default){ alert in
                self.navigationController?.popToRootViewController(animated: true)
                
            })
            
            self.present(alert, animated: true, completion: nil)
            
        }
        
    }
    
    
    /**
     Configure the default layout
     */
    fileprivate func configureView() {
        
        // iOS 10 fix to not have white spacing on top
        automaticallyAdjustsScrollViewInsets = false
        // Setup navigation
      
        let rightItem = UIBarButtonItem(title: R.string.maverickStrings.save(), style: .plain, target: self, action: #selector(saveButtonTapped(_:)))
        navigationItem.rightBarButtonItem = rightItem
        
        
        
        showNavBar(withTitle:  R.string.maverickStrings.changePasswordTittle())
        currentPassword.setHints(shortHint: R.string.maverickStrings.currentPasswordShortHint(), fullHint: R.string.maverickStrings.currentPasswordLongHint())
        newPassword.setHints(shortHint: R.string.maverickStrings.newPasswordShortHint(), fullHint: R.string.maverickStrings.newPasswordLongHint())
        
        view.backgroundColor = UIColor.white
        showOldPasswordButton.setTitleColor(UIColor.MaverickPrimaryColor, for: .normal)
        showOldPasswordButton.setTitleColor(UIColor.MaverickPrimaryColor, for: .selected)
        showOldPasswordButton.setTitle(R.string.maverickStrings.show(), for: .normal)
        showOldPasswordButton.setTitle(R.string.maverickStrings.hide(), for: .selected)
        
        
        showNewPasswordButton.setTitleColor(UIColor.MaverickPrimaryColor, for: .normal)
        showNewPasswordButton.setTitleColor(UIColor.MaverickPrimaryColor, for: .selected)
        showNewPasswordButton.setTitle(R.string.maverickStrings.show(), for: .normal)
        showNewPasswordButton.setTitle(R.string.maverickStrings.hide(), for: .selected)
      
    }
    
    
}

extension ProfileEditPasswordViewController : UITextFieldDelegate {
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField == currentPassword.entryTextView {
            
            newPassword.entryTextView.becomeFirstResponder()
            
        } else if textField == newPassword {
            
              view.endEditing(true)
            
        }
        
        return true
        
    }
    
}


