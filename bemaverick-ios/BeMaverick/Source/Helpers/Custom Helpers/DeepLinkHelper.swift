//
//  ShareHelper.swift
//  Maverick
//
//  Created by Garrett Fritz on 2/20/18.
//  Copyright © 2018 BeMaverick. All rights reserved.
//

import Foundation
import Branch


class DeepLinkHelper {
    static var overrideListenerEnabled = false
    /**
     Fire deep link signal from branch link
    */
    static func processBranchDeepLink(param : [String: AnyObject], services: GlobalModelsCoordinator) {
       
        guard let typeValue =  param[Constants.DeepLink.KEY_TYPE] as? String,
            let type = Constants.DeepLink.LinkType(rawValue: typeValue.lowercased()) else {
                services.onOverridenDeepLinkSignal.fire(nil)
                return
                
        }
        
      
        if type == .invite {
            
            processInviteCode(param: param, services: services)
            return
        
        }
        
        if type == .findFriends {
            
            var linkObject = Constants.DeepLink()
            linkObject.deepLink = type
            MainTabBarViewController.pendingDeepLink = linkObject
            services.onDeepLinkSignal.fire(linkObject)
            
        }
        
        if type == .logout {
            
            services.authorizationManager.logout()
            
        }
        
        if let linkId =  param[Constants.DeepLink.KEY_ID] as? String {
            
            var linkObject = Constants.DeepLink()
            linkObject.deepLink = type
            linkObject.id = linkId
            guard !overrideListenerEnabled else {
                services.onOverridenDeepLinkSignal.fire(linkObject)
                return
            }
            MainTabBarViewController.pendingDeepLink = linkObject
            services.onDeepLinkSignal.fire(linkObject)
            
        }
    
    }
    
    /**
     If user opened an invite, process it here
    */
    private static func processInviteCode(param : [String : AnyObject], services : GlobalModelsCoordinator) {
        
        guard let sourceValue =  param[Constants.DeepLink.INVITE_SOURCE_KEY] as? String,
            let dateString = param[Constants.DeepLink.INVITE_DATE_KEY] as? String,
        let miliseconds = Double(dateString) else { return }
        let date = Date(timeIntervalSince1970: (miliseconds / 1000.0))
        
        AnalyticsManager.Onboarding.trackInviteOpened(dateString, source: sourceValue)
        
    }
    
    /**
     If custom URI scheme is fired, this method will parse through path componenets and fire deep link signal
    */
    static func parseURIScheme(url : URL, services: GlobalModelsCoordinator?) {
        var linkObject = Constants.DeepLink()
        let components = url.pathComponents
        guard components.count > 0 else { return }
        if components.contains(Constants.DeepLink.LinkType.rate.rawValue) {
            
            linkObject.deepLink = .rate
            
           
        } else if components.index(of: Constants.DeepLink.LinkType.logout.rawValue) != nil {
            
            services?.authorizationManager.logout()
            return
            
        } else if let index = components.index(of: Constants.DeepLink.LinkType.challenge.rawValue), let id = components[safe: index + 1] {
            
            
            linkObject.deepLink = .challenge
            linkObject.id = id
            
            
        } else if let index = components.index(of: Constants.DeepLink.LinkType.streams.rawValue), let id = components[safe: index + 1] {
            
            
            linkObject.deepLink = .streams
            linkObject.id = id
            
            
        } else if let index = components.index(of: Constants.DeepLink.LinkType.main.rawValue), let id = components[safe: index + 1] {
            
            
            linkObject.deepLink = .main
            linkObject.id = id
            
            
        } else if let index = components.index(of: Constants.DeepLink.LinkType.user.rawValue), let id = components[safe: index + 1] {
            
            
            linkObject.deepLink = .user
            linkObject.id = id
            
            
        } else if let index = components.index(of: Constants.DeepLink.LinkType.request.rawValue), let id = components[safe: index + 1] {
            
            
            linkObject.deepLink = .request
            linkObject.id = id
            
            
        } else if let index = components.index(of: Constants.DeepLink.LinkType.response.rawValue), let id = components[safe: index + 1] {
            
            
            linkObject.deepLink = .response
            linkObject.id = id
            
            
        } else if let _ = components.index(of: Constants.DeepLink.LinkType.video.rawValue), let path = url.absoluteString.split(separator: "/").last {
            
            
            linkObject.deepLink = .video
            linkObject.id = String(path)
            
            
        } else if components.index(of: Constants.DeepLink.LinkType.feedback.rawValue) != nil {
            
            linkObject.deepLink = .feedback
            
        } else if components.index(of: Constants.DeepLink.LinkType.findFriends.rawValue) != nil {
        
             linkObject.deepLink = .findFriends
            
        }
        MainTabBarViewController.pendingDeepLink = linkObject
        services?.onDeepLinkSignal.fire(linkObject)
    
    }
    
}
