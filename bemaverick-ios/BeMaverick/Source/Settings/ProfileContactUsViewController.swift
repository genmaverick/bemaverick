//
//  ProfileContactUsViewController.swift
//  Maverick
//
//  Created by Chris Garvey on 5/1/18.
//  Copyright © 2018 BeMaverick. All rights reserved.
//

import UIKit

class ProfileContactUsViewController: ViewController {
    
    // MARK: - IBOutlets
    
    /// Instruction label for contact us
    @IBOutlet weak var instructionLabel: UILabel!
    /// The text view containing the message to be sent
    @IBOutlet weak var messageInputTextView: UITextView!
    /// Message hint label that will animate up and transform smaller
    @IBOutlet weak var messageHintLabel: UILabel!
    /// The top constraint of the hint label that will be animated
    @IBOutlet weak var hintTopConstraint: NSLayoutConstraint!
    /// The leading constraint of the hint label that will be animated
    @IBOutlet weak var hintLeadingConstraint: NSLayoutConstraint!
    /// The bottom constraint of the scroll view that will be animated
    @IBOutlet weak var scrollViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var horizontalRule: UIView!
    
    // MARK: - Public Properties
    
    /// The `GlobalServicesContainer` that maintains access to global services
    var services: GlobalServicesContainer!
    
    
    // MARK: - Private Properties
    
    /// Flag tracking whether the hint is in the textview or not
    private var hintIsInField = true
    /// The send button in the right hand corner of the navigation bar
    private var sendButton = UIBarButtonItem()
    /// A reference to the `UIKeyboardWillShow` notification
    private var keyboardWillShowId: NSObjectProtocol?
    /// A reference to the `UIKeyboardWillHide` notification
    private var keyboardWillHideId: NSObjectProtocol?
    
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        
        hasNavBar = true
        super.viewDidLoad()
        configureView()
        
        messageInputTextView.delegate = self
        
        messageHintLabel.layer.allowsEdgeAntialiasing = true
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        view.addGestureRecognizer(tap)
        
    }
    
  
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        messageInputTextView.becomeFirstResponder()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(keyboardWillShowId as Any)
        NotificationCenter.default.removeObserver(keyboardWillHideId as Any)
        
    }
    
 
    // MARK: - Private Methods
    

    /**
     Animates the hint label back into place and resigns first responder if necessary.
     - parameter sender: the user tap on the view
     */
    @objc private func handleTap(_ sender: UITapGestureRecognizer) {

        if sender.view != messageInputTextView {

            view.endEditing(true)

            if messageInputTextView.text == "" && hintIsInField == false {

                hintIsInField = true
                
                hintTopConstraint.constant += 18
                hintLeadingConstraint.constant += 6
                
                UIView.animate(withDuration: 0.2) {

                    self.view.layoutIfNeeded()
                    self.messageHintLabel.transform = .identity

                }

            }

        }

    }
    
    
    /**
     Configure the default layout
     */
    private func configureView() {

        // iOS 10 fix to not have white spacing on top
        automaticallyAdjustsScrollViewInsets = false
        // Setup navigation
     
        
        sendButton = UIBarButtonItem(title: R.string.maverickStrings.send(), style: .plain, target: self, action: #selector(sendButtonTapped(_:)))
        navigationItem.rightBarButtonItem = sendButton
        sendButton.isEnabled = false
        
        title = R.string.maverickStrings.contactUsTitle()
        view.backgroundColor = .white
        instructionLabel.text = R.string.maverickStrings.contactUsInstructionLabel()
        
        horizontalRule.backgroundColor = UIColor.MaverickPrimaryColor
        
        observeKeyboardWillShow()
        observeKeyboardWillHide()
        
    }
    
    /**
     Observe when the keyboard becomes visible and adjusts the scroll view inset. This
     method will only monitor the notification once.
     */
    private func observeKeyboardWillShow() {
        
        keyboardWillShowId = NotificationCenter.default.addObserver(forName: .UIKeyboardWillShow,
                                                                    object: nil,
                                                                    queue: nil)
        { [weak self] notification in
            
            if let userInfo = notification.userInfo {
                
                self?.adjustToKeyboard(userInfo: userInfo)
                
            }
            
        }
        
    }
    
    /**
     Observe when the keyboard hides and adjusts the scroll view inset. This
     method will only monitor the notification once.
     */
    private func observeKeyboardWillHide() {
        
        keyboardWillHideId = NotificationCenter.default.addObserver(forName: .UIKeyboardWillHide,
                                                                    object: nil,
                                                                    queue: nil)
        { [weak self] notification in
            
            
            if let userInfo = notification.userInfo {
                
                self?.adjustToKeyboard(userInfo: userInfo)
                
            }
            
        }
        
    }
    
    /**
     Move on Keyboard
     */
    private func adjustToKeyboard(userInfo: [AnyHashable : Any]) {
        
        if let animationDuration = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue,
            let keyboardEndFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue,
            let animCurve = userInfo[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber
        {
            let convertedKeyboardEndFrame = self.view.convert(keyboardEndFrame, from: self.view.window)
            let rawAnimationCurve = animCurve.uint32Value << 16
            let animationCurve = UIViewAnimationOptions(rawValue: UInt(rawAnimationCurve))
            self.scrollViewBottomConstraint?.constant = self.view.bounds.maxY - convertedKeyboardEndFrame.minY - 50
            
            UIView.animate(withDuration: animationDuration, delay: 0.0, options: [.beginFromCurrentState , animationCurve], animations: {
                self.view.layoutIfNeeded()
            }, completion: nil)
            
        }
        
    }
    
    /**
     Sends the message from the user.
     - parameter barButtonItem: The "Send" button in the navigation bar.
     */
    @objc private func sendButtonTapped(_ barButtonItem: UIBarButtonItem) {
        
        guard let message = messageInputTextView.text else { return }
        
        services.globalModelsCoordinator.submitContactUsForm(withMessage: message) { error in
            
            guard error == nil else {
                
                var errorMessage = error!.localizedDescription
                
                if errorMessage == "" {
                    errorMessage = R.string.maverickStrings.networkError()
                }
                
                if errorMessage == "Error sending ticket" {
                    errorMessage = R.string.maverickStrings.errorSendingTicket()
                }
                
                let alert = UIAlertController(title: nil, message: errorMessage, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                return
                
            }
            
            let alert = UIAlertController(title: R.string.maverickStrings.success(), message: R.string.maverickStrings.contactUsSuccessMessage(), preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default){ alert in
                self.navigationController?.popToRootViewController(animated: true)
            })
            
            self.present(alert, animated: true, completion: nil)
            
        }
        
    }
    
}

extension ProfileContactUsViewController: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        
        if textView == messageInputTextView {
            
            if textView.text.count > 3 && !textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                
                sendButton.isEnabled = true
                
            } else {
                
                sendButton.isEnabled = false
                
            }
            
        }
        
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        
        if textView == messageInputTextView {
            
            if textView.text.isEmpty {
                
                hintIsInField = false
                
                hintTopConstraint.constant -= 18
                hintLeadingConstraint.constant -= 6
                
                UIView.animate(withDuration: 1.0, delay: 0.0, usingSpringWithDamping: 0.3, initialSpringVelocity: 0.8, options: [.curveEaseOut], animations: {
                    
                    self.view.layoutIfNeeded()
                    self.messageHintLabel.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
                    
                })
                
            }
            
        }
        
    }

}
