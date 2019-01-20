//
//  MyProgressViewController.swift
//  Maverick
//
//  Created by Garrett Fritz on 9/13/18.
//  Copyright © 2018 BeMaverick. All rights reserved.
//

import Foundation
import RealmSwift



protocol MyProgressViewControllerDelegate : class {
    
    func projectTabChanged(filter : ProjectProgressTableViewCell.ProjectProgressViewFilter)
    
    func seeMoreProjectsTapped(filter : ProjectProgressTableViewCell.ProjectProgressViewFilter)
    
    func projectTapped(project : ProjectsProgress)
    
    func badgeTapped(badgeStats : BadgeStats)
    
    func levelDetailsTapped()
    
}

class MyProgressViewController : ViewController {
    
    @IBOutlet weak var containerView: UIView!
    var services : GlobalServicesContainer?
    var user : User?
    private var notificationToken : NotificationToken?
    private var embedded = false
    private var projectFilter = ProjectProgressTableViewCell.ProjectProgressViewFilter.inProgress
    @IBOutlet weak var tableView: UITableView!
    
    deinit {
        
        notificationToken?.invalidate()
        
    }
    
    func scrollToTop() {
        
        tableView.scrollToTop(animated: true)
        
    }
    
    override func viewDidLoad() {
        
        if !embedded {
        
            ignoreNavControl = false
            hasNavBar = true
        }
        
        super.viewDidLoad()
        if services == nil {
            
             services = (UIApplication.shared.delegate as! AppDelegate).services
            user = services?.globalModelsCoordinator.loggedInUser
            
        }
        configureView()
        configureData()
        
    }
    
    func configureView() {
        
        containerView.backgroundColor = UIColor(rgba: "F8F7F6")
        tableView.backgroundColor = UIColor(rgba: "F8F7F6")
        tableView.showsVerticalScrollIndicator = false
        tableView.showsHorizontalScrollIndicator = false
        tableView.allowsSelection = false
        tableView.register(R.nib.myProgressTableViewCell)
        tableView.register(R.nib.badgeProgressTableViewCell)
        tableView.register(R.nib.projectProgressTableViewCell)
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
        
        services?.globalModelsCoordinator.reloadLoggedInUser() { [weak self] in
            
            if let user = self?.services?.globalModelsCoordinator.loggedInUser {
                
                self?.user = user
                
            }
            
            self?.services?.globalModelsCoordinator.getProgression(for: self?.services?.globalModelsCoordinator.loggedInUser?.userId ?? "") {
                
                refreshControl?.endRefreshing()
                
            }
            
        }
        
    }
    
    func configureData() {
        
        services?.globalModelsCoordinator.reloadLoggedInUser() { [weak self] in
            
            if let user = self?.services?.globalModelsCoordinator.loggedInUser {
                
                self?.user = user
                
            }
            
        }
        services?.globalModelsCoordinator.getAllRewards(completionHandler: {
            
        })
        
        user = services?.globalModelsCoordinator.loggedInUser!
        
        notificationToken = user?.progression?.observe({ [weak self] (changes) in
            
            self?.tableView.reloadData()
            
        })
        
        services?.globalModelsCoordinator.getProgression(for: services?.globalModelsCoordinator.loggedInUser?.userId ?? "") { [weak self] in
            
            if self?.notificationToken == nil {
                
                self?.notificationToken = self?.user?.progression?.observe({ (changes) in
                    
                    self?.tableView.reloadData()
                    
                })
                
            }
            
            self?.tableView.reloadData()
            
        }
        
    }
    
}


extension MyProgressViewController : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 1
        
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        UIView.setAnimationsEnabled(true)
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            
            guard let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.myProgressTableViewCellId, for: indexPath) else { return UITableViewCell() }
            
            if let user = services?.globalModelsCoordinator.loggedInUser {
                
                cell.configure(with: user, delegate: self)
                
            }
            
            return cell
            
        }
        
        if indexPath.section == 1 {
            
            guard let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.projectProgressViewId, for: indexPath) else { return UITableViewCell() }
            
            //set animations to false stops the segment control from doing a weird growy animation on first load
            UIView.setAnimationsEnabled(false)
            cell.contentView.layoutIfNeeded()
            if let user = services?.globalModelsCoordinator.loggedInUser {
                
                cell.delegate = self
                cell.configure(with: user, filter: projectFilter)
                
            }
            
            return cell
            
        }
        
        if indexPath.section == 2 {
            
            guard let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.badgeProgressTableViewCellId, for: indexPath) else { return UITableViewCell() }
            
            if let user = services?.globalModelsCoordinator.loggedInUser {
                
                cell.configure(with: user, delegate : self)
                
            }
            
            return cell
            
        }
        
        return UITableViewCell()
        
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        if user?.hasBadgedResponses() ?? false {
            
            return 3
            
        }
        
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
                view.label.text = R.string.maverickStrings.progressionMyLevelHeader()
                
            case 1:
                view.label.text = R.string.maverickStrings.progressionMyProjectsHeader()
                
            case 2:
                view.label.text = R.string.maverickStrings.progressionMyBadgesHeader()
                
            default:
                view.label.text = ""
                
            }
            return view
            
        }
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return 32.0
        
    }
    
}

extension MyProgressViewController : MyProgressViewControllerDelegate {
    
    func seeMoreProjectsTapped(filter: ProjectProgressTableViewCell.ProjectProgressViewFilter) {
        
        AnalyticsManager.Progression.trackProjectSeeAllPressed(filter: filter)
        if let vc = R.storyboard.progression.projectsViewControllerId() {
            
            vc.initialFilter = filter
            vc.user = services?.globalModelsCoordinator.loggedInUser
            navigationController?.pushViewController(vc, animated: true)
            
        }
        
    }
    
    func badgeTapped(badgeStats: BadgeStats) {
        
        AnalyticsManager.Progression.trackBadgePressed(badgeId: badgeStats.badgeId)
        
        if let vc = R.storyboard.progression.badgesReceivedViewControllerId() {
            
            vc.initialStat = badgeStats
            vc.user = services?.globalModelsCoordinator.loggedInUser
            navigationController?.pushViewController(vc, animated: true)
            
        }
        
    }
    
    func levelDetailsTapped() {
        
        AnalyticsManager.Progression.trackNextLevelPressed()
        
        if let vc = R.storyboard.progression.levelDetailsViewControllerId(), let level = user?.progression?.nextLevel {
            
            vc.configure(with: level)
            vc.modalPresentationStyle = .overFullScreen
            present(vc, animated: true, completion: nil)
            
        }
        
    }
    
    func projectTapped(project: ProjectsProgress) {
        
        guard let projectId = project.project?.projectId else { return }
        AnalyticsManager.Progression.trackProjectPressed(projectId: projectId)
        if let vc = R.storyboard.progression.projectDetailsViewControllerId() {
            
            vc.configure(with: project)
            vc.modalPresentationStyle = .overFullScreen
            present(vc, animated: true, completion: nil)
            
        }
        
    }
    
    
    func projectTabChanged(filter : ProjectProgressTableViewCell.ProjectProgressViewFilter) {
        
        UIView.setAnimationsEnabled(false)
        projectFilter = filter
        tableView.reloadRows(at: [IndexPath(row: 0, section: 1)], with: .automatic)
        
    }
    
}
