//
//  OnboardFirstChallengeViewController.swift
//  BeMaverick
//
//  Created by David McGraw on 9/27/17.
//  Copyright © 2017 BeMaverick. All rights reserved.
//

import UIKit

class OnboardCelebrationViewController: ViewController {
    
    var services: GlobalServicesContainer!
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        

        
        if let vc = R.segue.onboardCelebrationViewController.firstChallengeFromOnboard(segue: segue)?.destination {
            
            vc.services = services
       
        }
        
        if let vc = R.segue.onboardCelebrationViewController.inviteFriendsSegue(segue: segue)?.destination {
            
            vc.services = services
            vc.fromOnboarding = true
        
        }
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(containerView)
        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            containerView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0),
            containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0),
            ])
        
        // add child view controller view to container
        
        let controller = CelebrationViewController()
        controller.delegate = self
        let titleString = Variables.Features.onboardCelebration_label1.stringValue().replacingOccurrences(of: "%s", with: services.globalModelsCoordinator.loggedInUser?.username ?? "you")
        
         controller.configure(label1: titleString, label2: Variables.Features.onboardCelebration_label2.stringValue(), label3: Variables.Features.onboardCelebration_label3.stringValue(), closingPhrase: Variables.Features.onboardCelebration_signature.stringValue(), closingName: Variables.Features.onboardCelebration_name.stringValue(), additionalMessage: "", buttonTitle: "Continue", backgroundColor: Variables.Features.onboardCelebration_backgroundColor.colorValue(), mainImage: R.image.onboard_celebration_image_chloeXhalle()!)
        addChildViewController(controller)
        controller.view.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(controller.view)
        
        NSLayoutConstraint.activate([
            controller.view.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            controller.view.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            controller.view.topAnchor.constraint(equalTo: containerView.topAnchor),
            controller.view.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
            ])
        
        controller.didMove(toParentViewController: self)
    
    }
    
}

extension OnboardCelebrationViewController : CelebrationViewControllerDelegate {
   
    func celebrationDismissed() {
      
        if Variables.Features.enableFindFriendsOnboarding.boolValue() {
            
            self.performSegue(withIdentifier: R.segue.onboardCelebrationViewController.inviteFriendsSegue, sender: self)
            
        } else {
        
            self.performSegue(withIdentifier: R.segue.onboardCelebrationViewController.firstChallengeFromOnboard, sender: self)
        
        }
  
    }
    
}
