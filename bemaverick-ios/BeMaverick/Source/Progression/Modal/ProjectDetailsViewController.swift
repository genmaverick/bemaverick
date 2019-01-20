//
//  ProjectDetailsViewController.swift
//  Maverick
//
//  Created by Garrett Fritz on 9/17/18.
//  Copyright © 2018 BeMaverick. All rights reserved.
//

import Foundation
import AudioToolbox


class ProjectDetailsViewController : DismissableViewController {
    
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var projectTitleLabel: UILabel!
    @IBOutlet weak var projectImageView: UIImageView!
    @IBOutlet weak var animationcontainer: UIView!
    @IBOutlet weak var projectDescription1: UILabel!
    @IBOutlet weak var projectDescription2: UILabel!
    @IBOutlet weak var circularProgress: CircularProgressBar!
    @IBOutlet weak var projectSpecsStackView: UIStackView!
    @IBOutlet weak var projectRequirementsLabel: UILabel!
    @IBOutlet weak var projectRewardsLabel: UILabel!
    
    @IBAction func closeButtonTapped(_ sender: Any) {
        
        dismiss(animated: true, completion: nil)
        
    }
    
    private var projectProgress : ProjectsProgress?
    private var projectComplete = false
   
    
    func configure(with projectProgress : ProjectsProgress) {
        
        self.projectProgress = projectProgress
        projectComplete = projectProgress.completed
        
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        configureView()
        configureData()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        
        if let progress = projectProgress?.progress {
            
            animateProgress(progress: projectComplete ? 1.0 : progress)
            
        }
        
    }
    
    func configureView() {
        
        projectImageView.layer.cornerRadius = projectImageView.frame.height / 2.0
        projectImageView.clipsToBounds = true
        projectImageView.alpha = 0.5
        closeButton.tintColor  = UIColor.MaverickBadgePrimaryColor
        
    }
    
    func configureData() {
        
        configureBasicData()
        
        if projectComplete {
            
            configureCompleteProject()
            
        } else {
            
            configureInProgressProject()
            
        }
        
    }
    
    private func configureBasicData() {
        
        guard let progress = projectProgress, let project = progress.project else { return }
        
        projectSpecsStackView.isHidden = projectComplete
        projectTitleLabel.text = project.name
        
        if let color = project.color {
            
            backgroundImage.tintColor = UIColor(rgba: color)
            
        }
        
        projectRequirementsLabel.text = project.requirementDescription
        projectRewardsLabel.text = R.string.maverickStrings.progressionProjectDetailsRewardTemplate("\(Int(project.reward))")
        
        setProjectImage()
        
    }
    
    private func configureInProgressProject() {
        
        guard let progress = projectProgress else { return }
        
        if progress.tasksCompleted == 0 {
            
            projectDescription1.text = R.string.maverickStrings.progressionProjectDetailsProgressNotStarted()
            
        } else {
            
            projectDescription1.text = R.string.maverickStrings.progressionProjectDetailsProgressTemplate("\(Int(progress.progress * 100))")
            
        }
        
        projectDescription2.text = nil
        
    }
    
    private func configureCompleteProject() {
        
        guard let progress = projectProgress, let project = progress.project else { return }
        
        projectDescription1.text = project.achievedDescription
        projectDescription2.text = project.achievedDescriptionSecondary
        
    }
    
    private func setProjectImage() {
        
        guard let progress = projectProgress else { return }
        
        if let url = progress.project?.getImageUrl() {
            
            projectImageView.kf.setImage(with: url) { (image, error, cache, url) in
                
                if error != nil {
                    
                    self.projectImageView.image = R.image.project_default()
                    
                }
                
            }
            
        } else {
            
            self.projectImageView.image = R.image.project_default()
            
        }
        
    }
    
    private func animateProgress(progress : Float) {
        
        circularProgress.setProgress(to: progress, withAnimation: true) { [weak self] completed in
            
            guard completed else { return }
            
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            
            UIView.animate(withDuration: 0.15, animations: {
                
                self?.projectImageView.alpha = 1.0
                self?.projectImageView.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
                
            }) { (finished) in
                
                UIView.animate(withDuration: 0.25, animations: {
                    
                    self?.projectImageView.transform = CGAffineTransform.identity
                    
                })
                
            }
            
        }
        
    }
    
}
