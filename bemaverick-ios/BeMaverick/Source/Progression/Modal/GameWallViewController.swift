//
//  GameWallViewController.swift
//  Maverick
//
//  Created by Garrett Fritz on 6/12/18.
//  Copyright © 2018 BeMaverick. All rights reserved.
//

import Foundation
import Lottie
import AudioToolbox


class GameWallViewController : ViewController {
    
    @IBOutlet weak var wallMidDescription: UILabel!
    @IBOutlet weak var dialogView: UIView!
    @IBOutlet weak var levelContainer: UIView!
    @IBOutlet weak var levelCounter: UILabel!
    @IBOutlet weak var imageHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var mainImageView: UIImageView!
    @IBOutlet weak var wallTitle: UILabel!
    @IBOutlet weak var wallDescription: UILabel!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var contentWhiteBackground: UIView!
    @IBOutlet weak var labelStackView: UIStackView!
    @IBOutlet weak var buttonDivider: UIView!
    @IBOutlet weak var animationContainer: UIView!
    
    @IBAction func backgroundTapped(_ sender: Any) {
        
        closePressed(self)
        
    }
    
    @IBAction func closePressed(_ sender: Any) {
        
        UIView.animate(withDuration: 0.25, animations: {
            
            self.view.alpha = 0
            
        }) { (result) in
            
            self.dismiss(animated: false, completion: nil)
            
        }
        
    }
    
    private var lockSize : CGFloat = 58.0
    private var projectSize : CGFloat = 160.0
    private var animationName = "firework_mint"
    private var titleString = "Locked"
    private var descriptionString = "Keep going to unlock this feature"
    private var closeText = "close"
    var level : Level?
    var project : Project?
    var reward : Reward?
    var hideStatusBar = false
    
    override var prefersStatusBarHidden: Bool {
        
        return hideStatusBar
    
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        configureView()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        UIView.animate(withDuration: 0.25, animations: {
            
            self.view.alpha = 1
            
        }) { (result) in
            
            if self.level != nil || self.project != nil {
                
                self.animateCelebration()
                
            }
            
        }
        
    }
    
    private func configureView() {
        
        wallMidDescription.isHidden = true
        view.alpha = 0.0
        contentWhiteBackground.layer.cornerRadius = 20
        contentWhiteBackground.clipsToBounds = false
        closeButton.setTitleColor(UIColor.MaverickBadgePrimaryColor, for: .normal)
        
        if let reward = reward {
            
            configureReward(reward: reward)
            
        } else if let level = level {
            
            configureLevel(level: level)
            
        } else if let project = project {
            
            configureProject(project: project)
            
        } else {
            
            configureLock()
            
        }
        
    }
    
    private func configureLock() {
        
        levelContainer.isHidden = true
        wallTitle.text = titleString
        wallDescription.text = descriptionString
        closeButton.setTitle(closeText, for: .normal)
        
    }
    
    private func configureReward(reward : Reward) {
        
        if let key = reward.key {
        
            AnalyticsManager.Progression.trackRewardLocked(rewardKey: key)
        
        }
        
        titleString = reward.name ?? R.string.maverickStrings.progressionLockedRewardTitle()
        descriptionString = R.string.maverickStrings.progressionLockedRewardDescription("\(reward.level?.levelNumber ?? 0)")
        configureLock()
        
    }
    
    private func configureLevel(level : Level) {
        
            AnalyticsManager.Progression.trackLevelAccomplished(levelNumber: "\(level.levelNumber)")
        
        setAlpha(alpha: 0.0)
        animationName = "firework_mint"
        wallTitle.text = R.string.maverickStrings.progressionLevelCompletedTitle("\(level.levelNumber)")
        wallDescription.text = R.string.maverickStrings.progressionLevelCompletedDescription("\(level.levelRewards ?? "")")
        closeButton.setTitle(R.string.maverickStrings.progressionLockedConfirmMessage(), for: .normal)
        levelContainer.transform = CGAffineTransform(scaleX: 0.0001, y: 0.0001)
        levelContainer.isHidden = false
        mainImageView.isHidden = true
        levelCounter.text = "\(level.levelNumber)"
        
    }
    
    private func configureProject(project : Project) {
        
        AnalyticsManager.Progression.trackProjectAccomplished(projectId: project.projectId)
        setAlpha(alpha: 0.0)
        wallMidDescription.isHidden = false
        wallMidDescription.text = project.requirementDescription
        animationName = "firework_red"
        wallTitle.text = project.name ?? "Project Complete"
        wallDescription.text = R.string.maverickStrings.progressionProjectCompletedDescription()
        closeButton.setTitle(R.string.maverickStrings.progressionLockedConfirmMessage(), for: .normal)
        mainImageView.transform = CGAffineTransform(scaleX: 0.0001, y: 0.0001)
        imageWidthConstraint.constant = projectSize
        imageHeightConstraint.constant = projectSize
        levelContainer.isHidden = true
        mainImageView.isHidden = false
        mainImageView.kf.setImage(with: project.getImageUrl())
        
    }
    
    private func setAlpha(alpha: CGFloat ) {
        
        labelStackView.alpha = alpha
        contentWhiteBackground.alpha = alpha
        buttonDivider.alpha = alpha
        closeButton.alpha = alpha
        levelContainer.alpha = alpha
        mainImageView.alpha = alpha
        
    }
    
    private func startLottieAnimation() {
        
        let lottieLogo = LOTAnimationView(name: animationName)
        
        var imageFrame = mainImageView.frame
        if level != nil {
            
            imageFrame = levelContainer.frame
            
        }
        
        let newFrame = mainImageView.superview?.convert(imageFrame, to: nil) ?? CGRect.zero
        lottieLogo.frame.origin.y = newFrame.origin.y - lottieLogo.frame.height / 2 - 20
        lottieLogo.frame.origin.x = newFrame.origin.x - lottieLogo.frame.width / 2
        animationContainer.addSubview(lottieLogo)
        lottieLogo.play()
        
    }
    
    private func animateCelebration() {
        
        AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
        startLottieAnimation()
        
        UIView.animate(withDuration: 0.5, animations: {
            
            self.mainImageView.alpha = 1.0
            self.levelContainer.alpha = 1.0
            self.levelContainer.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
            self.mainImageView.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
            
        }) { (finished) in
            
            UIView.animate(withDuration: 0.25, animations: {
                
                self.mainImageView.transform = CGAffineTransform.identity
                self.levelContainer.transform = CGAffineTransform.identity
                
                UIView.animate(withDuration: 0.25, animations: {
                    
                    self.setAlpha(alpha: 1.0)
                    
                }) { (result) in
                    
                }
            })
            
        }
        
    }
    
    func configure(with title : String, description : String, closeText : String = R.string.maverickStrings.progressionLockedConfirmMessage()) {
        
        titleString = title
        descriptionString = description
        self.closeText = closeText
        
    }
    
}
