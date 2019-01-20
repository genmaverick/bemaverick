//
//  GlobalServicesContainer.swift
//  BeMaverick
//
//  Created by David McGraw on 9/14/17.
//  Copyright © 2017 BeMaverick. All rights reserved.
//

/**
 A `GlobalServicesContainer` object maintains the global services necessary to
 operate the application.
 */
class GlobalServicesContainer {
    
    /// The `APIService` interfaces with the platform
    let apiService: APIService!
    
    /// The 'SocialShareManager' object facilitating share actions
    let shareService: SocialShareManager!
    
    /// The `GlobalModelsCoordinator` object maintains global state
    let globalModelsCoordinator: GlobalModelsCoordinator!
    
    // MARK: - Lifecycle
    
    init(withAPIService apiService: APIService,
         shareService: SocialShareManager,
         globalModelsCoordinator: GlobalModelsCoordinator)
    {
    
        self.apiService = apiService
        self.shareService = shareService
        self.globalModelsCoordinator = globalModelsCoordinator
        
    }
    
}
