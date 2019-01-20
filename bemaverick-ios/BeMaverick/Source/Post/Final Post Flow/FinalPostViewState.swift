//
//  FinalPostViewState.swift
//  Maverick
//
//  Created by Chris Garvey on 8/14/18.
//  Copyright © 2018 BeMaverick. All rights reserved.
//

import UIKit

/**
 The base class for the visual states of the Final Post View Controller and is not intended to be instantiated on its own.
 
 Access the individual state using the static method identifier for each subclass. For example, invoking AcceptInputState.identifier will return the instantiated class object for that state.
 */
class FinalPostViewState {
    
    // MARK: - Class Property
    
    /// The unique hashable identifier for the instantiated object.
    public class var identifier: AnyHashable {
        return ObjectIdentifier(self)
    }
    
    
    // MARK: - Instance Properties
    
    /// The view controller that is manipulated by the state.
    unowned let finalPostViewController: FinalPostViewController
    
    
    // MARK: - Lifecycle
    
    init(finalPostViewController: FinalPostViewController) {
        self.finalPostViewController = finalPostViewController
    }
    
    
    // MARK: - Public Method
    
    /// configureViewForState() will be overriden by its subclasses to configure the view based upon the current state.
    public func configureViewForState() { }
    
}

/// The initial state of the view controller when it first appears.
class InitialState: FinalPostViewState {
    
    override public func configureViewForState() {
        
        if finalPostViewController.finalPostViewModel?.description == "" {
            
            finalPostViewController.descriptionText.textColor = .gray
            finalPostViewController.descriptionText.text = R.string.maverickStrings.finalPostPlaceholderTextForDescriptionField()
            
        } else {
            
            finalPostViewController.descriptionText.textColor = .black
            finalPostViewController.descriptionText.text = finalPostViewController.finalPostViewModel?.description
            
        }
        
    }
    
    deinit {
        log.verbose("💥")
    }
    
}

/// The state of the view controller when the user is inputing text into the description field.
class AcceptInputState: FinalPostViewState {
    
    override public func configureViewForState() {
        
        finalPostViewController.descriptionText.textColor = .black
        
        if finalPostViewController.descriptionText.text == R.string.maverickStrings.finalPostPlaceholderTextForDescriptionField() {
            finalPostViewController.descriptionText.text = ""
        }

        if let keyboardHeight = finalPostViewController.keyboardHeight {
            
            finalPostViewController.actionViewBottomConstraint.constant += keyboardHeight - 44
            
            UIView.animate(withDuration: 0.3, delay: 0.0, options: [.curveEaseOut, .allowUserInteraction], animations: {
                self.finalPostViewController.view.layoutIfNeeded()
                }, completion: nil)
            
        }
        
    }
    
    deinit {
        log.verbose("💥")
    }
    
}

/// The state of the view controller after the user has finished inputting text into the description field.
class RestingState: FinalPostViewState {
    
    override public func configureViewForState() {
        
        finalPostViewController.actionViewBottomConstraint.constant = 56
        
        UIView.animate(withDuration: 0.2, delay: 0.0, options: [.curveEaseOut, .allowUserInteraction], animations: {
            self.finalPostViewController.view.layoutIfNeeded()
        }, completion: nil)
        
        if finalPostViewController.finalPostViewModel?.description == R.string.maverickStrings.finalPostPlaceholderTextForDescriptionField() || finalPostViewController.finalPostViewModel?.description == "" {
            
            finalPostViewController.descriptionText.textColor = .gray
            finalPostViewController.descriptionText.text = R.string.maverickStrings.finalPostPlaceholderTextForDescriptionField()
            
        }
        
        finalPostViewController.autoCompleteView.clear()
        
    }
    
    deinit {
        log.verbose("💥")
    }
    
}

/// The state of the view controller when video is being processed.
class ProcessingVideoState: FinalPostViewState {
    
    deinit {
        log.verbose("💥")
    }
    
    override public func configureViewForState() {
        
        finalPostViewController.progressContainer.backgroundColor = UIColor.MaverickPrimaryColor
        finalPostViewController.progressLabel.states = [
            "Preparing Video for Upload", "Preparing Video for Upload.","Preparing Video for Upload..","Preparing Video for Upload..."]
        finalPostViewController.progressBar.trackTintColor = .white
        finalPostViewController.progressBar.progressTintColor = UIColor.MaverickBadgePrimaryColor
        finalPostViewController.progressBar.setProgress(0.05, animated: false)
        openProgressContainer()
        finalPostViewController.progressLabel.start()
        finalPostViewController.previewViewImage.image = nil
        finalPostViewController.previewViewActivityIndicator.startAnimating()
        finalPostViewController.previewViewActivityIndicator.isHidden = false
        
    }
    
    /// Opens the progress container that houses the progress label and the progress bar.
    private func openProgressContainer() {
        
        finalPostViewController.progressContainerBottomConstraintForHeight.constant = 60
        
        UIView.animate(withDuration: 1.0, delay: 0.0,
                       usingSpringWithDamping: 0.4, initialSpringVelocity: 10.0, options: .curveEaseIn,
                       animations: {
                        self.finalPostViewController.view.layoutIfNeeded()
        }, completion: nil)
        
    }
    
}

/// The state of the view controller when video processing has completed.
class FinishedProcessingVideoState: FinalPostViewState {
    
    deinit {
        log.verbose("💥")
    }
    
    override public func configureViewForState() {
        
        finalPostViewController.previewViewActivityIndicator.stopAnimating()
        finalPostViewController.changeCoverButton.isHidden = false
        finalPostViewController.changeCoverButton.titleLabel?.addShadow()
        
        if finalPostViewController.progressContainerBottomConstraintForHeight.constant != 0 {
            closeProgressLabel()
        }
        
    }
    
    /// Closes the progress container that houses the progress label and the progress bar.
    private func closeProgressLabel() {
        
        finalPostViewController.progressContainerBottomConstraintForHeight.constant = 0
        
        UIView.animate(withDuration: 0.3,
                       delay: 0.0,
                       options: [.curveEaseIn],
                       animations:
            {
                self.finalPostViewController.view.layoutIfNeeded()
        }, completion: nil)
        
    }
    
}
