//
//  NetworkManager.swift
//  Maverick
//
//  Created by Chris Garvey on 5/21/18.
//  Copyright © 2018 BeMaverick. All rights reserved.
//

import Foundation
import Reachability
import SwiftMessages

class NetworkManager: NSObject {
    
    // MARK: - Public Properties
    
    /// Singleton object
    static public let sharedInstance: NetworkManager = { return NetworkManager() }()
    
    
    // MARK: - Private Properties
    
    /// The object that monitors network reachibilty
     let reachability: Reachability = Reachability()!
    
    /// The configuration object for the message to be displayed to the user
    private var messageConfiguration: SwiftMessages.Config!
    
    /// Flag to track whether network is currently reachable
    private var isReachable = true
    

    // MARK: - Life Cycle
    
    private override init() {
        super.init()
        
        configureReachability()
        configureMessage()
        
    }
    
    
    // MARK: - Public Functions
    
    /**
     Start the reachability service to monitor network status.
     */
    public func startMonitoringNetworkStatus() {
        startReachabilityNotifier()
    }
    
    /**
     Stop the reachability service monitoring network status.
     */
    public func stopMonitoringNetworkStatus() {
        stopReachabilityNotifier()
    }
    
    
    // MARK: - Private Functions
    
    /**
     Configure the reachability object that will monitor the network condition
     */
    private func configureReachability() {
        
        reachability.whenReachable = { reachability in
            
            log.debug("🌍 Network became reachable: \(reachability.connection.description)")
            
            if !self.isReachable {
                self.displayReachableMessage()
            }
            
            self.isReachable = true
            
        }
        
        reachability.whenUnreachable = { _ in
            log.debug("🌍 Network became unreachable")
            
            self.displayUnreachableMessage()
            self.isReachable = false
            
        }
        
    }
    
    /**
     Setup the configuration for the messaging object.
     */
    private func configureMessage() {
        
        var config = SwiftMessages.Config()
        config.presentationContext = .window(windowLevel: UIWindowLevelNormal)
        config.interactiveHide = false
        config.duration = SwiftMessages.Duration.seconds(seconds: 3.0)
        
        messageConfiguration = config
        
    }
    
    /**
     Start monitoring the network connection.
     */
    private func startReachabilityNotifier() {
        
        do {
            try reachability.startNotifier()
        } catch {
            log.debug("🌍 Failed to start reachability")
        }
        
    }
    
    /**
     Stop monitoring the network connection.
     */
    private func stopReachabilityNotifier() {
        reachability.stopNotifier()
    }
    
    /**
     Launch the message stating the network is reachable.
     */
    private func displayReachableMessage() {
        
        let view: NetworkManagerMessageView = try! SwiftMessages.viewFromNib(named: R.string.maverickStrings.networkManagerMessageViewNibName())
        view.setMessage(R.string.maverickStrings.networkReachableMessage())
        
        SwiftMessages.show(config: messageConfiguration,
                           view: view)
        
    }
    
    /**
     Launch the message stating the network is unreachable.
     */
    private func displayUnreachableMessage() {
        
        let view: NetworkManagerMessageView = try! SwiftMessages.viewFromNib(named: R.string.maverickStrings.networkManagerMessageViewNibName())
        view.setMessage(R.string.maverickStrings.networkUnreachableMessage())
        
        SwiftMessages.show(config: messageConfiguration,
                           view: view)
        
    }
    
}
