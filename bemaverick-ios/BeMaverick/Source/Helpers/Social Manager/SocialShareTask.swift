//
//  SocialShareTask.swift
//  Maverick
//
//  Created by David McGraw on 4/18/18.
//  Copyright © 2018 BeMaverick. All rights reserved.
//

import Foundation

/**
 An enum representing the type of task
 */
public enum SocialShareType: String {
    
    case none = "none"
    case user = "user"
    case response = "response"
    case challenge = "challenge"
    
}

protocol SocialShareTask {
    
    var channel: SocialShareChannels { get set }

    var type: SocialShareType { get set }
    
    var localIdentifier: String? { get set }
    
    var shareUrlPath: String { get set }
    
    var shareTitle: String { get set }
    
    var shareText: String { get set }
    
    var identifier: String { get set }
    
    var isPending: Bool { get set }
    
    init(channel: SocialShareChannels)
    
    init?(withSharePath shareUrlPath: String,
          localIdentifier: String?,
          shareTitle: String,
          shareText: String,
          identifier: String,
          channel: SocialShareChannels,
          type: SocialShareType)
    
    func isShareAvailable() -> Bool
    
    func share(fromViewController vc: UIViewController)
    
    func login(fromViewController vc: UIViewController,
               readOnly: Bool,
               completionHandler: @escaping (_ error: MaverickError?) -> Void)
    
}
