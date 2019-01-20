//
//  OnboardCompleteViewController.swift
//  BeMaverick
//
//  Created by David McGraw on 9/25/17.
//  Copyright © 2017 BeMaverick. All rights reserved.
//

import UIKit

class OnboardCompleteViewController: ViewController {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - Public Properties
    
    /// The `GlobalServicesContainer` that maintains access to global services
    var services: GlobalServicesContainer!
    
    var fromSignup = false
    // MARK: - Lifecycle
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        configureSignals()
        
        /// Preload User 'My Feed' if we've advanced here from the onboarding sequence,
        /// Preload Follow status and config data 
        /// otherwise wait for the auth signal to fire
        view.backgroundColor = UIColor.MaverickPrimaryColor
        navigationController?.setNavigationBarHidden(true, animated: false)
        navigationController?.setNavigationBarBackground(image: UIImage())
        navigationController?.setDefaultTitleAttributes()
        navigationItem.hidesBackButton = true
        navigationItem.leftBarButtonItem = nil
        
        if let _ = services.globalModelsCoordinator.loggedInUser {
            
            services.globalModelsCoordinator.refreshSiteConfigData()
            services.globalModelsCoordinator.getMyFeed(forceRefresh: false, downloadAssets: false)
            
        }
        
        
        Leanplum.onVariablesChanged { [weak self] in
            
            self?.view.backgroundColor = UIColor.MaverickPrimaryColor
            
        }
        
    }
    
    // MARK: - Private Methods
    
    fileprivate func advanceToMainExperience() {
        
        services.globalModelsCoordinator.prefetch(backgroundAppRefresh: false)
        
        if fromSignup {
            
            if let nav = R.storyboard.onboarding.onboardCompleteProfileViewControllerId() {
                
                // Inject services into the default tab
                if let vc = nav.topViewController as? OnboardCompleteProfileViewController
                {
                    
                    vc.services = services
                    
                }
                
                let delegate = UIApplication.shared.delegate as! AppDelegate
                delegate.transitionRootViewController(to: nav)
             
                
                return
                
            }
            
        }
        
        guard checkForUpgrade() else { return }
        
        guard !(services.globalModelsCoordinator.loggedInUser?.isRevoked ?? false) else  {
            
            services.globalModelsCoordinator.authorizationManager.onUserReinstatedSignal.subscribe(with: self) { result in
                
                let tabBarNav = R.storyboard.main.instantiateInitialViewController()!
                let delegate = UIApplication.shared.delegate as! AppDelegate
                delegate.transitionRootViewController(to: tabBarNav)
                
            }
            
            return
            
        }
        
        
        let tabBarNav = R.storyboard.main.instantiateInitialViewController()!
        let delegate = UIApplication.shared.delegate as! AppDelegate
        delegate.transitionRootViewController(to: tabBarNav)
        
    }
    
    /*
     Returns : bool for allowed to open the app normally
    **/
    fileprivate func checkForUpgrade () -> Bool {
        
        if let shortString = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ,
            let suggestedVersion = Variables.Features.suggestedUpgradeVersion.stringValue(),
            let forcedVersion = Variables.Features.forcedUpgradeVersion.stringValue() {
            //first check if current version is greater than forced version
            var result = shortString.compare(forcedVersion, options: String.CompareOptions.numeric)
            if result == ComparisonResult.orderedDescending || result == ComparisonResult.orderedSame {
                //now check if current version is greater than suggested version
                result = shortString.compare(suggestedVersion, options: String.CompareOptions.numeric)
                
                if result == ComparisonResult.orderedDescending || result == ComparisonResult.orderedSame {
                    
                    return true
                    
                } else if !services.globalModelsCoordinator.hasSeenSuggestedUpgrade(versionNumber: suggestedVersion) {
                    //now we are below the suggested version so show suggested
                    if let vc = R.storyboard.userBlock.inactiveUserViewControllerId() {
                        
                        vc.status = .suggestedUpgrade
                        vc.services = self.services
                        let delegate = UIApplication.shared.delegate as! AppDelegate
                        delegate.transitionRootViewController(to: vc)
                        return false
                        
                    }
                    
                }
                
            } else {
                
                if let vc = R.storyboard.userBlock.inactiveUserViewControllerId() {
                    
                    vc.status = .forecedUpgrade
                    vc.services = self.services
                    let delegate = UIApplication.shared.delegate as! AppDelegate
                    delegate.transitionRootViewController(to: vc)
                    return false
               
                }
                
            }
            
        }
        
        return true
    }
    
    fileprivate func configureSignals() {
        
        guard AnalyticsManager.isInitialized else {
            
            self.advanceToMainExperience()
            return
            
        }
        guard  NetworkManager.sharedInstance.reachability.connection  != .none else {
            
            self.advanceToMainExperience()
            return
        }
        Leanplum.onStartResponse { success in

            self.advanceToMainExperience()

        }
        
    }
    
}
