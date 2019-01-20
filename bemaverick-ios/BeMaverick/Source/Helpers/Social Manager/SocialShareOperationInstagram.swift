//
//  SocialShareOperationInstagram.swift
//  Maverick
//
//  Created by David McGraw on 4/18/18.
//  Copyright © 2018 BeMaverick. All rights reserved.
//

import Foundation
import Photos

class SocialShareOperationInstagram: SocialShareOperation {
    
    // MARK: - Public Methods
    
    deinit {
        log.verbose("💥")
    }
    
    required init(channel: SocialShareChannels = .instagram) {
        super.init(channel: channel)
    }
    
    /**
     Determine if the user is authorized to share through Instagram which requires
     no authorization.
     */
    override func isShareAvailable() -> Bool {
        return true
    }

    /**
     Kick off the operation
     */
    override func share(fromViewController vc: UIViewController) {
        
        if isPending { return }
        isPending = true
        
    }
    
    // MARK: - Operation
    
    override func main() {
        
        super.main()
        
        guard let _ = URL(string: shareUrlPath) else {
            executing(false)
            finish(true)
            return
        }
        
        if let localIdentifier = localIdentifier {
            
            showToast()
            
            // Give the toast time to sink in
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.0) {
            
                let c = "\(self.shareText) \(self.shareUrlPath)"
                if let caption = "\(c)".addingPercentEncoding(withAllowedCharacters: .urlHostAllowed),
                    let instagramUrl = URL(string: "instagram://library?LocalIdentifier=\(localIdentifier)&InstagramCaption=\(caption)")
                {
                    
                    DispatchQueue.main.async {
                        
                        if UIApplication.shared.canOpenURL(instagramUrl) {
                            UIApplication.shared.open(instagramUrl, options: [:], completionHandler: { _ in
                                
                                
                            })
                        }
                        
                    }
                    
                }
                
            }
            
        }
        
        executing(false)
        finish(true)
        
    }
    
}
