//
//  CreateChallengeEntryState.swift
//  Maverick
//
//  Created by Chris Garvey on 9/27/18.
//  Copyright © 2018 BeMaverick. All rights reserved.
//

import Foundation

/**
 The base class for the visual states of the CreateChallengeViewController and is not intended to be instantiated on its own.
 
 Access the individual state using the static method identifier for each subclass. For example, invoking TextEntryState.identifier will return the instantiated class object for that state.
 */
class CreateChallengeEntryState {
    
    // MARK: - Class Property
    
    /// The unique hashable identifier for the instantiated object. Necessary to allow the class to be used as a key in a dicitonary.
    public class var identifier: AnyHashable {
        return ObjectIdentifier(self)
    }
    
    
    // MARK: - Instance Properties
    
    /// The view controller that is manipulated by the state.
    unowned let createChallengeViewController: CreateChallengeViewController
    
    
    // MARK: - Lifecycle
    
    init(createChallengeViewController: CreateChallengeViewController) {
        self.createChallengeViewController = createChallengeViewController
    }
    
    
    // MARK: - Public Method
    
    /// configureViewForState() will be overriden by its subclasses to configure the view based upon the current state.
    public func configureViewForState() { }
    
}

/// The text entry state of the view controller when a user creates a challenge.
class TextEntryState: CreateChallengeEntryState {
    
    override public func configureViewForState() {
        
        createChallengeViewController.textChallengeViews.forEach { $0.isHidden = false }
        createChallengeViewController.videoChallengeViews.forEach { $0.isHidden = true }
        
    }
    
    deinit {
        log.verbose("💥")
    }
    
}

/// The video entry state of the view controller when a user creates a challenge.
class VideoEntryState: CreateChallengeEntryState {
    
    override public func configureViewForState() {
        
        createChallengeViewController.videoChallengeViews.forEach { $0.isHidden = false }
        createChallengeViewController.textChallengeViews.forEach { $0.isHidden = true }
        
    }
    
    deinit {
        log.verbose("💥")
    }
    
}
