//
//  ViewController.swift
//  Maverick
//
//  Created by Garrett Fritz on 5/17/18.
//  Copyright © 2018 BeMaverick. All rights reserved.
//

import Foundation


class ViewController : UIViewController {
    
    /// Property to set visibility of nav bar
    var hasNavBar = false
    var isVisible = false
    var ignoreNavControl = false
    var selectedImage : UIImage?
    var selectedFrame : CGRect?
    var customInteractor : CustomInteractor?
    var notificationButton : UIBarButtonItem?
    var shouldTrackScreen = true
    
    
    func getTransitionFrame() -> CGRect? {
        
        return nil
        
    }
    
    func transitionCompleted() {
        
        
        
    }
    
    func getTransitionAlphaView() -> [UIView] {
        
        return []
        
    }
    
    deinit {
        
        print("deinit 💥: \(NSStringFromClass(self.classForCoder))")
        
    }
    
    override var prefersStatusBarHidden: Bool {
        return false
    }
    
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .none
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return  .default
    }
    
    
    func trackScreen() {
        
        if shouldTrackScreen {
            
            AnalyticsManager.trackScreen(location: self)
            
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        selectedFrame = nil
        selectedImage = nil
        updateBadgeCount()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        navigationController?.delegate = self
        
        trackScreen()
        if !ignoreNavControl {
            navigationController?.navigationBar.backgroundColor = .white
            navigationController?.navigationBar.barStyle = .default
            navigationController?.setNavigationBarHidden(!hasNavBar, animated: false)
        }
        
        isVisible = true
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        super.viewWillDisappear(animated)
        isVisible = false
        
    }
    
    
    func showNavBar(withTitle title : String? = nil) {
        
        if !ignoreNavControl {
            
            navigationController?.setNavigationBarHidden(false, animated: false)
            
            if let title = title {
                
                self.title = title
                navigationItem.titleView = nil
                
            } else {
                
                self.title = nil
                navigationItem.titleView = UIImageView(image: R.image.nav_header())
                
            }
            
        }
        
    }
    
    /**
     Back button pressed to dismiss view
     */
    @objc func backButtonTapped(_ sender: Any) {
        
        navigationController?.popViewController(animated: true)
        
    }
    
    /**
     friends button pressed
     */
    @objc func friendsButtonTapped(_ sender: Any) {
        
        if let vc = R.storyboard.inviteFriends().instantiateInitialViewController() {
            
            vc.modalPresentationStyle = .fullScreen
            present(vc, animated: true, completion: nil)
            
        }
        
    }
    
    /**
     friends button pressed
     */
    @objc func notificationsButtonTapped(_ sender: Any) {
        
        if let vc = R.storyboard.profile.notificationViewControllerId() {
            
            navigationController?.pushViewController(vc, animated: true)
            
        }
        
    }
    private func updateBadgeCount() {
        
        var number = Leanplum.inbox().unreadCount()
        if number > 100 {
            number = 99
        }
        
        UIApplication.shared.applicationIconBadgeNumber =  Int(number)
        
        if UIApplication.shared.applicationIconBadgeNumber > 0 {
            
            if UIApplication.shared.applicationIconBadgeNumber > 99 {
                
                notificationButton?.addBadge(number: 99)
                
            } else {
                
                notificationButton?.addBadge(number: UIApplication.shared.applicationIconBadgeNumber)
                
            }
            
        } else {
            
            notificationButton?.removeBadge()
            
        }
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // iOS 10 fix to not have white spacing on top
        automaticallyAdjustsScrollViewInsets = false
        
        navigationController?.setNavigationBarBackground(image: UIImage())
        navigationController?.setDefaultTitleAttributes()
        navigationController?.navigationBar.tintColor = .black
        navigationItem.hidesBackButton = true
        if navigationController?.childViewControllers.count == 1 {
            
            showNotificationsButton()
            
            
        } else {
            
            navigationItem.leftBarButtonItem = UIBarButtonItem(image: R.image.back_purple(),
                                                               style: .plain,
                                                               target: self,
                                                               action: #selector(backButtonTapped(_:)))
            navigationItem.leftBarButtonItem?.tintColor = UIColor.MaverickBadgePrimaryColor
            
        }
        
        if hasNavBar {
            
            showNavBar()
            
        }
        
        Leanplum.inbox().onChanged { [weak self] in
            
           self?.updateBadgeCount()
            
        }
        
    }
    
    func showNotificationsButton() {
        
        if notificationButton == nil {
            
            notificationButton = UIBarButtonItem(image: R.image.nav_notification(),
                                                 style: .plain,
                                                 target: self,
                                                 action: #selector(notificationsButtonTapped(_:)))
            
        }
        navigationItem.rightBarButtonItem = notificationButton
        
        
    }
    
    func showFindFriendsButton() {
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: R.image.findFriendsHeader(),
                                                            style: .plain,
                                                            target: self,
                                                            action: #selector(friendsButtonTapped(_:)))
        
    }
    
}

extension ViewController : UINavigationControllerDelegate {
    
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        guard let destination = toVC as? ViewController else { return nil }
        guard let source = fromVC as? ViewController else { return nil }
        
        switch operation {
        case .push:
            
            
            guard let frame = source.selectedFrame else { return nil }
            guard let image = source.selectedImage else { return nil }
            
            customInteractor = CustomInteractor(attachTo: destination)
            destination.customInteractor = customInteractor
            return SummaryDetailsPresentAnimationController(duration: TimeInterval(UINavigationControllerHideShowBarDuration + 0.2), isPresenting: true, originFrame: frame, image:image)
            
        default:
            guard let frame = destination.selectedFrame else { return nil }
            guard let image = destination.selectedImage else { return nil }
            
            return SummaryDetailsPresentAnimationController(duration: TimeInterval(UINavigationControllerHideShowBarDuration), isPresenting: false, originFrame: frame, image: image)
        }
        
    }
    
    func navigationController(_ navigationController: UINavigationController, interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        
        
        guard let ci = customInteractor else { return nil }
        return ci.transitionInProgress ? customInteractor : nil
        
    }
    
}




