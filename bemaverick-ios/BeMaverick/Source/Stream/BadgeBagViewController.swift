//
//  BadgeBagViewController.swift
//  BeMaverick
//
//  Created by David McGraw on 11/28/17.
//  Copyright © 2017 BeMaverick. All rights reserved.
//

import UIKit

class BadgeBagViewController: ViewController {
    
    // MARK: - IBOutlets
    
    /// The main collection view displaying saved content
    @IBOutlet weak var tableView: UITableView!
    /// Segmented control
    @IBOutlet weak var segmentedControl: MaverickSegmentedControl!
    
    /// Segment item tapped
    @IBAction func segmentChanged(_ sender: Any) {
        
        filter = segmentedControl.selectedSegmentIndex - 1
        
        
    }
    
    /// The `GlobalServicesContainer` that maintains access to global services
    weak var services: GlobalServicesContainer?
    /// Response data
    fileprivate var response: Response?
    /// Original list of users
    fileprivate var unfilteredUsers: [User] = []
    /// Users to list
    fileprivate var users: [User] = []
    /// Flag to show empty view
    private var isEmpty = false
    /// islogged in user bool
    private var isLoggedInUser = false
    private var isDataLoaded = false
    /// The current filter
    fileprivate var filter: Int = -1 {
        
        didSet {
            
            if oldValue != filter {
                
                users = usersForSelectedFilterType()
                tableView.reloadData()
                
            }
            
        }
        
    }
    
    // MARK: - Lifecycle
  
    
    
    override func viewDidLoad() {
        
        hasNavBar = true
        super.viewDidLoad()
        configureView()
        
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        
    }
    
    /**
     Configure view with a response object
     */
    open func configure(withResponse response: Response) {
        
        self.response = response
        services?.globalModelsCoordinator.getResponseBadgeUsers(forResponseId: response.responseId, completionHandler: { users in
            
            self.isDataLoaded = true
            self.unfilteredUsers = users
            self.users = users
            
            self.tableView.reloadData()
            
        })
        
        if let creatorId = response.userId, let loggedInUserId = services?.globalModelsCoordinator.loggedInUser?.userId {
            isLoggedInUser = creatorId == loggedInUserId
        }
        
    }
    
    /**
     Configure the default layout
     */
    fileprivate func configureView() {
        
        // Configure Table View
        // iOS 10 fix to not have white spacing on top
        automaticallyAdjustsScrollViewInsets = false
        
        tableView.estimatedRowHeight = 34.0;
        tableView.rowHeight = UITableViewAutomaticDimension;
        
        view.backgroundColor = .white
        tableView.separatorColor = .clear
        tableView.backgroundColor = .white
        
        
        showNavBar(withTitle: "Badges")
        tableView.register(R.nib.userTableViewCell)
        tableView.register(R.nib.emptyTableViewCell)
        
        segmentedControl.setTitle("ALL", forSegmentAt: 0)
        
        segmentedControl.setTitle(MBadge.getFirstBadge().name, forSegmentAt: 1)
        segmentedControl.setTitle(MBadge.getSecondBadge().name, forSegmentAt: 2)
        segmentedControl.setTitle(MBadge.getThirdBadge().name, forSegmentAt: 3)
        segmentedControl.setTitle(MBadge.getFourthBadge().name, forSegmentAt: 4)
        
    }
    
    
    /**
     Filter `users` for the selected badge filter
     */
    fileprivate func usersForSelectedFilterType() -> [User] {
        
        guard filter >= 0 else {
            
            return unfilteredUsers
            
        }
        var items: [User] = []
        var badge = MBadge(badgeId: "-1")
        switch filter {
        case 0:
            badge = MBadge.getFirstBadge()
        case 1:
            badge = MBadge.getSecondBadge()
        case 2:
            badge = MBadge.getThirdBadge()
        case 3:
            badge = MBadge.getFourthBadge()
        default:
            break
        }
        
        
        let filterId = badge.badgeId
        
        items = unfilteredUsers.filter({ user -> Bool in
            
            if let responses = user.responses  {
                
                for (key, value) in responses {
                    
                    if self.response?.responseId == key {
                        
                        if let ids = value.badgeIds {
                            
                            if ids.contains(filterId) {
                                return true
                            }
                            
                        }
                        
                    }
                    
                }
                
            }
            return false
            
        })
        
        return items
        
    }
    
}

extension BadgeBagViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let user = users[safe: indexPath.row] {
            
            guard let vc = R.storyboard.profile.profileViewControllerId() else { return }
            vc.services = services
            vc.userId = user.userId
            navigationController?.pushViewController(vc, animated: true)
            
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
      
        if isEmpty {
        
            return tableView.frame.height - 20
       
        }
        
        return UITableViewAutomaticDimension;
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        guard isDataLoaded else { return 0 }
        let count = users.count
        if count == 0  {
            isEmpty = true
            return 1
        } else {
            isEmpty = false
            return count
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if isEmpty {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.emptyTableViewCellId, for: indexPath) else {
                return UITableViewCell()
            }
            
            var badge = MBadge(badgeId: "-1")
            switch filter {
            case 0:
                badge = MBadge.getFirstBadge()
            case 1:
                badge = MBadge.getSecondBadge()
            case 2:
                badge = MBadge.getThirdBadge()
            case 3:
                badge = MBadge.getFourthBadge()
            default:
                break
            }
            
            cell.emptyView.configure( dark: false, withBadge : badge, isLoggedInUser : isLoggedInUser )
            
            return cell
            
        }
        
        return cellForUserBadgeItem(atIndex: indexPath)
        
    }
    
    fileprivate func cellForUserBadgeItem(atIndex indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.userTableViewCellId, for: indexPath) else {
            return UITableViewCell()
        }

        if let user = users[safe: indexPath.row], let responses = user.responses, let responseId = responses[(response?.responseId)!], let badgeIds = responseId["badgeIds"] as? [String], let badgeId = badgeIds.first {
            
            let badgeGiven = MBadge.getOrderedBadges().filter { $0.badgeId == badgeId }.first
            
            let isFollowed = services?.globalModelsCoordinator.isFollowingUser(userId: user.userId)
            cell.configure(withUsername: user.username, userId: user.userId, content: nil, sublabel: user.firstName, date: nil, avatar: user.profileImage, avatarURL: nil, isFollowing: isFollowed, showVerifiedBadge: user.isVerified)
            
            if let badgeGiven = badgeGiven {
                cell.addAuxiliaryImage(auxImage: badgeGiven)
            }
            
        }
        
        cell.delegate = self
        
        return cell
        
    }
    
}


extension BadgeBagViewController: UserTableViewCellDelegate {
    
    func didSelectFollowToggleButton(forUserId id: String, follow : Bool) {
        
        AnalyticsManager.Profile.trackFollowTapped(userId: id, isFollowing: follow, location: self)
        
        services?.globalModelsCoordinator.toggleUserFollow(follow :follow, withId: id) {
            
        }
        
    }
    
    func didSelectProfileButton(forUserId id: String) {
        
        guard let vc = R.storyboard.profile.profileViewControllerId() else { return }
        
        vc.services = services
        vc.userId =  id
        navigationController?.pushViewController(vc, animated: true)
        
    }
    
}

