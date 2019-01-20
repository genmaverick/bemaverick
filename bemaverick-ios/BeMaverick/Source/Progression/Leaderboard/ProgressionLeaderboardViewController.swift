//
//  ProgressionLeaderboardViewController.swift
//  Maverick
//
//  Created by Garrett Fritz on 9/13/18.
//  Copyright © 2018 BeMaverick. All rights reserved.
//

import Foundation
import RealmSwift

class ProgressionLeaderboardViewController : ContentViewController {
    
    enum LeaderboardType : String {
        
        case following = "Following"
        case global = "Global"
       
    }
    
    enum LeaderboardTime : String {
        
        case monthly = "Monthly"
        case all = "All"
        
    }
    
    @IBOutlet weak var loggedInPointsLabel: UILabel!
    @IBOutlet weak var loggedInUsernameLabel: BadgeLabel!
    @IBOutlet weak var loggedInAvatarImageView: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    
    private var globalAll : List<User>? = List<User>()
    private var globalMonthly  : List<User>? = List<User>()
    private var followingAll  : List<User>? = List<User>()
    private var followingMonthly   : List<User>? = List<User>()
    private var monthlyType = LeaderboardType.global
    private var allType = LeaderboardType.global
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        ignoreNavControl = true
        configureData()
        configureView()
        
    }
    
    func configureData() {
        
        services?.globalModelsCoordinator.getProjects {
            
        }
        
        services?.globalModelsCoordinator.getProgressionLeaderboard(byType: .following, time: .all, completionHandler: { (users) in
           
            self.followingAll = users
        
        })
        
        services?.globalModelsCoordinator.getProgressionLeaderboard(byType: .following, time: .monthly, completionHandler: { (users) in
          
            self.followingMonthly = users
       
        })
        
       services?.globalModelsCoordinator.getProgressionLeaderboard(byType: .global, time: .all, completionHandler: { (users) in
               self.globalAll = users
        })
        
        
        services?.globalModelsCoordinator.getProgressionLeaderboard(byType: .global, time: .monthly, completionHandler: { (users) in
               self.globalMonthly = users
        })
        
        configureHeader()
        
    }
    
    func configureHeader() {
        
        guard let user = services?.globalModelsCoordinator.loggedInUser else { return }
        
        if let imagePath = user.profileImage?.getUrlForSize(size: loggedInAvatarImageView.frame), let url = URL(string: imagePath) {
            
            loggedInAvatarImageView.kf.setImage(with: url, placeholder: R.image.defaultMaverickAvatar(), options: [.transition(.fade(UIImage.fadeInTime))])
            
        } else {
            
            loggedInAvatarImageView.image = R.image.defaultMaverickAvatar()
            
        }
        
        loggedInUsernameLabel.text = user.username
        
        let points = user.progression?.totalPoints ?? 12.0
        
        loggedInPointsLabel.text = "\(Int(points)) PTS"
        
    }
    
    
    func configureView() {
        
        loggedInUsernameLabel.imageOffset = CGPoint(x: 0.0, y: -2.0)
        
        loggedInAvatarImageView.layer.cornerRadius = loggedInAvatarImageView.frame.height / 2
        loggedInAvatarImageView.clipsToBounds = true
        loggedInAvatarImageView.layer.borderWidth = 0.5
        loggedInAvatarImageView.layer.borderColor = UIColor(rgba: "D3D3D3ff")?.cgColor
        view.backgroundColor = UIColor(rgba: "F8F7F6")
        
        tableView.backgroundColor = UIColor(rgba: "F8F7F6")
        tableView.showsVerticalScrollIndicator = false
        tableView.showsHorizontalScrollIndicator = false
        tableView.allowsSelection = false
        tableView.register(R.nib.leaderboardTableViewCell)
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorColor = .clear
        
        tableView.estimatedRowHeight = 200
        tableView.rowHeight = UITableViewAutomaticDimension
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refresh(_:)), for: .valueChanged)
        tableView.refreshControl = refreshControl
        tableView.contentInset = UIEdgeInsetsMake(28.0, 0.0, 0.0, 0.0)
        
    }
    
    /**
     Swipe to refresh - tied to pull to refresh action
     */
    @objc func refresh(_ refreshControl: UIRefreshControl? = nil) {
        
        services?.globalModelsCoordinator.getProjects {
            
            self.tableView.reloadData()
            refreshControl?.endRefreshing()
            self.configureHeader()
        }
        configureData()
    }
    
    
}




extension ProgressionLeaderboardViewController : UITableViewDelegate, UITableViewDataSource {
   
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.leaderboardTableViewCellId, for: indexPath) else { return UITableViewCell() }
        UIView.setAnimationsEnabled(false)
        var users : List<User>? = List<User>()
        
        var type = monthlyType
        
        if indexPath.section == 0 {
            
            type = monthlyType
            if monthlyType == .global {
                
                users = globalMonthly
                
            } else {
                
                users = followingMonthly
                
            }
            
        } else {
            
            type = allType
            if allType == .global {
                
                users = globalAll
                
            } else {
                
                users = globalMonthly
                
            }
            
        }
        
       
       
        
        if let foundUsers = users {
        
            cell.delegate = self
            cell.configure(with: Array(foundUsers), type: type, time: indexPath.section == 0 ? .monthly : .all, delegate: self)
        
        }
        return cell
        
        
        
        
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        UIView.setAnimationsEnabled(true)
        
        
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
      
        return 2
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return UITableViewAutomaticDimension
        
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        
        return 0.0
        
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        return UIView(frame: CGRect.zero)
        
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        
        if let view =  R.nib.contactsHeaderView.firstView(owner: nil) {
            
            view.backgroundColor = .clear
            
            view.label.font = R.font.openSansBold(size: 12.0)
            view.leadingSpaceConstraint.constant = 36.0
            view.bottomSpaceConstraint.isActive = false
            
            switch section {
                
            case 0:
                view.label.text = "Monthly Leaderboard"
                
            case 1:
                view.label.text = "All Time Leaderboard"
         
            default:
                view.label.text = "Leaderboard"
                
            }
            return view
            
        }
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return 32.0
        
    }
    
}

extension ProgressionLeaderboardViewController : LeaderboardTableViewCellDelegate {
    
    
    func userTapped(user: User) {
        
        showProfile(forUserId: user.userId)
        
    }
    
   
    func tabChanged(type: ProgressionLeaderboardViewController.LeaderboardType, time: ProgressionLeaderboardViewController.LeaderboardTime) {
        UIView.setAnimationsEnabled(false)
        
        if time == .all {
            
            allType = type
            tableView.reloadRows(at: [IndexPath(row: 0, section: 1)], with: .automatic)
        }
        
        if time == .monthly {
            
            monthlyType = type
             tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
            
        }
        
    }
    
}
