//
//  FollowersViewController.swift
//  BeMaverick
//
//  Created by David McGraw on 11/17/17.
//  Copyright © 2017 BeMaverick. All rights reserved.
//

import UIKit
import PureLayout
import RealmSwift

class BlockedUsersViewController: FollowersViewController {
    
    
    override func configureView() {
        super.configureView()
        title = "Blocked Users"
    }
    
    
    override  func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return services.globalModelsCoordinator.getBlockedUsers().count
        
    }
    
    override  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.userTableViewCellId, for: indexPath) else {
            return UITableViewCell()
        }
        
        if let cellUser = services.globalModelsCoordinator.getBlockedUsers()[safe: indexPath.row] {
            
            cell.configure(withUsername: cellUser.username, userId: cellUser.userId,content: nil, sublabel: cellUser.firstName, date: nil, avatar: cellUser.profileImage, isFollowing: cellUser.isBlocked, showVerifiedBadge: cellUser.isVerified )
            cell.delegate = self
            cell.overrideButtonTitles(selected: "UNBLOCK", unselected: "BLOCK")
            
        }
        return cell
    }
    
    override func buttonPressedAction(forUserId id: String, isSelected : Bool) {
      
       services.globalModelsCoordinator.blockUser(withId: id, isBlocked: isSelected)
        
    }
   
    
}
