//
//  ProjectProgressView.swift
//  Maverick
//
//  Created by Garrett Fritz on 9/18/18.
//  Copyright © 2018 BeMaverick. All rights reserved.
//

import Foundation

class ProjectProgressTableViewCell : UITableViewCell {
    
    enum ProjectProgressViewFilter : String {
        
        case inProgress = "IN PROGRESS"
        case completed = "COMPLETED"
        case notStarted = "NOT STARTED"
        
    }
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet var seeMoreButton: UIButton!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var segmentControl: MaverickSegmentedControl!
    @IBOutlet weak var itemStackView: UIStackView!
    
    @IBAction func segmentValueChanged(_ sender: Any) {
    
        delegate?.projectTabChanged(filter : segmentControl.selectedSegmentIndex == 0 ? .inProgress : .completed)
        
    }

    @IBAction func seeMoreButtonTapped(_ sender: Any) {
        
        delegate?.seeMoreProjectsTapped(filter: segmentControl.selectedSegmentIndex == 0 ? .inProgress : .completed)
    
    }
    
    private var user : User?
    private var tabsInitialized = false
    var projectProgressViewFilter : ProjectProgressViewFilter = .inProgress
    weak var delegate : MyProgressViewControllerDelegate?
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        activityIndicator.stopAnimating()
        containerView.addShadow(color: .black, alpha: 0.06, x: 0.0, y: 0.4, blur: 6.0, spread: 0)
        
    }
  
    override func layoutIfNeeded() {
        
        super.layoutIfNeeded()
        for subview in itemStackView.subviews {
            
            subview.layoutIfNeeded()
            
        }
    
    }
    
    func configure(with user : User, filter filterToSet: ProjectProgressViewFilter) {
        
        self.user = user
        
        guard user.progression != nil else {
            
            activityIndicator.startAnimating()
            containerView.isHidden = true
            return
            
        }
        
        containerView.isHidden = false
        activityIndicator.stopAnimating()
        
        setTabs()
        
        var filter = filterToSet
        if user.progression?.hasInProgress() ?? false {
        
            if user.progression?.hasCompleted() ?? false {
                
                segmentControl.selectedSegmentIndex = filter == .inProgress ? 0 : 1
                
            } else {
                
                 segmentControl.selectedSegmentIndex = 0
                filter = .inProgress
            
            }
            
        } else {
            
            segmentControl.selectedSegmentIndex = 0
            filter = .completed
            
        }
       
        contentView.layoutIfNeeded()
       
        
        for subview in itemStackView.subviews {
            
            subview.removeFromSuperview()
        
        }
        
        var availableProgress : [ProjectsProgress]?
        
        if filter == .completed {
            availableProgress =  user.progression?.getCompletedProjects()
        } else {
            availableProgress =  user.progression?.getInProgressProjects()
            
        }
        if let availableProgress = availableProgress {
            
            for i in 0 ..< availableProgress.count {
                
                guard let progress = availableProgress[safe: i] else { continue }
                
                guard i < 3 else {
                    
                    insertSeeMoreView()
                    return
                
                }
         
                let itemView = ProjectVerticalProgressItem()
                itemStackView.addArrangedSubview(itemView)
                itemView.layoutIfNeeded()
                itemView.delegate = delegate
                itemView.configure(with: progress)
                
            }
         
        }
        
    }
    
    private func insertSeeMoreView() {
        
       itemStackView.addArrangedSubview(seeMoreButton)
        
    }
    
    private func setTabs() {
        
        segmentControl.removeAllSegments()
        
        if user?.progression?.hasInProgress() ?? false {
            
             segmentControl.insertSegment(withTitle:ProjectProgressViewFilter.inProgress.rawValue, at: segmentControl.numberOfSegments, animated: false)
            
        }
        
        if user?.progression?.hasCompleted() ?? false {
            
            segmentControl.insertSegment(withTitle: ProjectProgressViewFilter.completed.rawValue, at: segmentControl.numberOfSegments, animated: false)
            
        }
       
       
        
    }
    
}
