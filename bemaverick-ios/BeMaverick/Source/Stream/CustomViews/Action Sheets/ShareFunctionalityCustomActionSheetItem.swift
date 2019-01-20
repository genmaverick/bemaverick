//
//  ShareFunctionalityCustomActionSheetItem.swift
//  Maverick
//
//  Created by Chris Garvey on 4/24/18.
//  Copyright © 2018 BeMaverick. All rights reserved.
//

import Branch

class ShareFunctionalityCustomActionSheetItem: UIView, CustomMaverickActionSheetItem {
    
    // MARK: - Private Properties
    
    /// A reference `GlobalServicesContainer` to access the shareService
    private weak var services: GlobalServicesContainer!
    
    /// The share service manager containing the share functionality
    private weak var shareService: SocialShareManager!
    
    /// A user to share
    private var user: User?
    
    /// A response to share
    private var response: Response?
    
    /// A challenge to share
    private var challenge: Challenge?
    
    
    // MARK: - IBOutlets
    
    /// Content view containing instagram
    @IBOutlet weak var instagramShareContentView: UIView!
    
    /// Constraint that will be adjusted when the instragram view is removed
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    // MARK: - IBActions
    
    /**
     Share via Instagram
     */
    @IBAction func instagramButtonTapped(_ sender: Any) {
        
        if let response = response {
            handleShare(forShareableItem: response, channel: .instagram)
        } else if let challenge = challenge {
            handleShare(forShareableItem: challenge, channel: .instagram)
        }
        
    }
    
    /**
     Share via Facebook
     */
    @IBAction func facebookButtonTapped(_ sender: Any) {
        
        if let response = response {
            handleShare(forShareableItem: response, channel: .facebook)
        } else if let challenge = challenge {
            handleShare(forShareableItem: challenge, channel: .facebook)
        } else if let user = user {
            handleShare(forShareableItem: user, channel: .facebook)
        }
        
    }
    
    /**
     Share via Twitter
     */
    @IBAction func twitterButtonTapped(_ sender: Any) {
        
        if let response = response {
            handleShare(forShareableItem: response, channel: .twitter)
        } else if let challenge = challenge {
            handleShare(forShareableItem: challenge, channel: .twitter)
        } else if let user = user {
            handleShare(forShareableItem: user, channel: .twitter)
        }
        
    }
    
    /**
     Share via SMS
     */
    @IBAction func messageButtonTapped(_ sender: Any) {
        
        if let response = response {
            handleShare(forShareableItem: response, channel: .sms)
        } else if let challenge = challenge {
            handleShare(forShareableItem: challenge, channel: .sms)
        } else if let user = user {
            handleShare(forShareableItem: user, channel: .sms)
        }
        
    }
    
    /**
     Display additional share options
     */
    @IBAction func moreButtonTapped(_ sender: Any) {
        
        guard let rootVc = UIApplication.shared.keyWindow?.rootViewController else { return }
        
        let showShareSheet: (BranchUniversalObject, BranchLinkProperties, String) -> Void = { branch, properties, message in
            
            let username = self.services.globalModelsCoordinator.loggedInUser?.username ?? ""
            
            branch.showShareSheet(with: properties,
                                  andShareText: "\(message)\n\(R.string.maverickStrings.share_sms_ps("@\(username)"))\n",
                from: rootVc)
            { activityType, completed in
                
                
            }
            
        }
        
        if let response = response,
            let (_, branch, properties, _) = shareService.generateShareLink(forResponse: response) {
            
            performAction {
                
                let (title, message) = self.shareService.getShareStrings(forResponse: response, channel: .generic)
                properties.addControlParam("$email_subject", withValue: title)
                showShareSheet(branch, properties, message)
                
            }
            
        } else if let challenge = challenge,
            let (_, branch, properties, _) = shareService.generateShareLink(forChallenge: challenge) {
            
            performAction {
                
                let (title, message) = self.shareService.getShareStrings(forChallenge: challenge, channel: .generic)
                properties.addControlParam("$email_subject", withValue: title)
                showShareSheet(branch, properties, message)
                
            }
            
        } else if let user = user,
            let (_, branch, properties, _) = shareService.generateShareLink(forUser: user) {
            
            performAction {
                
                let (title, message) = self.shareService.getShareStrings(forUser: user, channel: .mail)
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
        } else if let user = user {
            link = shareService.generateShareLink(forUser: user)?.path
        }
        
        performAction {
            
            if let link = link {
                UIPasteboard.general.string = link
                
                if let vc = UIApplication.shared.keyWindow?.rootViewController {
                    vc.view.makeToast("Link Copied")
                }
                
            }
            
        }
        
    }
    
    
    // MARK: - Life Cycle
    
    convenience init(response: Response, services: GlobalServicesContainer) {
        self.init(user: nil, response: response, challenge: nil, services: services)
    }
    
    convenience init(user: User, services: GlobalServicesContainer) {
        self.init(user: user, response: nil, challenge: nil, services: services)
    }
    
    convenience init(challenge: Challenge, services: GlobalServicesContainer) {
        self.init(user: nil, response: nil, challenge: challenge, services: services)
    }
    
    init(user: User?, response: Response?, challenge: Challenge?, services: GlobalServicesContainer) {
        super.init(frame: CGRect(x: 0, y: 58, width: 347, height: 340))
        
        self.user = user
        self.response = response
        self.challenge = challenge
        self.services = services
        
        shareService = services.shareService
        
        let view = loadFromNib()
        addSubview(view)
        
        refreshAvailableShareOptions()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Public Functions
    
    func myHeight() -> Double {
        return 320
    }
    
    func myType() -> MaverickActionSheetItemType {
        return .customView
    }
    
    
    // MARK: - Private Functions
    
    /**
     Loads the associated nib for the view.
     */
    private func loadFromNib<T: UIView>() -> T {
        
        let selfType = type(of: self)
        let bundle = Bundle(for: selfType)
        let nibName = String(describing: selfType)
        let nib = UINib(nibName: nibName, bundle: bundle)
        
        guard let view = nib.instantiate(withOwner: self, options: nil).first as? T else {
            fatalError("Error loading nib with name \(nibName)")
        }
        
        return view
        
    }
    
    /**
     Refresh share options based on the creator of a response
     */
    private func refreshAvailableShareOptions() {
        
        let currentInstaShareHeight = instagramShareContentView.bounds.height + 10
        
        if challenge != nil {
            
            instagramShareContentView.isHidden = false
            return
            
        }
        
        if user != nil {
            
            instagramShareContentView.isHidden = true
            bottomConstraint.constant += currentInstaShareHeight
            layoutIfNeeded()
            return
            
        }
        
        let meUserId = shareService.globalModelsCoordinator.loggedInUser?.userId
        
        if let creator = response?.getCreator(), creator.userId == meUserId {
            
            instagramShareContentView.isHidden = false
            
        } else {
            
            instagramShareContentView.isHidden = true
            bottomConstraint.constant += currentInstaShareHeight
            layoutIfNeeded()
        }
        
    }
    
    /**
     Perform the share operation using a native share experience if available
     */
    private func handleShare(forShareableItem shareableItem: ShareableType, channel: SocialShareChannels) {
        
        performAction {
            
            guard let rootVc = UIApplication.shared.keyWindow?.rootViewController else { return }
            
            if self.shareService.isShareAvailable(forChannel: channel) {
                
                if let user = self.user {
                    
                    self.shareService.share(user: user,
                                            throughChannel: channel,
                                            shareText: "",
                                            fromViewController: rootVc)
                    
                } else if let response = self.response {
                    
                    self.shareService.share(response: response,
                                            throughChannel: channel,
                                            shareText: "",
                                            fromViewController: rootVc)
                    
                } else if let challenge = self.challenge {
                    
                    self.shareService.share(challenge: challenge,
                                            throughChannel: channel,
                                            shareText: "",
                                            fromViewController: rootVc)
                    
                }
                
            } else {
                
                self.shareService.login(fromViewController: rootVc,
                                        channel: channel)
                { error in
                    
                    if let error = error {
                        
                        let alert = UIAlertController(title: "Whoops!", message: "Something went wrong. Please try again. \(error.localizedDescription)", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        self.parentViewControllerForSelf?.present(alert, animated: true, completion: nil)
                        return
                        
                    }
                    
                    // Retry share now that we're logged in
                    if self.shareService.isShareAvailable(forChannel: channel) {
                        
                        if let user = self.user {
                            
                            self.shareService.share(user: user,
                                                    throughChannel: channel,
                                                    shareText: "",
                                                    fromViewController: rootVc)
                            
                        } else if let response = self.response {
                            
                            self.shareService.share(response: response,
                                                    throughChannel: channel,
                                                    shareText: "",
                                                    fromViewController: rootVc)
                            
                        } else if let challenge = self.challenge {
                            
                            self.shareService.share(challenge: challenge,
                                                    throughChannel: channel,
                                                    shareText: "",
                                                    fromViewController: rootVc)
                            
                        }
                        
                    }
                    
                }
                
            }
            
        }
        
    }
    
    /**
     Performs a closure after dimissing a parent view controller, if any.
     - parameter action: The closure to be executed.
     */
    private func performAction(action: @escaping (() -> Void)) {
        
        if let currentParentViewController = self.parentViewControllerForSelf as? MaverickActionSheetVC {
            
            currentParentViewController.dismiss(animated: true, completion: {
                action()
            })
            
        }
        
    }
    
}
