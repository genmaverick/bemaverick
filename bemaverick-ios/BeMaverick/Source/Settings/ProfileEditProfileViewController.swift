//
//  ProfileEditPasswordViewController.swift
//  BeMaverick
//
//  Created by David McGraw on 11/29/17.
//  Copyright © 2017 BeMaverick. All rights reserved.
//

import UIKit
import MessageUI
import RealmSwift

class ProfileEditProfileViewController: ViewController {
    
    override var shouldAutorotate: Bool {
        get { return false }
    }
    // MARK: - IBOutlets
    
    @IBOutlet weak var avatarImageShadow: UIView!
    @IBOutlet weak var contentContainerView: UIView!
    /// First name text entry field
    @IBOutlet weak var firstNameTextInput: TextInputLayout!
    /// Last name text entry field
    @IBOutlet weak var lastNameTextInput: TextInputLayout!
    /// Stack view holding the username field, gets removed for now
    @IBOutlet weak var usernameTextInput: TextInputLayout!
    /// Stack view holding the email field, gets removed for now
    @IBOutlet weak var emailTextInput: TextInputLayout!

    /// Change profile cover button
    @IBOutlet weak var changeProfileCover: UIButton!
    /// Change profile avatar button
    @IBOutlet weak var changeAvatarButton: UIButton!
    /// Image that is the custom background image
    @IBOutlet weak var coverImage: UIImageView!
    /// Avatar image view
    @IBOutlet weak var avatarImage: UIImageView!
    /// image that is visible if a preset image is selected, has .2 alpha
    @IBOutlet weak var scrollviewBottomConstraint: NSLayoutConstraint!
    /// Bio Text View - resizes so needs to not be textField
    @IBOutlet weak var bioTextInput: UITextView!
    /// line to style bio as text input layout
    @IBOutlet weak var bioDivider: UIView!
    /// label to style bio as text input layout
    @IBOutlet weak var bioHint: UILabel!
    
    
    /// Button in liu of editing email
    @IBOutlet weak var emailHelpButton: UIButton!
    
    @IBOutlet weak var mentionAutoCompleteView: MaverickAutoCompleteView!

    
    @IBOutlet weak var usernameHeight: NSLayoutConstraint!
    
    
    // MARK: - IBActions
    
    /**
     Open action sheet to select custom cover
     */
    @IBAction func changeProfileCover(_ sender: Any) {
        
        launchActionSheet(forAvatar:  false)
        AnalyticsManager.Settings.trackEditCoverPressed()
        
    }
    
    /**
     Open action sheet to change avatar
     */
    @IBAction func changeProfileAvatar(_ sender: Any) {
        
        launchActionSheet(forAvatar: true)
        
        
    }
    
    
    // MARK: - Public Properties
    
    /// The `GlobalServicesContainer` that maintains access to global services
    var services: GlobalServicesContainer?
    var loadingView: LoadingView?
    
    // MARK: - Private Properties
    /// Data returned from image picker
    private var coverData : Data?
    /// Data returned from image picker
    private var avatarData : Data?
    /// Logged in user object
    private var loggedInUser = User()
    /// We wait for avatar to upload before returning
    private var avatarLoadComplete = false
    /// We wait for cover to upload before returning
    private var coverLoadComplete = false
    /// flag for in uploading flow
    fileprivate var uploadingFlow = false
    /// Flag for upload cover starting
    fileprivate var isUpdatingCoverImage = false
    /// We wait for upload avatar starting
    private var isUpdatingAvatar = false
    /// A reference to the `UIKeyboardWillShow` notification
    private var keyboardWillShowId: NSObjectProtocol?
    /// A reference to the `UIKeyboardWillHide` notification
    private var keyboardWillHideId: NSObjectProtocol?
    /// should wipe out profile
    private var wipeOutAvatar = false
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        
        hasNavBar = true
        super.viewDidLoad()
        guard let me = services?.globalModelsCoordinator.loggedInUser else {
            
            backButtonTapped(self)
            return
        }
        
        loggedInUser = me
        configureView()
        
        bioTextInput.delegate = self
        
        mentionAutoCompleteView.configureWith(textView: bioTextInput, delegate: self, services: services)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(keyboardWillShowId as Any)
        NotificationCenter.default.removeObserver(keyboardWillHideId as Any)
        
    }
    

    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
    
        if ProfileEditCoverViewController.selectedId >= 0 {
            
            let cover = services?.globalModelsCoordinator?.getPresetProfileCover(byId: String(ProfileEditCoverViewController.selectedId))
            if let coverPath =  cover?.getUrlForSize(size: coverImage.frame), let url = URL(string: coverPath) {
                
                coverImage?.kf.setImage(with: url, options: [.transition(.fade(UIImage.fadeInTime))])
                
            }
            
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue == R.segue.profileEditProfileViewController.updateCoverSegue(segue: segue)?.segue {
            
            if let vc = R.segue.profileEditProfileViewController.updateCoverSegue(segue: segue)?.destination {
                vc.services = services
            }
            
        }
        
    }
    
    /**
     Launch alert view to instruct how to change
     */
    @IBAction func emailChangeTap(_ sender: Any) {
        
        AnalyticsManager.Settings.trackEditEmailPressed()
        
        let topSpacer = MaverickActionSheetMessage(text: " ", font: R.font.openSansRegular(size: 20.0)!, textColor: .black)
        
        let middleSpacer = MaverickActionSheetMessage(text: " ", font: R.font.openSansRegular(size: 20.0)!, textColor: .black)
        
        let bottomSpacer = MaverickActionSheetMessage(text: " ", font: R.font.openSansRegular(size: 20.0)!, textColor: .black)
        
        let message = MaverickActionSheetMessage(text: R.string.maverickStrings.changeEmailActionSheetMessage(), font: R.font.openSansRegular(size: 20.0)!, textColor: .black)
        
        let action = MaverickActionSheetButton(text: R.string.maverickStrings.supportEmailAddress(), font: R.font.openSansRegular(size: 20.0)!, action: { [unowned self] in
            
            if MFMailComposeViewController.canSendMail() {
                
                let mail = MFMailComposeViewController()
                mail.mailComposeDelegate = self
                mail.setSubject("Change Email")
                mail.setToRecipients([R.string.maverickStrings.supportEmailAddress()])
                let username = self.loggedInUser.username ?? ""
                mail.setMessageBody("<p>Please help update my email address for \(username)</p>", isHTML: true)
                self.present(mail, animated: true)
                
            }
            
            }, textColor: UIColor.MaverickPrimaryColor)
        
        let maverickActionSheetViewModel = MaverickActionSheetViewModel(title: R.string.maverickStrings.changeEmailActionSheetTitle(), maverickActionSheetItems: [topSpacer, message, middleSpacer, action, bottomSpacer], alignment: .center)
        let maverickActionSheetViewController = MaverickActionSheetVC(viewModel: maverickActionSheetViewModel)
        
        let maverickActionSheetTransitioningDelegate = MaverickActionSheetTransitioningDelegate()
        maverickActionSheetViewController.transitioningDelegate = maverickActionSheetTransitioningDelegate
        transitioningDelegate = maverickActionSheetTransitioningDelegate
        
        present(maverickActionSheetViewController, animated: true, completion: nil)
        
    }
    
    
    // MARK: - Private Methods
    
    /**
     Back button pressed to dismiss view
     */
    @objc override func backButtonTapped(_ sender: Any) {
        
        ProfileEditCoverViewController.selectedId = -1
        
        navigationController?.popViewController(animated: true)
        
    }
    
    /**
     Cancel button pressed to dismiss view
     */
    @objc fileprivate func cancelButtonTapped(_ sender: Any) {
        
        ProfileEditCoverViewController.selectedId = -1
        AnalyticsManager.Settings.trackEditProfileCancelPressed()
        navigationController?.popViewController(animated: true)
        
    }
    
    /**
     Launch image editing flow for avatar or cover photo.
     */
    fileprivate func handleUpdateAccountImageSelection(isUpdatingAvatar: Bool) {
        
        if loggedInUser.shouldShowVPC() {
            
            if let vc = R.storyboard.general.onboardVPCNavViewControllerId() {
                
                vc.modalPresentationStyle = .overFullScreen
                present(vc, animated: true, completion: nil)
                
            }
            return
            
        }
        
        self.isUpdatingAvatar = isUpdatingAvatar
        self.isUpdatingCoverImage = !isUpdatingAvatar

        if let editingViewController = R.storyboard.post().instantiateViewController(withIdentifier: "PostRecordViewController") as? PostRecordViewController {
            
            if isUpdatingAvatar {
                editingViewController.forAvatar = true
            } else {
                editingViewController.forProfileCover = true
            }
            
            editingViewController.delegate = self
            present(editingViewController, animated: true, completion: nil)
        }
        
    }
    
    
    /**
     recursive function to wait till uploads are complete
     */
    private func attemptToLeave() {
        
        if coverData == nil || coverLoadComplete  {
            if avatarData == nil || avatarLoadComplete {
                self.navigationController?.popToRootViewController(animated: true)
                return
            }
        }
        
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.15) {
            log.verbose()
            self.attemptToLeave()
        }
        
    }
    
    /**
     Display an activity indicator
     */
    func showLoadingIndicator(withMessage message: String = "Saving Profile") {
        
        if loadingView == nil {
            loadingView = LoadingView.instanceFromNib()
            view.addSubview(loadingView!)
            
            loadingView?.autoAlignAxis(toSuperviewAxis: .vertical)
            loadingView?.autoAlignAxis(.horizontal, toSameAxisOf: view, withOffset: -50)
            loadingView?.autoSetDimension(.width, toSize: 240)
            loadingView?.autoSetDimension(.height, toSize: 128)
            
            view.isUserInteractionEnabled = false
            
            loadingView?.titleLabel.text = message
            loadingView?.startAnimating()
            
        }
       
    }
    
    /**
     Save button pressed - attempt to leave
     */
    @objc fileprivate func saveButtonTapped(_ sender: Any) {
        
        AnalyticsManager.Settings.trackEditProfileSavePressed()
        
        if (usernameTextInput.entryTextView.text?.count)! < 4 {
            
            usernameTextInput.setValidState(isValid: false,
                                            validationText: R.string.maverickStrings.fieldRequiredWithQuantity(R.string.maverickStrings.loginUsernameShortHint().lowercased(), 4))
            
            navigationItem.rightBarButtonItem?.isEnabled = false
            
            return
            
        }
        
        
        showLoadingIndicator()
        
        if avatarData != nil || wipeOutAvatar {
            //this function calls attempt to upload cover
            attemptToUploadAvatar()
            
        } else {
            
            attemptToUploadCover()
            
        }
        
        services?.globalModelsCoordinator.updateUserData(withBio: bioTextInput.text, firstName: firstNameTextInput.text ?? "", lastName: lastNameTextInput.text ?? "", username: usernameTextInput.entryTextView.text ?? ""){ error in
            
            guard error == nil else {
                
                self.loadingView?.removeFromSuperview()
                self.displayErrorMessage(error: error!)
                return
                
            }
            self.attemptToLeave()
            
        }
        
    }
    /**
     Configure the default layout
     */
    fileprivate func configureView() {
        
        // iOS 10 fix to not have white spacing on top
        automaticallyAdjustsScrollViewInsets = false
        
        view.backgroundColor = .white
        contentContainerView.backgroundColor = .white
        
       
        let rightButton = UIBarButtonItem(title: R.string.maverickStrings.save(), style: .plain, target: self, action: #selector(saveButtonTapped(_:)))
        
        navigationItem.rightBarButtonItem = rightButton
        
       showNavBar(withTitle:  R.string.maverickStrings.editProfileTitle())
        
        emailTextInput?.shouldBeGrayedOut = true
        emailTextInput?.entryTextView.isEnabled = false
        emailTextInput?.bringSubview(toFront: emailHelpButton)
        
        
        
        bioHint.text = R.string.maverickStrings.bioHint()
        bioDivider.backgroundColor = UIColor.MaverickPrimaryColor
        
        avatarImage.layer.cornerRadius = avatarImage.frame.height / 2
        avatarImage.layer.borderWidth = 1
        avatarImage.layer.borderColor = UIColor.white.cgColor
        avatarImage.layer.masksToBounds = true
        avatarImage.clipsToBounds = true
        observeKeyboardWillShow()
        observeKeyboardWillHide()
        
        if loggedInUser.overThirteen ?? true {
            
            emailTextInput?.setHints(shortHint: R.string.maverickStrings.email(), fullHint: R.string.maverickStrings.over13EmailHint())
            
        } else {
            
            emailTextInput?.setHints(shortHint: R.string.maverickStrings.email(), fullHint: R.string.maverickStrings.under13EmailHint())
            
            
        }
        
        
        
        firstNameTextInput?.setHints(shortHint: R.string.maverickStrings.firstNameHint(), fullHint: R.string.maverickStrings.firstNameHint())
        
        lastNameTextInput?.setHints(shortHint: R.string.maverickStrings.lastNameHint(), fullHint: R.string.maverickStrings.lastNameHint())
        
        emailHelpButton.setTitleColor(UIColor.MaverickPrimaryColor, for: .normal)
        changeAvatarButton.setTitleColor(UIColor.MaverickPrimaryColor, for: .normal)
        changeAvatarButton.setTitle(R.string.maverickStrings.changePhoto(), for: .normal)
        changeProfileCover.setTitleColor(UIColor.white, for: .normal)
        changeProfileCover.setTitle(R.string.maverickStrings.changeCover(), for: .normal)
        changeProfileCover.addShadow(alpha: 0.8)
        changeProfileCover.contentHorizontalAlignment = .center
        changeAvatarButton.contentHorizontalAlignment = .center
        changeProfileCover.titleLabel?.textAlignment = .center
        changeAvatarButton.titleLabel?.textAlignment = .center
        
        emailHelpButton.contentHorizontalAlignment = .right
        
        refreshUserData()
        
        avatarImageShadow.addShadow()
        avatarImageShadow.layer.shadowPath = UIBezierPath(roundedRect: avatarImageShadow.bounds, cornerRadius: avatarImageShadow.frame.height).cgPath
        
        usernameTextInput.shouldBeGrayedOut = false
        usernameTextInput.entryTextView.isEnabled = true
        usernameTextInput.setHints(shortHint: R.string.maverickStrings.loginUsernameShortHint(), fullHint: R.string.maverickStrings.loginUsernameHint())
        usernameTextInput.charLimit = 15
        usernameTextInput.delegate = self
        usernameTextInput.entryTextView.returnKeyType = .done
        usernameTextInput.entryTextView.autocorrectionType = .no
        usernameTextInput.characterCounter.isHidden = true
        usernameHeight.constant = 60
        
        usernameTextInput.entryTextView.addTarget(self, action: #selector(usernameTextInputChanged(_:)), for: .editingChanged)
    
        
    }
    
    @objc
    func usernameTextInputChanged(_ sender: Any) {
        
        navigationItem.rightBarButtonItem?.isEnabled = false
        usernameTextInput.setValidState(isValid: false, validationText: "Checking username...")
        
        if (usernameTextInput.entryTextView.text?.count)! < 4 {
            
            usernameTextInput.setValidState(isValid: false,
                                            validationText: R.string.maverickStrings.fieldRequiredWithQuantity(R.string.maverickStrings.loginUsernameShortHint().lowercased(), 4))
            
            navigationItem.rightBarButtonItem?.isEnabled = false
            
        } else if usernameTextInput.text != loggedInUser.username {
            
            attemptUsernameValidation(withName: usernameTextInput.entryTextView.text!, completionHandler: { (valid, errorMessage) in
                
                if valid {
                    
                    DispatchQueue.main.async {
                        self.usernameTextInput.setValidState(isValid: true)
                        self.navigationItem.rightBarButtonItem?.isEnabled = true
                    }
                    
                } else {
                    
                    DispatchQueue.main.async {
                        self.usernameTextInput.setValidState(isValid: false, validationText: errorMessage!)
                        self.navigationItem.rightBarButtonItem?.isEnabled = false
                    }
                    
                }
                
            })
            
        } else {
            
            usernameTextInput.setValidState(isValid: true)
            self.navigationItem.rightBarButtonItem?.isEnabled = true
            
        }
        
    }
    
    /**
     Update field data with current user object
     */
    private func refreshUserData() {
        
        firstNameTextInput.text = loggedInUser.firstName
        lastNameTextInput.text = loggedInUser.lastName
        bioTextInput.text = loggedInUser.bio
        emailTextInput?.text = loggedInUser.emailAddress ?? loggedInUser.parentEmailAddress
        
        emailTextInput?.isHidden = emailTextInput?.text == nil
        
        usernameTextInput?.text = loggedInUser.username
        // Set cover image
        
        
        
        
        if let path = loggedInUser.profileCover?.getUrlForSize(size: coverImage.frame), let url = URL(string: path) {
            
            coverImage.kf.setImage(with: url, placeholder: R.image.defaultCover(), options: [.transition(.fade(UIImage.fadeInTime))], progressBlock: nil, completionHandler: nil)
            
        }
        
        if let path = loggedInUser.profileImage?.getUrlForSize(size: avatarImage.frame), let url = URL(string: path) {
            
            avatarImage.kf.setImage(with: url, placeholder: R.image.defaultMaverickAvatar(), options: [.transition(.fade(UIImage.fadeInTime))], progressBlock: nil, completionHandler: nil)
            
        } else {
            
            avatarImage.image = R.image.defaultMaverickAvatar()
            
        }
        
        if let path = loggedInUser.profileImage?.getUrlForSize(size: avatarImage.frame), let url = URL(string: path) {
            
            avatarImage.kf.setImage(with: url, placeholder: R.image.defaultMaverickAvatar(), options: [.transition(.fade(UIImage.fadeInTime))], progressBlock: nil, completionHandler: nil)
            
        } else {
            
            avatarImage.image = R.image.defaultMaverickAvatar()
            
        }
        
    }
    
    /**
     Prepare and display custom action sheet
     */
    private func launchActionSheet(forAvatar: Bool) {
        
        let editAction = {
            
            if !forAvatar {
                
                if let vc = R.storyboard.progression.gameWallViewControllerId(), let reward = self.services?.globalModelsCoordinator.isRewardAvailable(rewardKey: .coverPhotoEditor), !reward.completed {
                    
                    
                    vc.reward = reward
                    vc.modalPresentationStyle = .overFullScreen
                    self.present(vc, animated: false, completion: nil)
                    return
                    
                }
                
            }
            self.isUpdatingCoverImage = !forAvatar
            self.isUpdatingAvatar = forAvatar
            self.handleUpdateAccountImageSelection(isUpdatingAvatar: forAvatar)
            
        }
        
        let selectMaverickCoverAction = {
            
            self.performSegue(withIdentifier: R.segue.profileEditProfileViewController.updateCoverSegue, sender: self)
            
        }
        
        let removeCurrentPhotoAction = { 
            
            self.wipeOutAvatar = true
            self.avatarData = nil
            self.avatarImage.image = R.image.defaultMaverickAvatar()
            
        }
        
        let actionSheetTitle = forAvatar ? R.string.maverickStrings.changeProfilePhotoActionSheetTitle() : R.string.maverickStrings.changeCoverPhotoActionSheetTitle()
        
        let actionSheetItem: MaverickActionSheetItem = forAvatar ? ChangeProfilePhotoActionSheetItem(editAvatarAction: editAction, removeCurrentPhotoAction: removeCurrentPhotoAction) : ChangeCoverPhotoActionSheetItem(createNewCoverAction: editAction, selectMaverickCoverAction: selectMaverickCoverAction)
        
        let maverickActionSheetViewModel = MaverickActionSheetViewModel(title: actionSheetTitle, maverickActionSheetItems: [actionSheetItem], alignment: .leading)
        let maverickActionSheetViewController = MaverickActionSheetVC(viewModel: maverickActionSheetViewModel)
        
        let maverickActionSheetTransitioningDelegate = MaverickActionSheetTransitioningDelegate()
        maverickActionSheetViewController.transitioningDelegate = maverickActionSheetTransitioningDelegate
        transitioningDelegate = maverickActionSheetTransitioningDelegate
        
        present(maverickActionSheetViewController, animated: true, completion: nil)
        
    }
    
    
    /**
     Utility function: draws an outline around the textview container
     */
    private func styleTextViewBorder(_ inputView: UIView?) {
        
        inputView?.superview?.layer.borderColor = UIColor.maverickGrey.cgColor
        inputView?.superview?.layer.borderWidth = 1.0
        
    }
    
   
    
    
    
    /**
     Utility function to show error
     */
    private func displayErrorMessage(error : MaverickError) {
        var errorMessage = error.localizedDescription 
        if errorMessage == "" {
            errorMessage = R.string.maverickStrings.networkError()
        }
        let alert = UIAlertController(title: nil, message: errorMessage, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
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
            self.scrollviewBottomConstraint?.constant = self.view.bounds.maxY - convertedKeyboardEndFrame.minY - 50
            
            UIView.animate(withDuration: animationDuration, delay: 0.0, options: [.beginFromCurrentState , animationCurve], animations: {
                self.view.layoutIfNeeded()
            }, completion: nil)
            
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
            
            if self.isUpdatingCoverImage {
                
                self.isUpdatingCoverImage = false
                DispatchQueue.main.async {
                    
                    self.coverImage.image = resized
                    self.coverData  = data
                    ProfileEditCoverViewController.selectedId = -1
                    
                }
                
            }
            
            if self.isUpdatingAvatar {
                
                self.wipeOutAvatar = false
                self.isUpdatingAvatar = false
                DispatchQueue.main.async {
                    
                    self.avatarImage.image = resized
                    self.avatarData  = data
                    
                }
                
            }
            
        }
        
    }
    
    
    private func attemptToUploadAvatar() {
        
        if avatarData != nil || wipeOutAvatar {
            
            DispatchQueue.main.async {
                
                self.services?.globalModelsCoordinator.updateUserAvatar(withImageData: self.avatarData) {
                    
                    self.avatarData = nil
                    self.avatarLoadComplete = true
                    if self.coverData != nil || ProfileEditCoverViewController.selectedId >= 0 {
                        
                        self.attemptToUploadCover()
                        
                    }
                    
                }
                
            }
            
        }
        
    }
    
    private func attemptToUploadCover() {
        
        if ProfileEditCoverViewController.selectedId >= 0 {
            
            self.services?.globalModelsCoordinator.updateUserCover(withPreset:  ProfileEditCoverViewController.selectedId ) { error in
                
                self.coverLoadComplete = true
                
            }
            
        } else if let coverData = self.coverData {
            
            DispatchQueue.main.async {
                self.services?.globalModelsCoordinator.updateUserCoverImage(withImageData: coverData) {
                    
                    self.coverLoadComplete = true
                    
                }
            }
            
        }
        
    }
    
    fileprivate func attemptUsernameValidation(withName name: String, completionHandler: @escaping (_ isValid: Bool, _ errorMessage: String?) -> Void) {
        
        services?.apiService.validateAvailability(withUsername: name) { (response , error) in
            
            guard error == nil else {
                
                var message = error?.localizedDescription
                if message == "" {
                    message = R.string.maverickStrings.networkError()
                }
                
                completionHandler(false, message)
                return
                
            }
            
            completionHandler(true, nil)
            
        }
        
    }
    
}

extension ProfileEditProfileViewController: MaverickPickerDelegate, PostRecordViewControllerDelegate {
    
    func imageSelected(image: UIImage) {
        
        completeProfileImageUpdate(withImage: image, size: image.size)
        
    }
    
}

extension ProfileEditProfileViewController: MFMailComposeViewControllerDelegate {
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        
        controller.dismiss(animated: true)
        
    }
    
}

extension ProfileEditProfileViewController : UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField == firstNameTextInput.entryTextView {
            
            lastNameTextInput.entryTextView.becomeFirstResponder()
            
        } else if textField == lastNameTextInput.entryTextView {
            
            bioTextInput.becomeFirstResponder()
            
        } else {
            textField.resignFirstResponder()
        }
        
        return true
        
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == usernameTextInput.entryTextView {
            AnalyticsManager.Settings.trackEditUserNamePressed()
            
            usernameTextInput.characterCounter.isHidden = false
            usernameHeight.constant = 90
            
            UIView.animate(withDuration: 0.3, animations: {
                self.view.layoutIfNeeded()
            })
            
        } 
    }
    
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextFieldDidEndEditingReason) {
        
        if textField == usernameTextInput.entryTextView  {
            if var text = textField.text {
                let components = text.components(separatedBy: NSCharacterSet.whitespacesAndNewlines)
                text = components.filter { !$0.isEmpty }.joined(separator: " ")
                textField.text = text.replacingOccurrences(of: " ", with: "_")
            }
            
            usernameHeight.constant = 60
            usernameTextInput.characterCounter.isHidden = true
            
            UIView.animate(withDuration: 0.3, animations: {
                self.view.layoutIfNeeded()
            })
            
            if usernameTextInput.validationLabel.text != nil {
                
                usernameTextInput.text = loggedInUser.username
                usernameTextInput.setValidState(isValid: true)
                self.navigationItem.rightBarButtonItem?.isEnabled = true
                
            }
            
        }
        
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if textField == usernameTextInput.entryTextView {
            
            let aSet = NSCharacterSet(charactersIn:"qwertyuiopasdfghjklzxcvbnmQWERTYUIOPASDFGHJKLMNBVCXZ_-.0123456789 ").inverted
            let compSepByCharInSet = string.components(separatedBy: aSet)
            let numberFiltered = compSepByCharInSet.joined(separator: "")
            if string != numberFiltered {
                
                usernameTextInput.setValidState(isValid: false, validationText: R.string.maverickStrings.usernameCharacterValidation() )
                self.navigationItem.rightBarButtonItem?.isEnabled = false
                
            }
            
            return string == numberFiltered
        }
        
        let maxLength = 100
        let currentCharacterCount = textField.text?.count ?? 0
        
        if (range.length + range.location > currentCharacterCount) {
            return false
        }
        let newLength = currentCharacterCount + string.count - range.length
        return newLength <= maxLength
        
    }
    
}


extension ProfileEditProfileViewController: UITextViewDelegate {
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        
        if textView == bioTextInput {
            
            if loggedInUser.shouldShowVPC(){
                
                if let vc = R.storyboard.general.onboardVPCNavViewControllerId() {
                    
                    vc.modalPresentationStyle = .overFullScreen
                    present(vc, animated: true, completion: nil)
                    
                }
                
                return false
                
            } else {
                
                return true
                
            }
            
        } else {
            
            return true
            
        }
        
    }
    
    
    
}

