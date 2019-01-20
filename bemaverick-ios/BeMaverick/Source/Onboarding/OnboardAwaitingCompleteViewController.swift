//
//  OnboardAwaitingCompleteViewController.swift
//  Maverick
//
//  Created by Garrett Fritz on 7/6/18.
//  Copyright © 2018 BeMaverick. All rights reserved.
//

import Foundation


class OnboardAwaitingCompleteViewController : ViewController {
    
    
    var fromSignup = false
    
    var skipStraightToComplete = false
    /// The `GlobalServicesContainer` that maintains access to global services
    var services: GlobalServicesContainer!
    
    
    override func viewDidLoad() {
       
        super.viewDidLoad()
        configureSignals()
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let vc = R.segue.onboardAwaitingCompleteViewController.onboardCompletedSegue(segue: segue)?.destination {
            
            vc.services = services
            
            vc.fromSignup = fromSignup
            
        }
        
    }
    /**
     Configure signals
     */
    fileprivate func configureSignals() {
        
        services.globalModelsCoordinator.authorizationManager.onUserAuthorizedSignal.subscribe(with: self) { [weak self] _ in
            
            log.verbose("🔔 Received user authorized signal")
            self?.performSegue(withIdentifier: R.segue.onboardAwaitingCompleteViewController.onboardCompletedSegue, sender: self)
            
        }
        
    }
    
    
}
