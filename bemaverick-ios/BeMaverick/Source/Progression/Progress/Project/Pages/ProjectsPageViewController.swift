
//
//  ProjectsPageViewController.swift
//  Maverick
//
//  Created by Garrett Fritz on 9/17/18.
//  Copyright © 2018 BeMaverick. All rights reserved.
//

import Foundation

class ProjectsPageViewController: ViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var services : GlobalServicesContainer!
    var user : User?
    var filter : ProjectProgressTableViewCell.ProjectProgressViewFilter = .inProgress
    
    override func viewDidLoad() {
       
        ignoreNavControl = true
        super.viewDidLoad()
        configureView()
        
    }
    
    func configureView() {
    
        view.backgroundColor = UIColor(rgba: "F8F7F6")
        tableView.backgroundColor = UIColor(rgba: "F8F7F6")
        tableView.showsVerticalScrollIndicator = false
        tableView.showsHorizontalScrollIndicator = false
        tableView.allowsSelection = false
        tableView.register(R.nib.projectVerticalTableViewCell)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorColor = .clear
        tableView.estimatedRowHeight = 200
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.reloadData()
        tableView.contentInset = .zero
    
    }
    
}

extension ProjectsPageViewController : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        var availableProgress : [ProjectsProgress]?
        
        if filter == .completed {
            availableProgress =  user?.progression?.getCompletedProjects()
        } else {
            availableProgress =  user?.progression?.getInProgressProjects()
            
        }
        
         if let availableProgress = availableProgress {
            
            return availableProgress.count
            
        }
        
        return 0
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var availableProgress : [ProjectsProgress]?
        
        if filter == .completed {
            availableProgress =  user?.progression?.getCompletedProjects()
        } else {
            availableProgress =  user?.progression?.getInProgressProjects()
            
        }
        
      guard let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.projectVerticalTableViewCellId, for: indexPath), let projects = availableProgress, let progress = projects[safe: indexPath.row] else { return UITableViewCell() }
        
        cell.configure(with: progress, delegate: self)
        return cell
        
    }
    
}


extension ProjectsPageViewController : MyProgressViewControllerDelegate {
   
    func projectTabChanged(filter: ProjectProgressTableViewCell.ProjectProgressViewFilter) {
        
    }
    
    func seeMoreProjectsTapped(filter: ProjectProgressTableViewCell.ProjectProgressViewFilter) {
        
    }
    
    func badgeTapped(badgeStats: BadgeStats) {
        
    }
    
    func levelDetailsTapped() {
        
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
    
}

