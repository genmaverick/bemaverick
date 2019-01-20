//
//  NotificationViewController.swift
//  Production
//
//  Created by Garrett Fritz on 1/22/18.
//  Copyright © 2018 BeMaverick. All rights reserved.
//

import Foundation

class NotificationViewController: ViewController {
    /// Main table view for this VC
    
    @IBOutlet weak var tableView: UITableView!
    
    private var allMessages: [LPInboxMessage] = []
    /// API + Model services
    var services : GlobalServicesContainer!
    var refreshControl : UIRefreshControl!
    // MARK: - Lifecycle
    /// Flag to show empty view
    private var isEmpty = false
    
    
    override func viewDidLoad() {
        hasNavBar =  true
        services = (UIApplication.shared.delegate as! AppDelegate).services
        
        super.viewDidLoad()
        
        configureView()
        showNavBar(withTitle: "Notifications")
    }
    
    
    func scrollToTop() {
        
        tableView?.scrollToTop(animated: true)
        
    }

    
    /**
     Configure the default layout
     */
    fileprivate func configureView() {
        
        // iOS 10 fix to not have white spacing on top
        automaticallyAdjustsScrollViewInsets = false
        
        tableView.backgroundColor = UIColor.white
        tableView.allowsSelection = true
        tableView.separatorColor = .clear
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refresh(_:)), for: .valueChanged)
        tableView.refreshControl = refreshControl
        view.backgroundColor = UIColor.MaverickBackgroundColor
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.register(R.nib.notificationTableViewCell)
        tableView.register(R.nib.emptyTableViewCell)
        allMessages  = Leanplum.inbox().allMessages() as! [LPInboxMessage]
        allMessages.reverse()
        
    }
    
    
    
    /**
     Swipe to refresh - tied to pull to refresh action
     */
    @objc func refresh(_ refreshControl: UIRefreshControl? = nil) {
        
        Leanplum.forceContentUpdate{
            self.allMessages  = Leanplum.inbox().allMessages() as! [LPInboxMessage]
            self.allMessages.reverse()
            self.refreshControl?.endRefreshing()
            self.tableView.reloadData()
        }
        
    }
    
}


extension NotificationViewController: UITableViewDelegate, UITableViewDataSource {
    
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        var items: [UITableViewRowAction] = []
        
        if let message = allMessages[safe: indexPath.row] {
            
            
            let delete = UITableViewRowAction(style: .normal, title: "Delete") { action, index in
                
                message.remove()
                self.allMessages.remove(at: indexPath.row)
                // when empty, we show the empty item, so we dont want to tell the table we are deleting, but rather updating
                if self.allMessages.count == 0 {
                    
                    self.tableView.reloadData()
                    
                } else {
                    
                    self.tableView.deleteRows(at: [indexPath], with: .automatic)
                    
                }
                
            }
            
            delete.backgroundColor = UIColor.red
            items.append(delete)
            
            
        }
        
        return items
        
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        if isEmpty {
            
            guard let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.emptyTableViewCellId, for: indexPath) else {
                return UITableViewCell()
            }
            
            cell.emptyView.configure(title: R.string.maverickStrings.notificationsEmptyTitle(), subtitle: R.string.maverickStrings.notificationsEmptySubTitle(), dark: false)
            return cell
            
        }
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.notificationTableViewCellId, for: indexPath) else { return UITableViewCell() }
        
        let message = allMessages[indexPath.row]
        
        cell.configure(with: message)
        
        if !message.isRead() {
            
            message.read()
            
        }
        cell.delegate = self
        return  cell
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let count = allMessages.count
        
        if count == 0  {
            isEmpty = true
            return 1
        } else {
            isEmpty = false
            return count
        }
        
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        return nil
        
    }
    
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return 0.0
        
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        
        return 0.0
        
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        return UIView(frame: CGRect.zero)
        
    }
    
}


extension NotificationViewController : NotificationTableViewCellDelegate {
    
    func targetAreaPressed(message : LPInboxMessage) {
        
        if let data = message.data() {
           
            if let cele = data["celebration"] as? [String:Any] {
                
                if let enabled = cele["enabled"] as? String, let boolEnabled = enabled.toBool(), boolEnabled {
                    
                    let copy1 = cele["copy1"] as? String
                    let copy2 = cele["copy2"] as? String
                    let ctaText = cele["ctaText"] as? String
                    let deepLinkUrl = data[Constants.DeepLink.KEY_DEEP_LINK_URL] as? String
                    var color : UIColor? = nil
                    if let colorString = cele["color_rrggbbaa"] as? String  {
                      
                        color = UIColor(rgba: colorString)
                  
                    }
                    let imageUrl = cele["image"] as? String
                    
                    if let vc = R.storyboard.celebrations.simpleCelebrationViewControllerId() {
                        vc.configure(imageUrl: imageUrl, copy1: copy1, copy2: copy2, backgroundColor:  color, ctaText: ctaText, deepLinkString : deepLinkUrl, services: services )
                        
                        present(vc, animated: true, completion: nil)
                        return
                  
                    }
              
                }
          
            }
      
        }
            
            
        if let  data = message.data(),  let deepLinkUrl = data[Constants.DeepLink.KEY_DEEP_LINK_URL] as? String, let url = URL(string: deepLinkUrl) {
            
            DeepLinkHelper.parseURIScheme(url: url, services: services.globalModelsCoordinator)
            
        }
        
    }
    
    func sourceAreaPressed(message : LPInboxMessage) {
        
        if let  data = message.data(),  let deepLinkUrl = data[Constants.DeepLink.KEY_SOURCE_DEEP_LINK_URL] as? String, let url = URL(string: deepLinkUrl) {
            
            DeepLinkHelper.parseURIScheme(url: url, services: services.globalModelsCoordinator)
            
        }
        
    }
    
}
