//
//  ProjectVerticalProgressItem.swift
//  Maverick
//
//  Created by Garrett Fritz on 9/18/18.
//  Copyright © 2018 BeMaverick. All rights reserved.
//

import Foundation

class ProjectVerticalProgressItem : UIView {
    
    @IBOutlet weak var progressBarContainer: UIView!
    @IBOutlet weak var projectImageView: UIImageView!
    @IBOutlet weak var projectNameLabel: UILabel!
    @IBOutlet weak var completedSpacer: UIView!
    @IBOutlet weak var projectDescriptionLabel: UILabel!
    @IBOutlet weak var projectAvailableProgressView: UIView!
    @IBOutlet weak var projectCompletedProgressView: UIView!
    @IBOutlet weak var projectCompletedProgressWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var projectProgressDescriptionLabel: UILabel!
    /// Parent view
    @IBOutlet weak var view: UIView!
    
    @IBAction func cellTapped(_ sender: Any) {
        
        guard let project = projectsProgress else { return }
        delegate?.projectTapped(project: project)
        
    }
    
    weak var delegate : MyProgressViewControllerDelegate?
    private var projectsProgress : ProjectsProgress?
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        setup()
        
    }
    
    required init?(coder: NSCoder) {
        
        super.init(coder: coder)
        setup()
        
    }
    
    //Needed here to update the width constraint of the completed bar relative to parent after cell gets sized appropriately
    override func layoutIfNeeded() {
        
        if let projectsProgress = projectsProgress {
            
            updateProgress(projectsProgress: projectsProgress)
            
        }
        
        super.layoutIfNeeded()
        
    }
    
    private func instanceFromNib() -> UIView {
        
        return R.nib.projectVerticalProgressItem.firstView(owner: self)!
        
    }
    
    private func setup() {
        
        view = instanceFromNib()
        addSubview(view)
        view.autoPinEdgesToSuperviewEdges()
        view.frame = self.bounds
        view.backgroundColor = UIColor.clear
        projectImageView.layer.cornerRadius = projectImageView.frame.height / 2
        projectImageView.clipsToBounds = true
        projectCompletedProgressView.layer.cornerRadius = projectCompletedProgressView.frame.height / 2
        projectAvailableProgressView.layer.cornerRadius = projectAvailableProgressView.frame.height / 2
        
    }
    
    private func updateProgress(projectsProgress : ProjectsProgress) {
        
        let progress = projectAvailableProgressView.frame.width * CGFloat(projectsProgress.progress)
        projectCompletedProgressWidthConstraint.constant = projectsProgress.completed ? projectAvailableProgressView.frame.width : progress
        
    }
    
    private func setProjectImage() {
        
        if let url = projectsProgress?.project?.getImageUrl() {
            
            projectImageView.kf.setImage(with: url) { (image, error, cache, url) in
                
                if error != nil {
                    
                    self.projectImageView.image = R.image.project_default()
                    
                }
                
            }
            
        } else {
            
            self.projectImageView.image = R.image.project_default()
            
        }
        
    }
    
    private func configureCompletedProject() {
        
        guard let projectsProgress = projectsProgress else { return }
        if let dateComplete = projectsProgress.getTimeStamp() {
            
            projectProgressDescriptionLabel.text = "Completed on: \(dateComplete.toString(dateFormat: "MMM-dd hh:mm a"))"
            
        } else {
            
            projectProgressDescriptionLabel.text = nil
        
        }
        
        progressBarContainer.isHidden = true
        completedSpacer.isHidden = false
        
    }
    
    private func configureInProgressProject() {
        
        guard let projectsProgress = projectsProgress else { return }
        let needed = projectsProgress.project?.tasksRequired ?? 0
        let completed = projectsProgress.tasksCompleted
        completedSpacer.isHidden = true
        projectProgressDescriptionLabel.text = "\(completed) / \(needed)"
        projectProgressDescriptionLabel.isHidden = needed <= 1
        progressBarContainer.isHidden = false
        updateProgress(projectsProgress: projectsProgress)
        
    }
    
    func configure(with projectsProgress : ProjectsProgress) {
        
        self.projectsProgress = projectsProgress
       
        setProjectImage()
        projectNameLabel.text = projectsProgress.project?.name
        projectDescriptionLabel.text = projectsProgress.project?.requirementDescription
        
        if projectsProgress.completed {
            
            configureCompletedProject()
            
        } else {
            
            configureInProgressProject()
            
        }
        
    }
    
}
