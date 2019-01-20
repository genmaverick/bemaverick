//
//  PostMetadataViewController.swift
//  BeMaverick
//
//  Created by David McGraw on 12/15/17.
//  Copyright © 2017 BeMaverick. All rights reserved.
//

import UIKit
//import SCRecorder

class PostMetadataViewController: PostRecordParentViewController {
    
    // MARK: - IBOutlets
    
    /// The main content scroll view
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var coachMarkView: UIView!
    
    @IBOutlet weak var previewContainer: UIView!
    @IBOutlet weak var upperNavBar: UIView!
    @IBOutlet weak var coachMarkLabel: UILabel!
    
    @IBOutlet weak var coverActivityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var coachMarkTopConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var progressContainer: UIView!
    
    @IBOutlet weak var progressLabel: LoadingLabel!
    
    @IBOutlet weak var progressBar: UIProgressView!
    /// A button over the preview image
    @IBOutlet weak var coverImageButton: UIButton!
    
    /// A button under the preview
    @IBOutlet weak var changeCoverImageButton: UIButton!
    
    /// The text view for the description
    @IBOutlet weak var descriptionTextView: UITextView!
    
    @IBOutlet weak var mentionAutoCompleteview: MaverickAutoCompleteView!
    
    /// Facebook share
    @IBOutlet weak var facebookShareToggle: UISwitch?
    
    /// Twitter share
    @IBOutlet weak var twitterShareToggle: UISwitch?
    
    /// Instagram share
    @IBOutlet weak var instagramShareToggle: UISwitch?
    
    /// Share options
    @IBOutlet weak var shareContentView: UIView!
    
    /// Used to submit the response
    @IBOutlet weak var postButton: UIButton!
    
    /// Used to cancel the flow
    @IBOutlet weak var cancelButton: UIButton!
    
    // MARK: - IBActions
    
    @IBAction func postButtonTapped(_ sender: Any) {
        
        trackPostButtonTapped()
        guard finishedProcessing(allow : true) else { return }
        handlePostButtonTapped()
        
    }
    
    private func finishedProcessing(allow : Bool) -> Bool {
        
        if !progressContainer.isHidden {
            
            if let vc = R.storyboard.main.errorDialogViewControllerId() {
                
                var message = "We are still processing your video.\n\nFill out a description and add some tags while you wait!"
                var main = "Hold On!"
                
                if allow {
                   
                    message = "We are processing your video. You can go to your profile to see the status.\n\nPlease do not close the app until we have completed processing your video."
                    main = "Got it"
                    vc.delegate = self
                    
                }
                
                vc.setValues(description: message, title: main)
                vc.modalPresentationStyle = .overCurrentContext
                present(vc, animated: false, completion: nil)
                return false
                
            }
            
        }
        
        return true
        
    }
    @IBAction func backButtonTapped(_ sender: Any) {
        
        guard finishedProcessing(allow : false) else { return }
        
        AnalyticsManager.Post.trackDetailsBackPressed(responseType: productionState, challengeId: challengeId)
        navigationController?.popViewController(animated: true)
        
    }
    
    @IBAction func changeCoverImageTapped(_ sender: Any) {
        
        AnalyticsManager.Post.trackDetailsChangeCoverPressed(responseType: productionState, challengeId: challengeId)
        
        if productionState == .video {
            performSegue(withIdentifier: R.segue.postMetadataViewController.updateCoverImageSegue, sender: self)
        }
        
    }
    
    @IBAction func instagramSwitched(_ sender: Any) {
        
        guard let toggle = sender as? UISwitch, toggle.isOn == true else { return }
        handleLogin(withShareChannel: .instagram)
        
    }
    
    @IBAction func facebookSwitched(_ sender: Any) {
        
        guard let toggle = sender as? UISwitch, toggle.isOn == true else { return }
        handleLogin(withShareChannel: .facebook)
        
    }
    
    @IBAction func twitterSwitched(_ sender: Any) {
        
        guard let toggle = sender as? UISwitch, toggle.isOn == true else { return }
        handleLogin(withShareChannel: .twitter)
        
    }
    
    @IBAction func saveDraftButtonTapped(_ sender: Any) {
        
        let hasDescription = !descriptionTextView.text.isEmpty
        let hasTags = (descriptionTextView.text.count - descriptionTextView.text.replacingOccurrences(of: "#", with: "").count > 0)
        
        AnalyticsManager.Post.trackDetailsSavePressed(responseType: productionState, challengeId: challengeId, hasTags: hasTags, hasDescription: hasDescription)
        
        cameraManager?.saveRecordSession(withComposition: editorVideoComposition)
        performSegue(withIdentifier: R.segue.postMetadataViewController.unwindSegueToHomeId, sender: self)
        
    }
    
    /**
     Return to the metadata and reload metadata
     */
    @IBAction func unwindSegueToMetadataAndReload(_ sender: UIStoryboardSegue) {
        imagePreviewView.image = cameraManager?.sessionCoverImage
    }
    
    // MARK: - Public Properties
    
    /// Cover image
    open var customCoverImage: UIImage?
    
    /// Location of the cover image on disk
    open var coverImageURL: URL?
    
    // MARK: - Private Properties
    
    /// Final, fully exported, video path
    private var outputUrl: URL?
    
    /// Monitor taps on the view to dismiss the keyboard
    private var tapGestureHandler: UITapGestureRecognizer?
    
    /// A reference to the `UIKeyboardWillShow` notification
    private var keyboardWillShowId: NSObjectProtocol?
    
    /// A reference to the `UIKeyboardWillHide` notification
    private var keyboardWillHideId: NSObjectProtocol?
    
    private var isBouncing = false
    private var bounceAmplitude : CGFloat = 7.5
    private var bounceOrigin : CGFloat = -7.5
    
    /// Benchmarking Temp Properties
    fileprivate var exportDuration: Double = 0.0
    fileprivate var uploadDuration: Double = 0.0
    fileprivate var benchmarkStartTime: CFAbsoluteTime = CFAbsoluteTimeGetCurrent()
    fileprivate var benchmarkEndTime: CFAbsoluteTime = CFAbsoluteTimeGetCurrent() {
        
        didSet {
            log.verbose("⏰ Time to process video took \(Double(benchmarkEndTime).rounded(toPlaces: 1))s")
        }
        
    }
    
    
    // MARK: - Lifecycle
    
    deinit {
        
        NotificationCenter.default.removeObserver(keyboardWillShowId as Any)
        NotificationCenter.default.removeObserver(keyboardWillHideId as Any)
        log.verbose("💥")
        
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        configureView()
        
        processVideo()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
       
        // Set description
        descriptionTextView.text = cameraManager?.sessionDescription
        if (services.globalModelsCoordinator.loggedInUser?.createdResponses.count ?? 0) == 0 {
            
            showCTACoachMark(text: nil, delay: 0.0)
            
        } else {
            
            coachMarkView.isHidden = true
            
        }
        

    }
    
    /**
     Handle preparing the video editor and verifying that a recording is valid
     */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let vc = R.segue.postMetadataViewController.updateCoverImageSegue(segue: segue)?.destination {
            
            vc.services = services
            vc.cameraManager = cameraManager
            vc.editorVideoComposition = editorVideoComposition
            vc.productionState = productionState
            
        }
        
    }
    
    // MARK: - Private Methods

    override func configureView() {
        
        super.configureView()
        
        
        upperNavBar.addShadow(alpha: 0.05, offset: CGSize(width: 0.0, height: 1.1), radius : 1.0)
        progressContainer.backgroundColor = UIColor.MaverickPrimaryColor
        progressLabel.states = [
            "Preparing Video for Upload.","Preparing Video for Upload..","Preparing Video for Upload..."]
        progressLabel.start()
        progressBar.trackTintColor = .white
        progressBar.progressTintColor = UIColor.MaverickBadgePrimaryColor
        
        if let v = navigationItem.titleView as? UILabel {
            v.textColor = .maverickOrange
        }
        
        videoPreviewView?.player?.loopEnabled = true
        
        imagePreviewView.image = cameraManager?.sessionCoverImage
        
        descriptionTextView.delegate = self
        
        
        if productionState != .video {
            changeCoverImageButton.isHidden = true
        }
        
        // Observe keyboard visibility
        observeKeyboardWillShow()
        observeKeyboardWillHide()
        scrollView.delegate = self
        
        mentionAutoCompleteview.configureWith(textView: descriptionTextView, delegate: self, services: services)
        bounceOrigin = coachMarkTopConstraint.constant
        coachMarkView.addShadow(alpha: 0.3)
    }
    
    
    
    private func checkProgress() {
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) { [weak self] in
            
            guard let sessionId = self?.cameraManager?.session?.identifier else { return }
            let (checkState, progress) = MaverickComposition.getProgress(sessionId: sessionId)
            guard let state = checkState else { return }
            
            if state == .failed {
                
                let alert = UIAlertController(title: "Whoops!", message: "Something went wrong when prepraing the video for upload.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default) { result in
                    
                    self?.backButtonTapped(self!)
                    
                })
                self?.present(alert, animated: true, completion: nil)
                return
                
            } else if state == .success {
                // Fetch a cover image for the video
                self?.editorVideoComposition?.generateCoverImage(completionHandler: { image in
                    
                    self?.saveCoverImage(image: image)
                    UIView.animate(withDuration: 0.2, animations: {
                        
                        self?.progressContainer.alpha = 0.0
                        self?.progressContainer.isHidden = true
                        self?.previewContainer.isHidden = false
                        self?.previewContainer.alpha = 1.0
                        
                    })
                    
                    self?.coverActivityIndicator.stopAnimating()
                    
                })
                
                return
                
            } else {
                
                self?.progressBar.progress = progress
                
            }
            
            self?.checkProgress()
            
        }
        
        
    }
    private func processVideo() {
        
        progressBar.setProgress(0.0, animated: false)
        if productionState == .video {
            
            editorVideoComposition?.prepareVideoCompositionForSegments(sessionId: cameraManager!.session!.identifier)
            checkProgress()
            
        } else {
            
            self.previewContainer.isHidden = false
            self.previewContainer.alpha = 1.0
            self.progressContainer.isHidden = true
            self.coverActivityIndicator.stopAnimating()
        }
        
    }
    
    /**
     Saves the image to disk
     */
    func saveCoverImage(image: UIImage) {
        
        let randomFilename = "\(cameraManager!.session!.identifier)_coverImage" + ".jpg"
        let data = UIImageJPEGRepresentation(image, 1.0)
        let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last!
        coverImageURL = dir.appendingPathComponent(randomFilename)
        cameraManager?.sessionCoverImage = image
        
        cameraManager?.sessionCoverImageURL = coverImageURL
        FileManager.default.createFile(atPath: coverImageURL!.path, contents: data, attributes: nil)
        
        DispatchQueue.main.async {
            
            self.imagePreviewView.image = image
            
        }
        
    }
    
  
    
    /**
     */
    fileprivate func showAlert(withMessage message: String) {
        
        let alert = UIAlertController(title: "Upload Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
        
    }
    
    /**
     
     */
    fileprivate func handlePostButtonTapped() {
        
        view.isUserInteractionEnabled = false
        showLoadingIndicator(withMessage: "One moment...")
        
        if productionState == .video {
            
            guard let asset = editorVideoComposition?.videoAssetWithOverlay else {
                
                AnalyticsManager.Post.trackPostFail(responseType: productionState, challengeId: challengeId, postFailureError: Constants.Analytics.Post.Properties.POST_FAILURE_REASON.assetLoadingFailure)
                hideLoadingIndicator()
                showAlert(withMessage: "Unable to export. Couldn't find the asset. Please try again.")
                return
                
            }
            
            cameraManager!.exportRecording(withAsset: asset) { outputUrl in
                
                self.outputUrl = outputUrl
                self.uploadResponse()
                
            }
            
        } else {
            
            guard let image = editorVideoComposition?.finalEditedImage else {
                AnalyticsManager.Post.trackPostFail(responseType: productionState, challengeId: challengeId, postFailureError: Constants.Analytics.Post.Properties.POST_FAILURE_REASON.assetLoadingFailure)
                hideLoadingIndicator()
                showAlert(withMessage: "Unable to export. Couldn't find the edited image. Please try again.")
                return
            }
            
            let outputPath = editorVideoComposition!.saveImageForUpload(withImage: image)
            outputUrl = URL(fileURLWithPath: outputPath)
            uploadResponse()
            
        }
        
    }
    
    /**
     Create an upload operation and begin the upload process in the background
     */
    fileprivate func uploadResponse() {
        
        // saving the draft to help with uploading indicator and retry if failed
        // call super to save-only vs. save + return to home screen
        super.handleSaveDraft()
        
        // Gather active share channels
        let shareChannels: [SocialShareChannels] = []
        
        // Upload
        services.globalModelsCoordinator.uploadContentResponse(withFileURL: outputUrl!,
                                                               forChallengeId: cameraManager!.sessionChallengeId,
                                                               description: cameraManager!.sessionDescription,
                                                               coverImage: cameraManager?.sessionCoverImageURL,
                                                               responseType: productionState,
                                                               sessionId: cameraManager!.session!.identifier,
                                                               shareChannels: shareChannels)
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
            
            self.hideLoadingIndicator()            
            self.performSegue(withIdentifier: R.segue.postMetadataViewController.unwindSegueToHomeId, sender: self)
            
        }
        
    }
    
    /**
     Assemble a list based on the active share toggles
     */
    fileprivate func getSelectedSocialChannels() -> [SocialShareChannels] {
        
        var shareChannels: [SocialShareChannels] = []
        
        if facebookShareToggle?.isOn ?? false {
            shareChannels.append(.facebook)
        }
        
        if twitterShareToggle?.isOn ?? false {
            shareChannels.append(.twitter)
        }
        
        // Keep instagram as the last channel to process the 'easy' channels first
        if instagramShareToggle?.isOn ?? false {
            shareChannels.append(.instagram)
        }
        
        return shareChannels
        
    }
    
    /**
     Observe when the keyboard becomes visible and adjusts the scroll view inset.
     */
    fileprivate func observeKeyboardWillShow() {
        
        keyboardWillShowId = NotificationCenter.default.addObserver(forName: .UIKeyboardWillShow,
                                                                    object: nil,
                                                                    queue: nil)
        { [weak self] notification in
            
            if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
                self?.scrollView?.contentInset = UIEdgeInsetsMake(0, 0, keyboardSize.height, 0)
            }
            
        }
        
    }
    
    /**
     Observe when the keyboard hides and adjusts the scroll view inset.
     */
    fileprivate func observeKeyboardWillHide() {
        
        keyboardWillHideId = NotificationCenter.default.addObserver(forName: .UIKeyboardWillHide,
                                                                    object: nil,
                                                                    queue: nil)
        { [weak self] _ in
            
            self?.scrollView?.contentInset = UIEdgeInsetsMake(0, 0, 0, 0)
            
        }
        
    }
    
    
    /**
     Begins the login flow with the provided channel
     */
    fileprivate func handleLogin(withShareChannel channel: SocialShareChannels) {
        
        // Don't attempt if an access token exists for the channel
        if services.shareService.isShareAvailable(forChannel: channel) {
            return
        }
        
        services.shareService.login(fromViewController: self,
                                    channel: channel)
        { error in
            
            if let error = error {
                self.showAlert(withMessage: error.localizedDescription)
            }
            
        }
        
    }
    
    /**
     Sends an analytics event when the user taps the post button.
     */
    private func trackPostButtonTapped() {
        
        let hasDescription = !descriptionTextView.text.isEmpty
        let hasTags = (descriptionTextView.text.count - descriptionTextView.text.replacingOccurrences(of: "#", with: "").count > 0)
        
        let hasMultipleSegments: Bool? = {
            if productionState == .video {
                return (editorVideoComposition?.session.segments.count)! > 1 ? true : false
            } else {
                return nil
            }
        }()
        
        let views = editorVideoComposition?.masterOverlayView.componentsView?.subviews
        let hasStickers: Bool = (views?.filter { $0.isKind(of: UIImageView.self) }.count)! > 0 ? true : false
        let hasText: Bool = (views?.filter { $0.isKind(of: UITextView.self) }.count)! > 0 ? true : false
        
        let hasFilter: Bool = {
            if let _ = editorVideoComposition?.masterOverlayFilter {
                return true
            } else {
                return false
            }
        }()
        
        let hasDoodle: Bool = {
            if (editorVideoComposition?.masterOverlayView.paperState?.everyVisibleStroke().count)! > 0 {
                return true
            } else {
                return false
            }
        }()
        
//        let lengthOfUpload: Float64? = {
//            if productionState == .video {
//                return CMTimeGetSeconds((editorVideoComposition?.session.segmentsDuration)!)
//            } else {
//                return nil
//            }
//        }()
        
//        AnalyticsManager.Post.trackUploadPressed(responseType: productionState, challengeId: challengeId, hasTags: hasTags, hasDescription: hasDescription, hasMultipleSegments: hasMultipleSegments, hasStickers: hasStickers, hasText: hasText, hasDoodle: hasDoodle, hasFilter: hasFilter, length: lengthOfUpload)
        
    }
    
    // MARK: - Overrides
    
    override func handleSaveDraft() {
        
        super.handleSaveDraft()
        
        performSegue(withIdentifier: R.segue.postMetadataViewController.unwindSegueToHomeId, sender: self)
        
    }
    
    override func handleRestart() {
        
        super.handleRestart()
        
        performSegue(withIdentifier: R.segue.postMetadataViewController.unwindSegueToPostReset, sender: self)
        
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    
    override var prefersStatusBarHidden: Bool {
        return false
    }
    
    
    private func lowerCoachMark( delay : CGFloat = 0) {
        self.coachMarkTopConstraint.constant = bounceOrigin + bounceAmplitude
        
        UIView.animateKeyframes(withDuration: 0.5, delay: TimeInterval(delay), options: [], animations: {
            
            self.coachMarkView.alpha = 1
            self.view.layoutIfNeeded()
            
        }) { (result) in
            
            if self.isBouncing {
                
                self.raiseCoachmark()
                
            } else {
                
                UIView.animate(withDuration: 0.5, animations: {
                    
                    self.coachMarkView.alpha = 0
                    
                }, completion: nil)
                
            }
            
        }
        
    }
    
    private func raiseCoachmark() {
        
        self.coachMarkTopConstraint.constant = bounceOrigin
        UIView.animate(withDuration: 0.5, animations: {
            
            self.view.layoutIfNeeded()
            
        }) { (result) in
            
            if self.isBouncing {
                
                self.lowerCoachMark()
                
            }  else {
                
                UIView.animate(withDuration: 0.5, animations: {
                    
                    self.coachMarkView.alpha = 0
                    
                }, completion: nil)
                
            }
            
        }
        
    }
    
    
    func showCTACoachMark(text : String?, delay : CGFloat) {
        
        if !isBouncing {
            
            if let text = text {
                
                coachMarkLabel.text = text
                
            }
            isBouncing = true
            lowerCoachMark(delay: delay)
            
        }
        
    }
    
}

extension PostMetadataViewController: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        
        if textView == descriptionTextView {
            
            AnalyticsManager.Post.trackDetailsDescriptionEntryStarted(responseType: productionState, challengeId: challengeId)
            
        }
        
    }
    
    
    func textViewDidEndEditing(_ textView: UITextView) {
        cameraManager?.sessionDescription = textView.text ?? ""
    }
    
}

extension PostMetadataViewController : UIScrollViewDelegate {
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        
        if descriptionTextView.isFirstResponder {
            view.endEditing(true)
        }
        
    }
    
}

extension PostMetadataViewController : ErrorDialogViewControllerDelegate {
    
    /**
     Delegate method called by the Error Dialog View Controller when the user has attempted to leave the final post flow before video processing has completed to inform the view controller that the dialog has been dismissed.
     */
    func endDisplay() {
  
        guard let sessionId = cameraManager?.session?.identifier, let cameraManager = cameraManager else { return }
        editorVideoComposition?.clearDraftToPost(sessionId: sessionId, cameraManager: cameraManager, services: services)
        dismiss(animated: true, completion: nil)
    }
    
}
