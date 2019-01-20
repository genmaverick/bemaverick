//
//  SocialShareOperationFacebook.swift
//  Maverick
//
//  Created by David McGraw on 4/18/18.
//  Copyright © 2018 BeMaverick. All rights reserved.
//

import Foundation
import FBSDKCoreKit
import FBSDKLoginKit
import FBSDKShareKit

class SocialShareOperationFacebook: SocialShareOperation {
    
    // MARK: - Public Methods
    
    deinit {
        log.verbose("💥")
    }
    
    required init(channel: SocialShareChannels = .facebook) {
        super.init(channel: channel)
    }
    
    /**
     Determine if the user is authorized to share through Facebook
    */
    override func isShareAvailable() -> Bool {
        return FBSDKAccessToken.current() != nil
    }
    
    /**
     Use the built-in share experience
    */
    override func share(fromViewController vc: UIViewController) {
    
        guard let url = URL(string: shareUrlPath) else { return }
        
        if isPending { return }
        isPending = true
        
        showToast(excludeUrl: true)
        
        // Give the toast time to sink in
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.0) {
            
            let content = FBSDKShareLinkContent()
            content.contentURL = url
            FBSDKShareDialog.show(from: vc, with: content, delegate: nil)
            
        }
        
    }
    
    /**
     Begin the login flow using Facebook Login Kit
    */
    override func login(fromViewController vc: UIViewController,
                        readOnly: Bool = false,
                        completionHandler: @escaping (_ error: MaverickError?) -> Void)
    {
        
        let login: FBSDKLoginManager = FBSDKLoginManager()
        
        if readOnly {
            loginWithReadPermissions(fromViewController: vc, completionHandler: completionHandler)
            return
        }
        
        login.logIn(withPublishPermissions: ["publish_actions"],
                    from: vc)
        { result, error in
        
            if let error = error {
                
                if error.isCancelled {
                    completionHandler(MaverickError.shareFailed(reason: .loginCanceledError()))
                } else {
                    completionHandler(MaverickError.shareFailed(reason: .unknownError(message: error.localizedDescription)))
                }
                return
                
            }
            
            if let isCancelled = result?.isCancelled, isCancelled == true {
                completionHandler(MaverickError.shareFailed(reason: .loginCanceledError()))
                return
            }
            
            completionHandler(nil)
            
        }
        
    }
    
    func loginWithReadPermissions(fromViewController vc: UIViewController,
                                  completionHandler: @escaping (_ error: MaverickError?) -> Void) {
        
        let login: FBSDKLoginManager = FBSDKLoginManager()
    
        login.logIn(withReadPermissions: ["email", "user_friends"],
                    from: vc)
        { result, error in
            
            if let error = error {
                
                if error.isCancelled {
                    completionHandler(MaverickError.shareFailed(reason: .loginCanceledError()))
                } else {
                    completionHandler(MaverickError.shareFailed(reason: .unknownError(message: error.localizedDescription)))
                }
                return
                
            }
            
            if let isCancelled = result?.isCancelled, isCancelled == true {
                completionHandler(MaverickError.shareFailed(reason: .loginCanceledError()))
                return
            }
            
            completionHandler(nil)
            
        }
        
    }
    
    // MARK: - Operation
    
    override func main() {
        
        super.main()
        
        guard let url = URL(string: shareUrlPath) else {
            
            finish(true)
            return
            
        }
        
        let content = FBSDKShareLinkContent()
        content.contentURL = url
        
        FBSDKShareAPI.share(with: content, delegate: self)
        
    }
    
}

extension SocialShareOperationFacebook: FBSDKSharingDelegate {
    
    func sharer(_ sharer: FBSDKSharing!, didCompleteWithResults results: [AnyHashable : Any]!) {
        
        executing(false)
        finish(true)
        
    }
    
    func sharer(_ sharer: FBSDKSharing!, didFailWithError error: Error!) {
        
        self.error = MaverickError.shareFailed(reason: .unknownError(message: error.localizedDescription))
        
        executing(false)
        finish(true)
        
    }
    
    func sharerDidCancel(_ sharer: FBSDKSharing!) {
        
        error = MaverickError.shareFailed(reason: .shareCanceledError())
        
        executing(false)
        finish(true)
        
    }
    
}

