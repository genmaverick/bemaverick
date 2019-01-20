//
//  SearchMaverickViewController.swift
//  Maverick
//
//  Created by Garrett Fritz on 6/12/18.
//  Copyright © 2018 BeMaverick. All rights reserved.
//

import Foundation
import RealmSwift

protocol SearchMaverickViewControllerDelegate : UserTableViewCellDelegate {
    
    func isUserSelected(users : User) -> Bool
    
}
class SearchMaverickViewController : ViewController {
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var scrollViewBottomConstraint: NSLayoutConstraint!
    
    /// A reference to the `UIKeyboardWillShow` notification
    private var keyboardWillShowId: NSObjectProtocol?
    /// A reference to the `UIKeyboardWillHide` notification
    private var keyboardWillHideId: NSObjectProtocol?
    
    private var suggestedUsers = List<User>()
    private var users : List<User>? {
        
        didSet {
            
            tableView.reloadData()
            
        }
        
    }
    
    private var isEmpty = false
    weak var delegate : SearchMaverickViewControllerDelegate?
    var services : GlobalServicesContainer!
    var showInviteButton = false
    
    override func viewDidLoad() {
        
        hasNavBar = true
        super.viewDidLoad()
        configureView()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(keyboardWillShowId as Any)
        NotificationCenter.default.removeObserver(keyboardWillHideId as Any)
        
    }
    
    
    
    
    private func configureView() {
        
        observeKeyboardWillShow()
        observeKeyboardWillHide()
        
        tableView.register(R.nib.userTableViewCell)
        tableView.register(R.nib.emptyTableViewCell)
        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self
        tableView.tableFooterView = UIView()
        tableView.separatorColor = .clear
        showNavBar(withTitle: "Find Mavericks")
        searchBar.setImage(R.image.search(), for: .search, state: .normal)
        searchBar.setImage(R.image.close_purple(), for: .clear, state: .normal)
       
        let adjustForTabbarInsets: UIEdgeInsets = UIEdgeInsetsMake(0, 0, self.tabBarController?.tabBar.frame.height ?? 0.0, 0)
        tableView.contentInset = adjustForTabbarInsets
        tableView.scrollIndicatorInsets = adjustForTabbarInsets
        
        if let suggested = services.globalModelsCoordinator.loggedInUser?.suggestedUsers, suggested.count > 0 {
            
            suggestedUsers = suggested
            
        } else if let suggested = services.globalModelsCoordinator.loggedInUser?.loggedInUserFollowing {
            
            suggestedUsers = suggested
            
        }
        
        users = suggestedUsers
        searchBar.tintColor = UIColor.lightGray
        if showInviteButton {
            
            showFindFriendsButton()
            
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        searchBar.becomeFirstResponder()
    
    }

}

extension SearchMaverickViewController : UITableViewDelegate, UITableViewDataSource {
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if isEmpty {
            
            return 1
        
        }
        
        return users?.count ?? 0
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if users?.count == 0 {
            
            if let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.emptyTableViewCellId, for: indexPath) {
                
                cell.emptyView.configure(title: "No One Yet", subtitle: "We can't find any matches, invite your friends to sign up.", dark: false)
                
                return cell
                
            }
            
        }
        guard let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.userTableViewCellId, for: indexPath) else {
            
            return UITableViewCell()
            
        }
        
        
        if let user = users?[safe: indexPath.row] {
            
            var isFollowing = services.globalModelsCoordinator.isFollowingUser(userId: user.userId)
            if let delegate = delegate {
                
                cell.delegate = delegate
                cell.overrideButtonTitles(selected: "Added!", unselected: "+ADD")
                isFollowing = delegate.isUserSelected(users: user)
                
            } else {
                
                cell.delegate = self
           
            }
            
            cell.configure(withUsername: user.username, userId: user.userId, content: nil, sublabel: nil, date: nil, avatar: user.profileImage, avatarURL: nil, avatarImage: nil, isFollowing: isFollowing, showVerifiedBadge: user.isVerified)
            
        }
        
        return cell
        
    }
    
}

extension SearchMaverickViewController : UISearchBarDelegate {
    
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if searchText.isEmpty || searchText.count < 2 {
            
            isEmpty = false
            users = suggestedUsers
            
        } else {
            services.globalModelsCoordinator.getUsers(byUsername: searchText, contentType: nil, contentId: nil) { [weak self] (results) in
                
                if results?.count == 0 {
                    
                    self?.isEmpty = true
                    
                } else {
                    
                    self?.isEmpty = false
                    
                }
                self?.users = results
                
                
            }
            
        }
    }
    
}

extension SearchMaverickViewController : UserTableViewCellDelegate {
    
    func didSelectFollowToggleButton(forUserId id: String, follow: Bool) {
        
        AnalyticsManager.Profile.trackFollowTapped(userId: id, isFollowing: follow, location: self)
        
        services.globalModelsCoordinator.toggleUserFollow(follow: follow, withId: id) {
            
        }
        
    }
    
    func didSelectProfileButton(forUserId id: String) {
        guard let vc = R.storyboard.profile.profileViewControllerId() else { return }
        
        vc.services = services
        vc.userId =  id
        
        
        navigationController?.pushViewController(vc, animated: true)
        
    }
    
}



extension SearchMaverickViewController : UIScrollViewDelegate  {
    
    /**
     Observe when the keyboard becomes visible and adjusts the scroll view inset. This
     method will only monitor the notification once.
     */
    fileprivate func observeKeyboardWillShow() {
        
        keyboardWillShowId = NotificationCenter.default.addObserver(forName: .UIKeyboardWillShow,
                                                                    object: nil,
                                                                    queue: nil)
        { [weak self] notification in
            
            if let userInfo = notification.userInfo {
                
                self?.adjustToKeyboard(userInfo: userInfo)
                
            }
            
        }
        
    }
    
    /**
     Observe when the keyboard hides and adjusts the scroll view inset. This
     method will only monitor the notification once.
     */
    fileprivate func observeKeyboardWillHide() {
        
        keyboardWillHideId = NotificationCenter.default.addObserver(forName: .UIKeyboardWillHide,
                                                                    object: nil,
                                                                    queue: nil)
        { [weak self] notification in
            
            
            if let userInfo = notification.userInfo {
                
                self?.adjustToKeyboard(userInfo: userInfo)
                
            }
            
        }
        
    }
    
    /**
     Move on Keyboard
     */
    fileprivate func adjustToKeyboard(userInfo: [AnyHashable : Any]) {
        
        if let animationDuration = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue,
            let keyboardEndFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue,
            let animCurve = userInfo[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber
        {
            let convertedKeyboardEndFrame = self.view.convert(keyboardEndFrame, from: self.view.window)
            
            let rawAnimationCurve = animCurve.uint32Value << 16
            let animationCurve = UIViewAnimationOptions(rawValue: UInt(rawAnimationCurve))
            
            self.scrollViewBottomConstraint?.constant = self.view.bounds.maxY - convertedKeyboardEndFrame.minY
            
            UIView.animate(withDuration: animationDuration, delay: 0.0, options: [.beginFromCurrentState , animationCurve], animations: {
                self.view.layoutIfNeeded()
            }, completion: nil)
            
        }
        
    }
    
}
