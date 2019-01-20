//
//  MaverickMessages.swift
//  BeMaverick
//
//  Created by David McGraw on 2/4/18.
//  Copyright © 2018 BeMaverick. All rights reserved.
//

import UIKit
import SwiftMessages

/**
 A helper which provides custom alert views and configs
 */
struct MaverickMessages {
 
    /**
     The config for displaying a styled alert for uploading
    */
    static func uploadCompletedMessageConfig() -> SwiftMessages.Config {
        
        var config = SwiftMessages.Config()
        config.presentationContext = .window(windowLevel: UIWindowLevelNormal)
        config.interactiveHide = true
        config.duration = SwiftMessages.Duration.seconds(seconds: 10.0)

        
        return config
        
    }
    
    /**
     The config for displaying a styled alert for upload progress tracking
     */
    static func uploadProgressMessageConfig() -> SwiftMessages.Config {
        
        var config = SwiftMessages.Config()
        config.presentationContext = .window(windowLevel: UIWindowLevelNormal)
        config.interactiveHide = true
        config.duration = .forever
        
        return config
        
    }
    
    /**
     The alert view signaling an upload completed
    */
    static func uploadCompleteMessageView(error: String? = nil,
                                          response: Response? = nil,
                                          challenge : Challenge? = nil,
                                          localIdentifier: String? = nil) -> UIView {
        
        let view: UploadMessageView = try! SwiftMessages.viewFromNib(named: "UploadMessageView")
        
        view.response = response
        view.challenge = challenge
        view.localIdentifier = localIdentifier
        
        if error != nil {
            view.setErrorMessage(message: "\(error ?? "")")
        }
        return view
        
    }
    
    /**
     The alert view signaling an upload progress
     */
    static func uploadProgressMessageView(withId id: String = "uploading") -> UIView {
        
        let view: UploadMessageView = try! SwiftMessages.viewFromNib(named: "UploadMessageView")
        
        view.setUploadProgress(withProgress: 10.0)
        view.id = id
        
        return view
        
    }
    
}
