//
//  ProfileSettingsViewController.swift
//  BeMaverick
//
//  Created by David McGraw on 11/28/17.
//  Copyright © 2017 BeMaverick. All rights reserved.
//

import UIKit
import PureLayout


class ProfileSettingsViewController: ViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Public Properties
    
    /// The `GlobalServicesContainer` that maintains access to global services
    var services: GlobalServicesContainer!
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        hasNavBar = true
        super.viewDidLoad()
        configureView()
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        
        if let vc = R.segue.profileSettingsViewController.updatePasswordSegue(segue: segue)?.destination {
            vc.services = services
        }
        
        if let vc = R.segue.profileSettingsViewController.notificationSettingsSegue(segue: segue)?.destination {
            vc.services = services
        }
        
        if let vc = R.segue.profileSettingsViewController.updateProfileSegue(segue: segue)?.destination {
            vc.services = services
        }
        
        if let vc = R.segue.profileSettingsViewController.contactUsSegue(segue: segue)?.destination {
            vc.services = services
        }
        
    }
    
    
   
    
    // MARK: - Private Methods


    
    
    /**
     Configure the default layout
     */
    fileprivate func configureView() {
        
        // Setup navigation
        
        showNavBar(withTitle: "Settings")
        
        
        let infoButton = UIButton(type: .infoLight)
        infoButton.setImage(R.image.infoButton(), for: .normal)
        infoButton.tintColor = UIColor.MaverickBadgePrimaryColor
        infoButton.addTarget(self, action: #selector(displayAboutDialog(_:)), for: .touchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: infoButton)
            
           view.backgroundColor = UIColor.white
        
        // iOS 10 fix to not have white spacing on top
        automaticallyAdjustsScrollViewInsets = false
        
    }
    
    /**
     Deactivate button pressed.
     prompts for confirmation, logs user out on success
     */
    @objc func deactivateAccountTapped(_ sender: Any) {
        
        AnalyticsManager.Settings.trackDeactivateProfilePressed()
        
        let continueToDeactivationAction = {
            
            self.services.globalModelsCoordinator.toggleActivation(deactivate: true) { error in
                
                guard error == nil else {
                    
                    self.displayErrorMessage(error: error!)
                    return
                }
                
                self.services.globalModelsCoordinator.authorizationManager.logout()
                
            }
            
        }
        
        let cancelDeactivationAction = {
            return
        }
        
        let actionSheetItem = DeactivateAccountCustomActionSheetItem(continuteToDeactivationAction: continueToDeactivationAction, cancelDeactivationAction: cancelDeactivationAction)
        
        let maverickActionSheetViewModel = MaverickActionSheetViewModel(title: R.string.maverickStrings.deactivateAccountActionSheetTitle(), maverickActionSheetItems: [actionSheetItem], alignment: .leading)
        let maverickActionSheetViewController = MaverickActionSheetVC(viewModel: maverickActionSheetViewModel)
        
        let maverickActionSheetTransitioningDelegate = MaverickActionSheetTransitioningDelegate()
        maverickActionSheetViewController.transitioningDelegate = maverickActionSheetTransitioningDelegate
        transitioningDelegate = maverickActionSheetTransitioningDelegate
        
        present(maverickActionSheetViewController, animated: true, completion: nil)
        
    }
    
    private func displayErrorMessage(error : MaverickError) {
      
        var errorMessage = error.localizedDescription
        if errorMessage == "" {
       
            errorMessage = R.string.maverickStrings.networkError()
       
        }
        let alert = UIAlertController(title: nil, message: errorMessage, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
  
    }
   
    
    @objc private func displayAboutDialog(_ sender: Any) {
        
        if let name = Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName"),
            let bundleVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion"),
            let bundleId = Bundle.main.object(forInfoDictionaryKey: "CFBundleIdentifier"),
            let shortString = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString"){
            
            let environment = DBManager.sharedInstance.getConfiguration().apiEnvironment.rawValue
            var message = "\(name)\n\(bundleId)\nVersion: \(shortString)\nBuild: \(bundleVersion)"
            if let gitCommit = Bundle.main.object(forInfoDictionaryKey: "mainCommit") as? String {
                let smallGitCode = gitCommit.prefix(7)
                message = "\(message)\nCode: \(smallGitCode)"
            }
            
            message = "\(message)\nEnv: \(environment.capitalizingFirstLetter())"
            let alertController = UIAlertController(title: "About", message: message, preferredStyle: .alert)
            let dismiss = UIAlertAction(title: "OK", style: .default) {(action:UIAlertAction) in
                
            }
            alertController.addAction(dismiss)
            
            self.present(alertController, animated: true, completion: nil)
       
        }
    
    }
    
}

extension ProfileSettingsViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 2
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        // General
        if section == 0 {
            if services.globalModelsCoordinator.getBlockedUsers().count > 0 {
                
                return 4
            
            }
            return 3
        }
        
        // Logout Action
        return 4
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.settingButtonId, for: indexPath)
        if indexPath.section == 0 {
            
            
            switch indexPath.row {
                
            case 0:
                cell?.titleLabel.text = R.string.maverickStrings.pushNotificationSettingsTitle()
            case 1:
                cell?.titleLabel.text = R.string.maverickStrings.changePasswordTittle()
            case 2:
                cell?.titleLabel.text = R.string.maverickStrings.contactUs()
            case 3:
                cell?.titleLabel.text = "Blocked Users"
                
            default:
                break
            }
            
            return cell ?? UITableViewCell()
            
        }
        
        
        switch indexPath.row {
            
        case 0:
            
            cell?.titleLabel.text = R.string.maverickStrings.termsOfServiceAction()
            
        case 1:
            
            cell?.titleLabel.text = R.string.maverickStrings.communityGuidelinesAction()
            
        case 2:
            
            cell?.titleLabel.text = R.string.maverickStrings.logoutAction()
            
        case 3:
            
            cell?.titleLabel.text = R.string.maverickStrings.deactivateAction()
            
        default:
            break
        }
        cell?.titleLabel.textColor = UIColor.MaverickPrimaryColor
        
        cell?.rightImageView.isHidden = true
        cell?.divider.isHidden = true
        
        return cell ?? UITableViewCell()
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.section == 0 {
            
            switch indexPath.row {
                
            case 0:
                performSegue(withIdentifier: R.segue.profileSettingsViewController.notificationSettingsSegue, sender: self)
            case 1:
                performSegue(withIdentifier: R.segue.profileSettingsViewController.updatePasswordSegue, sender: self)
            case 2:
                performSegue(withIdentifier: R.segue.profileSettingsViewController.contactUsSegue, sender: self)
            case 3:
                if let vc = R.storyboard.profile.blockedUsersViewControllerId() {
                    
                    vc.services = services
                    navigationController?.pushViewController(vc, animated: true)
                    
                }
            default:
                return
            }
            
        } else {
            
            switch indexPath.row {
                
            case 0:
                let urlToDisplay = URL(string: Constants.termsOfServiceURL)
                let webViewController = NavigationViewController(rootViewController: WebContentViewController(url: urlToDisplay!, webViewTitle: "Terms Of Service"))
                present(webViewController, animated: true, completion: nil)
            case 1:
                let urlToDisplay = URL(string: Constants.communityGuidelinesURL)
                let webViewController = NavigationViewController(rootViewController: WebContentViewController(url: urlToDisplay!, webViewTitle: "Community Guidelines"))
                present(webViewController, animated: true, completion: nil)
            case 2:
                AnalyticsManager.Settings.trackLogoutPressed()
                services.globalModelsCoordinator.authorizationManager.logout()
            case 3:
                deactivateAccountTapped(tableView)
            default:
                return
                
            }
           
        }
        
    }
    
}

extension ProfileSettingsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return UITableViewAutomaticDimension
        
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
}
