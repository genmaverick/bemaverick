//
//  SocialShareOperationSMS.swift
//  Maverick
//
//  Created by David McGraw on 4/18/18.
//  Copyright © 2018 BeMaverick. All rights reserved.
//

import Foundation
import MessageUI

class SocialShareOperationSMS: SocialShareOperation, MFMessageComposeViewControllerDelegate {
    
    // MARK: - Public Methods
    
    deinit {
        log.verbose("💥")
    }
    
    required init(channel: SocialShareChannels = .sms) {
        super.init(channel: channel)
    }
    
    /**
     Determine if the user can SMS on this device
     */
    override func isShareAvailable() -> Bool {
        return MFMessageComposeViewController.canSendText()
    }
    
    /**
     Share content using SMS
     */
    override func share(fromViewController vc: UIViewController) {
        
        guard let _ = URL(string: shareUrlPath) else { return }
        
        if isPending { return }
        isPending = true
        let username = "@\(DBManager.sharedInstance.getLoggedInUser()?.username ?? "")"
        let controller = MFMessageComposeViewController()
        controller.body = "\(shareText)\(shareUrlPath)\n\n\(R.string.maverickStrings.share_sms_ps(username))"
        controller.messageComposeDelegate = self
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
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController,
                                      didFinishWith result: MessageComposeResult)
    {
        
        controller.dismiss(animated: true) {
            
            self.executing(false)
            self.finish(true)
            
        }
        
    }
    
}
