//
//  SimpleCelebrationViewDefinitions.swift
//  Maverick
//
//  Created by Chris Garvey on 3/20/18.
//  Copyright © 2018 BeMaverick. All rights reserved.
//

import SwiftMessages

/**
 Contains the constant values that are used by both the LPMessageTemplates.h file and the CelebrationViewController.swift files.
 */
@objcMembers
class BannerViewDefinitions: NSObject {
    
    
    static func getDefinitions() -> [LPActionArg] {
        
         return [
            
        LPActionArg(named: "Background Color", with: UIColor.MaverickBadgePrimaryColor),
        LPActionArg(named: "Seconds to Display", with: 5.0),
        LPActionArg(named: "Title", withDict: [:]),
        LPActionArg(named: "Title.Text Color", with: .white),
        LPActionArg(named: "Title.Text", with: "Banner Text Here"),
        LPActionArg(named: "CTA", withDict: [:]),
        LPActionArg(named: "CTA.Text", with: "Click Me!"),
        LPActionArg(named: "CTA.Text Color", with: .white),
        LPActionArg(named: "CTA.Background Color", with: UIColor.MaverickPrimaryColor),
        LPActionArg(named: "CTA.Enabled", with: true),
        LPActionArg(named: "CTA.Action", with: "maverick://maverick/user/1"),
        LPActionArg(named: "Has Close Button", with: false),
       
        ]
    
    }
    
    static func launchMessage(context: LPActionContext) {
        
        launchMessage(backgroundColor: context.colorNamed("Background Color"), titleText: context.stringNamed("Title.Text"), titleColor: context.colorNamed("Title.Text Color"), ctaText: context.stringNamed("CTA.Text"), ctaTextColor: context.colorNamed("CTA.Text Color"), ctaBackgroundColor: context.colorNamed("CTA.Background Color"), ctaEnabled: context.boolNamed("CTA.Enabled"), ctaUrl: context.stringNamed("CTA.Action"), hasCloseButton: context.boolNamed("Has Close Button"), displayLength: context.numberNamed("Seconds to Display"))
        
        
    }
    
    static func launchMessage(backgroundColor : UIColor, titleText : String, titleColor : UIColor, ctaText : String, ctaTextColor : UIColor, ctaBackgroundColor : UIColor, ctaEnabled : Bool, ctaUrl : String, hasCloseButton : Bool, displayLength : NSNumber ) {
        
        
        var config = SwiftMessages.Config()
        config.presentationContext = .window(windowLevel: UIWindowLevelNormal)
        config.interactiveHide = true
        config.duration = SwiftMessages.Duration.seconds(seconds: TimeInterval(truncating: displayLength))
        let messageView: LPBannerMessage = try! SwiftMessages.viewFromNib(named: "LPBannerMessage")
        
        messageView.configure(backgroundColor : backgroundColor, titleText : titleText, titleColor : titleColor, ctaText : ctaText, ctaTextColor : ctaTextColor, ctaBackgroundColor : ctaBackgroundColor, ctaEnabled : ctaEnabled, ctaUrl : ctaUrl, hasCloseButton : hasCloseButton )
        messageView.configureDropShadow()
       
        
        SwiftMessages.show(config: config,
                           view: messageView)
        
        
    }
    
    
}
