//
//  InviteSelectorViewController.swift
//  Maverick
//
//  Created by Garrett Fritz on 5/9/18.
//  Copyright © 2018 BeMaverick. All rights reserved.
//

import Foundation
import Contacts
import FBSDKLoginKit

class InviteSelectorViewController : ViewController {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var topContainer: UIView!
    @IBOutlet weak var emailContainer: UIView!
    
    @IBOutlet weak var searchContainer: UIView!
    @IBOutlet weak var emailLabel: UILabel!
    
    @IBOutlet weak var textContainer: UIView!
    
    @IBOutlet weak var textLabel: UILabel!
    
    @IBOutlet weak var qrContainer: UIView!
    
    @IBOutlet weak var qrLabel: UILabel!
    
    @IBOutlet weak var facebookContainer: UIView!
    // MARK: - IBActions
    
    @IBAction func emailTapped(_ sender: Any) {
        
        AnalyticsManager.Invite.trackSelectorEmailPressed(source: source)
        requestAccess { (granted) in
            
            guard granted else { return }
            DispatchQueue.main.async {
                
                if let vc = R.storyboard.inviteFriends.contactsViewControllerId() {
                    vc.mode = .email
                    vc.challengeId = self.challengeId
                    vc.source = self.source
                    vc.services = self.services
                    self.navigationController?.pushViewController(vc, animated: true)
                    return
                }
                
            }
            
        }
        
    }
    
    @IBAction func findMaverickTapped(_ sender: Any) {
        
        if let vc = R.storyboard.inviteFriends.searchMaverickViewControllerId() {
            vc.services = services
            self.navigationController?.pushViewController(vc, animated: true)
            return
        }
        
    }
    
    
    @IBAction func textTapped(_ sender: Any) {
        
        AnalyticsManager.Invite.trackSelectorTextPressed(source : source)
        requestAccess { (granted) in
            
            guard granted else { return }
            DispatchQueue.main.async {
                
                if let vc = R.storyboard.inviteFriends.contactsViewControllerId() {
                    vc.mode = .phone
                    vc.source = self.source
                    vc.services = self.services
                    self.navigationController?.pushViewController(vc, animated: true)
                    return
                }
                
            }
            
        }
        
    }
    
    @IBAction func facebookTapped(_ sender: Any) {
        
        let processFacebookHandler = {
            
            if let vc = R.storyboard.inviteFriends.contactsViewControllerId() {
                vc.mode = .facebook
                vc.source = self.source
                vc.services = self.services
                self.navigationController?.pushViewController(vc, animated: true)
            }
            
        }
        
        // The user may already have a valid token. Immediately process if so.
        if let _ = services?.shareService.accessTokens(forChannel: .facebook).key {
            
            let grantedFriends = services!.shareService.hasGrantedFacebookPermission(permission: "user_friends")
            if grantedFriends {
                processFacebookHandler()
                return
            }
            
        }
        
        // Login
        services?.shareService.login(fromViewController: self,
                                     channel: .facebook,
                                     readOnly: true)
        { error in
            
            if let err = error {
                self.displayAlert(withMessage: err.localizedDescription)
                return
            }
            
            let grantedFriends = self.services!.shareService.hasGrantedFacebookPermission(permission: "user_friends")
            if grantedFriends {
                processFacebookHandler()
            } else {
                self.displayAlert(withMessage: "It appears that we do not have permission to access your friends. Please try again.")
            }
            
        }
        
    }
    
    @IBAction func qrTapped(_ sender: Any) {
        
        AnalyticsManager.Invite.trackSelectorQRPressed(source : source)
        if let vc = R.storyboard.inviteFriends.qrViewControllerId() {
            vc.services = services
            vc.source = source
            vc.modalPresentationStyle = .fullScreen
            present(vc, animated: true, completion: nil)
            return
        }
        
    }
    
    // MARK: - Private Properties
    
    /// flag to determine if back button should be displayed
    private var isRootView = false
    
    // MARK: - Public Properties
    
    var fromOnboarding = false
    var challengeId : String?
    /// The `GlobalServicesContainer` that maintains access to global services
    var services: GlobalServicesContainer?
    
    // MARK: - Lifecycle
    var source = Constants.Analytics.Invite.Properties.SOURCE.deepLink
    override func viewDidLoad() {
        
        hasNavBar = true
        super.viewDidLoad()
        if services == nil {
            isRootView = true
            services = (UIApplication.shared.delegate as! AppDelegate).services
        }
        configureView()
        
    }
    
    
    override func trackScreen() {
        
        AnalyticsManager.Invite.trackInviteScreen(viewController: self, source: source)
        
    }
    
    /**
     Tapping back button
     */
    @IBAction override func backButtonTapped(_ sender: Any) {
        navigationController?.popViewController(animated: true)
        dismiss(animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let vc = R.segue.inviteSelectorViewController.sendToOnboardComplete(segue: segue)?.destination {
            
            vc.services = services
            
        }
        
    }
    
    // MARK: - Public Methods
    
    /**
     Save button pressed - attempt to leave
     */
    @objc fileprivate func nextButtonPressed(_ sender: Any) {
        
        if fromOnboarding {
            
            self.performSegue(withIdentifier: R.segue.inviteSelectorViewController.sendToOnboardComplete, sender: self)
            
        } else {
            
            if isRootView {
          
                dismiss(animated: true, completion: nil)
                return
            
            }
            
            navigationController?.popViewController(animated: true)
        
        }
    
    }
    
    /**
    */
    func requestAccess(completionHandler: @escaping (_ accessGranted: Bool) -> Void) {
        
        switch CNContactStore.authorizationStatus(for: .contacts) {
        case .authorized:
            completionHandler(true)
        case .denied:
            showSettingsAlert(completionHandler)
        case .restricted, .notDetermined:
            CNContactStore().requestAccess(for: .contacts) { granted, error in
                if granted {
                    completionHandler(true)
                } else {
                    DispatchQueue.main.async {
                        self.showSettingsAlert(completionHandler)
                    }
                }
            }
        }
        
    }
    
    // MARK: - Private Methods
    
    /**
    */
    private func configureView() {
        
        // iOS 10 fix to not have white spacing on top
        automaticallyAdjustsScrollViewInsets = false
        
        view.backgroundColor = .white
        
    
        
        if fromOnboarding {
            
            let rightButton = UIBarButtonItem(title: R.string.maverickStrings.next(), style: .plain, target: self, action: #selector(nextButtonPressed(_:)))
            
            navigationItem.rightBarButtonItem = rightButton
            
        } else if isRootView {
            
            let rightButton = UIBarButtonItem(title: "DONE", style: .plain, target: self, action: #selector(backButtonTapped(_:)))
            
            navigationItem.rightBarButtonItem = rightButton
        }
        
        navigationItem.leftBarButtonItem = (fromOnboarding || isRootView) ? nil : UIBarButtonItem(image: R.image.back_purple(),
                                                                                                  style: .plain,
                                                                                                  target: self,
                                                                                                  action: #selector(backButtonTapped(_:)))
        navigationItem.leftBarButtonItem?.tintColor = UIColor.MaverickBadgePrimaryColor

        
        showNavBar(withTitle: "Find My Friends")
        
        if !Variables.Features.facebookFriendsEnabled.boolValue() {
            
            facebookContainer.isHidden = true
        
        } else {
            
            facebookContainer.isHidden = false
            
        }
        
        if source == .editChallenge {
            
            facebookContainer.isHidden = true
            qrContainer.isHidden = true
            searchContainer.isHidden = true
            topContainer.isHidden = true
            showNavBar(withTitle: "INVITE MY FRIENDS")
            
            navigationItem.leftBarButtonItem = UIBarButtonItem(image: R.image.back_purple(),
                                                               style: .plain,
                                                               target: self,
                                                               action: #selector(backButtonTapped(_:)))
            navigationItem.leftBarButtonItem?.tintColor = UIColor.MaverickBadgePrimaryColor
            
            navigationItem.rightBarButtonItem = nil
            
        }
   
    }
    
    /**
     */
    private func showSettingsAlert(_ completionHandler: @escaping (_ accessGranted: Bool) -> Void) {
        
        let alert = UIAlertController(title: nil, message: "This app requires access to Contacts to proceed. Would you like to open settings and grant permission to contacts?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Open Settings", style: .default) { action in
            completionHandler(false)
            UIApplication.shared.open(URL(string: UIApplicationOpenSettingsURLString)!)
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { action in
            completionHandler(false)
        })
        present(alert, animated: true)
        
    }
    
    /**
     Display a generic alert controller
     */
    private func displayAlert(withMessage message: String) {
        
        let alert = UIAlertController(title: "Whoops!", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
        
    }
    
    // MARK: - Overrides
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return  .lightContent
    }
    
    override var prefersStatusBarHidden: Bool {
        return false
    }
    
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .none
    }
    
}
