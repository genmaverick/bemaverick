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

class FollowersViewController: ViewController {
    
    /// The main collection view displaying saved content
    @IBOutlet weak var tableView: UITableView!
    
    /// The `GlobalServicesContainer` that maintains access to global services
    var services: GlobalServicesContainer! = (UIApplication.shared.delegate as! AppDelegate).services
    /// Flag to show empty view
    private var isEmpty = false
    /// The loaded user being interacted with
    fileprivate var user = User()
    /// A list of suggested users to follow
    fileprivate var suggestedUsers : [User]?
    private var initialLoadComplete = false
    fileprivate var following = List<User>()
    fileprivate var followers = List<User>()
    /// The follow type used to layout the view
    fileprivate var followType: Constants.FollowerType = .followers
    
    
   
  
    override func viewDidLoad() {
        
        hasNavBar = true
        super.viewDidLoad()
        configureView()
        configureData()
        
    }
    
    // MARK: - Public Methods
    
    func configure(withUser user: User, followType: Constants.FollowerType) {
        
        self.followType = followType
        self.user = user
        
    }

    
    /**
     Default layout configuration
     */
     func configureView() {
        
        // iOS 10 fix to not have white spacing on top
        automaticallyAdjustsScrollViewInsets = false
        view.backgroundColor = UIColor.white
        tableView.separatorColor = .clear
        tableView.backgroundColor = .white
        
        tableView.register(R.nib.userTableViewCell)
        tableView.register(R.nib.emptyTableViewCell)
        tableView.register(R.nib.loadingTableViewCell)
        tableView.rowHeight = UITableViewAutomaticDimension
        
        showNavBar(withTitle: followType == .following ? "Following" : "Followers")
   
    }
    
    
    fileprivate func configureData() {
        
        if let suggested = services.globalModelsCoordinator.loggedInUser?.suggestedUsers {
            let fullList = Array(suggested)
            suggestedUsers = fullList.filter( {
                (self.services.globalModelsCoordinator.isFollowingUser(userId: $0.userId) == false
                    && self.services.globalModelsCoordinator.loggedInUser?.userId != $0.userId)
            })
        }
        
        self.services.globalModelsCoordinator.getUserFollowingData(forUserId: user.userId) {[weak self] (followers, following) in
            
            self?.initialLoadComplete = true
            self?.following = following
            self?.followers = followers
            self?.tableView.reloadData()
     
        }
        
    }
    
    /**
     Navigates the user to the selected user profile
     */
    fileprivate func loadProfile(forUserId id: String) {
        
        guard let vc = R.storyboard.profile.profileViewControllerId() else { return }
        
        vc.services = services
        vc.userId =  id
        navigationController?.pushViewController(vc, animated: true)
        
    }
    
    /**
     Fetches the follower data for the loaded user
     */
    fileprivate func reloadFollowerData() {
        
        services.globalModelsCoordinator.getUserFollowingData(forUserId: user.userId)
        
    }
    
    func buttonPressedAction(forUserId id: String, isSelected : Bool) {
        
        AnalyticsManager.Profile.trackFollowTapped(userId: id, isFollowing: isSelected, location: self)
        
        services.globalModelsCoordinator.toggleUserFollow(follow: isSelected, withId: id) {
            
        }
        
    }
    
}

extension FollowersViewController: UITableViewDataSource {
    
    /**
     List of users and suggested users
     */
    func numberOfSections(in tableView: UITableView) -> Int {
     
        if suggestedUsers?.count ?? 0 > 0 {
        
            return 2
        
        }
       
        return 1
    
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 1 {
            
            return suggestedUsers?.count ?? 0
        
        }
        
        
        guard initialLoadComplete else { return 1 }
        var count = 0
        if followType == .followers {
            count = followers.count
        } else {
            count = following.count
        }
        
        if count == 0  {
            isEmpty = true
            return 1
        } else {
            isEmpty = false
            return count
        }
        
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        
        view.tintColor = UIColor.white
        
        let header : UITableViewHeaderFooterView = view as! UITableViewHeaderFooterView
        if let label = header.textLabel {
            label.font = R.font.openSansRegular(size: 14.0)
            label.textColor = .black
        }
        
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        if section == 1 {
            
            return R.string.maverickStrings.suggestedHeader()
            
        }
        
        return nil
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard initialLoadComplete else {
            if let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.loadingTableViewCellId, for: indexPath)  {
                return cell
            }
            return UITableViewCell()
        }
        if isEmpty {
            
            if indexPath.section == 0 {
                guard let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.emptyTableViewCellId, for: indexPath) else {
                    return UITableViewCell()
                }
                
                if followType == .followers {
                    
                    cell.emptyView.configure(title: R.string.maverickStrings.followersEmptyTitle(), subtitle: R.string.maverickStrings.followersEmptySubTitle(user.username ?? ""), dark: false)
                } else {
                    
                    cell.emptyView.configure(title: R.string.maverickStrings.followingEmptyTitle(), subtitle: R.string.maverickStrings.followingEmptySubTitle(user.username ?? ""), dark: false)
                }
                return cell
            }
            
        }
        
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.userTableViewCellId, for: indexPath) else {
            return UITableViewCell()
        }
        
        // Suggested Users
        if indexPath.section == 1 {
            
            if let cellUser = suggestedUsers?[safe: indexPath.row] {
                
                cell.configure(withUsername: cellUser.username, userId: cellUser.userId, content: nil, sublabel: cellUser.firstName, date: nil, avatar: cellUser.profileImage, isFollowing: services.globalModelsCoordinator.isFollowingUser(userId: cellUser.userId), showVerifiedBadge: cellUser.isVerified)
                
            }
            
        }
        
        if followType == .followers {
            
            if indexPath.section == 0 {
                if let cellUser = followers[safe: indexPath.row] {
                    cell.configure(withUsername: cellUser.username, userId: cellUser.userId, content: nil, sublabel: cellUser.firstName, date: nil, avatar: cellUser.profileImage, isFollowing: services.globalModelsCoordinator.isFollowingUser(userId: cellUser.userId), showVerifiedBadge: cellUser.isVerified)
                }
                
            }
            
        } else {
            
            if indexPath.section == 0 {
                
                if let cellUser = following[safe: indexPath.row] {
                    
                    cell.configure(withUsername: cellUser.username, userId: cellUser.userId,content: nil, sublabel: cellUser.firstName, date: nil, avatar: cellUser.profileImage, isFollowing: services.globalModelsCoordinator.isFollowingUser(userId: cellUser.userId), showVerifiedBadge: cellUser.isVerified)
                    
                }
            }
            
        }
        
        cell.delegate = self
        return cell
        
    }
    
}

extension FollowersViewController: UserTableViewCellDelegate {
    
    func didSelectFollowToggleButton(forUserId id: String, follow : Bool) {
        
        buttonPressedAction(forUserId: id, isSelected: follow)
     
        
    }
    
    func didSelectProfileButton(forUserId id: String) {
        
        loadProfile(forUserId: id)
        
    }
    
}

