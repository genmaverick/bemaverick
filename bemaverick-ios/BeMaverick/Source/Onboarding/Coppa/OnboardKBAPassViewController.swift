//
//  OnboardKBAPassViewController.swift
//  Maverick
//
//  Created by David McGraw on 2/21/18.
//  Copyright © 2018 BeMaverick. All rights reserved.
//

import UIKit
import MessageUI

class OnboardKBAPassViewController: ViewController {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var message: UILabel!
    
    @IBOutlet weak var tosButton: UIButton!
    @IBOutlet weak var verifyAssetsButton: UIButton!
    private var submitButton : UIBarButtonItem!
    // MARK: - IBActions
    
    @IBAction func verifyAssetsButtonTapped(_ sender: Any) {
        
        verifyAssetsButton.isSelected = !verifyAssetsButton.isSelected
        submitButton.isEnabled = verifyAssetsButton.isSelected
        
    }
    
    @IBAction func tosTapped(_ sender: Any) {
        
        if success {
            let urlToDisplay = URL(string: Constants.termsOfServiceURL)
            let webViewController = NavigationViewController(rootViewController: WebContentViewController(url: urlToDisplay!, webViewTitle: "Terms Of Service"))
            present(webViewController, animated: true, completion: nil)
        } else {
            if MFMailComposeViewController.canSendMail() {
                
                let mail = MFMailComposeViewController()
                mail.mailComposeDelegate = self
                mail.setToRecipients(["support@bemaverick.com"])
                mail.setSubject("Maverick Parent Verification")
                let username = self.services.globalModelsCoordinator.loggedInUser?.username ?? ""
                    mail.setMessageBody("<p>Please help verify my account: \(username)</p>", isHTML: true)
                self.present(mail, animated: true)
                
            }
        }
        
    }
    
    
    @IBAction func continueButtonTapped(_ sender: Any) {
        
        guard success else {
            
            backButtonTapped(sender)
            return
            
        }
        services.globalModelsCoordinator.updateVPCStatus(withChildId: services.globalModelsCoordinator.loggedInUser!.userId,
                                                         status: 1)
        { error in
            
            if error != nil {
                
                let message = error?.localizedDescription ?? "Something went wrong. Please try again."
                let alert = UIAlertController(title: "Whoops!", message: message, preferredStyle: .alert)
                AnalyticsManager.Onboarding.trackVPCPermissionGrantFailure(apiFailure: true, reason: message)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                return
                
            }
            
            AnalyticsManager.Onboarding.trackVPCPermissionGrantSuccess()
            
            let user = self.services.globalModelsCoordinator.loggedInUser!
            DBManager.sharedInstance.updateUserFields(value: ["userId": user.userId, "vpcStatus": true])
            
            self.performSegue(withIdentifier: R.segue.onboardKBAPassViewController.unwindToHomeSegue, sender: self)
            
        }
        
    }
    
    
    
    // MARK: - Public Properties
    
    /// The `GlobalServicesContainer` that maintains access to global services
    var services: GlobalServicesContainer! = (UIApplication.shared.delegate as! AppDelegate).services
    
    var success = false
    // MARK: - Lifecycle

    
    override func viewDidLoad() {
        hasNavBar = true
        super.viewDidLoad()
        
        configureView()
        
        if let region = Locale.current.regionCode, region != "US" {
            
            success = true
            continueButtonTapped(submitButton)
            
        }
        
    }
    
    
    
    
    
    
    /**
     Back button pressed to dismiss view
     */
    override func backButtonTapped(_ sender: Any) {
        
        navigationController?.dismiss(animated: true, completion: nil)
        
    }
    
    /**
     Initialize Views
     */
    fileprivate func configureView() {
        
        // Setup navigation
        
        view.backgroundColor = .white
        
        submitButton = UIBarButtonItem(title: success ? R.string.maverickStrings.submit() : R.string.maverickStrings.close(), style: .plain, target: self, action: #selector(continueButtonTapped(_:)))
        submitButton.tintColor = UIColor.MaverickPrimaryColor
        navigationItem.rightBarButtonItem = submitButton
        
        
        showNavBar(withTitle: success ? R.string.maverickStrings.vpcCompleteTitle() : "SORRY")
        message.text = success ? R.string.maverickStrings.vpcCheckboxConfirmText() : R.string.maverickStrings.vpcFinalErrorTitle()
        
        
        let copy1 = R.string.maverickStrings.vpcTerms_1()
        let boldCopy1 = R.string.maverickStrings.vpcTerms_2()
        let boldCopy2 = R.string.maverickStrings.vpcTerms_3()
        
        
        let color = UIColor.MaverickDarkTextColor
        
        let attributedText = copy1.boldSubstrings(withColor: UIColor.MaverickPrimaryColor,
                                                  substrings: [ boldCopy1,boldCopy2 ],
                                                  boldFont: R.font.openSansRegular(size: 14.0)!,
                                                  regularFont: R.font.openSansRegular(size: 14.0)!,
                                                  regulardColor:  color)
        
        submitButton.isEnabled = !success
        
        if !success {
            
            tosButton.setTitle("support@bemaverick.com", for: .normal)
            tosButton.setTitleColor(UIColor.MaverickPrimaryColor, for: .normal)
        
        } else {
        
            tosButton.setAttributedTitle(attributedText, for: .normal)
        
        }
        
        if !success {
        
            verifyAssetsButton.removeFromSuperview()
        
        }
        
    }
    
}

extension OnboardKBAPassViewController: MFMailComposeViewControllerDelegate {
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        
        controller.dismiss(animated: true)
        
    }
    
}

