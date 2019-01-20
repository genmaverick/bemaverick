//
//  MyStreamViewController.swift
//  BeMaverick
//
//  Created by David McGraw on 1/11/18.
//  Copyright © 2018 BeMaverick. All rights reserved.
//

import UIKit
import RealmSwift
import AVKit
/**
 `MyStream` displays a feed of responses from followers/following
 */
class MyStreamViewController: MultiStreamTableViewController {
    
    /// Array for horizontally scrollable users at top of table
    private var suggestedUsers = List<User>()
    /// Array for horizontally scrollable searched users at top of table
    private var searchedUsers : List<User>?
    private weak var userCell : HorizontalUserListTableViewCell?
    private var isEmpty = false
    
    private var suggestedUserNotifyToken : NotificationToken?
    private var challengesNotifyToken : NotificationToken?
    private var responsesNotifyToken : NotificationToken?
    
    deinit {
        
        suggestedUserNotifyToken?.invalidate()
        challengesNotifyToken?.invalidate()
        responsesNotifyToken?.invalidate()
        
    }
    
    override func viewDidLoad() {
        
        services = (UIApplication.shared.delegate as! AppDelegate).services
        hasNavBar = true
        streamDelegate = self
        super.viewDidLoad()
        tableView?.register(R.nib.userTableViewCell)
        tableView?.register(R.nib.mySreamEmptyHeaderCell)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        if DBManager.sharedInstance.shouldSeeTutorial(tutorialVersion : .myFeed) {
            
            if let vc = R.storyboard.main.tutorialViewControllerId() {
                
                vc.configureFor(tutorialVersion: .myFeed)
                vc.modalPresentationStyle = .overFullScreen
                present(vc, animated: false, completion: nil)
                
            }
            
        }
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        _ = super.tableView(tableView, cellForRowAt: indexPath)
        
        if indexPath.section == 0 {
            
             if isEmpty {
                
                if let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.mySreamEmptyHeaderCellId, for: indexPath) {
                    
                    cell.delegate = self
                    return cell
                    
                }
                
            }
            if let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.horizontalUserListTableViewCellID, for: indexPath) {
                
                userCell = cell
                if let searchedUsers = searchedUsers {
               
                    cell.configureView(with: Array(searchedUsers))
                
                } else {
                
                        cell.configureView(with: Array(suggestedUsers))
                    
                }
                
                cell.delegate = self
                return cell
                
            }
            
        }
        if isEmpty {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.userTableViewCellId, for: indexPath) else {
                return UITableViewCell()
            }
            
            if let cellUser = services.globalModelsCoordinator.loggedInUser?.suggestedUsers[safe: indexPath.row] {
                
                cell.configure(withUsername: cellUser.username, userId: cellUser.userId, content: nil, sublabel: cellUser.firstName, date: nil, avatar: cellUser.profileImage, isFollowing: services.globalModelsCoordinator.isFollowingUser(userId: cellUser.userId), showVerifiedBadge: cellUser.isVerified)
                 cell.delegate = self
                return cell
            }
            
        }
        return getCell(cellForRowAt: indexPath)
        
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return 2
        
    }
    
    override  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 0 {
            
            return 1
            
        } else {
            
            isEmpty = responseData.count == 0
            
            if isEmpty {
                
               return suggestedUsers.count
                
            } else {
                
                return responseData.count
           
            }
        
        }
        
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.section == 1 {
            
            return UITableViewAutomaticDimension
        
        } else {
        
            if suggestedUsers.count > 0 {
            
            
                return isEmpty ? UITableViewAutomaticDimension : 200
            
            }
            
            return 60
        
        }
        
    }
    
    override func attachDataObserver() {
       
        super.attachDataObserver()
        
        challengesNotifyToken = services.globalModelsCoordinator.loggedInUser?.myFeed?.challenges.observe({  [weak self] changes in
            
            switch changes {
            case .update(_, let deletions, let insertions, let modifications):
                
                if deletions.count == 0 && insertions.count == 0 && modifications.count > 0 {
                    
                    self?.tableView?.reloadData()
                
                }
            
            default :
                break
            }
            
        })
        
        responsesNotifyToken = services.globalModelsCoordinator.loggedInUser?.myFeed?.responses.observe({  [weak self] changes in
            
            switch changes {
            case .update(_, let deletions, let insertions, let modifications):
                
                if deletions.count == 0 && insertions.count == 0 && modifications.count > 0 {
                    
                    self?.tableView?.reloadData()
                    
                }
                
            default :
                break
            }
            
        })
        
        suggestedUserNotifyToken = services.globalModelsCoordinator.loggedInUser?.followingUserIds.observe() { [weak self] changes in
            
            if self?.isEmpty ?? false {
                
                self?.tableView?.reloadData()
            
            }
        
        }
    
    }
    override func notifyScroll() {
        
        super.notifyScroll()
        
        userCell?.dismissKeyboard()
    
    }
    
    override func addBadge(responseId id: String, badgeId: String, remove: Bool, cell : Any?) {
        
        var notificationTokens : [NotificationToken] = []
        if let responsesUpdatedToken = responsesUpdatedToken {
            notificationTokens.append(responsesUpdatedToken)
        }
        
        if let responsesNotifyToken = responsesNotifyToken {
           
            notificationTokens.append(responsesNotifyToken)
       
        }
        
        if let challengesNotifyToken = challengesNotifyToken {
            
            notificationTokens.append(challengesNotifyToken)
            
        }
        
        if remove {
             services.globalModelsCoordinator.deleteBadgeFromResponse(withResponseId: id, badgeId: badgeId, realmNotificationToken: notificationTokens) { success in
                
            }
        } else {
            
            services.globalModelsCoordinator.addBadgeToResponse(withResponseId: id, badgeId: badgeId, realmNotificationToken: notificationTokens) { success in
                
            }
            
        }
        
    }
    
}

extension MyStreamViewController : HorizontalUserListTableViewCellDelegate {
    
    func launchSearchMode() {
        
        if let vc = R.storyboard.inviteFriends.searchMaverickViewControllerId() {
            
            vc.showInviteButton = true
            vc.services = services
            self.navigationController?.pushViewController(vc, animated: true)
            return
        }
        
    }
    func searchEntryStarted() {
        
        tableView?.scrollToTop(animated: true)
        launchSearchMode()
        
    }
    
    
    func searchString(cell: HorizontalUserListTableViewCell, search: String?) {
    
        if let search = search {
            
            services.globalModelsCoordinator.getUsers(byUsername: search, contentType: nil, contentId: nil) {[weak self] (foundUsers) in
                
                self?.searchedUsers = foundUsers
               
                if let foundUsers = foundUsers {
                
                    cell.configureView(with: Array(foundUsers))
                
                }
        
            }
        
        } else {
            
            cell.configureView(with: Array(suggestedUsers))
            searchedUsers = nil
        
        }
        
    }
    
    
    func itemTapped(userId: String?) {
        
        if let userId = userId {
        guard let vc = R.storyboard.profile.profileViewControllerId() else { return }
        
        vc.userId = userId
        vc.services = services
        navigationController?.pushViewController(vc, animated: true)
        
        } else {
            
            if let vc = R.storyboard.inviteFriends().instantiateInitialViewController() {
                
                vc.modalPresentationStyle = .fullScreen
                present(vc, animated: true, completion: nil)
          
            }
            
        }
        
    }

}


extension MyStreamViewController : StreamRefreshControllerDelegate {
    
    func getMainSectionItemCount() -> Int {
        
        return responseData.count
    
    }
    
    func refreshDataRequest() {
        
        
        services.globalModelsCoordinator.getSuggestedUsers()
        
        services.globalModelsCoordinator.getMyFeed(forceRefresh: true, downloadAssets: false) { [weak self] in
            
            self?.refreshCompleted()
            
            if self?.responsesNotifyToken == nil {
                
                self?.attachDataObserver()
            
            }
        
        }
        
    }
    
    func loadNextPageRequest() {
        
        services.globalModelsCoordinator.getMyFeed(offset: responseData.count, forceRefresh: true, downloadAssets: false) { [weak self] in
            
            self?.nextPageLoadCompleted()
            
        }
        
    }
    
    /**
     Called on view did load, meant to be overriden to load in data and set the
     data update observer
     */
    func configureData() {
        
        
        responseTableViewSection = 1
        guard let loggedInUser = services.globalModelsCoordinator.loggedInUser else { return }
        
       
        if loggedInUser.suggestedUsers.count > 0 {
            
            suggestedUsers = loggedInUser.suggestedUsers
            
        } else  {
            
            suggestedUsers = loggedInUser.loggedInUserFollowing
            
        }
        
        
        
        if let feed = loggedInUser.myFeed?.feed {
            
            responseData = feed
            attachDataObserver()
            
        }
       
        refreshCompleted()
        
    }
    
}

extension MyStreamViewController : UserTableViewCellDelegate {
    
    func didSelectFollowToggleButton(forUserId id: String, follow : Bool) {
        
        AnalyticsManager.Profile.trackFollowTapped(userId: id, isFollowing: follow, location: self)
        
        services.globalModelsCoordinator.toggleUserFollow(follow: follow, withId: id) {
            
        }
        
    }
    
    func didSelectProfileButton(forUserId id: String) {
        
        showProfile(forUserId: id)
        
    }
    
    
}

extension MyStreamViewController :  MySreamEmptyHeaderCellDelegate {
    
    func searchTapped() {
        
         launchSearchMode()
        
    }
    
    func inviteTapped() {
        
        if let vc = R.storyboard.inviteFriends().instantiateInitialViewController() {
            
            vc.modalPresentationStyle = .fullScreen
            present(vc, animated: true, completion: nil)
        }
        
        
    }
    
}
