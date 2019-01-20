//
//  NotificationSettingsViewController.swift
//  Maverick
//
//  Created by Garrett Fritz on 3/13/18.
//  Copyright © 2018 BeMaverick. All rights reserved.
//

import Foundation
import UserNotifications

class NotificationSettingsViewController : ViewController {
    /// Main tableview
    @IBOutlet weak var tableView: UITableView!
    /// API + Model services
    var services : GlobalServicesContainer!
    var loggedInUser : User? = nil
    private var authorizationStatus = UNAuthorizationStatus.notDetermined
    /// Data to populate settings
    private var settings = [
        
        Constants.NotificationSettings.push,
        Constants.NotificationSettings.push_general,
        Constants.NotificationSettings.push_posts,
        Constants.NotificationSettings.push_follower,
        
        ]
    
    /*
 current.requestAuthorization(options: [.badge,.alert,.sound]){ (granted,error) in
 
 self.tableView.reloadData()
 
 }
 UIApplication.shared.registerForRemoteNotifications()
     */
    
    override func viewDidLoad() {
        
        hasNavBar = true
        super.viewDidLoad()
        configureView()
        
        loggedInUser = services.globalModelsCoordinator.loggedInUser
        
      
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        UNUserNotificationCenter.current().getNotificationSettings(completionHandler: { (settings) in
            
            self.authorizationStatus = settings.authorizationStatus
            
            DispatchQueue.main.async {
                
                self.tableView.reloadData()
                
            }
            
        })
        
    }
    
    func configureView() {
        
        // iOS 10 fix to not have white spacing on top
        automaticallyAdjustsScrollViewInsets = false
        tableView.register(R.nib.emptyTableViewCell)
    
        
        
    
        showNavBar(withTitle: R.string.maverickStrings.notificationSettingsTitle())
        view.backgroundColor = .white
        tableView.backgroundColor = .white
        tableView.bounces = false
    
    }
    
    

    
} 


extension NotificationSettingsViewController : UITableViewDelegate , UITableViewDataSource {
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
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
                
                DispatchQueue.main.async {
                    
                    self.tableView.reloadData()
                    
                }
                
            }
            UIApplication.shared.registerForRemoteNotifications()
        }
       
        
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if authorizationStatus == .notDetermined || authorizationStatus == .denied {
            
            return 1
            
        }
        
        guard let loggedInUser = loggedInUser else { return 1 }
        return loggedInUser.pushEnabled ? settings.count : 1
        
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        switch authorizationStatus {
        case .authorized:
            if let cell =  tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.notificationSettingTableViewCellId, for: indexPath), let loggedInUser = loggedInUser {
                
                cell.titleLabel.text = settings[indexPath.row].stringValue
                cell.descriptionLabel.text = settings[indexPath.row].description
                cell.backgroundColor = UIColor.MaverickProfilePowerBackgroundColor
                var isOn = true
                switch settings[indexPath.row] {
                case .push:
                    cell.backgroundColor = UIColor.white
                    isOn = loggedInUser.pushEnabled
                case .push_follower:
                    isOn = loggedInUser.pushFollowerEnabled
                case .push_posts:
                    isOn = loggedInUser.pushPostsEnabled
                case .push_general:
                    isOn = loggedInUser.pushGeneralEnabled
                    
                }
                
                cell.on(isOn: isOn)
                cell.delegate = self
                return cell
                
            }
        case .provisional:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.emptyTableViewCellId, for: indexPath) else {
                return UITableViewCell()
            }
            
            cell.emptyView.configure(title: R.string.maverickStrings.notificationsSettingsDeniedTitle(), subtitle: R.string.maverickStrings.notificationsSettingsDeniedSubTitle(), dark: false, isLink: true)
            return cell
            
        case .denied:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.emptyTableViewCellId, for: indexPath) else {
                return UITableViewCell()
            }
            
            cell.emptyView.configure(title: R.string.maverickStrings.notificationsSettingsDeniedTitle(), subtitle: R.string.maverickStrings.notificationsSettingsDeniedSubTitle(), dark: false, isLink: true)
            return cell
            
        case .notDetermined:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.emptyTableViewCellId, for: indexPath) else {
                return UITableViewCell()
            }
            
            cell.emptyView.configure(title: R.string.maverickStrings.notificationsSettingsNotDeterminedTitle(), subtitle: R.string.maverickStrings.notificationsSettingsNotDeterminedSubTitle(), dark: false, isLink: true)
            return cell
            
            
        }
        
       
        
    
       
        return UITableViewCell()
        
    }
    
    
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

extension NotificationSettingsViewController : NotificationSettingsTableViewCellDelegate {
    
    /**
     Not yet implemented
    */
    func switchFlipped(selected : Bool, cell : UITableViewCell) {
        
        
        if let indexPath = tableView.indexPath(for: cell), let setting = settings[safe: indexPath.row] {
            
            services.globalModelsCoordinator.updateUserData(notificationSetting: setting, isEnabled: selected)
            
            if setting == .push {
                
                tableView.reloadData()
            
            }
        
        }
        
    }
    
}
