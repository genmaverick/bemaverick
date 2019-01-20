//
//  OnboardForgotPasswordViewController.swift
//  BeMaverick
//
//  Created by David McGraw on 9/27/17.
//  Copyright © 2017 BeMaverick. All rights reserved.
//

import UIKit

class OnboardCompleteProfileViewController: OnboardParentViewController {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var descriptionLabel: UILabel!
    /// Mid Section welcome description
    @IBOutlet weak var welcomeLabel: UILabel!
    /// invisible button over the plus image view
    @IBOutlet weak var pickAvatarImageButton: UIButton!
    /// button text under the image
    @IBOutlet weak var pickAvatarLabelButton: UIButton!
    /// hint text for bio
    @IBOutlet weak var bioHint: UILabel!
    /// text entry for user description
    @IBOutlet weak var bioInputField: UITextView!
    /// default avatar + custom avatar image view
    @IBOutlet weak var avatarImage: UIImageView!
    /// skip/next button
    @IBOutlet weak var bottomNext: UIButton!
    /// skip/next button
    @IBOutlet weak var nextButton: UIButton!
    /// style item
    @IBOutlet weak var bioUnderline: UIView!
    /// makes view scrollable on keyboard show
    @IBOutlet weak var nextBottomConstraint: NSLayoutConstraint!
    /// Data returned from image picker
    private var avatarData : Data?
    /// We wait for avatar to upload before returning
    private var avatarLoadComplete = false
    
    @IBAction func unwindSegueToHome(_ sender: UIStoryboardSegue) {
        
    }
    
    
     // MARK: - IBActions
    
    /**
     Update avatar tappde
    */
    @IBAction func ctaButtonTapped(_ sender: Any) {
        
        
        if  let loggedinuser = services.globalModelsCoordinator.loggedInUser, loggedinuser.shouldShowVPC()  {
            
            if let vc = R.storyboard.general.onboardVPCNavViewControllerId() {
                
                vc.modalPresentationStyle = .overFullScreen
                present(vc, animated: true, completion: nil)
                
            }
            return
        }
        
        bioInputField.resignFirstResponder()
        handleUpdateAccountImageSelection()
        
    }
    
    /**
     Move to next screen
    */
    @IBAction func nextButtonTapped(_ sender: Any) {
        
        bioInputField.resignFirstResponder()
        
        guard Variables.Features.enableCompleteProfileCelebration.boolValue() else {
            
            if Variables.Features.enableFindFriendsOnboarding.boolValue() {
                
                self.performSegue(withIdentifier: R.segue.onboardCompleteProfileViewController.inviteFriendsSegue, sender: self)
                
            } else if Variables.Features.enableOnboardingIntroVideo.boolValue() {
                
                self.performSegue(withIdentifier: R.segue.onboardCompleteProfileViewController.firstChallengeSegue, sender: self)
                
            } else {
                
                self.performSegue(withIdentifier: R.segue.onboardCompleteProfileViewController.onboardCompleteSegue, sender: self)
                
            }
            
            return
        }
        
        if let text = bioInputField.text, text != "" {
            
            services?.globalModelsCoordinator.updateUserData(withBio: text , firstName: "", lastName:  "", username: user.username ?? "") { error in
                
                if Variables.Features.enableOnboardingIntroVideo.boolValue() {
                
                    self.performSegue(withIdentifier: R.segue.onboardCompleteProfileViewController.celebrationSegue, sender: self)
                
                } else {
                    
                      self.performSegue(withIdentifier: R.segue.onboardCompleteProfileViewController.onboardCompleteSegue, sender: self)
                    
                }
                
            }
            
        } else {
            
            if !Variables.Features.enableOnboardingIntroVideo.boolValue() {
                
                self.performSegue(withIdentifier: R.segue.onboardCompleteProfileViewController.onboardCompleteSegue, sender: self)
                
            } else if avatarData == nil {
                
                if Variables.Features.enableFindFriendsOnboarding.boolValue() {
                    
                    self.performSegue(withIdentifier: R.segue.onboardCompleteProfileViewController.inviteFriendsSegue, sender: self)
                    
                } else {
                    
                    self.performSegue(withIdentifier: R.segue.onboardCompleteProfileViewController.firstChallengeSegue, sender: self)
                    
                }
                
            } else {
                
                self.performSegue(withIdentifier: R.segue.onboardCompleteProfileViewController.celebrationSegue, sender: self)
                
            }
            
        }
        
    }

    /// Logged in user
    private var user : User!
    // MARK: - Public Properties
    /// The `GlobalServicesContainer` that maintains access to global services
    var services: GlobalServicesContainer!
    
   
    
    override func viewDidLoad() {
        
        services.globalModelsCoordinator.fromSignup = true
        
        if #available(iOS 11.0, *) {
        
            scrollView.contentInsetAdjustmentBehavior = .never
        
        } else {
        
            automaticallyAdjustsScrollViewInsets = false
        
        }
        
        scrollView.showsVerticalScrollIndicator = false
        services = (UIApplication.shared.delegate as! AppDelegate).services
        guard let user = services.globalModelsCoordinator.loggedInUser else { return }
        self.user = user
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: false)
        navigationController?.navigationBar.tintColor = UIColor.MaverickPrimaryColor
        
        bioInputField.delegate = self
        
    
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        AnalyticsManager.Onboarding.trackCompleteProfileNextPressed(hasAvatar: avatarData != nil, hasBio: bioInputField.text.count > 0)
        
        if let vc = R.segue.onboardCompleteProfileViewController.firstChallengeSegue(segue: segue)?.destination {
          
            vc.services = services
        
        }
        
        if let vc = R.segue.onboardCompleteProfileViewController.onboardCompleteSegue(segue: segue)?.destination {
            
            vc.services = services
            
        }
        
        if let vc = R.segue.onboardCompleteProfileViewController.celebrationSegue(segue: segue)?.destination {
            
          vc.services = services
            
        }
        
        
        if let vc = R.segue.onboardCompleteProfileViewController.inviteFriendsSegue(segue: segue)?.destination {
            
            vc.source = .onboarding
            vc.services = services
            vc.fromOnboarding = true
            
        }
      
    }
    
    /**
     Initialize views
    */
    override func configureView() {
        
        super.configureView()
        bioUnderline.backgroundColor = UIColor.MaverickPrimaryColor
        welcomeLabel.text = "WELCOME TO MAVERICK"
        welcomeLabel.textColor = UIColor.MaverickBadgePrimaryColor
        
        
        descriptionLabel.text = R.string.maverickStrings.onboardWelcomeLabel(user.username ?? "")
        pickAvatarLabelButton.setTitle(R.string.maverickStrings.onboardPickAvatar(), for: .normal)
        bottomNext.tintColor = UIColor.MaverickBadgePrimaryColor
        pickAvatarLabelButton.setTitleColor(UIColor.MaverickBadgePrimaryColor, for: .normal)
        bioHint.text = "Tell us about yourself in a few sentences"
        bioInputField.tintColor = UIColor.MaverickPrimaryColor
        view.backgroundColor = .white
        
        nextButton.setTitleColor(UIColor.MaverickBadgePrimaryColor, for: .normal)
        nextButton.setTitle(R.string.maverickStrings.skip().uppercased(), for: .normal)
        avatarImage.layer.cornerRadius = avatarImage.frame.width / 2
        
        bottomNext.isHidden = false
        
    }
    
    /**
     toggles visibility of next button + allows scrollable content to scroll
    */
    override func updateBottomConstraint( value : CGFloat) {

        super.updateBottomConstraint(value: value == 0 ? 0 : value + 60)
//        nextButton.isHidden = value > 0
//        bottomNext.isHidden = value == 0
        
        self.nextBottomConstraint.constant = value + 10
    }
    
   
    
    /**
     launch image picker
     */
    fileprivate func handleUpdateAccountImageSelection() {
        
        AnalyticsManager.Onboarding.trackAvatarSelectionStarted()
        
        if services.globalModelsCoordinator.loggedInUser?.shouldShowVPC() ?? false {
            
            if let vc = R.storyboard.general.onboardVPCNavViewControllerId() {
                
                vc.modalPresentationStyle = .overFullScreen
                present(vc, animated: true, completion: nil)
                
            }
            return
            
        }
        
        if let editingViewController = R.storyboard.post().instantiateViewController(withIdentifier: "PostRecordViewController") as? PostRecordViewController {
    
            editingViewController.forAvatar = true
            editingViewController.forProfileCover = true
            editingViewController.delegate = self
            present(editingViewController, animated: true, completion: nil)
            
        }
        
    }
    
    
    private func attemptToUploadAvatar() {
        
        if let avatarData = self.avatarData {
            
            DispatchQueue.main.async {
                
                self.services?.globalModelsCoordinator.updateUserAvatar(withImageData: avatarData) {
                    
                    self.avatarLoadComplete = true
                    
                }
                
            }
            
        }
        
    }
    
    
    /**
     Upload the provided image and update the user profile based on `isUpdatingAvatar`
     and `isUpdatingCoverImage`
     */
    fileprivate func completeProfileImageUpdate(withImage image: UIImage, size: CGSize? = nil, quality: CGFloat = 0.8) {
        
        
        DispatchQueue.global(qos: .utility).async {
            
            let size = size ?? image.size
            guard let resized = image.resizedImage(with: .scaleAspectFill,
                                                   bounds: size,
                                                   interpolationQuality: .medium),
                let data = UIImageJPEGRepresentation(resized, quality) else
            {
                
                log.error("Failed to parse the retrieved image from the image picker")
                return
                
            }
            
            
            
            DispatchQueue.main.async {
                
                self.avatarImage.image = resized
                self.avatarData  = data
                self.attemptToUploadAvatar()
                
            }
            
        }
        
    }
    
}

extension OnboardCompleteProfileViewController: PostRecordViewControllerDelegate {
    
    func imageSelected(image: UIImage) {
        
        completeProfileImageUpdate(withImage: image, size: image.size)
        
    }
    
}

extension OnboardCompleteProfileViewController : UITextViewDelegate {
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        
        AnalyticsManager.Onboarding.trackBioBeganEditing()
        if  let loggedinuser = services.globalModelsCoordinator.loggedInUser, loggedinuser.shouldShowVPC()  {
            
            if let vc = R.storyboard.general.onboardVPCNavViewControllerId() {
                
                vc.modalPresentationStyle = .overFullScreen
                present(vc, animated: true, completion: nil)
                
            }
            return false
        }
        
        return true
    }
    
}


