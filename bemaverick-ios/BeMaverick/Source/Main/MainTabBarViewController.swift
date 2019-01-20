//
//  MainTabBarViewController.swift
//  BeMaverick
//
//  Created by David McGraw on 9/7/17.
//  Copyright © 2017 BeMaverick. All rights reserved.
//

import UIKit
import StoreKit
import MessageUI
import AVKit
import Photos
import UserNotifications

class MainTabBarViewController: UITabBarController {
    
    private var ctaButton : UIButton!
    private var authorizationStatus = UNAuthorizationStatus.notDetermined
    private var previousIndex = 2
    override var prefersStatusBarHidden: Bool {
        return false
    }
    private var ctaPositionInitialized = false
    
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .none
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return  .default
    }
    
    
    // MARK: - Private Properties
    static var pendingDeepLink : Constants.DeepLink?
    
    /// Instance to the global services container
    private let services = (UIApplication.shared.delegate as! AppDelegate).services
    
    // MARK: - IBActions
    
    
    @IBAction func unwindSegueToHome(_ sender: UIStoryboardSegue) {
        
    }
    
    private func registerForPush() {
        
        if authorizationStatus == .denied {
            
            guard let settingsUrl = URL(string: UIApplicationOpenSettingsURLString) else {
                return
            }
            
            if UIApplication.shared.canOpenURL(settingsUrl) {
                
                UIApplication.shared.open(settingsUrl, options: [:], completionHandler: nil)
                navigationController?.popViewController(animated: false)
                
            }
            
        } else if authorizationStatus == .notDetermined  {
            
            UNUserNotificationCenter.current().requestAuthorization(options: [.badge,.alert,.sound]){ (granted,error) in
                
                
                self.authorizationStatus = granted ? .authorized : .denied
                
            }
            
            UIApplication.shared.registerForRemoteNotifications()
            
        }
        
    }
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        UNUserNotificationCenter.current().getNotificationSettings() { (settings) in
            
            self.authorizationStatus = settings.authorizationStatus
            
        }
            
        ctaButton = UIButton(frame: CGRect(x: 0, y: 0, width: 66.0, height: 66.0))
        
        view.addSubview(ctaButton)
        
        
        ctaButton.autoPinEdge(.trailing, to: .trailing, of: view, withOffset: -16.0)
       
       
        ctaButton.setImage(R.image.create_challenge(), for: .normal)
        ctaButton.addShadow()
        ctaButton.transform = CGAffineTransform(scaleX: 0.0, y: 0.0)
        ctaButton.addTarget(self, action:#selector(self.ctaClicked), for: .touchUpInside)
        
        CacheManager.shared.trimOldVideos()
        
        navigationController?.navigationBar.backgroundColor = .white
        navigationController?.navigationBar.barStyle = .default
        navigationController?.setNavigationBarHidden(false, animated: false)
        
        delegate = self
        selectedIndex = Variables.Features.homeTabIndex.integerValue()
        configureSignals()
        
        if let items = tabBar.items, let font = R.font.openSansRegular(size : 10){ let attrsSelected = [
            NSAttributedStringKey.font: font
            ]
            
            for item in items {
                item.setTitleTextAttributes(attrsSelected, for: .normal)
                item.setTitleTextAttributes(attrsSelected, for: .selected)
            }
        
        }
        
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if let tabs = tabBar as? MainTabBar {
            tabs.configureView()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        
        if !ctaPositionInitialized {
          
            ctaPositionInitialized = true
            if #available(iOS 11.0, *) {
                let window = UIApplication.shared.keyWindow
                
                let bottomPadding = window?.safeAreaInsets.bottom ?? 0.0
                
                ctaButton.autoPinEdge(.bottom, to: .bottom, of: view, withOffset: -64.0 - bottomPadding)
                
            } else {
                
                ctaButton.autoPinEdge(.bottom, to: .bottom, of: view, withOffset: -64.0)
                
            }
            view.layoutIfNeeded()
            
        }
        if let linkObject = MainTabBarViewController.pendingDeepLink {
            
            services?.globalModelsCoordinator.onDeepLinkSignal.fire(linkObject)
            
        }
        
        if let fromSignup = services?.globalModelsCoordinator.fromSignup, fromSignup {
            
            AnalyticsManager.Onboarding.trackSignupSuccess()
            services?.globalModelsCoordinator.fromSignup = false
            
        }
        
    }
    
    /**
     Configure signals
     */
    fileprivate func configureSignals() {
         services?.globalModelsCoordinator.onFABVisibilityChanged.subscribe(with: self, callback: { [weak self] (shouldHide) in
            
            if shouldHide {
                
                self?.hideCTA()
                
            } else {
                
                self?.showCTA(image: R.image.create_challenge())
                
            }
            
        })
        
        services?.globalModelsCoordinator.onProjectAchieved.subscribe(with: self) { [weak self] project in
            
            if let vc = R.storyboard.progression.gameWallViewControllerId() {
                
                vc.project = project
                vc.modalPresentationStyle = .overFullScreen
                self?.present(vc, animated: false)
                
            }
            
        }
        
        services?.globalModelsCoordinator.onLevelAchieved.subscribe(with: self) { [weak self] level in
            
            if let vc = R.storyboard.progression.gameWallViewControllerId() {
                
                vc.level = level
                vc.modalPresentationStyle = .overFullScreen
                self?.present(vc, animated: false)
                
            }
            
        }
        
        services?.globalModelsCoordinator.onDeepLinkSignal.subscribe(with: self) { [weak self] deepLink in
            
            MainTabBarViewController.pendingDeepLink = nil
            switch deepLink.deepLink {
            case .streams:
                
                if let streamType = self?.services?.globalModelsCoordinator.getStreamType(by: deepLink.id) {
                    
                    switch streamType {
                    
                    case .advertisement:
                        break
                        
                    case .response:
                        if let vc = R.storyboard.feed.genericResponseStreamViewControllerId() {
                            
                            vc.configure(streamId: deepLink.id, paginationEnabled: true)
                            vc.services = self?.services
                            guard let navController =  self?.selectedViewController as? UINavigationController else { return }
                            navController.pushViewController(vc, animated: true)
                            
                        }
                        
                    case .challenge:
                        if let stream = self?.services?.globalModelsCoordinator.getChallengeStream(by:  deepLink.id), let vc = R.storyboard.feed.genericChallengeStreamViewControllerId()  {
                            
                            vc.configure(stream: stream, paginationEnabled: true)
                            vc.services = self?.services
                            guard let navController =  self?.selectedViewController as? UINavigationController else { return }
                            navController.pushViewController(vc, animated: true)
                            
                        }
                        
                    }
                    
                }
                
            case .video:
                
                guard let path = deepLink.id.decodeUrl(), let videoURL = URL(string: path) else { return }
                
                let player = AVPlayer(url: videoURL)
                let playerViewController = AVPlayerViewController()
                playerViewController.player = player
                self?.present(playerViewController, animated: true) {
                   
                    playerViewController.player!.play()
                
                }
                
            case .findFriends:
                
                if let vc = R.storyboard.inviteFriends().instantiateInitialViewController() {
                    
                    vc.modalPresentationStyle = .fullScreen
                    self?.present(vc, animated: true, completion: nil)
                }
                
            case .challenge:
                
                guard let challenge = self?.services?.globalModelsCoordinator.challenge(forChallengeId: deepLink.id) else { return }
                if let vc = R.storyboard.challenges.challengeDetailsPageViewControllerId() {
                    vc.services = self?.services
                    vc.configure(with: challenge, startMinimized: false)
                    
                    guard let navController =  self?.selectedViewController as? UINavigationController else { return }
                    navController.pushViewController(vc, animated: true)
                }
                
            case .response:
                
                if let vc = R.storyboard.feed.singleContentItemViewControllerId() {
                    vc.services = self?.services
                    vc.configure(forContentType: .response, andId: deepLink.id)
                    guard let navController =  self?.selectedViewController as? UINavigationController else { return }
                    navController.pushViewController(vc, animated: true)
                }
                return
                
               
            case .request:
                
                self?.registerForPush()
                return
                
            case .rate:
                
                if #available(iOS 10.3, *) {
                    
                    SKStoreReviewController.requestReview()
                    
                } else {
                    // Fallback on earlier versions
                }
                
                return
                
            case .user:
                
                guard let vc = R.storyboard.profile.profileViewControllerId() else { return }
                vc.services = self?.services
                vc.userId =  deepLink.id
                guard let navController =  self?.selectedViewController as? UINavigationController else { return }
                navController.pushViewController(vc, animated: true)
                
            case .feedback:
                
                if MFMailComposeViewController.canSendMail() {
                    
                    let mail = MFMailComposeViewController()
                    mail.mailComposeDelegate = self
                    mail.setToRecipients(["support@bemaverick.com"])
                    let username = self?.services?.globalModelsCoordinator.loggedInUser?.username ?? ""
                    mail.setSubject("Maverick Feedback")
                    mail.setMessageBody("<p>I have something to say about the app from \(username)</p>", isHTML: true)
                    self?.present(mail, animated: true)
                    
                }
                
            case .main:
                guard let id = Int(deepLink.id) else { return }
                self?.selectedIndex = id
                guard let navController =  self?.selectedViewController as? UINavigationController else { return }
                navController.popToRootViewController(animated: true)
                
            default:
                
                return
                
            }
            
        }
        
    }
    
    func showCTA(image : UIImage? = nil) {
        
        self.ctaButton.isHidden = false
        ctaButton.setImage(image, for: .normal)
        UIView.animate(withDuration: 0.15, animations: { [weak self] in
            
            self?.ctaButton.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
            
        }) { (finished) in
            
            UIView.animate(withDuration: 0.25, animations: {[weak self] in
                
                self?.ctaButton.transform = CGAffineTransform.identity
                
            })
            
        }
        
        
    }
    
    func hideCTA() {
        
        UIView.animate(withDuration: 0.15, animations: { [weak self] in
            
            let transform =  CGAffineTransform(scaleX: 0.01, y: 0.01)
            self?.ctaButton.transform = transform //.rotated(by: CGFloat(M_PI))
            
        }) { [weak self](finished) in
            
            self?.ctaButton.isHidden = true
            
        }
        
    }
    
   
    
    @objc func ctaClicked() {
        
        AnalyticsManager.CreateChallenge.trackCreateCTA(location: .challenges)
        CreateChallengeViewController.attemptToCreateChallenge(services: services, viewController: self)
        
    }
    
}

extension MainTabBarViewController: UITabBarControllerDelegate {
    
    func tabBarController(_ tabBarController: UITabBarController,
                          shouldSelect viewController: UIViewController) -> Bool {
        
        return true
        
    }
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        
        if let items = tabBar.items, let index = items.index(of: item) {
            
            AnalyticsManager.Main.trackTabPressed(index: index)
            
            
             guard let navController =  self.selectedViewController as? UINavigationController else { return }
            
            if previousIndex == index {
                
               
                
                if navController.childViewControllers.count == 1 {
                    
                    if let mainController = navController.childViewControllers[0] as? StreamRefreshController {
                        
                        mainController.scrollToTop()
                        
                    } else if let mainController = navController.childViewControllers[0] as? NotificationViewController {
                        
                        mainController.scrollToTop()
                        
                    } else if let mainController = navController.childViewControllers[0] as? ChallengesViewController {
                        
                        mainController.scrollToTop()
                        
                    } else if let mainController = navController.childViewControllers[0] as? MyProgressViewController {
                        
                        mainController.scrollToTop()
                        
                    } else if let mainController = navController.childViewControllers[0] as? ProgressionViewController {
                        
                        mainController.scrollToTop()
                        
                    }
                    
                } else {
                    
                    navController.delegate = nil
                    
                }
                
            } else {
                selectedViewController?.navigationController?.delegate = nil
               previousIndex = index
                
            }
            
        }
        
    }
    
}

extension MainTabBarViewController: MFMailComposeViewControllerDelegate {
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        
        controller.dismiss(animated: true)
        
    }
    
}

