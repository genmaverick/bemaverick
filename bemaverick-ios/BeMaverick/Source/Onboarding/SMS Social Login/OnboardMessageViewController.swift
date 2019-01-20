//
//  OnboardMessageViewController.swift
//  Maverick
//
//  Created by David McGraw on 5/10/18.
//  Copyright © 2018 BeMaverick. All rights reserved.
//

import Foundation

protocol OnboardMessageDelegate {
    
    func shouldCreateAccount(forSocialChannel channel: SocialShareChannels)
    func shouldRetryVerification(forSocialChannel channel: SocialShareChannels)
    
}

class OnboardMessageViewController: UIViewController {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var createAccountButton: UIButton!
    
    @IBOutlet weak var retryButton: UIButton!
    
    // MARK: - IBActions
    
    @IBAction func createAccountButtonTapped(_ sender: Any) {
        delegate?.shouldCreateAccount(forSocialChannel: channel)
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func retryButtonTapped(_ sender: Any) {
        delegate?.shouldRetryVerification(forSocialChannel: channel)
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Public Properties
    
    /// The object that acts as the delegate of the message view
    var delegate: OnboardMessageDelegate?
    
    /// Social channel being authorized
    var channel: SocialShareChannels = .generic
    
}
