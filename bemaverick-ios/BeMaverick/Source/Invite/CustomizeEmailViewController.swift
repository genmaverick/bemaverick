//
//  CustomizeEmailViewController.swift
//  Maverick
//
//  Created by Garrett Fritz on 5/30/18.
//  Copyright © 2018 BeMaverick. All rights reserved.
//

import Foundation
import SwiftMessages

class CustomizeEmailViewController : ViewController {
    
    @IBOutlet weak var subjectTextView: UITextView!
    
    @IBOutlet weak var bodyTextView: UITextView!
    
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var subjectLabel: UIView!
    
    override func viewDidLoad() {
         hasNavBar = true
        super.viewDidLoad()
        configureView()
        
    }
    
    var challengeId : String?
    /// The `GlobalServicesContainer` that maintains access to global services
    var services: GlobalServicesContainer?
    /// A reference to the `UIKeyboardWillShow` notification
    private var keyboardWillShowId: NSObjectProtocol?
    var emailsToSend : [String] = []
    var contactsToSend : [String] = []
    var source = Constants.Analytics.Invite.Properties.SOURCE.profile
    /// A reference to the `UIKeyboardWillHide` notification
    private var keyboardWillHideId: NSObjectProtocol?
    private var originalSubject = ""
    private var originalBody = ""
    
    func configureView() {
        
        observeKeyboardWillShow()
        observeKeyboardWillHide()
        
        
      
        
        
        let rightButton = UIBarButtonItem(title: R.string.maverickStrings.invite(), style: .plain, target: self, action: #selector(sendButtonPressed(_:)))
        
        navigationItem.rightBarButtonItem = rightButton
         
        
        if let username = services?.globalModelsCoordinator.loggedInUser?.username {
            
            if source != .editChallenge {

                bodyTextView.text = R.string.maverickStrings.custom_invite_template_body(username)
            
                subjectTextView.text = R.string.maverickStrings.custom_invite_template_subject(username)
                
            } else {
                
                bodyTextView.text = R.string.maverickStrings.custom_invite_challenge_template_body(username)
                subjectTextView.text = R.string.maverickStrings.custom_invite_challenge_template_subject(username)
                
            }
            originalSubject = subjectTextView.text
            originalBody = bodyTextView.text
        }
        
        
        subjectTextView.becomeFirstResponder()
        showNavBar(withTitle: "Email")
    
        let imagePath = UIBezierPath(rect: subjectLabel.frame)
        
        subjectTextView.textContainer.exclusionPaths = [imagePath]
    }
    
    
    /**
     Save button pressed - attempt to leave
     */
    @objc fileprivate func sendButtonPressed(_ sender: Any) {
        
        let subjectEdited = originalSubject != subjectTextView.text
        let bodyEdited = originalBody != bodyTextView.text
        AnalyticsManager.Invite.trackContactCustomizedInviteSent(mode: .email, source: source, edited: subjectEdited || bodyEdited)
        
        if let loggedInUser = services?.globalModelsCoordinator.loggedInUser, let link = services?.shareService.generateShareLink(forUser: loggedInUser)?.path {
            
            if let challengeId = challengeId , let challenge = services?.globalModelsCoordinator.challenge(forChallengeId: challengeId), let challengelink = services?.shareService.generateShareLink(forChallenge: challenge)?.path {
                
                services?.globalModelsCoordinator.inviteContacts(byEmails: emailsToSend, inviteUrl: challengelink, subject: subjectTextView.text, body: bodyTextView.text, completionHandler: { list in
                    
                })
                
            } else {
                
                services?.globalModelsCoordinator.inviteContacts(byEmails: emailsToSend, inviteUrl: link, subject: subjectTextView.text, body: bodyTextView.text, completionHandler: { list in
                    
                })
            }
          
            
            services?.globalModelsCoordinator.setInvited(id: contactsToSend, mode: .email)
            
            self.navigationController?.popViewController(animated: true)
            self.showMessagesSent()
            
        }
        
    }
    
    /**
     Display a message that invites have been sent
     */
    private func showMessagesSent() {
        
        var config = SwiftMessages.Config()
        config.presentationContext = .window(windowLevel: UIWindowLevelNormal)
        config.interactiveHide = true
        config.duration = SwiftMessages.Duration.seconds(seconds: 3.0)
        let messageView: InvitesSentMessageView = try! SwiftMessages.viewFromNib(named: "InvitesSentMessageView")
        
        messageView.configure(with: "Congratulations 🎉 We have sent invites for you!", avatar: nil)
        SwiftMessages.show(config: config,
                           view: messageView)
        
    }
   
        
    
    /**
     Observe when the keyboard becomes visible and adjusts the scroll view inset. This
     method will only monitor the notification once.
     */
    fileprivate func observeKeyboardWillShow() {
        
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
     Move on Keyboard
     */
    fileprivate func adjustToKeyboard(userInfo: [AnyHashable : Any]) {
        
        if let animationDuration = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue,
            let keyboardEndFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue,
            let animCurve = userInfo[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber
        {
            let convertedKeyboardEndFrame = self.view.convert(keyboardEndFrame, from: self.view.window)
            let rawAnimationCurve = animCurve.uint32Value << 16
            let animationCurve = UIViewAnimationOptions(rawValue: UInt(rawAnimationCurve))
            self.bottomConstraint.constant = self.view.bounds.maxY - convertedKeyboardEndFrame.minY - 50
            
            UIView.animate(withDuration: animationDuration, delay: 0.0, options: [.beginFromCurrentState , animationCurve], animations: {
                self.view.layoutIfNeeded()
            }, completion: nil)
            
        }
        
    }
    
    /**
     Observe when the keyboard hides and adjusts the scroll view inset. This
     method will only monitor the notification once.
     */
    fileprivate func observeKeyboardWillHide() {
        
        keyboardWillHideId = NotificationCenter.default.addObserver(forName: .UIKeyboardWillHide,
                                                                    object: nil,
                                                                    queue: nil)
        { [weak self] notification in
            
            
            if let userInfo = notification.userInfo {
                
                self?.adjustToKeyboard(userInfo: userInfo)
                
            }
            
        }
        
    }
    
}
