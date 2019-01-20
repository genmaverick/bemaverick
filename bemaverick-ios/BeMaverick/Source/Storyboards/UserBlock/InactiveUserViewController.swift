//
//  InactiveUserViewController.swift
//  Maverick
//
//  Created by Garrett Fritz on 4/20/18.
//  Copyright © 2018 BeMaverick. All rights reserved.
//

import Foundation
import MessageUI


class InactiveUserViewController : ViewController {
    
  
    @IBOutlet var titleLabel: UILabel!
    
    @IBOutlet var ctaButton: UIButton!
    @IBOutlet var descriptionLabel: UILabel!
    
    var services: GlobalServicesContainer!
    var status : Constants.blockState = .deactivated
    
    var revokedMode : Constants.RevokedMode? = nil
    
    @IBOutlet weak var subCtaButton: CTAButton!
 
    override func trackScreen() {
        
        AnalyticsManager.trackScreen(location: self,
                                     withProperties: ["BLOCKED" : (revokedMode != nil) ? "true" : "false"])
    
    }
    
    private func revokedCTA() {
        if MFMailComposeViewController.canSendMail() {
            
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients(["support@bemaverick.com"])
            mail.setSubject("Maverick Parent Reinstate Child Account")
            let username = self.services.globalModelsCoordinator.loggedInUser?.username ?? ""
            var message = "<p>Please help me reinstate my child's account: \(username)</p>"
            if (revokedMode ?? .parent) == .admin {
                message = "<p>Please help me reinstate my account: \(username)</p>"
            }
            mail.setMessageBody(message, isHTML: true)
            self.present(mail, animated: true)
            
        }
    }
    
    private func deactivatedCTA() {
        
        self.services?.globalModelsCoordinator.toggleActivation(deactivate : false) { error in
            
            guard error == nil else {
                var errorMessage = error?.localizedDescription
                if errorMessage == "" {
                    
                    errorMessage = R.string.maverickStrings.networkError()
                    
                }
                let alert = UIAlertController(title: nil, message: errorMessage, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                return
            }
            
            self.services?.globalModelsCoordinator.reloadLoggedInUser()
            let tabBarNav = R.storyboard.main.instantiateInitialViewController()!
            
            
            
            let delegate = UIApplication.shared.delegate as! AppDelegate
            delegate.transitionRootViewController(to: tabBarNav)
            
        }
    
    
    }
    
    private func reccomendedUpdateCTA() {
        
        openStoreProductWithiTunesItemIdentifier(identifier: IntegrationConfig.appStoreId)
        
    }
    
    private func forcedUpdateCTA() {
        
        openStoreProductWithiTunesItemIdentifier(identifier: IntegrationConfig.appStoreId)
        
        
    }
    
    func openStoreProductWithiTunesItemIdentifier(identifier: String) {
        let storeViewController = SKStoreProductViewController()
        storeViewController.delegate = self
        
        let parameters = [ SKStoreProductParameterITunesItemIdentifier : identifier]
        storeViewController.loadProduct(withParameters: parameters) { [weak self] (loaded, error) -> Void in
            if loaded {
                // Parent class of self is UIViewContorller
                self?.present(storeViewController, animated: true, completion: nil)
            }
        }
    }
    
    func productViewControllerDidFinish(viewController: SKStoreProductViewController) {
        viewController.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func ctaPressed(_ sender: Any) {
        
        switch status {
        case .deactivated:
            deactivatedCTA()
        case .revoked:
            revokedCTA()
        case .suggestedUpgrade:
            reccomendedUpdateCTA()
        case .forecedUpgrade:
            forcedUpdateCTA()
            
        }
        
    }

    @IBAction func subCtaPressed(_ sender: Any) {
        
        
        switch status {
        case .deactivated:
                    services.globalModelsCoordinator.authorizationManager.logout()
        case .revoked:
                    services.globalModelsCoordinator.authorizationManager.logout()
        case .suggestedUpgrade:
            
            if let loadingVC = R.storyboard.onboarding().instantiateViewController(withResource: R.storyboard.onboarding.onboardCompleteViewControllerId)  {
                loadingVC.services = services
                let delegate = UIApplication.shared.delegate as! AppDelegate
                delegate.transitionRootViewController(to: loadingVC)
            }
        case .forecedUpgrade:
            break
            
        }

        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleLabel.textColor = .white
        descriptionLabel.textColor = .white
        subCtaButton.backgroundColor = .white
        subCtaButton.setTitleColor(.black, for: .normal)
        
        ctaButton.backgroundColor = .black
        ctaButton.setTitleColor(.white, for: .normal)
        subCtaButton.setTitle(R.string.maverickStrings.logoutAction(), for: .normal)
      
        
        switch status {
        case .deactivated:
            ctaButton.setTitle(R.string.maverickStrings.reactivateAction(), for: .normal)
            titleLabel.text = R.string.maverickStrings.inactiveUserTitle()
            descriptionLabel.text = R.string.maverickStrings.inactiveUserSubTitle()
        case .revoked:
            ctaButton.setTitle("Contact Support", for: .normal)
            
            if revokedMode == .admin {
            
                titleLabel.text = Variables.Features.adminRevokedTitle.stringValue()
                descriptionLabel.text = Variables.Features.adminRevokedSubTitle.stringValue()
            
            } else {
                
                titleLabel.text = Variables.Features.parentRevokedTitle.stringValue()
                descriptionLabel.text = Variables.Features.parentRevokedSubTitle.stringValue()
            
            }
            
            
        case .suggestedUpgrade:
            
            ctaButton.setTitle("Update Now", for: .normal)
            subCtaButton.setTitle("Later", for: .normal)
            titleLabel.text = Variables.Features.suggestedUpgradeTitle.stringValue()
            descriptionLabel.text = Variables.Features.suggestedUpgradeDescription.stringValue()
            
        case .forecedUpgrade:
            
            ctaButton.setTitle("Update Now", for: .normal)
            subCtaButton.isHidden = true
            titleLabel.text = Variables.Features.forcedUpgradeTitle.stringValue()
            descriptionLabel.text = Variables.Features.forcedUpgradeDescription.stringValue()
            
        }
        
       
    }
    
}


extension InactiveUserViewController: MFMailComposeViewControllerDelegate {
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        
        controller.dismiss(animated: true)
        
    }
    
}

extension InactiveUserViewController : SKStoreProductViewControllerDelegate {
    
    func productViewControllerDidFinish(_ viewController: SKStoreProductViewController) {
        
        viewController.dismiss(animated: true, completion: nil)
    
    }
    
    
}


