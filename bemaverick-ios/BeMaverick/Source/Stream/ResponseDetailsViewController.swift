//
//  ResponseDetailsViewController.swift
//  BeMaverick
//
//  Created by David McGraw on 11/28/17.
//  Copyright © 2017 BeMaverick. All rights reserved.
//

import UIKit

enum ResponseDetailMode {
    case comments, badges
}

class ResponseDetailsViewController: UIViewController {
    
    // MARK: - IBOutlets
    
    /// The main collection view displaying saved content
    @IBOutlet weak var tableView: UITableView!
    
    /// The spacing of the top of the table view to the super view
    @IBOutlet weak var tableViewTopConstraint: NSLayoutConstraint!
    
    /// Center position of the badge filter indicator
    @IBOutlet weak var navigationIndicatorCenterConstraint: NSLayoutConstraint!
    
    /// Center position of the badge filter indicator
    @IBOutlet weak var indicatorSelectorCenterConstraint: NSLayoutConstraint!
    
    /// The height of the badge filter view. Default 80
    @IBOutlet weak var badgeFilterBarHeightConstraint: NSLayoutConstraint!
    
    /// Contains filtering options for badges
    @IBOutlet weak var badgeFilterView: UIView!
    
    /// Badge Filter Actions
    @IBOutlet weak var badgeAllButton: UIButton!
    @IBOutlet weak var badgeDaringButton: UIButton!
    @IBOutlet weak var badgeCreativeButton: UIButton!
    @IBOutlet weak var badgeUniqueButton: UIButton!
    @IBOutlet weak var badgeUnstoppableButton: UIButton!
    
    /// Navigation Actions
    @IBOutlet weak var commentsButton: UIButton!
    @IBOutlet weak var badgesButton: UIButton!
    
    // MARK: - IBActions
    
    @IBAction func backButtonTapped(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func navigationFilterButtonTapped(_ sender: Any) {
        
        guard let button = sender as? UIButton else { return }
        
        if button == commentsButton {
            
            if mode == .comments { return }
            mode = .comments
            
        } else if button == badgesButton {
            
            if mode == .badges { return }
            mode = .badges
            
        }
        
        refreshModeLayout()
        
    }
    
    @IBAction func badgeFilterButtonTapped(_ sender: Any) {
        
        guard let button = sender as? UIButton else { return }
        filter = Constants.MaverickBadgeType(rawValue: button.tag) ?? filter
        
    }
    
    // MARK: - Public Properties
    
    /// The `GlobalServicesContainer` that maintains access to global services
    var services: GlobalServicesContainer?
    
    // MARK: - Private Properties
    
    /// Response data containing the saved challenges
    fileprivate var response: Response?
    
    /// Original list of users
    fileprivate var unfilteredUsers: [User] = []
    
    /// Users to list
    fileprivate var users: [User] = []
    
    /// TODO
    fileprivate var comments: [String] = []
    
    /// The current mode of the view
    fileprivate var mode: ResponseDetailMode = .badges
    
    /// The current filter
    fileprivate var filter: Constants.MaverickBadgeType = .all {
        
        didSet {
            if oldValue != filter {
                refreshFilterLayout()
            }
        }
        
    }
    
    // MARK: - Lifecycle
    
    deinit {
        log.verbose("💥")
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        configureView()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        refreshModeLayout()
        
    }
    
    // MARK: - Public Methods
    
    open func configure(withResponse response: Response, mode: ResponseDetailMode) {
        
        self.response = response
        self.mode = mode
        
        if mode == .badges {
            
            guard let responseId = response.responseId, let id = Int(responseId) else { return }

            services?.globalModelsCoordinator.getResponseBadgeUsers(forResponseId: id, completionHandler: { users in
                
                self.unfilteredUsers = users
                self.users = users
                
            })
            
        }
        
    }
    
    // MARK: - Private
    
    /**
     Configure the default layout
     */
    fileprivate func configureView() {
        
        // Setup navigation
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        badgeAllButton.tag = Constants.MaverickBadgeType.all.index
        badgeDaringButton.tag = Constants.MaverickBadgeType.daring.index
        badgeCreativeButton.tag = Constants.MaverickBadgeType.creative.index
        badgeUniqueButton.tag = Constants.MaverickBadgeType.unique.index
        badgeUnstoppableButton.tag = Constants.MaverickBadgeType.unstoppable.index
        
    }
    
    /**
     Configure the default signals to listen for
     */
    fileprivate func configureSignals() {
        
    }
    
    /**
 
    */
    fileprivate func refreshModeLayout() {
        
        commentsButton.isSelected = false
        badgesButton.isSelected = false
        
        view.setNeedsUpdateConstraints()
        if mode == .comments {
            
            commentsButton.isSelected = true
            navigationIndicatorCenterConstraint.constant = -(badgesButton.frame.size.width / 2)
            tableViewTopConstraint.constant = -80
            badgeFilterView.isHidden = true
            
        } else {
            
            badgesButton.isSelected = true
            navigationIndicatorCenterConstraint.constant = badgesButton.frame.size.width / 2
            tableViewTopConstraint.constant = 0
            badgeFilterView.isHidden = false
            
        }
        view.layoutIfNeeded()
        
        tableView.reloadData()
        
    }
    
    /**
    */
    fileprivate func refreshFilterLayout() {
    
        badgeAllButton.isSelected = false
        badgeDaringButton.isSelected = false
        badgeCreativeButton.isSelected = false
        badgeUniqueButton.isSelected = false
        badgeUnstoppableButton.isSelected = false
        
        let buttonWidth = badgeDaringButton.frame.size.width
        
        // Update Selected Button
        switch filter {
        case .all:
            
            users = unfilteredUsers
            badgeAllButton.isSelected = true
            indicatorSelectorCenterConstraint.constant = 0
            tableView.reloadData()
            return
            
        case .daring:
            
            badgeDaringButton.isSelected = true
            indicatorSelectorCenterConstraint.constant = buttonWidth
            
        case .creative:
            
            badgeCreativeButton.isSelected = true
            indicatorSelectorCenterConstraint.constant = buttonWidth * 2
            
        case .unique:
            
            badgeUniqueButton.isSelected = true
            indicatorSelectorCenterConstraint.constant = buttonWidth * 3
            
        case .unstoppable:
            
            badgeUnstoppableButton.isSelected = true
            indicatorSelectorCenterConstraint.constant = buttonWidth * 4
            
        }
        
        users = usersForSelectedFilterType()
        tableView.reloadData()
        
    }
    
    /**
     Filter `users` for the selected badge filter
    */
    fileprivate func usersForSelectedFilterType() -> [User] {
        
        var items: [User] = []
        let filterId = String(filter.rawIndex + 1)
        
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

extension ResponseDetailsViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if mode == .comments {
            return comments.count
        }
        return users.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if mode == .comments {
            return UITableViewCell()
        }

        return cellForUserBadgeItem(atIndex: indexPath)
        
    }
    
    fileprivate func cellForUserBadgeItem(atIndex indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.userItemId, for: indexPath) else {
            return UITableViewCell()
        }
        
        if let user = users[safe: indexPath.row],
            let responses = user.responses {
            
            cell.user = user
            
            // Find the loaded challenge and get the badges the user added to it
            for (key, value) in responses {
                
                if self.response?.responseId == key {
                    
                    var badges: [Constants.MaverickBadgeType] = []
                    
                    if let ids = value.badgeIds {
                        
                        for id in ids {
                            
                            let offset = Constants.MaverickBadgeType.all.index
                            if let intId = Int(id),
                                let badge = Constants.MaverickBadgeType(rawValue: offset + intId) {
                                badges.append(badge)
                            }
                            
                        }
                        
                    }
                    
                    cell.addBadges(withBadges: badges)
                    break
                    
                }
                
            }
            
        }
        
        return cell
        
    }
    
}

extension ResponseDetailsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 68
    }
    
}
