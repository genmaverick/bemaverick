//
//  ShareViewController.swift
//  Maverick
//
//  Created by David McGraw on 4/18/18.
//  Copyright © 2018 BeMaverick. All rights reserved.
//

import UIKit
import Branch

class ShareViewController: UIViewController {
    
    // MARK: - IBOutlets
    
    /// The height of the share content
    @IBOutlet weak var shareContentViewHeight: NSLayoutConstraint!
    
    /// Content view containing instagram
    @IBOutlet weak var instagramShareContentView: UIView!
    
    /// Share via instagram
    @IBOutlet weak var instagramButton: UIButton!
    
    /// Share via facebook
    @IBOutlet weak var facebookButton: UIButton!
    
    /// Share via twitter
    @IBOutlet weak var twitterButton: UIButton!
    
    /// Share via message
    @IBOutlet weak var messageButton: UIButton!
    
    /// Show additional options
    @IBOutlet weak var moreButton: UIButton!
    
    /// Share via link
    @IBOutlet weak var linkButton: UIButton!
    
    // MARK: - IBActions
    
    /**
     Dismiss the share flow
     */
    @IBAction func doneButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    /**
     Share via Instagram
    */
    @IBAction func instagramButtonTapped(_ sender: Any) {
        
        if let response = response {
            handleResponseShare(response: response, channel: .instagram)
        } else if let challenge = challenge {
            handleChallengeShare(challenge: challenge, channel: .instagram)
        }
        
    }
    
    /**
     Share via Facebook
    */
    @IBAction func facebookButtonTapped(_ sender: Any) {
        
        if let response = response {
            handleResponseShare(response: response, channel: .facebook)
        } else if let challenge = challenge {
            handleChallengeShare(challenge: challenge, channel: .facebook)
        }
        
    }
    
    /**
     Share via Twitter
     */
    @IBAction func twitterButtonTapped(_ sender: Any) {
        
        if let response = response {
            handleResponseShare(response: response, channel: .twitter)
        } else if let challenge = challenge {
            handleChallengeShare(challenge: challenge, channel: .twitter)
        }
        
    }
    
    /**
     Share via SMS
     */
    @IBAction func messageButtonTapped(_ sender: Any) {
        
        if let response = response {
            handleResponseShare(response: response, channel: .sms)
        } else if let challenge = challenge {
            handleChallengeShare(challenge: challenge, channel: .sms)
        }
        
    }
    
    /**
     Display additional share options
     */
    @IBAction func moreButtonTapped(_ sender: Any) {
        
        guard let rootVc = UIApplication.shared.keyWindow?.rootViewController else { return }
        
        let showShareSheet: (BranchUniversalObject, BranchLinkProperties, String) -> Void = { branch, properties, message in
            
            branch.showShareSheet(with: properties,
                                  andShareText: "\(message)\n\n",
                                  from: rootVc)
            { activityType, completed in
                
                
            }
            
        }
        
        if let response = response,
            let (_, branch, properties, _) = shareService.generateShareLink(forResponse: response) {

            dismiss(animated: true) {
                
                let (title, message) = self.shareService.getShareStrings(forResponse: response, channel: .generic)
                properties.addControlParam("$email_subject", withValue: title)
                showShareSheet(branch, properties, message)
                
            }
            
        } else if let challenge = challenge,
            let (_, branch, properties, _) = shareService.generateShareLink(forChallenge: challenge) {
            
            dismiss(animated: true) {
                
                let (title, message) = self.shareService.getShareStrings(forChallenge: challenge, channel: .generic)
                properties.addControlParam("$email_subject", withValue: title)
                showShareSheet(branch, properties, message)
                
            }
            
        }
        
    }
    
    /**
     Share via Link
     */
    @IBAction func linkButtonTapped(_ sender: Any) {
     
        var link: String?
        
        if let response = response {
            link = shareService.generateShareLink(forResponse: response)?.path
        } else if let challenge = challenge {
            link = shareService.generateShareLink(forChallenge: challenge)?.path
        }
        
        dismiss(animated: true) {
            
            if let link = link {
                UIPasteboard.general.string = link
                
                if let tabBar = UIApplication.shared.keyWindow?.rootViewController as? MainTabBarViewController,
                    let vc = tabBar.selectedViewController {
                    vc.view.makeToast("Link Copied")
                }
                
            }
            
        }
        
    }
    
    // MARK: - Public Properties
    
    /// A reference `GlobalServicesContainer` to acces
    open var shareService: SocialShareManager!
    
    /// A user to share
    open var user: User?
    
    /// A response to share
    open var response: Response?
    
    /// A challenge to share
    open var challenge: Challenge?
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        refreshAvailableShareOptions()
        
    }
    
    // MARK: - Private Methods
    
    /**
     Refresh share options based on the creator of a response
    */
    fileprivate func refreshAvailableShareOptions() {
        
        if challenge != nil { return }
        
        let meUserId = shareService.globalModelsCoordinator.loggedInUser?.userId
        if let creator = response?.getCreator(), creator.userId == meUserId {
            instagramShareContentView.isHidden = false
            shareContentViewHeight.constant = 340
        } else {
            instagramShareContentView.isHidden = true
            shareContentViewHeight.constant = 290
        }
        
    }
    
    /**
     Perform the share operation using a native share experience if available
     */
    fileprivate func handleResponseShare(response: Response,
                                         channel: SocialShareChannels)
    {
        
        dismiss(animated: true) {
            
            guard let rootVc = UIApplication.shared.keyWindow?.rootViewController else { return }
            
            if self.shareService.isShareAvailable(forChannel: channel) {
                
                self.shareService.share(response: response,
                                        throughChannel: channel,
                                        shareText: "",
                                        fromViewController: rootVc)
                
            } else {
                
                self.shareService.login(fromViewController: rootVc,
                                        channel: channel)
                { error in
                    
                    if let error = error {
                        
                        let alert = UIAlertController(title: "Whoops!", message: "Something went wrong. Please try again. \(error.localizedDescription)", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                        return
                        
                    }
                    
                    // Retry share now that we're logged in
                    if self.shareService.isShareAvailable(forChannel: channel) {
                        
                        self.shareService.share(response: response,
                                                throughChannel: channel,
                                                shareText: "",
                                                fromViewController: rootVc)
                        
                    }
                    
                }
                
            }
            
        }
        
    }
    
    /**
     Perform the share operation using a native share experience if available
     */
    fileprivate func handleChallengeShare(challenge: Challenge,
                                          channel: SocialShareChannels)
    {
        
        dismiss(animated: true) {
            
            guard let rootVc = UIApplication.shared.keyWindow?.rootViewController else { return }
            
            if self.shareService.isShareAvailable(forChannel: channel) {
                
                self.shareService.share(challenge: challenge,
                                        throughChannel: channel,
                                        shareText: "",
                                        fromViewController: rootVc)
                
            } else {
                
                self.shareService.login(fromViewController: rootVc,
                                        channel: channel)
                { error in
                    
                    if let error = error {
                        
                        let alert = UIAlertController(title: "Whoops!", message: "Something went wrong. Please try again. \(error.localizedDescription)", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                        
                    }
                    
                }
                
            }
            
        }
        
    }
    
}
