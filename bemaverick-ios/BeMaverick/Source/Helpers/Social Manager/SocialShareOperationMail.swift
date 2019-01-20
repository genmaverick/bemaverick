//
//  SocialShareOperationMail.swift
//  Maverick
//
//  Created by David McGraw on 4/19/18.
//  Copyright © 2018 BeMaverick. All rights reserved.
//

import Foundation
import MessageUI

class SocialShareOperationMail: SocialShareOperation, MFMailComposeViewControllerDelegate {
    
    // MARK: - Public Methods
    
    deinit {
        log.verbose("💥")
    }
    
    required init(channel: SocialShareChannels = .mail) {
        super.init(channel: channel)
    }
    
    /**
     Determine if the user can MAIL from this device
     */
    override func isShareAvailable() -> Bool {
        return MFMailComposeViewController.canSendMail()
    }
    
    /**
     Share content using MAIL
     */
    override func share(fromViewController vc: UIViewController) {
        
        guard let _ = URL(string: shareUrlPath) else { return }
        
        if isPending { return }
        isPending = true
        
        let controller = MFMailComposeViewController()
        controller.mailComposeDelegate = self
        controller.setSubject("\(shareTitle)")
        controller.setMessageBody("\(shareText)\n\n\(shareUrlPath)", isHTML: false)
        vc.present(controller, animated: true, completion: nil)
        
    }
    
    // MARK: - Operation
    
    /**
     This operation cannot be done on the background
     */
    override func main() {
        super.main()
    }
    
    // MARK: - MFMessageComposeViewControllerDelegate
    
    func mailComposeController(_ controller: MFMailComposeViewController,
                               didFinishWith result: MFMailComposeResult, error: Error?)
    {
        
        controller.dismiss(animated: true) {
            
            self.executing(false)
            self.finish(true)
            
        }
        
    }
    
}
