//
//  CreateChallengeViewController.swift
//  Maverick
//
//  Created by Garrett Fritz on 6/13/18.
//  Copyright © 2018 BeMaverick. All rights reserved.
//

import Foundation
import Photos
import AVKit
import AVFoundation
import Kingfisher

extension CreateChallengeViewController {
    
    private static func launchChallengeCreate(services : GlobalServicesContainer?, viewController : UIViewController ) {
        
        if  let user = services?.globalModelsCoordinator.loggedInUser, user.shouldShowVPC()  {
            
            if let vc = R.storyboard.general.onboardVPCNavViewControllerId() {
                
                vc.modalPresentationStyle = .overFullScreen
                viewController.present(vc, animated: true, completion: nil)
                
            }
            
            return
            
        }
        
        if let vc = R.storyboard.userGeneratedChallenge.createChallengeViewControllerId() {
            
            vc.modalPresentationStyle = .fullScreen
            if let createChallengeVC = vc.childViewControllers[safe : 0] as? CreateChallengeViewController {
                
                createChallengeVC.services = services
                
            }
            
            viewController.present(vc, animated: false, completion: nil)
            return
            
        }
        
    }
    
    static func prefetchThemes() {
        
        let urls: [URL] = DBManager.sharedInstance.getUserChallengeThemes().compactMap {
            
            if let path = $0.backgroundImage, let url = URL(string: path) {
                
                return url
                
            }
            
            return nil
            
        }
        
        //        print("🎥 start prefetching THEMES: \(urls.count)")
        ImagePrefetcher(urls: urls) { skippedResources, failedResources, completedResources in
            
            if ImagePrefetcher.logOn {
                print("🎥 prefetching THEMES Complete")
                print("🎥 THEMES : skippedResources : \(skippedResources.count)")
                print("🎥 THEMES : failedResources : \(failedResources)")
                for resource in failedResources {
                    print("🎥 THEMES : failedResource \(resource.downloadURL)")
                }
                print("🎥 THEMES : completedResources : \(completedResources.count)")
            }
            
            }.start()
        
    }
    
    static func attemptToCreateChallenge(services : GlobalServicesContainer?, viewController : UIViewController ) {
        
        CreateChallengeViewController.prefetchThemes()
        
        guard let user = services?.globalModelsCoordinator.loggedInUser, let features = user.features else { return }
        
        if features.createChallenges {
            CreateChallengeViewController.launchChallengeCreate(services: services, viewController: viewController)
            return
            
        }
        
        if let vc = R.storyboard.progression.gameWallViewControllerId() {
            
            vc.hideStatusBar = true
            vc.configure(with: "LOCKED!", description: "THIS WILL UNLOCK EVENTUALLY")
            vc.modalPresentationStyle = .overCurrentContext
            viewController.present(vc, animated: false, completion: nil)
            return
            
        }
        
    }
    
}


class CreateChallengeViewController : ViewController {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var lockedLinkImage: UIImageView!
    @IBOutlet weak var lockedCameraButton: UIButton!
    @IBOutlet weak var lockedCameraImage: UIImageView!
    @IBOutlet weak var lockedLinkButton: UIButton!
    @IBOutlet weak var attachLinkButton: UIButton!
    @IBOutlet weak var linkView: LinkView!
    @IBOutlet weak var linkCoverOverlay: UIView!
    @IBOutlet weak var counter: UILabel!
    @IBOutlet weak var counterContainer: UIView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var scrollContainer: UIView!
    @IBOutlet weak var hintLabel: UILabel!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var themeTitleLabel: UILabel!
    
    
    @IBOutlet weak var counterBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var scrollviewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var takePhotoButton: UIButton!
    @IBOutlet var viewsToHide: [UIStackView]!
    @IBOutlet weak var textFieldConstraint_bottom: NSLayoutConstraint!
    @IBOutlet weak var textFieldConstraint_top: NSLayoutConstraint!
    @IBOutlet weak var textFieldConstraint_left: NSLayoutConstraint!
    @IBOutlet weak var textFieldConstraint_right: NSLayoutConstraint!
    @IBOutlet weak var swipeCoachMark: UIImageView!
    @IBOutlet weak var flipCameraButton: UIButton!
    @IBOutlet weak var turnOnCameraButton: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var previewImage: UIImageView!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var closeLinkViewButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var addLinkButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var navigationContentView: PassthroughTouchView!
    @IBOutlet weak var addLinkTitleLabel: UILabel!
    @IBOutlet weak var entrySegmentControl: MaverickSegmentedControl!
    @IBOutlet weak var recordVideoButton: UIButton!
    
    @IBOutlet weak var deleteVideoSegmentButton: UIButton!
    
    @IBOutlet weak var cameraIconView: UIView!
    @IBOutlet weak var libraryIconView: UIView!
    @IBOutlet weak var flashButton: UIButton!
    @IBOutlet weak var videoFlipCameraButton: UIButton!
    @IBOutlet weak var countdownButton: UIButton!
    @IBOutlet weak var videoCameraControlsGroup: UIStackView!
    @IBOutlet weak var videoCameraPreviewView: UIView!
    @IBOutlet weak var videoEditorContentView: UIView!
    
    @IBOutlet var textChallengeViews: [UIView]!
    @IBOutlet var videoChallengeViews: [UIView]!
    
    // MARK: - Private Properties
    
    private var awaitingModeration = false
    private var initializedView = false
    private var captureSession: AVCaptureSession!
    private var loggedInUser : User!
    private var hasPhoto = false
    private var maxChar = 150
    private var previewLayer: AVCaptureVideoPreviewLayer?
    private var themes : [Theme]?
    private var pageViewController : CreateChallengePageViewController?
    private var isInitialized = false
    private var oldTextHeight : CGFloat = 0
    private var previousIncrement = -1000
    /// A reference to the `UIKeyboardWillShow` notification
    private var keyboardWillShowId: NSObjectProtocol?
    /// A reference to the `UIKeyboardWillHide` notification
    private var keyboardWillHideId: NSObjectProtocol?
    
    /// The current state of the entry.
    lazy private var currentState = states[TextEntryState.identifier]!
    
    /// An array of all possible states for the view controller.
    lazy private var states = [
        TextEntryState.identifier: TextEntryState(createChallengeViewController: self),
        VideoEntryState.identifier: VideoEntryState(createChallengeViewController: self)
    ]
    
    
    // MARK: - Public Properties
    
    let cameraOutput = AVCapturePhotoOutput()
    /// The `GlobalServicesContainer` that maintains access to global services
    var services: GlobalServicesContainer?
    var maxFontSize : CGFloat = 38.0
    var cameraPosition: AVCaptureDevice.Position = .back
    var titles : [String] = []
    
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        
        hasNavBar = false
        super.viewDidLoad()
        
        configureData()
        configureView()
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let vc = R.segue.createChallengeViewController.paginationSegue(segue: segue)?.destination {
            
            pageViewController = vc
            pageViewController?.services = services
            
        }
        
        if let vc = R.segue.createChallengeViewController.editChallengeSegue(segue: segue)?.destination {
            
            vc.image = prepareImage()
            
            vc.imageText = textView.text
            
            vc.selectedLink = linkView.selectedLink
            
            if let theme = themes?[safe : pageControl.currentPage] {
                
                vc.configureChallengeSettings(hasPhoto: !previewImage.isHidden, themeName: theme.name, charCount: textView.text.count)
                
            }
            vc.services = services
            
        }
        
    }
    
    private func toggleLinkLock(isHidden : Bool){
        
        lockedLinkButton.isHidden = isHidden
        lockedLinkImage.isHidden = isHidden
        attachLinkButton.isEnabled = isHidden
        
    }
    
    private func toggleCameraLock(isHidden : Bool){
        
        lockedCameraButton.isHidden = isHidden
        lockedCameraImage.isHidden = isHidden
        turnOnCameraButton.isEnabled = isHidden
        
    }
        
    @IBAction func lockedLinkButtonTapped(_ sender: Any) {
   
        if let vc = R.storyboard.progression.gameWallViewControllerId(), let reward = services?.globalModelsCoordinator.isRewardAvailable(rewardKey: .linkChallenge) {
           
            vc.hideStatusBar = true
            vc.reward = reward
            vc.modalPresentationStyle = .overFullScreen
            present(vc, animated: false, completion: nil)
       
        }
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
       
        
        attachLinkButton.isHidden = false
        let linkAvailable = services?.globalModelsCoordinator.isRewardAvailable(rewardKey: .linkChallenge)?.completed ?? false
        toggleLinkLock(isHidden: linkAvailable)
        
         let cameraAvailable = services?.globalModelsCoordinator.isRewardAvailable(rewardKey: .imageChallenge)?.completed ?? false
        toggleCameraLock(isHidden: cameraAvailable)
        
        
        // toggle the link functionality for testing/debug 
//
//        toggleLinkLock(isHidden: true)
//        attachLinkButton.isHidden = false
//        attachLinkButton.isEnabled = true
        
        // use this line to hide the video option on or off
        entrySegmentControl.superview?.isHidden = true
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(keyboardWillShowId as Any)
        NotificationCenter.default.removeObserver(keyboardWillHideId as Any)
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        if !initializedView {
            
            initializedView = true
            
            guard let theme = themes?[safe: 0] else { return }
            
            pageControl.currentPage = 0
            if var fontColor = theme.fontColor {
                
                var locked = false
                if let key = theme.rewardKey, let reward = services?.globalModelsCoordinator.isRewardAvailable(rewardKey: key) {
                    
                    locked = !reward.completed
                    
                }
                
                if locked {
                    
                    fontColor = "#FFFFFF"
                    
                }
                
                textView.textColor = UIColor(rgba: fontColor)
                hintLabel.textColor = UIColor(rgba: fontColor)
                themeTitleLabel.textColor = UIColor(rgba: fontColor)
                
            }
            theme.setFont(forLabel: hintLabel, textView: textView)
            if theme.allCaps() {
                //when setting text like this, it resets the cursor to the end, kindof annoying when editing the middle of a paragraph, so record cursor position before change and set it back
                var arbitraryValue: Int = textView.text.count - 1
                if let selectedRange = textView.selectedTextRange {
                    
                    arbitraryValue = textView.offset(from: textView.beginningOfDocument, to: selectedRange.start)
                    
                }
                
                textView.text = textView.text.uppercased()
                hintLabel.text = R.string.maverickStrings.createChallengeTypeHint().uppercased()
                
                if let newPosition = textView.position(from: textView.beginningOfDocument, offset: arbitraryValue) {
                    textView.selectedTextRange = textView.textRange(from: newPosition, to: newPosition)
                }
                
            } else {
                
                hintLabel.text = R.string.maverickStrings.createChallengeTypeHint()
                
            }
            
            updatePadding(theme: theme)
            updateFont(theme : theme)
            updateJustification(theme : theme)
            
            textView.addShadow(alpha: theme.fontShadow ? 0.75 : 0.0)
            hintLabel.addShadow(alpha: theme.fontShadow ? 0.75 : 0.0)
            
            themeTitleLabel.text = theme.name
            
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    
    // MARK: - Superclass Overrides
    
    override func backButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    
    // MARK: - Private Functions
    
    private func activatesScanner() {
        
        guard captureSession == nil else {
            
            if captureSession?.isRunning == false {
                
                captureSession?.startRunning()
                
            }
            previewLayer?.isHidden = false
            return
            
        }
        
        captureSession = AVCaptureSession()
        captureSession.sessionPreset = .photo
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
        let videoInput: AVCaptureDeviceInput
        
        do {
            
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
            
        } catch {
            return
        }
        
        if (captureSession.canAddInput(videoInput)) {
            captureSession.addInput(videoInput)
        } else {
            
            return
        }
        
        captureSession.addOutput(cameraOutput)
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer?.frame = containerView.layer.bounds
        previewLayer?.videoGravity = .resizeAspectFill
        if let previewLayer = previewLayer {
            
            previewImage.layer.insertSublayer(previewLayer, at: 0)
            
        }
        
        captureSession.startRunning()
        
    }
    
    private func attemptScanner() {
        
        //Camera
        AVCaptureDevice.requestAccess(for: AVMediaType.video) { response in
            if response {
                
                DispatchQueue.main.async {
                    
                    self.activatesScanner()
                    
                }
                
            } else {
                
                let alert = UIAlertController(title: "Need Permission", message: "Please go to your Settings and grant permission for us to use your camera", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Go to Settings", style: .default){action in
                    guard let settingsUrl = URL(string: UIApplicationOpenSettingsURLString) else {
                        return
                    }
                    
                    if UIApplication.shared.canOpenURL(settingsUrl) {
                        UIApplication.shared.open(settingsUrl, options: [:], completionHandler: nil)
                    }
                })
                
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { result in
                    
                    
                })
                self.present(alert, animated: true, completion: nil)
                
                
            }
            
        }
        
    }
    
    private func configureData() {
        
        guard let user = services?.globalModelsCoordinator.loggedInUser else {
            
            dismiss(animated: true, completion: nil)
            return
            
        }
        
        loggedInUser = user
        themes = DBManager.sharedInstance.getUserChallengeThemes()
        
        
        pageViewController?.configure(with: DBManager.sharedInstance.getUserChallengeThemes(), loggedInUser: loggedInUser, delegate: self)
        
    }
    
    private func prepareImage() -> UIImage {
        
        for subView in viewsToHide {
            subView.isHidden = true
        }
        attachLinkButton.isHidden = true
        lockedLinkImage.isHidden = true
        slider.superview?.isHidden = true
        takePhotoButton.isEnabled = false
        flipCameraButton.isEnabled = false
        
        
        let image = UIImage(view: scrollContainer)
        
        return image
        
    }
    
    private func dismissCoachMark() {
        
        guard !swipeCoachMark.isHidden else { return }
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5, execute: {
            
            UIView.animate(withDuration: 0.25, animations: {  [weak self] in
                
                self?.swipeCoachMark.alpha = 0.0
                
                }, completion: { [weak self]  (result) in
                    
                    self?.swipeCoachMark.isHidden = true
                    
            })
            
        })
        
    }
    
    private func updateCharCounter(newCount : Int? = nil) {
        
        counterContainer.isHidden = maxChar == 0
        var charCount = 0
        
        if let calcCharCount = textView.text?.count {
            charCount = calcCharCount
        }
        if let newCount = newCount {
            charCount = newCount
        }
        if charCount >= maxChar {
            counter.textColor = UIColor(rgba: "D0021B")
        } else if CGFloat(charCount) >= (120.0 / 150.0 * CGFloat(maxChar)) {
            counter.textColor = UIColor(rgba: "F5A623")
        } else {
            counter.textColor = UIColor(rgba: "2C2C2C")
        }
        let value = "\(charCount) / \(maxChar)"
        counter.text = value
        
    }
    
    private func configureView() {
        
        entrySegmentControl.plain = false
        entrySegmentControl.setTitle("TEXT", forSegmentAt: 0)
        entrySegmentControl.setTitle("VIDEO", forSegmentAt: 1)
        entrySegmentControl.selectedSegmentIndex = 0
        
        linkView.delegate = self
        counterContainer.layer.cornerRadius = 6.0
        counterContainer.layer.borderWidth = 0.0
        textView.tintColor = UIColor.MaverickPrimaryColor
        swipeCoachMark.isHidden = !DBManager.sharedInstance.shouldSeeTutorial(tutorialVersion: .ugc_swipe)
        
        pageControl.isHidden = true
        textView.spellCheckingType = .no
        pageControl.pageIndicatorTintColor = UIColor.lightGray
        pageControl.currentPageIndicatorTintColor = UIColor.MaverickBadgePrimaryColor
        pageControl.currentPage = 0
        takePhotoButton.imageView?.contentMode = .scaleAspectFit
        closeLinkViewButton.tintColor = UIColor.MaverickBadgePrimaryColor
        
        showNavBar(withTitle: "Create Challenge")
        
        pageControl.numberOfPages = themes?.count ?? 0
        
        setDefaultNavigationItems()
        textView.delegate = self
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(userDidTapLabel(tapGestureRecognizer:)))
        containerView.addGestureRecognizer(tapGesture)
        
        maxFontSize = textView.font!.pointSize
        view.layoutIfNeeded()
        if let theme = themes?[safe: 0] {
            
            updatePadding(theme: theme)
            updateFont(theme : theme)
            
        }
        updateTextFont()
        observeKeyboardWillShow()
        observeKeyboardWillHide()
        
    }
    
    private func updateJustification(theme: Theme) {
        
        if let justification = theme.textJustification {
            
            switch justification {
                
            case "justified":
                textView.textAlignment = .justified
            case "left":
                textView.textAlignment = .left
            case "right":
                textView.textAlignment = .right
            case "center":
                textView.textAlignment = .center
            default:
                textView.textAlignment = .center
                
            }
            
        } else {
            
            textView.textAlignment = .center
            
        }
        
    }
    
    private func updateFont(theme : Theme) {
        
        maxChar = theme.maxCharacters
        maxFontSize = CGFloat(theme.maxFontSize)
        updateCharCounter()
    }
    
    private func updatePadding(theme : Theme) {
        
        let left = CGFloat(theme.padding_left) / 100.0
        let right = CGFloat(theme.padding_right) / 100.0
        let bottom = -CGFloat(theme.padding_bottom) / 100.0
        let top = CGFloat(theme.padding_top) / 100.0
        
        textFieldConstraint_top.constant = previewImage.frame.width * top
        textFieldConstraint_bottom.constant = previewImage.frame.width * bottom
        textFieldConstraint_right.constant = previewImage.frame.width * right
        textFieldConstraint_left.constant = previewImage.frame.width * left
        
        textView.setNeedsUpdateConstraints()
        view.layoutIfNeeded()
        
    }
    
    private func allowedToCreateChallenge() -> Bool {
        
        guard let theme = themes?[safe: pageControl.currentPage] else { return true }
        if let key = theme.rewardKey, let reward = services?.globalModelsCoordinator.isRewardAvailable(rewardKey: key) {
            
            if !reward.completed {
                
                if let vc = R.storyboard.progression.gameWallViewControllerId() {
                    
                    vc.reward = reward
                    vc.hideStatusBar = true
                    vc.modalPresentationStyle = .overCurrentContext
                    present(vc, animated: false, completion: nil)
                    return false
                    
                }
                
            }
        }
        
        return true
        
    }
    
    private func takePicture() -> Bool {
        
        if captureSession?.isRunning ?? false {
            
            previewLayer?.isHidden = true
            textView.isUserInteractionEnabled = false
            takePhotoButton.isEnabled = false
            flipCameraButton.isEnabled = false
            if let theme = themes?[safe : pageControl.currentPage] {
                
                slider.superview?.isHidden = !theme.allowAlpha
                
            }
            let settings = AVCapturePhotoSettings()
            let previewPixelType = settings.availablePreviewPhotoPixelFormatTypes.first!
            let previewFormat = [
                kCVPixelBufferPixelFormatTypeKey as String: previewPixelType,
                kCVPixelBufferWidthKey as String: 160,
                kCVPixelBufferHeightKey as String: 160
            ]
            settings.previewPhotoFormat = previewFormat
            turnOnCameraButton.isSelected = true
            capturePhoto()
            captureSession.stopRunning()
            
            return true
            
        }
        
        return false
    }
    
    private func findLongestWord(word: String) -> String? {
        if let longestWord = word.components(separatedBy: " ").max(by: { $1.count > $0.count }) {
            return longestWord
        }
        
        return nil
    }
    
    
    // MARK: - IBActions
    
    
    @IBAction func timerButtonTapped(_ sender: Any) {
    }
    
    @IBAction func flipCameraButtonTapped(_ sender: Any) {
    }
    
    
    @IBAction func flashButtonTapped(_ sender: Any) {
    }
    
    @IBAction func libraryIconButtonPressed(_ sender: Any) {
        // do your thing
    }
    
    
    
    @IBAction func recordVideoButtonPressed(_ sender: Any) {
        
        // transition to recording state
    }
    
    @IBAction func deleteVideoSegmentButtonPressed(_ sender: Any) {
        
    }
    
    
    @IBAction func entrySegmentControlValueChanged(_ sender: Any) {
        
        if (entrySegmentControl.selectedSegmentIndex == 0) && currentState is TextEntryState ||
            (entrySegmentControl.selectedSegmentIndex == 1) && currentState is VideoEntryState {
            return
        } else {
            transitionToState(matching: (entrySegmentControl.selectedSegmentIndex == 0 ? TextEntryState.identifier : VideoEntryState.identifier))
        }
        
    }
    
    @IBAction func closeLinkViewButtonPressed(_ sender: Any) {
        
        AnalyticsManager.CreateChallenge.trackCreateChallengeClearLinkPressed()
        
        linkView.isHidden = true
        linkCoverOverlay.isHidden = true
        setDefaultNavigationItems()
        linkView.clearLink()
        linkView.linkEntryField.text = nil
        attachLinkButton.isSelected = false
        
        if currentState is VideoEntryState {
            videoCameraControlsGroup.isHidden = false
        }
        
    }
    
    
    @IBAction func addLinkButtonPressed(_ sender: Any) {
        
        AnalyticsManager.CreateChallenge.trackCreateChallengeCommitLinkPressed()
        linkView.isHidden = true
        linkCoverOverlay.isHidden = true
        setDefaultNavigationItems()
        attachLinkButton.isSelected = linkView.selectedLink != nil
        
        if currentState is VideoEntryState {
            videoCameraControlsGroup.isHidden = false
        }
        
    }
    
    
    @IBAction func nextButtonPressed(_ sender: Any) {
        
        view.endEditing(true)
        
        AnalyticsManager.CreateChallenge.trackCreateThemePressed()
        stopEditing()
        updateTextFont()
        
        guard allowedToCreateChallenge() else { return }
        
        let spaceRemoved = textView.text.replacingOccurrences(of: " ", with: "")
        
        if maxChar > 0 && textView.text.count > maxChar {
            
            let message = "Looks like you wrote too much for this theme, try cutting it down or swipe left and right to change themes."
            AnalyticsManager.CreateChallenge.trackCreateFail(apiFailure: false, reason: message)
            if let vc = R.storyboard.main.errorDialogViewControllerId() {
                
                vc.hideStatusBar = true
                vc.setValues(description : message)
                vc.modalPresentationStyle = .overCurrentContext
                present(vc, animated: false, completion: nil)
                return
                
            }
            
            return
            
        }
        guard textView.text.count >= 9 && spaceRemoved.count > 4 else {
            
            let message = "Looks like you didn’t write a Challenge! You must have a minimum of 9 characters."
            AnalyticsManager.CreateChallenge.trackCreateFail(apiFailure: false, reason: message)
            if let vc = R.storyboard.main.errorDialogViewControllerId() {
                
                vc.hideStatusBar = true
                vc.setValues(description : message)
                vc.modalPresentationStyle = .overCurrentContext
                present(vc, animated: false, completion: nil)
                return
                
            }
            
            return
            
        }
        
        guard !awaitingModeration else { return }
        awaitingModeration = true
        services?.globalModelsCoordinator.moderateText(text: textView.text, completionHandler: { (replacement) in
            
            self.awaitingModeration = false
            guard let replacement = replacement else {
                
                self.performSegue(withIdentifier: R.segue.createChallengeViewController.editChallengeSegue, sender: self)
                return
                
            }
            
            self.textView.text = replacement
            let message = R.string.maverickStrings.userGeneratedChallengeModeration()
            AnalyticsManager.CreateChallenge.trackCreateFail(apiFailure: false, reason: message)
            if let vc = R.storyboard.main.errorDialogViewControllerId() {
                
                vc.hideStatusBar = true
                vc.setValues(description : message)
                vc.modalPresentationStyle = .overCurrentContext
                self.present(vc, animated: false, completion: nil)
                return
                
            }
        })
        
    }
    
    @IBAction func attachLinkButtonTapped(_ sender: Any) {
        
        AnalyticsManager.CreateChallenge.trackCreateChallengeCreateLinkPressed()
        
        if currentState is TextEntryState {
            stopEditing()
        }
        
        linkView.isHidden = false
        linkCoverOverlay.isHidden = false
        
        nextButton.isHidden = true
        backButton.isHidden = true
        addLinkButton.isHidden = false
        closeLinkViewButton.isHidden = false
        navigationContentView.backgroundColor = .white
        addLinkTitleLabel.isHidden = false
        
        if currentState is VideoEntryState {
            videoCameraControlsGroup.isHidden = true
        }
        
        linkView.linkEntryField.becomeFirstResponder()
        
    }
    
    @IBAction func infoTapped(_ sender: Any) {
        
        AnalyticsManager.CreateChallenge.trackCreateLearnMorePressed()
        
        guard let path = Variables.Features.createChallengeTutorialPath.stringValue() else {
            
            log.verbose("create challenge not found")
            return
            
        }
        
        let videoURL = URL(string: path)
        let player = AVPlayer(url: videoURL!)
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        self.present(playerViewController, animated: true) {
            
            playerViewController.player!.play()
            
        }
        
    }
    
    @IBAction func lockedCameraTapped(_ sender: Any) {
        
        if let vc = R.storyboard.progression.gameWallViewControllerId(), let reward = services?.globalModelsCoordinator.isRewardAvailable(rewardKey: .imageChallenge) {
            
            vc.hideStatusBar = true
            vc.reward = reward
            vc.modalPresentationStyle = .overFullScreen
            present(vc, animated: false, completion: nil)
        }
        
    }
    
    @IBAction func sliderChanged(_ sender: Any) {
        
        pageViewController?.view.alpha = CGFloat(slider.value)
        
    }
    
    @IBAction func cameraTapped(_ sender: Any) {
        dismissCoachMark()
        AnalyticsManager.CreateChallenge.trackCameraPressed()
        guard let theme = themes?[pageControl.currentPage] else { return }
        stopEditing()
        
        if takePicture() {
            
            return
            
        }
        
        if (previewImage.image != nil ) {
            
            previewImage.image = nil
            previewLayer?.isHidden = true
            turnOnCameraButton.isSelected = false
            slider.superview?.isHidden = true
            pageViewController?.view.alpha = 1.0
            return
            
        }
        
        flipCameraButton.isEnabled = true
        takePhotoButton.isEnabled = true
        
        if theme.allowAlpha {
            
            slider.value = 0.75
            pageViewController?.view.alpha = 0.75
            
        } else {
            
            pageViewController?.view.alpha = 1
            
        }
        
        previewImage.transform = CGAffineTransform(scaleX: 1, y: 1)
        previewLayer?.isHidden = false
        attemptScanner()
        
    }
    
    @IBAction func pageControlChanged(_ sender: Any) {
        dismissCoachMark()
        AnalyticsManager.CreateChallenge.trackThemeChanged()
        stopEditing()
        
        let index = pageControl.currentPage
        if let firstViewController = pageViewController?.orderedViewControllers()[safe: index] {
            
            
            let direction = (pageViewController?.getSelectedIndex() ?? 0) > index ? UIPageViewControllerNavigationDirection.reverse : UIPageViewControllerNavigationDirection.forward
            pageViewController?.setViewControllers([firstViewController],
                                                   direction: direction,
                                                   animated: true,
                                                   completion: nil)
        }
        
    }
    
    
    @IBAction func flipCamera(_ sender: Any) {
        
        AnalyticsManager.CreateChallenge.trackCameraFlipped()
        stopEditing()
        
        if let session = captureSession {
            
            let currentCameraInput: AVCaptureInput = session.inputs[0]
            session.removeInput(currentCameraInput)
            var newCamera: AVCaptureDevice
            newCamera = AVCaptureDevice.default(for: AVMediaType.video)!
            
            if (currentCameraInput as! AVCaptureDeviceInput).device.position == .back {
                cameraPosition = .front
                newCamera = self.cameraWithPosition(.front)!
                
                
            } else {
                cameraPosition = .back
                newCamera = self.cameraWithPosition(.back)!
                
                
            }
            do {
                try self.captureSession?.addInput(AVCaptureDeviceInput(device: newCamera))
            }
            catch {
                print("error: \(error.localizedDescription)")
            }
            
        }
    }
    
    @IBAction func navigationBackButtonPressed(_ sender: Any) {
        backButtonTapped(sender)
        
    }
    
    
    // MARK: - Public Functions
    
    /**
     Transitions the view and functionality to a new state.
     - paramater identifier: The name of the state to which a transition should be made.
     */
    public func transitionToState(
        matching identifier: AnyHashable) {
        
        let state = states[identifier]!
        currentState = state
        currentState.configureViewForState()
        
    }
    
    func cameraWithPosition(_ position: AVCaptureDevice.Position) -> AVCaptureDevice? {
        let deviceDescoverySession = AVCaptureDevice.DiscoverySession.init(deviceTypes: [AVCaptureDevice.DeviceType.builtInWideAngleCamera], mediaType: AVMediaType.video, position: AVCaptureDevice.Position.unspecified)
        
        for device in deviceDescoverySession.devices {
            if device.position == position {
                return device
            }
        }
        return nil
    }
    
    
    func setDefaultNavigationItems() {
        
        backButton.isHidden = false
        nextButton.isHidden = false
        closeLinkViewButton.isHidden = true
        addLinkButton.isHidden = true
        addLinkTitleLabel.isHidden = true
        navigationContentView.backgroundColor = .clear
        
    }
    
    
    func updateTextFont(bySize size: CGFloat? = nil) {
        
        if (textView.text.isEmpty || textView.bounds.size.equalTo(CGSize.zero)) {
            return;
        }
        
        guard let theme = themes?[safe : pageControl.currentPage] else { return }
        
        if theme.allCaps() {
            
            //when setting text like this, it resets the cursor to the end, kindof annoying when editing the middle of a paragraph, so record cursor position before change and set it back
            var arbitraryValue: Int = textView.text.count - 1
            if let selectedRange = textView.selectedTextRange {
                
                arbitraryValue = textView.offset(from: textView.beginningOfDocument, to: selectedRange.start)
                
            }
            
            textView.text = textView.text.uppercased()
            
            if let newPosition = textView.position(from: textView.beginningOfDocument, offset: arbitraryValue) {
                textView.selectedTextRange = textView.textRange(from: newPosition, to: newPosition)
            }
            
        }
        
        if let size = size {
            
            stopEditing()
            
            textView.font = textView.font!.withSize(textView.font!.pointSize + size)
            
        } else {
            
            let textViewSize = textView.frame.size;
            let fixedWidth = textViewSize.width;
            let expectSize = textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat(MAXFLOAT)));
            var expectFont = textView.font;
            var increment = 0
            
            let maxHeight = containerView.frame.height - textFieldConstraint_top.constant + textFieldConstraint_bottom.constant
            //first try to shrink text to fit
            if (expectSize.height > maxHeight) {
                while (textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat(MAXFLOAT))).height > maxHeight) {
                    increment = increment - 1
                    expectFont = textView.font!.withSize(textView.font!.pointSize - 1)
                    textView.font = expectFont
                    
                }
                
            }
            else {
                
                //otherwise grow to fit
                while (textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat(MAXFLOAT))).height < maxHeight && textView.font!.pointSize < maxFontSize) {
                    expectFont = textView.font
                    increment = increment + 1
                    textView.font = textView.font!.withSize(textView.font!.pointSize + 1)
                    
                }
                
            }
            
            //force longest word to fit in space
            if let longestword = findLongestWord(word: textView.text) {
                
                var size: CGSize = longestword.size(withAttributes: [NSAttributedStringKey.font: textView.font!])
                while size.width > textView.frame.width - 10 {
                    
                    increment = increment - 1
                    expectFont = textView.font!.withSize(textView.font!.pointSize - 1)
                    textView.font = expectFont
                    size = longestword.size(withAttributes: [NSAttributedStringKey.font: textView.font!])
                    
                }
                
            }
            
            //      don't bounce back and forth between sizes
            //      print("💯 text size updated by: \(increment) to : \(expectFont?.pointSize)")
            
            textView.font = expectFont;
            previousIncrement = increment
            updateCharCounter()
            view.layoutIfNeeded()
            
        }
        
    }
    
    @objc func userDidTapLabel(tapGestureRecognizer: UITapGestureRecognizer) {
        
        dismissCoachMark()
        
        if takePicture() {
            
            return
            
        }
        
        guard allowedToCreateChallenge() else {
            
            if let theme = themes?[safe: pageControl.currentPage] {
                
            }
            
            return
            
        }
        
        
        if textView.isFirstResponder {
            
            stopEditing()
            return
            
        }
        
        textView.becomeFirstResponder()
        textView.isUserInteractionEnabled = true
        hintLabel.isHidden = true
        
    }
    
    func stopEditing() {
        
        textView.resignFirstResponder()
        textView.isUserInteractionEnabled = false
        let rightButton = UIBarButtonItem(title: R.string.maverickStrings.next(), style: .plain, target: self, action: #selector(nextButtonPressed(_:)))
        
        navigationItem.rightBarButtonItem = rightButton
        
        if textView.text.isEmpty {
            
            var locked = false
            
            if let theme = themes?[safe: pageControl.currentPage], let key = theme.rewardKey, let reward = services?.globalModelsCoordinator.isRewardAvailable(rewardKey: key) {
                
                locked = !reward.completed
                
            }
            
            hintLabel.isHidden = locked
            
        }
        
    }
    
}

extension CreateChallengeViewController : AVCapturePhotoCaptureDelegate {
    
    func capturePhoto() {
        
        let settings = AVCapturePhotoSettings()
        let previewPixelType = settings.availablePreviewPhotoPixelFormatTypes.first!
        let previewFormat = [kCVPixelBufferPixelFormatTypeKey as String: previewPixelType,
                             kCVPixelBufferWidthKey as String: 160,
                             kCVPixelBufferHeightKey as String: 160]
        settings.previewPhotoFormat = previewFormat
        
        self.cameraOutput.capturePhoto(with: settings, delegate: self)
        
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photoSampleBuffer: CMSampleBuffer?, previewPhoto previewPhotoSampleBuffer: CMSampleBuffer?, resolvedSettings: AVCaptureResolvedPhotoSettings, bracketSettings: AVCaptureBracketedStillImageSettings?, error: Error?) {
        if let error = error {
            print(error.localizedDescription)
        }
        
        if let sampleBuffer = photoSampleBuffer, let previewBuffer = previewPhotoSampleBuffer, let dataImage = AVCapturePhotoOutput.jpegPhotoDataRepresentation(forJPEGSampleBuffer: sampleBuffer, previewPhotoSampleBuffer: previewBuffer) {
            
            if cameraPosition == .front
            {
                
                previewImage.transform = CGAffineTransform(scaleX: -1, y: 1)
                
            } else {
                
                
                previewImage.transform = CGAffineTransform(scaleX: 1, y: 1)
            }
            previewImage.image = UIImage(data: dataImage)
            
        }
        
    }
    
}

extension CreateChallengeViewController : UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        updateTextFont()
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        guard maxChar > 0 else { return true }
        let originalCount = textView.text?.count ?? 0
        var newCount = text.count
        
        if newCount == 0 {
            newCount = -range.length
        }
        guard newCount >= 0 else { return true }
        newCount = originalCount + newCount
        
        if newCount > maxChar {
            return false
        } else {
            updateCharCounter(newCount: newCount)
        }
        
        return true
    }
}

extension CreateChallengeViewController : PagerViewControllerDelegate {
    
    func paginatedViewController(paginatedViewController: PagerViewController, didUpdatePageCount count: Int) {
        
        pageControl.numberOfPages = count
        
    }
    
    func paginatedViewController(paginatedViewController: PagerViewController, didUpdatePageIndex index: Int) {
        
        stopEditing()
        dismissCoachMark()
        guard let theme = themes?[safe: index] else { return }
        pageControl.currentPage = index
        
        if let backColor = theme.backgroundColor {
            
            previewImage.backgroundColor = UIColor(rgba: backColor)
            
        }
        if let fontColor = theme.fontColor {
            
            var locked = false
            if let key = theme.rewardKey, let reward = services?.globalModelsCoordinator.isRewardAvailable(rewardKey: key) {
                
                locked = !reward.completed
            
            }
            
            hintLabel.isHidden = !textView.text.isEmpty || locked
            textView.isHidden = locked
            
            textView.textColor = UIColor(rgba: fontColor)
            hintLabel.textColor = UIColor(rgba: fontColor)
            themeTitleLabel.textColor = UIColor(rgba: fontColor)
            
            if previewImage.image != nil || !(previewLayer?.isHidden ?? true) {
                
                
                if theme.allowAlpha {
                    
                    if !takePhotoButton.isEnabled {
                        
                        slider.superview?.isHidden = false
                        
                    }
                    
                    slider.value = 0.75
                    pageViewController?.view.alpha = 0.75
                    
                } else {
                    
                    slider.superview?.isHidden = true
                    pageViewController?.view.alpha = 1
                    
                }
                
                
            } else {
                
                slider.superview?.isHidden = true
                pageViewController?.view.alpha = 1
                
            }
            
        }
        
        theme.setFont(forLabel: hintLabel, textView: textView)
        
        if theme.allCaps() {
            
            textView.text = textView.text.uppercased()
            hintLabel.text = R.string.maverickStrings.createChallengeTypeHint().uppercased()
            
        } else {
            
            hintLabel.text = R.string.maverickStrings.createChallengeTypeHint()
            
        }
        
        
        updatePadding(theme: theme)
        updateFont(theme : theme)
        updateJustification(theme: theme)
        
        textView.addShadow(alpha: theme.fontShadow ? 0.75 : 0.0)
        hintLabel.addShadow(alpha: theme.fontShadow ? 0.75 : 0.0)
        themeTitleLabel.text = theme.name
        updateTextFont()
        
    }
    
}


class CreateChallengePageViewController : PagerViewController {
    
    private var loggedInUser : User!
    private var themes : [Theme] = []
    var services: GlobalServicesContainer?
    
    func configure(with themes : [Theme], loggedInUser : User, delegate : PagerViewControllerDelegate) {
        
        self.pageDelegate = delegate
        self.loggedInUser = loggedInUser
        self.themes = themes
        
        vcs = []
        for theme in themes {
            
            vcs?.append(self.newViewController(theme, loggedInUser: loggedInUser))
            
        }
        
        if let firstViewController = orderedViewControllers().first {
            setViewControllers([firstViewController],
                               direction: .forward,
                               animated: true,
                               completion: nil)
        }
        
        pageDelegate?.paginatedViewController(paginatedViewController: self, didUpdatePageCount: orderedViewControllers().count)
        
        
    }
    private var vcs : [UIViewController]?
    override func orderedViewControllers() -> [UIViewController] {
        
        if vcs == nil {
            vcs = []
            for theme in themes {
                
                vcs?.append(self.newViewController(theme, loggedInUser: loggedInUser))
                
            }
            
        }
        
        return vcs ?? []
        
    }
    
    private func newViewController(_ theme: Theme, loggedInUser : User) -> UIViewController {
        
        if let vc = R.storyboard.userGeneratedChallenge.onboardPageId() {
            
            if let path = theme.backgroundImage, let url = URL(string: path) {
                
                var locked = false
                if let key = theme.rewardKey, let reward = services?.globalModelsCoordinator.isRewardAvailable(rewardKey: key) {
                    
                    locked = !reward.completed
                    
                }
                
                vc.configure(with: url, locked : locked)
                
            }
            
            return vc
        }
        
        return UIViewController()
    }
}

extension CreateChallengeViewController {
    
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
            
            if self.view.bounds.maxY - convertedKeyboardEndFrame.minY == 0 {
                
                self.scrollView.scrollToTop(animated: false)
                
            }
            
            let rawAnimationCurve = animCurve.uint32Value << 16
            let animationCurve = UIViewAnimationOptions(rawValue: UInt(rawAnimationCurve))
            self.scrollviewBottomConstraint?.constant = self.view.bounds.maxY - convertedKeyboardEndFrame.minY
            
           
            UIView.animate(withDuration: animationDuration, delay: 0.0, options: [.beginFromCurrentState , animationCurve], animations: {
                self.view.layoutIfNeeded()
            }, completion: nil)
            
        }
        
    }
    
}

extension CreateChallengeViewController : LinkViewDelegate {
    
    func linkUpdated(url: URL?, bottomExpanded: Bool) {
    }
    
    func commitToLink() {
        addLinkButtonPressed(self)
    }
    
}
