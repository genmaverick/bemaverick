//
//  UploadMessageView.swift
//  BeMaverick
//
//  Created by David McGraw on 2/4/18.
//  Copyright © 2018 BeMaverick. All rights reserved.
//

import SwiftMessages

// FYI -- Clashing with R.swift w/o this https://github.com/SwiftKickMobile/SwiftMessages/issues/70
class UploadMessageView: MessageView {
    
    // MARK: - IBOutlet
    
    @IBOutlet weak var previewImageLeadingSpace: NSLayoutConstraint!
    
    @IBOutlet weak var previewImage: UIImageView!
    
    @IBOutlet weak var shareIconStackViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var uploadContainerView: UIView!
    
    
    @IBOutlet weak var uploadMessageLabel: UILabel!
    
    
    @IBOutlet weak var progressBarContainer: UIView!
    
    @IBOutlet weak var progressBarWidth: NSLayoutConstraint!
    
    // MARK: - IBActions
    
    @IBAction func instagramButtonTapped(_ sender: Any) {
        share(throughChannel: .instagram)
    }
    
    @IBAction func facebookButtonTapped(_ sender: Any) {
        share(throughChannel: .facebook)
    }
    
    @IBAction func twitterButtonTapped(_ sender: Any) {
        share(throughChannel: .twitter)
    }
    
    @IBAction func smsButtonTapped(_ sender: Any) {
        share(throughChannel: .sms)
    }
    
    @IBAction func mailButtonTapped(_ sender: Any) {
        share(throughChannel: .mail)
    }
    
    @IBAction func linkButtonTapped(_ sender: Any) {
        
        var link: String?
        
        if let response = response {
            
            link = services.shareService.generateShareLink(forResponse: response)?.path
        
        } else if let challenge = challenge {
        
            link = services.shareService.generateShareLink(forChallenge: challenge)?.path
        
        }
        
        if let link = link {
            
            UIPasteboard.general.string = link
            
            if let vc = UIApplication.shared.keyWindow?.rootViewController {
                
                vc.view.makeToast("Link Copied")
            
                SwiftMessages.hideAll()
            }
            
        }
        
    }
    
    // MARK: - Public Properties
    
    /// A reference to the global services
    open var services: GlobalServicesContainer = (UIApplication.shared.delegate as! AppDelegate).services
    
    /// A response being shared
    open var response: Response? {
        
        didSet {
            refreshPreviewImage()
        }
        
    }
    
    
    /// A response being shared
    open var challenge: Challenge? {
        
        didSet {
            refreshPreviewImage()
        }
        
    }
    
    
    /// The identifier of the asset within the library
    open var localIdentifier: String?
    
    // MARK: - Public Methods
    
    open func setErrorMessage(message: String) {
        
        if message.contains("cancelled") {
            titleLabel?.text = "Upload cancelled. Saved to Drafts."
        } else {
            titleLabel?.text = message
        }
        
        previewImageLeadingSpace.constant = -previewImage.frame.size.width
        shareIconStackViewHeight.constant = 0
        
    }
    
    open func setUploadProgress(withProgress progress: CGFloat) {
        
        uploadContainerView.isHidden = false
        bringSubview(toFront: uploadContainerView)
        
        setNeedsUpdateConstraints()
        UIView.animate(withDuration: 0.225,
                       delay: 0.0,
                       options: [.beginFromCurrentState, .curveLinear],
                       animations:
        {
            
            self.progressBarWidth.constant = self.progressBarContainer.frame.size.width * (progress / 100)
            self.layoutIfNeeded()
            
        }, completion: { _ in
            
            if progress == 100 {
                SwiftMessages.hide()
            }
            
        })
        
    }
    
    
    // MARK: - Private Methods
    
    fileprivate func refreshPreviewImage() {
        
        previewImage.image = nil
        
        var path: String = ""
        if let response = response {
            
            path = response.videoCoverImageMedia?.getUrlForSize(size: previewImage.frame) ?? response.imageMedia?.getUrlForSize(size: previewImage.frame) ?? ""
        
        }
        
        if let challenge = challenge {
           
               path =  challenge.mainImageMedia?.getUrlForSize(size: previewImage.frame) ?? challenge.imageChallengeMedia?.getUrlForSize(size: previewImage.frame) ?? ""
            
        }
        
        if let url = URL(string: path) {
            
            previewImage.kf.setImage(with: url)
        
        }
        
    }
    
    fileprivate func share(throughChannel channel: SocialShareChannels) {
        
        guard let rootVc = UIApplication.shared.keyWindow?.rootViewController else { return }
        
        
        if services.shareService.isShareAvailable(forChannel: channel) != true {
            
            services.shareService.login(fromViewController: rootVc, channel: channel) { error in
                
                if let error = error {
                    
                    let alert = UIAlertController(title: "Whoops!", message: "Something went wrong. Please try again. \(error.localizedDescription)", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.parentViewControllerForSelf?.present(alert, animated: true, completion: nil)
                    return
                    
                }
                
            }
            
        }
        
        if let challenge = challenge {
            
            services.shareService.share(challenge: challenge,
                                        throughChannel: channel,
                                        localIdentifier: localIdentifier,
                                        fromViewController: rootVc)
            
        } else if let response = response {
            
            services.shareService.share(response: response,
                                        throughChannel: channel,
                                        localIdentifier: localIdentifier,
                                        fromViewController: rootVc)
            
        }
           
        
      
        SwiftMessages.hideAll()
        
        
    }
    
}
