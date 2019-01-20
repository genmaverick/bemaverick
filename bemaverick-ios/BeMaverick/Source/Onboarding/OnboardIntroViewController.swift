//
//  OnboardIntroViewController.swift
//  BeMaverick
//
//  Created by David McGraw on 9/25/17.
//  Copyright © 2017 BeMaverick. All rights reserved.
//

import UIKit
import SCRecorder

class OnboardIntroViewController: ViewController {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var environmentButton: UIButton!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var containerView: UIView!
    
    @IBOutlet weak var ctaButton: CTAButton!
    
    
    // MARK: - IBActions
    
    @IBAction func environmentPressed(_ sender: Any) {
        
        launchActionSheet()
  
    }
   
    // MARK: - Public Properties
    
    /// The `GlobalServicesContainer` that maintains access to global services
    var services: GlobalServicesContainer!
    
    // MARK: - Lifecycle
  
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        configureView()
        
    }
    
 
    
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        
        // Fetch a client token so the user can proceed through authorization
        refreshClientToken()
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if let vc = R.segue.onboardIntroViewController.onboardAuthSelectorSegue(segue: segue)?.destination {
            
            AnalyticsManager.Onboarding.trackSplashCTAPressed()
            vc.services = services
            
        } else if let vc = R.segue.onboardIntroViewController.paginationSegue(segue: segue)?.destination {

            vc.pageDelegate = self
            pageControl.currentPageIndicatorTintColor = UIColor.MaverickBadgePrimaryColor
            pageControl.pageIndicatorTintColor = UIColor.lightGray
            
        }
        
    }
    
    
    // MARK: - Private Methods
    
    /**
     A CLIENT token is required to issue future responses. Get the token and store
     it within the keychain.
     */
    fileprivate func refreshClientToken(forceUpdate: Bool = false) {
        
        // Already have an access token
        if !forceUpdate, let _ = services.globalModelsCoordinator.authorizationManager.clientAccessToken {
            
            
            return
            
        }
        
        // Request a new token
        services.apiService.getClientAuthorizationToken { response, error in
            
            guard let accessToken = response?.accessToken, error == nil else {
                
                let alert = UIAlertController(title: nil, message: error!.localizedDescription, preferredStyle: .alert)
                
                let retry = UIAlertAction(title: "RETRY", style: .default, handler: { action in
                    self.refreshClientToken()
                })
                alert.addAction(retry)
                
                alert.addAction(UIAlertAction(title: "CANCEL", style: .cancel, handler: nil))

                return
                
            }
            
            self.services.globalModelsCoordinator.authorizationManager.clientAccessToken = accessToken
            
            
            
        }
        
    }
    
    fileprivate func configureView() {
       
        environmentButton.setTitleColor(UIColor.MaverickPrimaryColor, for: .normal)

        #if DEVELOPMENT
            environmentButton.isHidden = false
        #else
            environmentButton.isHidden = true
        #endif
        
        ctaButton.setTitle("GET STARTED", for: .normal)
        
    }
    
    /**
     Prepare and display custom action sheet
     */
    private func launchActionSheet() {
        
        let environment = services.globalModelsCoordinator.authorizationManager.environment
        
        let productionAction = MaverickActionSheetButton(text: environment == .production ? "Production ✅" : "Production", font: R.font.openSansRegular(size: 18.0)!, action: { [unowned self] in
            
            self.services.globalModelsCoordinator.authorizationManager.environment = Constants.APIEnvironmentType.production
            self.refreshClientToken(forceUpdate: true)
            
            }, textColor: UIColor.MaverickPrimaryColor)
        
        let stagingAction = MaverickActionSheetButton(text: environment == .staging ? "Staging ✅" : "Staging", font: R.font.openSansRegular(size: 18.0)!, action: { [unowned self] in
            
            self.services.globalModelsCoordinator.authorizationManager.environment = Constants.APIEnvironmentType.staging
            self.refreshClientToken(forceUpdate: true)
            
            }, textColor: UIColor.MaverickPrimaryColor)
        
        let developmentAction = MaverickActionSheetButton(text: environment == .development ? "Development ✅" : "Development", font: R.font.openSansRegular(size: 18.0)!, action: { [unowned self] in
            
            self.services.globalModelsCoordinator.authorizationManager.environment = Constants.APIEnvironmentType.development
            self.refreshClientToken(forceUpdate: true)
            
            }, textColor: UIColor.MaverickPrimaryColor)
        
        let customAction = MaverickActionSheetButton(text: environment == .custom ? "\(self.services.globalModelsCoordinator.apiService.apiHostname) ✅" : "Custom", font: R.font.openSansRegular(size: 18.0)!, action: { [unowned self] in
            
            let alertController = UIAlertController(title: "Custom", message: "Set a custom backend URL", preferredStyle: .alert)
            alertController.addTextField(configurationHandler: {(_ textField: UITextField) -> Void in
                textField.placeholder = self.services.globalModelsCoordinator.apiService.apiHostname
                textField.isSecureTextEntry = false
            })
            let confirmAction = UIAlertAction(title: "OK", style: .default, handler: {(_ action: UIAlertAction) -> Void in
                guard let newURL = alertController.textFields?[0].text else { return }
                self.services.globalModelsCoordinator.authorizationManager.customBackendURL = newURL
                self.refreshClientToken(forceUpdate: true)
            })
            alertController.addAction(confirmAction)
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {(_ action: UIAlertAction) -> Void in
                
                
            })
            alertController.addAction(cancelAction)
            self.present(alertController, animated: true, completion: {
                
            })
            
            }, textColor: UIColor.MaverickPrimaryColor)
        
        
        let actionSheetTitle = "CHOOSE ENVIRONMENT"
        
        let maverickActionSheetViewModel = MaverickActionSheetViewModel(title: actionSheetTitle, maverickActionSheetItems: [productionAction, stagingAction, developmentAction, customAction], alignment: .leading)
        let maverickActionSheetViewController = MaverickActionSheetVC(viewModel: maverickActionSheetViewModel)
        
        let maverickActionSheetTransitioningDelegate = MaverickActionSheetTransitioningDelegate()
        maverickActionSheetViewController.transitioningDelegate = maverickActionSheetTransitioningDelegate
        transitioningDelegate = maverickActionSheetTransitioningDelegate
        
        present(maverickActionSheetViewController, animated: true, completion: nil)
        
    }
    
    
}

extension OnboardIntroViewController : PagerViewControllerDelegate {
    func paginatedViewController(paginatedViewController: PagerViewController, didUpdatePageCount count: Int) {
    
        pageControl.numberOfPages = count

    }
    
    func paginatedViewController(paginatedViewController: PagerViewController, didUpdatePageIndex index: Int) {
       
     
        pageControl.currentPage = index
        AnalyticsManager.Onboarding.trackSplashPageChange(index: index)
    
    }
    
   
   

}
