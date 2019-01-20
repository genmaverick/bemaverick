//
//  FinalPostViewController.swift
//  Maverick
//
//  Created by Chris Garvey on 8/6/18.
//  Copyright © 2018 BeMaverick. All rights reserved.
//

import UIKit

class FinalPostViewController: UIViewController {

    // MARK: - IBOutlets
    
    /// The title of the navigation bar for a response to a challenge
    @IBOutlet weak var postResponseTitle: UILabel!
    
    /// The title of the navigation bar for a post not associated to a challenge
    @IBOutlet weak var postTitle: UILabel!
    
    /// The name of the challenge for which the post is created.
    @IBOutlet weak var challengeTitle: UILabel!
    
    /// Preview image of the post.
    @IBOutlet weak var previewViewImage: UIImageView!
    
    /// The post description create by the user.
    @IBOutlet weak var descriptionText: UITextView!
    
    /// The footer label at the bottom of the view controller containing additional information.
    @IBOutlet weak var footerLabel: UILabel!
    
    /// The bottom constraint for the action view that is animated depending on the state of the view controller.
    @IBOutlet weak var actionViewBottomConstraint: NSLayoutConstraint!
    
    /// The MaverickAutoCompleteView used to auto complete hash tags and mentions in the description field.
    @IBOutlet weak var autoCompleteView: MaverickAutoCompleteView!
    
    /// The constraint used to show or hide the autoCompleteView.
    @IBOutlet weak var autoCompleteViewTopConstraint: NSLayoutConstraint!
    
    /// The activity indicator for the image preview.
    @IBOutlet weak var previewViewActivityIndicator: UIActivityIndicatorView!
    
    /// The view containing all of the share icons.
    @IBOutlet weak var shareView: UIView!
    
    /// The button on the preview image that allows the cover to be changed for video posts.
    @IBOutlet weak var changeCoverButton: UIButton!
    
    /// The constraint used to show or hide the progress container.
    @IBOutlet weak var progressContainerBottomConstraintForHeight: NSLayoutConstraint!
    
    /// The progress container view that contains the progress label and progress bar.
    @IBOutlet weak var progressContainer: UIView!
    
    /// The progress label telling the user that a video is preparing for upload.
    @IBOutlet weak var progressLabel: LoadingLabel!
    
    /// The progress bar indicating the progress of the video preparing for upload.
    @IBOutlet weak var progressBar: UIProgressView!
    
    /// The button used to save a draft of the post.
    @IBOutlet weak var saveDraftButton: UIButton!
    
    /// The button used to post a response.
    @IBOutlet weak var postButton: UIButton!
    
    
    // MARK: - Private Properties
    
    /// The current state of the view.
    lazy private var currentState = states[InitialState.identifier]!
    
    /// The current state of the video processing.
    lazy private var currentProcessingVideoState: FinalPostViewState! = nil
    
    /// An array of all possible states for the view controller.
    lazy private var states = [
        InitialState.identifier: InitialState(finalPostViewController: self),
        AcceptInputState.identifier: AcceptInputState(finalPostViewController: self),
        RestingState.identifier: RestingState(finalPostViewController: self),
        ProcessingVideoState.identifier: ProcessingVideoState(finalPostViewController: self),
        FinishedProcessingVideoState.identifier: FinishedProcessingVideoState(finalPostViewController: self)
    ]
    
    
    // MARK: - Public Properties
    
    /// The view model for which the view controller obtains all data.
    public weak var finalPostViewModel: FinalPostViewModel?
    
    /// The height of the keyboard used to determine how far the action view should be moved.
    public var keyboardHeight: CGFloat?
    
    /// The tap gesture recognizer that is used to move the action view based upon whether the user is editing the description or not.
    private var tapGestureRecognizer: UITapGestureRecognizer!
    
    /// The constant for the autoCompleteViewTopConstraint used to open and close the view.
    private var autoCompleteViewTopConstraintConstant: CGFloat = 0 {
        didSet {
            autoCompleteViewTopConstraint.constant = floor(autoCompleteViewTopConstraintConstant) + 8
            view.layoutIfNeeded()
        }
    }
    
    
    // MARK: - IBActions
    
    /**
     The change cover button was tapped in the video post flow.
     */
    @IBAction func changeCoverButtonTapped(_ sender: UIButton) {
        finalPostViewModel?.changeCoverButtonTapped()
    }
    
    /**
     The back navigation button was tapped.
     */
    @IBAction func backButtonTapped(_ sender: Any) {
        
        updateDescriptionIfNeeded()
        
        if finalPostViewModel?.productionState == .video {
            guard videoHasFinishedProcessing(allow: false) else { return }
        }

        finalPostViewModel?.backButtonTapped()
        
    }
    
    /**
     The share button for instagram was tapped.
     */
    @IBAction func instagramButtonTapped(_ sender: Any) {
        finalPostViewModel?.shareButtonTapped(forChannel: .instagram)
    }
    
    /**
     The share button for facebook was tapped.
     */
    @IBAction func facebookButtonTapped(_ sender: Any) {
        finalPostViewModel?.shareButtonTapped(forChannel: .facebook)
    }
    
    /**
     The share button for twitter was tapped.
     */
    @IBAction func twitterButtonTapped(_ sender: Any) {
        finalPostViewModel?.shareButtonTapped(forChannel: .twitter)
    }
    
    /**
     The share button for sms was tapped.
     */
    @IBAction func smsButtonTapped(_ sender: Any) {
        finalPostViewModel?.shareButtonTapped(forChannel: .sms)
    }
    
    /**
     The share button for mail was tapped.
     */
    @IBAction func mailButtonTapped(_ sender: Any) {
        finalPostViewModel?.shareButtonTapped(forChannel: .mail)
    }
    
    /**
     The share button for a link was tapped.
     */
    @IBAction func linkButtonTapped(_ sender: Any) {
        finalPostViewModel?.shareButtonTappedForLink()
    }
    
    /**
     The save draft button was tapped.
     */
    @IBAction func saveDraftButtonTapped(_ sender: Any) {
        handleSaveDraftButtonTapped()
    }
    
    /**
     Thepost button was tapped.
     */
    @IBAction func postButtonTapped(_ sender: Any) {
        
        postButton.isEnabled = false
        handlePostButtonTapped()
        
    }
    
    
    // MARK: - Lifecycle
    
    init(viewModel: FinalPostViewModel) {
        super.init(nibName: nil, bundle: nil)
        finalPostViewModel = viewModel
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureView()
        currentState.configureViewForState()
        setupTapGestureRecognizer()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardNotification(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        if finalPostViewModel?.productionState == .video {
            processVideo()
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        trackScreen()
    }
    
    deinit {
        log.verbose("💥")
    }
    
    
    // MARK: - State Management
    
    /**
     Transitions the view to a new state.
     - paramater identifier: The name of the state to which a transition should be made.
     */
    public func transitionToState(
        matching identifier: AnyHashable) {
        
        let state = states[identifier]!
        currentState = state
        currentState.configureViewForState()
    
    }
    
    /**
     Transitions the view to a new state related to video processing.
     - parameter identifier: The name of the video processing state to which a transition should be made.
     */
    public func transitionToVideoState(
        matching identifier: AnyHashable) {
        
        let state = states[identifier]!
        currentProcessingVideoState = state
        currentProcessingVideoState.configureViewForState()
        
    }
    
    
    // MARK: - Public Methods
    
    /**
     Show an alert from the view controller.
     - parameter title: The title of the alert.
     - parameter message: The message within the alert.
     - parameter action: The action to be executed upon interacting with the alert.
     */
    private func showAlert(withTitle title: String, withMessage message: String, withAction action: UIAlertAction) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
        
    }
    
    
    // MARK: - Private Methods
    
    /**
     Posts the user's response.
     */
    private func handlePostButtonTapped() {
        
        updateDescriptionIfNeeded()
        
        if finalPostViewModel?.productionState == .video {
            guard videoHasFinishedProcessing(allow: true) else { return }
        }
        
        finalPostViewModel?.postButtonTapped { errorMessage in
            
            if errorMessage != nil {
                
                self.postButton.isEnabled = true
                
                let action = UIAlertAction(title: "Ok", style: .default, handler: nil)
                self.showAlert(withTitle: "Upload Error", withMessage: errorMessage!, withAction: action)
            }
            
        }
        
    }
    
    /**
     Saves the user's draft response.
     */
    private func handleSaveDraftButtonTapped() {
        
        updateDescriptionIfNeeded()
        finalPostViewModel?.saveDraftButtonTapped()
        
    }
    
    /**
     Indicates whether a video has completed processing for upload or not.
     - parameter allow: The boolean indicating whether the user should be able to navigate away from the view controller if the video has not finished processing.
     */
    private func videoHasFinishedProcessing(allow: Bool) -> Bool {
        
        if currentProcessingVideoState is ProcessingVideoState {
            
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
    
    /**
     Set up the tap gesture recognizer for the view.
     */
    private func setupTapGestureRecognizer() {
        
        tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        
        view.addGestureRecognizer(tapGestureRecognizer)
        tapGestureRecognizer.cancelsTouchesInView = false
        
    }
    
    /**
     Handles the taps from the tapGestureRecognizer for the view. If taps occur outside of the description, then the keyboard is dismissed and the transitions to its resting state.
     */
    @objc func handleTap(_ sender: UITapGestureRecognizer) {
        
        let point = sender.location(in: view)
        
        if descriptionText.point(inside: point, with: nil) == false {
            
            if autoCompleteView.isActivelyPresenting() {
                
                if autoCompleteView.point(inside: point, with: nil) == false {
                    autoCompleteView.clear()
                }
                
            } else {
                
                if descriptionText.isFirstResponder {
                    
                    if postButton.isHighlighted {
                        handlePostButtonTapped()
                    } else if saveDraftButton.isHighlighted {
                        handleSaveDraftButtonTapped()
                    }
                    
                    descriptionText.resignFirstResponder()
                    updateDescriptionIfNeeded()
                    transitionToState(matching: RestingState.identifier)
                    
                }
                
            }
            
        }
        
    }
    
    /**
     The delegate method called when the keyboard appears.
     */
    @objc func keyboardNotification(notification: Notification) {
        
        if let keyboardSizeHeight = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.height {
            keyboardHeight = keyboardSizeHeight
        }
        
    }
    
    /**
     Track that the user has started viewing this class.
     */
    private func trackScreen() {
        AnalyticsManager.trackScreen(location: self)
    }
    
    /**
     Configure the initial view of the view controller.
     */
    private func configureView() {
        
        shareView.isHidden = true
        
        let title = setChallengeTitle()
        
        if title.isEmpty || title == "Create a New Post" {
            
            postResponseTitle.isHidden = true
            challengeTitle.isHidden = true
            postTitle.isHidden = false
            
            footerLabel.text = R.string.maverickStrings.finalPostAdditionalInfoFooterForStandalonePosts()
            
        } else {
            
            challengeTitle.text = title
            footerLabel.text = R.string.maverickStrings.finalPostAdditionalInfoFooter()
            
        }
        
        previewViewImage.image = retrievePreviewImage()
        descriptionText.delegate = self
        
        autoCompleteView.configureWith(textView: descriptionText, delegate: self, services: (UIApplication.shared.delegate as! AppDelegate).services)
        
    }
    
    /**
     Start the video processing.
     */
    private func processVideo() {
        finalPostViewModel?.prepareVideo()
    }
    
    /**
     Retrieve the challenge title if there is one from the view model.
     */
    private func setChallengeTitle() -> String {
        
        if let challengeNameForNavigationBar = finalPostViewModel?.challengeTitle {
            return challengeNameForNavigationBar
        } else {
            return ""
        }
        
    }
    
    /**
     Retrieve the preview image if there is one from the view model.
     */
    private func retrievePreviewImage() -> UIImage {

        if let previewImage = finalPostViewModel?.previewImage {
            return previewImage
        } else {
            return UIImage()
        }
        
    }
    
    /**
     Inform the view model that the description has been updated if the description has been changed by the user.
     */
    private func updateDescriptionIfNeeded() {
        
        let currentDescription: String = {
            if descriptionText.text == R.string.maverickStrings.finalPostPlaceholderTextForDescriptionField() {
                return ""
            } else {
                return descriptionText.text.trimmingCharacters(in: .whitespacesAndNewlines)
            }
        }()
        
        if currentDescription != finalPostViewModel?.description {
            finalPostViewModel?.descriptionUpdated(withText: currentDescription)
        }
        
    }
    
    /**
     Update the preview image in the view.
     */
    fileprivate func updatePreviewImage() {
        
        let toImage = self.retrievePreviewImage()
        
        DispatchQueue.main.async {
            
            UIView.transition(with: self.previewViewImage,
                              duration: 0.2,
                              options: .transitionCrossDissolve,
                              animations: {
                                self.previewViewImage.image = toImage
            }, completion: nil)
            
        }
        
    }
    
    // MARK: - Overrides
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
}


extension FinalPostViewController: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        
        finalPostViewModel?.trackDescriptionBeganEditing()
        transitionToState(matching: AcceptInputState.identifier)
        
    }
    
    func textViewDidChange(_ textView: UITextView) {
        
        if let cursorPosition = textView.selectedTextRange?.start {
            
            let caretPositionYValue: CGFloat = textView.caretRect(for: cursorPosition).maxY
            
            if caretPositionYValue != autoCompleteViewTopConstraintConstant && caretPositionYValue <=  textView.bounds.height {
                autoCompleteViewTopConstraintConstant = caretPositionYValue
                
            }
            
        }

    }
    
}

extension FinalPostViewController: FinalPostViewModelVideoDelegate {
    
    /**
     Delegate method called by the view model informing the view controller that the progess bar status has been updated.
     */
    func didUpdateProgess(withValue value: Float) {
        
        if currentProcessingVideoState == nil {
            transitionToVideoState(matching: ProcessingVideoState.identifier)
        }
        
        DispatchQueue.main.async {
            if value > 0.05 {
                self.progressBar.progress = value
            }
        }
        
    }
    
    /**
     Delegate method called by the view model to indicate that the video has finished processing and the view model should transition its state and update its views.
     */
    func didFinishProcessingVideo(success: Bool, withError error: String?) {
        
        transitionToVideoState(matching: FinishedProcessingVideoState.identifier)
        
        if success {
            
            updatePreviewImage()
            
        } else {
            
            guard let errorString = error else { return }
            let action = UIAlertAction(title: "Ok", style: .default, handler: {(alert: UIAlertAction!) in
                self.finalPostViewModel?.backButtonTapped()
            })
            
            showAlert(withTitle: "Whoops!", withMessage: errorString, withAction: action)
            
        }
        
    }
    
    /**
     Delegate method called by the view model to inform the view controller that cover photo has been updated by the user and the preview view needs to be updated accordingly.
     */
    func didUpdatePreviewImage() {
        updatePreviewImage()
    }
    
}

extension FinalPostViewController: ErrorDialogViewControllerDelegate {
    
    /**
    Delegate method called by the Error Dialog View Controller when the user has attempted to leave the final post flow before video processing has completed to inform the view controller that the dialog has been dismissed.
    */
    func endDisplay() {
        finalPostViewModel?.endDisplay()
    }
    
}
