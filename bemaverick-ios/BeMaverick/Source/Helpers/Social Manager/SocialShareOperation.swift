//
//  SocialShareOperation.swift
//  Maverick
//
//  Created by David McGraw on 4/18/18.
//  Copyright © 2018 BeMaverick. All rights reserved.
//

import Foundation

/**
 The operation contains platform-specific sharing behavior. The operation can be
 executed to perform the share behavior in the background.
 */
class SocialShareOperation: BaseMaverickOperation, SocialShareTask {

    // MARK: - Public Properties
    
    var channel: SocialShareChannels
    var type: SocialShareType
    var localIdentifier: String?
    var shareUrlPath: String
    var shareTitle: String
    var shareText: String
    var identifier: String
    
    var isPending: Bool
    
    // MARK: - Public Methods
    
    required init(channel: SocialShareChannels) {
        
        self.channel = channel
        self.type = .none
        self.localIdentifier = nil
        self.shareUrlPath = ""
        self.shareTitle = ""
        self.shareText = ""
        self.identifier = ""
        self.isPending = false
        
        super.init()
        
    }
    
    required convenience init?(withSharePath shareUrlPath: String,
                               localIdentifier: String? = nil,
                               shareTitle: String,
                               shareText: String,
                               identifier: String,
                               channel: SocialShareChannels,
                               type: SocialShareType)
    {
        
        self.init(channel: channel)
        
        self.type = type
        self.localIdentifier = localIdentifier
        self.shareUrlPath = shareUrlPath
        self.shareTitle = shareTitle
        self.shareText = shareText
        self.identifier = identifier
        
    }

    func isShareAvailable() -> Bool {
        return false
    }

    func share(fromViewController vc: UIViewController) {
        
    }
    
    func login(fromViewController vc: UIViewController,
               readOnly: Bool = false,
               completionHandler: @escaping (_ error: MaverickError?) -> Void) {
        
    }
    
    func showToast(excludeUrl: Bool = false) {
        
        DispatchQueue.main.async {
            
            if let tabBar = UIApplication.shared.keyWindow?.rootViewController as? MainTabBarViewController,
                let vc = tabBar.selectedViewController {
                
                if excludeUrl {
                    UIPasteboard.general.string = "\(self.shareText)"
                } else {
                    UIPasteboard.general.string = "\(self.shareText) \(self.shareUrlPath)"
                }
                
                vc.view.makeToast("Caption Copied")
                
            }
            
        }
        
    }
    
    override func main() {
        
        // Finish if canceled or share isn't available
        guard isCancelled == false || !isShareAvailable() else {
            finish(true)
            return
        }
        
        if isPending { return }
        isPending = true
        
        executing(true)
        
    }
    
}
