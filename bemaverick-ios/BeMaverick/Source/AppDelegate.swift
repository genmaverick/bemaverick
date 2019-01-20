
//
//  AppDelegate.swift
//  BeMaverick
//
//  Created by David McGraw on 9/7/17.
//  Copyright © 2017 BeMaverick. All rights reserved.
//

import UIKit
import Reachability
import Fabric
import Crashlytics
import XCGLogger
import Branch
import Firebase
import AVFoundation
import UserNotifications
import SwiftMessages

/// Global reference to a configured `XCGLogger` instance
let log: XCGLogger = {
    
    let log = XCGLogger.default
    let systemDestination = AppleSystemLogDestination(owner: log, identifier: "logger.systemDestination")
    
    #if DEBUG
    systemDestination.outputLevel = .verbose
    #else
    systemDestination.outputLevel = .error
    #endif
    
    systemDestination.showLogIdentifier = false
    systemDestination.showFunctionName = true
    systemDestination.showThreadName = false
    systemDestination.showLevel = false
    systemDestination.showFileName = true
    systemDestination.showLineNumber = false
    systemDestination.showDate = false
    
    log.add(destination: systemDestination)
    
    log.logAppDetails()
    
    return log
    
}()



@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    var branchInitialized = false
    var storyboardLoaded = false
    private var lastLaunchOptions : [UIApplicationLaunchOptionsKey: Any]? = nil
    
    /// The `GlobalServicesContainer` maintains access to global services
    var services: GlobalServicesContainer!
    
    /// An object for monitoring the network reachability
    let networkManager = NetworkManager.sharedInstance

    
    func applicationDidReceiveMemoryWarning(_ application: UIApplication) {
        AnalyticsManager.DebugMemory.trackReceivedLowMemoryWarning()
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        // Fetch data using the default time period.
        UIApplication.shared.setMinimumBackgroundFetchInterval(UIApplicationBackgroundFetchIntervalMinimum)
        
        /// Configure services and dependencies
        configureDependencies(withApplication: application, launchOptions: launchOptions)
        
        //  Check if this is a background refresh action and stop here if it is
        guard UIApplication.shared.applicationState != .background  else { return true }
        
         NewRelic.start(withApplicationToken: IntegrationConfig.newRelicKey)
        
        // Crashlytics needs to be the last 3rd party init
        Fabric.with([Crashlytics.self, Answers.self])
        
        /// Load the proper storyboard based on the user authentication status
        loadStoryboard()
        /// Observe signals that warrent being at the delegate level (auth, for example, to reset the root controller)
        configureSignals()
        
        if let remoteOptions = launchOptions?[UIApplicationLaunchOptionsKey.remoteNotification] as? [String : Any], let lpx = remoteOptions["_lpx"] as? [String : String],  let urlPath = lpx["URL"], let url = URL(string: urlPath) {
            
            let handle = services.shareService.application(application,
                                                           open: url,
                                                           options: [:])
            
            if handle {
                return true
            }
            var branchHandled = false
            // pass the url to the handle deep link call
            if branchInitialized {
                
                branchHandled = Branch.getInstance().application(application,
                                                                 open: url,
                                                                 sourceApplication: nil,
                                                                 annotation: nil)
            }
            
            if !branchHandled {
                
                DeepLinkHelper.parseURIScheme(url : url, services: services.globalModelsCoordinator)
                
            }
        }
        
        return true
        
    }
    
    func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {

            AnalyticsManager.BackgroundAppRefresh.backgroundAppRefreshStarted()
        
            let refreshStartedTime = Date().timeIntervalSince1970
        
            guard let services = services else {
            AnalyticsManager.BackgroundAppRefresh.backgroundAppRefreshEnded(completionState: .failed, refreshDuration: 0)
            
            completionHandler(.noData)
            return
            
            }
        services.globalModelsCoordinator.authorizationManager.refreshAuthorizationCredentials(){ success in
            
            guard success else {
                
                AnalyticsManager.BackgroundAppRefresh.backgroundAppRefreshEnded(completionState: .failed, refreshDuration: 0)
                completionHandler(.noData)
                
                return
                
            }
            
            services.globalModelsCoordinator.prefetch(backgroundAppRefresh: true) { success in
                
                let duration = Date().timeIntervalSince1970 - refreshStartedTime
                
                guard success else {
                    AnalyticsManager.BackgroundAppRefresh.backgroundAppRefreshEnded(completionState: .noData, refreshDuration: Int(duration))
                    completionHandler(.noData)
                    
                    return
                }
                
                AnalyticsManager.BackgroundAppRefresh.backgroundAppRefreshEnded(completionState: .newData, refreshDuration: Int(duration))
                
                completionHandler(.newData)
                
            }
                
        }
        
    }
    
    
    func application(_ application: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        
        let handle = services.shareService.application(application,
                                                       open: url,
                                                       options: options)
        
        if handle {
            return true
        }
        var branchHandled = false
        // pass the url to the handle deep link call
        if branchInitialized {
            
            
            branchHandled = Branch.getInstance().application(application,
                                                             open: url,
                                                             sourceApplication: nil,
                                                             annotation: nil)
        }
        
        if !branchHandled {
            
            DeepLinkHelper.parseURIScheme(url : url, services: services.globalModelsCoordinator)
            
        }
        
        return true
        
    }
    
    // Respond to URI scheme links
    //DO NOT REMOVE THE ? FROM ANY, THIS KEEPS IT FROM CRASHING, IGNORE THE WARNING
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any?) -> Bool {
        
        var branchHandled = false
        // pass the url to the handle deep link call
        if branchInitialized {
            
            // pass the url to the handle deep link call
            branchHandled = Branch.getInstance().application(application,
                                                             open: url,
                                                             sourceApplication: sourceApplication,
                                                             annotation: annotation)
        }
        
        if !branchHandled {
            DeepLinkHelper.parseURIScheme(url : url, services: services.globalModelsCoordinator)
        }
        
        return false
        
    }
    
    // Respond to Universal Links
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([Any]?) -> Void) -> Bool {
        
        guard branchInitialized else { return true }
        // pass the url to the handle deep link call
        Branch.getInstance().continue(userActivity)
        
        return true
    }
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        
        if self.window?.rootViewController?.presentedViewController is FullScreenMediaViewController {
            
            if let secondController = self.window!.rootViewController?.presentedViewController as? FullScreenMediaViewController{
                
                if secondController.isBeingDismissed {
                    
                    return UIInterfaceOrientationMask.portrait
                    
                } else {
                    
                    return UIInterfaceOrientationMask.all
                    
                }
            }
        }
        
        if let navControler = self.window?.rootViewController?.presentedViewController as? UINavigationController {
            
            if navControler.viewControllers[safe: 0] is PostRecordParentViewController {
                
                return UIInterfaceOrientationMask.portrait
                
            }
            
        }
        switch (UIScreen.main.traitCollection.userInterfaceIdiom) {
        case .pad:
            return UIInterfaceOrientationMask.all
        default :
            return UIInterfaceOrientationMask.portrait
            
        }
        
        
    }
    
    func isSimulatorOrTestFlight() -> Bool {
        guard let path = Bundle.main.appStoreReceiptURL?.path else {
            return false
        }
        return path.contains("CoreSimulator") || path.contains("sandboxReceipt")
    }
    
    
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        
        if (application.applicationState == .active) // active --- forground
        {
            // publish your notification message
        }
        
        Leanplum.forceContentUpdate()
        
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        completionHandler(.newData)
        
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        
        
        if !storyboardLoaded {
            
            loadStoryboard()
        
        }
        
        /// Monitor the network
        networkManager.startMonitoringNetworkStatus()
        
        /// For now refresh authorization upon returning to the app
        services?.globalModelsCoordinator.authorizationManager.refreshAuthorizationCredentials()
        
        Leanplum.forceContentUpdate()
        
        if services.globalModelsCoordinator.loggedInUser != nil {
            
            var number = Leanplum.inbox().unreadCount()
            if number > 100 {
                number = 99
            }
            UIApplication.shared.applicationIconBadgeNumber =  Int(number)
            
        }
        
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        
        /// Stop monitoring the network
        networkManager.stopMonitoringNetworkStatus()
        
    }
    
    // MARK: - Public Methods
    
    /**
     Animates the transition between view controllers, setting the root controller
     to the inbound controller.
     */
    func transitionRootViewController(to controller: UIViewController) {
        
        UIView.transition(with: window!,
                          duration: 0.40,
                          options: .transitionCrossDissolve,
                          animations:
            {
                
                UIView.setAnimationsEnabled(false)
                self.window!.rootViewController = controller
                UIView.setAnimationsEnabled(true)
                
        }, completion: nil)
        
    }
    
    // MARK: - Private Methods
    
    /**
     Configure the dependencies to operate the app
     */
    fileprivate func configureDependencies(withApplication application: UIApplication,
                                           launchOptions: [UIApplicationLaunchOptionsKey: Any]?) {
        
        lastLaunchOptions = launchOptions
        
        // Force the log object to be created
        let _ = log
        
        /**
         Configure Maverick services
         */
        let globalModelsCoordinator = GlobalModelsCoordinator()
        
        let shareService = SocialShareManager(withGlobalModelsCoordinator: globalModelsCoordinator,
                                              application: application,
                                              launchOptions: launchOptions)
        
        let apiService = APIService(withGlobalModelsCoordinator: globalModelsCoordinator)
        
        let authorizationManager = AuthorizationManager()
        authorizationManager.apiService = apiService
        
        globalModelsCoordinator.apiService = apiService
        globalModelsCoordinator.authorizationManager = authorizationManager
        
        services = GlobalServicesContainer(withAPIService: apiService,
                                           shareService: shareService,
                                           globalModelsCoordinator: globalModelsCoordinator)
        
        AnalyticsManager.initialize()
        
        // Clean this entire file up...
        
        NotificationCenter.default.addObserver(self, selector: #selector(branchReady(_:)), name: NSNotification.Name(rawValue: "io.segment.analytics.integration.did.start"), object: BNCBranchIntegrationFactory.instance().key())
        
        NotificationCenter.default.addObserver(self, selector: #selector(leanplumReady(_:)), name: NSNotification.Name(rawValue: "io.segment.analytics.integration.did.start"), object: SEGLeanplumIntegrationFactory.instance().key())
        
        
        UIBarButtonItem.appearance().setTitleTextAttributes(
            [
                NSAttributedStringKey.font : R.font.openSansBold(size: 17.0)!,
                NSAttributedStringKey.foregroundColor : UIColor.MaverickBadgePrimaryColor,
                ], for: .normal)
        
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedStringKey.font : R.font.openSansRegular(size: 12.0)!], for: .normal)
        
        
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
        }
        catch {
            // report for an error
        }
        
    }
    
    /**
     We are getting the leanplum key from our segment integration, so we have to wait a moment for that to initialize, then we can set up leanplum things.
     */
    @objc func leanplumReady(_ notification: Notification) {
        
        Leanplum.inbox().onChanged {
            
            var number = Leanplum.inbox().unreadCount()
            if number > 100 {
                number = 99
            }
            UIApplication.shared.applicationIconBadgeNumber =  Int(number)
            
        }
    }
    
    /**
     We are getting the branch key from our segment integration, so we have to wait a moment for that to initialize, then we can set up branch.
     */
    @objc func branchReady(_ notification: Notification) {
        
        let branch: Branch = Branch.getInstance()
        branch.initSession(launchOptions: lastLaunchOptions, andRegisterDeepLinkHandler: {[weak self] params, error in
            if error == nil {
                guard let params = params as? [String: AnyObject],
                    let services = self?.services.globalModelsCoordinator else { return }
                
                DeepLinkHelper.processBranchDeepLink(param: params, services : services)
                
            }
        })
        branchInitialized = true
        
    }
    
    /**
     Load the appropriate storyboard based on authentication status.
     */
    fileprivate func loadStoryboard() {
        
        if window != nil { return }
        
        window = UIWindow(frame: UIScreen.main.bounds)
        
        // Load onboarding if we don't have a token
        guard let _ = services.globalModelsCoordinator.authorizationManager.currentAccessToken else {
            
            if let onboarding = R.storyboard.onboarding.instantiateInitialViewController() {
                
                if let vc = onboarding.viewControllers.first as? OnboardIntroViewController {
                    vc.services = services
                }
                
                window?.rootViewController = onboarding
                window?.makeKeyAndVisible()
                
            }
            storyboardLoaded = true
            return
            
        }
        
        // Display loading controller while things are setup
        if let loadingVC = R.storyboard.onboarding().instantiateViewController(withResource: R.storyboard.onboarding.onboardCompleteViewControllerId) {
            
            loadingVC.services = services
            
            window?.rootViewController = loadingVC
            window?.makeKeyAndVisible()
            
        }
        storyboardLoaded = true
    }
    
    
    func forceLogout() {
        
        
        services.globalModelsCoordinator.logout()
        
        /// Return to onboarding
        if let onboarding = R.storyboard.onboarding.instantiateInitialViewController() {
            
            if let vc = onboarding.viewControllers.first as? OnboardIntroViewController {
                
                vc.services = self.services
                
            }
            self.transitionRootViewController(to: onboarding)
            
        }
        
    }
    
    /**
     Observe critical system signals
     */
    fileprivate func configureSignals() {
        
        services.globalModelsCoordinator.authorizationManager.onUserInactiveSignal.subscribe(with: self) { revoked in
            
            log.verbose("🔔 Received user incative signal - revoked: \(revoked)")
            
            
            if let vc = R.storyboard.userBlock.inactiveUserViewControllerId() {
                
                vc.status = revoked != nil ? .revoked : .deactivated
                vc.revokedMode = revoked
                vc.services = self.services
                self.transitionRootViewController(to: vc)
                
            }
            
        }
        services.globalModelsCoordinator.authorizationManager.onUserAuthorizedSignal.subscribe(with: self) { authorized in
            
            log.verbose("🔔 Received user authorized signal - \(authorized)")
            
            if authorized {
                
                self.services.globalModelsCoordinator.reloadLoggedInUser()
                
            } else {
                
                self.forceLogout()
                
            }
            
        }
        
        services.globalModelsCoordinator.onResponsesUploadCompletedSignal.subscribe(with: self) {[weak self] (error, response, localIdentifier, shareChannels) in
            
            log.verbose("🔔 Received video uploaded signal - \(error ?? "")")
            SwiftMessages.hideAll()
            
            guard self?.services.globalModelsCoordinator.loggedInUser?.createdResponses.count ?? 0 > 1 else { return }
            
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1, execute: {
                
                SwiftMessages.show(config: MaverickMessages.uploadCompletedMessageConfig(),
                                   view: MaverickMessages.uploadCompleteMessageView(error: error,
                                                                                    response: response,
                                                                                    localIdentifier: localIdentifier))
                
            })
            
            // Kick off share actions
            if let response = response {
                
                for channel in shareChannels {
                    self?.services.shareService.share(response: response,
                                                     throughChannel: channel,
                                                     localIdentifier: localIdentifier)
                
                }
                
            }
            
        }
        
        services.globalModelsCoordinator.onResponsesUploadProgressSignal.subscribe(with: self) { progress in
            
            // Upload progress
            if let view = SwiftMessages.current(id: "uploading") as? UploadMessageView {
                
                view.setUploadProgress(withProgress: progress)
            
            } else {
                
                SwiftMessages.show(config: MaverickMessages.uploadProgressMessageConfig(),
                                   view: MaverickMessages.uploadProgressMessageView())
                
            }
            
        }
        
    }
    
}

