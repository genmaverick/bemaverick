//
//  PostModeConfirmViewController.swift
//  Maverick
//
//  Created by David McGraw on 3/7/18.
//  Copyright © 2018 BeMaverick. All rights reserved.
//

import Foundation

/// This view controller is deprecated and unused at the moment. Keeping it around for now as reference until all of the final post flow is completed.
class PostModeConfirmViewController: UIViewController {
    
    // MARK: - IBActions
    
    @IBAction func closeButtonPressed(_ sender: Any) {
        dismiss(animated: false, completion: nil)
    }
    
    @IBAction func acceptButtonPressed(_ sender: Any) {
        
        acceptButtonHandler?()
        dismiss(animated: false, completion: nil)
        
    }
    
    // MARK: - Lifecycle
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        trackScreen()
        
    }
    
    
    // MARK: - Private Methods
    
    /**
     Track that the user has started viewing this class.
     */
    private func trackScreen() {
        AnalyticsManager.trackScreen(location: self)
    }
    
    // MARK: - Public Properties
    
    /// Observe when the accept button is tapped
    open var acceptButtonHandler: (() -> Void)?
    
    
    
}
