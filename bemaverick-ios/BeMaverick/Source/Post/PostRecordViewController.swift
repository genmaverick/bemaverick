//
//  PostRecordViewController.swift
//  BeMaverick
//
//  Created by David McGraw on 9/7/17.
//  Copyright © 2017 BeMaverick. All rights reserved.
//

import UIKit
import SCRecorder
import Photos

enum TimerState: Int {
    case none = 0, five = 5, ten = 10
}

protocol PostRecordViewControllerDelegate: class {
    func imageSelected(image: UIImage)
}

class PostRecordViewController: PostRecordParentViewController {
    
    // MARK: - IBOutlet
    
    /// A custom view containing nav components
    @IBOutlet weak var navContainerView: UIView!
    
    @IBOutlet weak var tapToTypeHint: UILabel!
    /// A button for going back a step based on the selected option
    @IBOutlet weak var backButton: UIButton!
    
    @IBOutlet weak var coachMarkTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var coachmarkTrailingConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var textPostNewCoachmark: UIView!
    /// Advance to the editor layout
    @IBOutlet weak var nextButton: UIButton!
    
    /// A button that displays the time remaining
    @IBOutlet weak var recordingIndicatorButton: UIButton!
    
    /// Cancel the current record timer to the preview step
    @IBOutlet weak var countdownCancelButton: UIButton!
    
    /// The stack view containing camera controls
    @IBOutlet weak var cameraControlsView: UIStackView!
    
    /// Button used to undo the last action
    @IBOutlet weak var undoButton: UIButton!
    
    /// Remove the selected segment
    @IBOutlet weak var removeSegmentButton: UIButton!
    
    /// A label used for a countdown to begin recording
    @IBOutlet weak var timerCountdownLabel: UILabel!
    
    /// A button used to begin recording
    @IBOutlet weak var recordButton: UIButton!
    
    /// A button used to toggle playback
    @IBOutlet weak var playButton: UIButton!
    
    /// Show the user's photo and video library
    @IBOutlet weak var libraryButton: UIButton!
    
    /// A button for flipping the device camera
    @IBOutlet weak var flipCameraButton: UIButton!
    
    /// A button for turning on the flash
    @IBOutlet weak var flashButton: UIButton!
    
    /// A button displaying countdown options
    @IBOutlet weak var countdownButton: UIButton!
    
    /// Video selector bar
    
    @IBOutlet weak var segmentControl: MaverickSegmentedControl!
    
    /// A container view with the video and photo buttons
    @IBOutlet weak var recordControlModeSelectorView: UIView!
    
    
    /// A view on standby to use when permissions are changed
    @IBOutlet weak var enableAccessContentView: UIView!
    
    /// A view on standby to use when permissions are changed
    @IBOutlet weak var recordControlsContentView: UIView!
    
    @IBOutlet weak var filterButton: RoundSelectedButton!
    @IBOutlet weak var stickersButton: UIButton!
    @IBOutlet weak var textButton: UIButton!
    @IBOutlet weak var drawingButton: UIButton!
    
    /// The scroll view containing the image to crop
    @IBOutlet weak var imagePreviewScrollView: UIScrollView!
    
    /// The content view containing the image
    @IBOutlet weak var imagePreviewContentView: UIView!
    
    /// The width of `imagePreviewContentView`
    @IBOutlet weak var imagePreviewContentViewWidth: NSLayoutConstraint!
    
    /// The height of `imagePreviewContentView`
    @IBOutlet weak var imagePreviewContentViewHeight: NSLayoutConstraint!
    
    
    @IBOutlet weak var editStickerOptionsViewTappableMinimizerView: UIView!
    
    @IBOutlet weak var aspectRatio: NSLayoutConstraint!
    
    @IBOutlet weak var cameraViewTopConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var recordControlsTopConstraint: NSLayoutConstraint!
    
    
    // MARK: - IBActions
    
    @IBAction func segmentValueChanged(_ sender: Any) {
        
        if (forAvatar || forProfileCover) {
            
            if (segmentControl.selectedSegmentIndex == 0) && productionState == .image {
                return
            } else if segmentControl.selectedSegmentIndex == 1 {
                updateResponseType(toType: .text)
            }
            
        } else {
            
            let mediaTypePressed: Constants.Analytics.Main.Properties.MEDIA_TYPE = segmentControl.selectedSegmentIndex == 0 ? .video :
                segmentControl.selectedSegmentIndex == 1 ? .image : .text
            
            AnalyticsManager.Post.trackCameraTabPressed(responseType: productionState, challengeId: challengeId, mediaTypePressed: mediaTypePressed)
            
            if (segmentControl.selectedSegmentIndex == 0) && productionState == .video ||
                (segmentControl.selectedSegmentIndex == 1) && productionState == .image {
                return
            }
            
            
            isBouncing = false
            
            if segmentControl.selectedSegmentIndex > 0 && (editorVideoComposition?.session.segments.count ?? 0) > 0
            {
                segmentControl.selectedSegmentIndex = 0
            }
            
            handlePhotoModeToggle(goToText: mediaTypePressed == .text)
            
        }
        
    }
    
    
    /**
     When the user taps the record button, begin the recording
     */
    @IBAction func recordButtonPressed(_ sender: Any) {
        
        let isRecording = productionState == .image ? false : (cameraManager?.isRecording() ?? false)
        
        if isRecording {
            
            AnalyticsManager.Post.trackCameraStopPressed(responseType: productionState, challengeId: challengeId)
            
        } else {
            
            let flashSelectionState =
                flashButton.isSelected ? Constants.Analytics.Post.Properties.FLASH_STATE.on : Constants.Analytics.Post.Properties.FLASH_STATE.off
            
            let captureDevicePosition = cameraManager?.recorder.device == .front ? Constants.Analytics.Post.Properties.CAPTURE_DEVICE_POSITION.front : Constants.Analytics.Post.Properties.CAPTURE_DEVICE_POSITION.back
            
            
            let timerSelectionState: Constants.Analytics.Post.Properties.TIMER_STATE = {
                
                switch timerState {
                    
                case .none:
                    return Constants.Analytics.Post.Properties.TIMER_STATE.none
                case .five:
                    return Constants.Analytics.Post.Properties.TIMER_STATE.five
                case .ten:
                    return Constants.Analytics.Post.Properties.TIMER_STATE.ten
                    
                }
                
            }()
            
            AnalyticsManager.Post.trackCameraRecordPressed(responseType: productionState, challengeId: challengeId, flashState: flashSelectionState, cameraFlipState: captureDevicePosition, timerState: timerSelectionState)
            
        }
        
        if timerState != .none && !isRecording {
            beginRecording(after: timerState.rawValue)
            return
        }
        
        if productionState == .video {
            
            if let isRecording = cameraManager?.isRecording() {
                handleRecordingStateChanged(isRecording: isRecording)
            }
            
        } else {
            
            cameraManager?.captureImage { image in
                
                self.editorOptionsView.filterOptionsView.defaultPreviewImage = image
                self.editorVideoComposition?.lastCapturedImage = image
                self.imagePreviewView.image = image
                self.isRecordingActive = false
                
            }
            
        }
        
    }
    
    /**
     Toggle preview playback
     */
    @IBAction func playButtonPressed(_ sender: Any) {
        
        if playButton.isSelected {
            
            AnalyticsManager.Post.trackEditPausePressed(responseType: productionState, challengeId: challengeId)
            previewPlayer?.pause()
            
        } else {
            
            AnalyticsManager.Post.trackEditPlayPressed(responseType: productionState, challengeId: challengeId)
            previewPlayer?.play()
            
        }
        
        playButton.isSelected = !playButton.isSelected
        
    }
    
    /**
     Undo the last recorded action
     */
    @IBAction func undoButtonPressed(_ sender: Any) {
        
        AnalyticsManager.Post.trackEditUndoPressed(responseType: productionState, challengeId: challengeId)
        
        if let activeOverlay = editorVideoComposition?.getActiveOverlay() {
            activeOverlay.undoManager.undo()
        }
        
    }
    
    /**
     Removes the selected segment from the composition and move back to the recording flow
     */
    @IBAction func deleteSegmentButton(_ sender: Any) {
        
        if recordingTimelineView.selectedTimelineIndex == -1 {
            editorVideoComposition?.removeLastSegment()
        } else {
            editorVideoComposition?.removeSegment(atIndex: recordingTimelineView.selectedTimelineIndex)
        }
        
        recordingTimelineView.removeSelectedSegment()
        
        if editorVideoComposition?.session.segments.count == 0 {
            editorOptionsView.filterOptionsView.defaultPreviewImage = nil
        }
        
        // Move back to the beginning
        editorVideoComposition?.seekToSegmentIndex(index: 0)
        editorVideoComposition?.reloadSessionComposition()
        isRecordingActive = true
        
    }
    
    /**
     Show the user's photo and video library
     */
    @IBAction func libraryButtonTapped(_ sender: Any) {
        
        AnalyticsManager.Post.trackCameraLibraryPressed(responseType: productionState, challengeId: challengeId)
        
        if (forAvatar || forProfileCover) {
            
            if let imagePicker = R.storyboard.general.maverickPickerId() {
                imagePicker.modalPresentationStyle = .overFullScreen
                
                if let maverickPicker = imagePicker.childViewControllers[0] as? MaverickPicker {
                    
                    maverickPicker.delegate = self
                    maverickPicker.aspectRatio = forAvatar ? 1 : 4/3
                    maverickPicker.forNonPostFlow = true
                    
                }
                
                present(imagePicker, animated: true, completion: nil)
                
            }
            
        } else {
            
            if CGFloat(editorVideoComposition?.session.duration.seconds ?? 0.0) >= Constants.CameraManagerMaxRecordDuration {
                
                let alert = UIAlertController(title: "Whoops!", message: "You've reached the max recording duration and will need to remove a segment to continue.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                present(alert, animated: true, completion: nil)
                return
                
            }
            
            guard let vc = R.storyboard.general.instantiateInitialViewController() else {
                return
            }
            
            vc.postRecordViewController = self
            vc.productionState = productionState
            vc.editorVideoComposition = editorVideoComposition
            vc.challengeId = challengeId
            navigationController?.pushViewController(vc, animated: true)
            
        }
        
    }
    
    /**
     Show the editor layout
     */
    @IBAction func editorToggleButtonTapped(_ sender: Any) {
        
        isRecordingActive = false
        didSelectSegment(atIndex: 0)
        
    }
    
    /**
     Toggle the device's torch on or off
     */
    @IBAction func flashButtonTapped(_ sender: Any) {
        
        flashButton.isSelected = !flashButton.isSelected
        
        let newFlashState: Constants.Analytics.Post.Properties.FLASH_STATE = flashButton.isSelected ? .on : .off
        
        AnalyticsManager.Post.trackCameraFlashPressed(responseType: productionState, challengeId: challengeId, flashState: newFlashState)
        
        if newFlashState == .on {
            
            if productionState == .image {
                cameraManager?.toggleTorchMode(mode: .on)
            } else {
                cameraManager?.toggleTorchMode(mode: .light)
            }
            
        } else {
            cameraManager?.toggleTorchMode(mode: .off)
        }
        
        UserDefaults.standard.isRecordFlashOn = flashButton.isSelected
        
    }
    
    /**
     Begin a countdown timer that will lead to active recording based on the
     button tapped.
     */
    @IBAction func timerButtonTapped(_ sender: Any) {
        
        guard let button = sender as? UIButton else { return }
        
        if timerState == .ten {
            timerState = .none
            button.setTitleColor(.clear, for: .normal)
            UserDefaults.standard.recordTimerState = 0
            
            AnalyticsManager.Post.trackCameraTimerPressed(responseType: productionState, challengeId: challengeId, timerState: .none)
            
            
        } else {
            
            if timerState == .none {
                timerState = .five
                button.setTitle("5", for: .normal)
                UserDefaults.standard.recordTimerState = 5
                
                AnalyticsManager.Post.trackCameraTimerPressed(responseType: productionState, challengeId: challengeId, timerState: .five)
                
                
            } else if timerState == .five {
                timerState = .ten
                button.setTitle("10", for: .normal)
                UserDefaults.standard.recordTimerState = 10
                
                AnalyticsManager.Post.trackCameraTimerPressed(responseType: productionState, challengeId: challengeId, timerState: .ten)
                
            }
            button.setTitleColor(.white, for: .normal)
            
        }
        
    }
    
    /**
     Cancel an active countdown timer
     */
    @IBAction func cancelTimerButtonTapped(_ sender: Any) {
        
        AnalyticsManager.Post.trackCameraCancelTimerPressed(responseType: productionState, challengeId: challengeId)
        
        countdownTimer?.invalidate()
        recordControlsContentView.isHidden = false
        recordControlModeSelectorView.isHidden = false
        editorOptionsView.isHidden = false
        navContainerView.isHidden = false
        libraryButton.isHidden = false
        countdownCancelButton.isHidden = true
        timerCountdownLabel.isHidden = true
        timerCountdownLabel.alpha = 0.0
        
        // Show the 'NEXT' action if there are segments
        if let count = editorVideoComposition?.session.segments.count, count > 0 {
            nextButton.isHidden = false
            removeSegmentButton.isHidden = false
        }
        
    }
    
    /**
     Toggle the camera device being used
     */
    @IBAction func flipCameraButtonTapped(_ sender: Any) {
        
        cameraManager?.toggleCameraPosition()
        
        if let position = cameraManager?.session?.recorder?.device {
            
            if position == .front {
                UserDefaults.standard.isRecordBackDeviceActive = false
                flashButton.isHidden = true
                cameraManager?.toggleTorchMode(mode: .off)
                
                AnalyticsManager.Post.trackCameraFlipPressed(responseType: productionState, challengeId: challengeId, cameraFlipState: .front)
                
            } else if position == .back {
                UserDefaults.standard.isRecordBackDeviceActive = true
                flashButton.isHidden = false
                
                if UserDefaults.standard.isRecordFlashOn {
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.225, execute: {
                        
                        if self.productionState == .image {
                            self.cameraManager?.toggleTorchMode(mode: .on)
                        } else {
                            self.cameraManager?.toggleTorchMode(mode: .light)
                        }
                        
                    })
                }
                
                AnalyticsManager.Post.trackCameraFlipPressed(responseType: productionState, challengeId: challengeId, cameraFlipState: .back)
                
            }
            
        }
        
    }
    
    /**
     Hide the option selector for the editor (returning to the recording layout)
     */
    @IBAction func endEffectEditingTapped(_ sender: Any) {
        
        isRecordingActive = false
        editorVideoComposition?.deselectActiveOverlay()
        
    }
    
    /**
     Begin filter selection mode for the current segment
     */
    @IBAction func filterButtonTapped(_ sender: Any) {
        
        tapToTypeHint.isHidden = true
        AnalyticsManager.Post.trackEditTabPressed(responseType: productionState, challengeId: challengeId, tabSelected: productionState == .text ? .background : .filter)
        
        showOptionSelector(forMode: productionState == .text ? .background : .filter)
       
        filterButton.shouldShowBorder = productionState == .text
        filterButton.isSelected = true
        
        let overlay = editorVideoComposition?.getActiveOverlay()
        overlay?.toggleDrawingEnabled(enabled: false)
        
    }
    
    /**
     Begin sticker selection mode for the current segment
     */
    @IBAction func stickerButtonTapped(_ sender: Any) {
        
        tapToTypeHint.isHidden = true
        AnalyticsManager.Post.trackEditTabPressed(responseType: productionState, challengeId: challengeId, tabSelected: .sticker)
        
        showOptionSelector(forMode: .sticker)
        stickersButton.isSelected = true
        
        let overlay = editorVideoComposition?.getActiveOverlay()
        overlay?.toggleDrawingEnabled(enabled: false)
        
    }
    
    /**
     Begin text editing mode on the current segment
     */
    @IBAction func textButtonTapped(_ sender: Any) {
        
        AnalyticsManager.Post.trackEditTabPressed(responseType: productionState, challengeId: challengeId, tabSelected: .text)
        
        showOptionSelector(forMode: .text)
        textButton.isSelected = true
        
        let overlay = editorVideoComposition?.getActiveOverlay()
        overlay?.toggleDrawingEnabled(enabled: false)
        
        if let subviews = overlay?.componentsView?.subviews {
            
            tapToTypeHint.isHidden = subviews.count > 0
            
            if subviews.count == 1, let textViewToCheck = subviews[0] as? UITextView, textViewToCheck.text.isEmpty {
                
                tapToTypeHint.isHidden = false
                
            }
            
        }
        
    }
    
    /**
     Begin drawing mode for the current segment
     */
    @IBAction func drawButtonTapped(_ sender: Any) {
        
        tapToTypeHint.isHidden = true
        AnalyticsManager.Post.trackEditTabPressed(responseType: productionState, challengeId: challengeId, tabSelected: .drawing)
        
        showOptionSelector(forMode: .doodle)
        
        let overlay = editorVideoComposition?.getActiveOverlay()
        overlay?.toggleDrawingEnabled(enabled: true)
        
        drawingButton.isSelected = true
        
    }
    
    /**
     Leave the recording flow if a recording wasn't started.
     */
    @IBAction func backButtonTapped(_ sender: Any) {
        handleBackButtonTapped(recordingState: isRecordingActive, forNonPostFlow: (forAvatar || forProfileCover))
    }
    
    /**
     Advance to cover selection
     */
    @IBAction func nextButtonTapped(_ sender: Any) {
        
        view.endEditing(true)
        
        if (forAvatar || forProfileCover) {
            
            guard let composition = editorVideoComposition else { return }
            
            tapToTypeHint.isHidden = true
            
            let image = composition.prepareImageComposition(image: UIImage(view: imagePreviewView))
            delegate?.imageSelected(image: image)
            dismiss(animated: true, completion: nil)
            
        } else {
            
            isBouncing = false
            
            if isRecordingActive && (productionState == .video || productionState == .image) {
                
                AnalyticsManager.Post.trackCameraNextPressed(responseType: productionState, challengeId: challengeId)
                isRecordingActive = false
                return
                
            } else {
                
                AnalyticsManager.Post.trackEditNextPressed(responseType: productionState, challengeId: challengeId)
                
                
            }
            
            AnalyticsManager.Post.trackEditNextPressed(responseType: productionState, challengeId: challengeId)
            
            if productionState == .video {
                
                startFinalPostCoordinator()
                
            } else if productionState == .image {
                
                editorVideoComposition?.finalEditedImage = editorVideoComposition?.prepareImageComposition(image: editorVideoComposition!.lastCapturedImage!)
                saveCoverImage(image: editorVideoComposition!.finalEditedImage!)
                
                startFinalPostCoordinator()
                
            } else {
                
                if let overlay = editorVideoComposition?.getActiveOverlay(), !overlay.hasEditingContent() {
                    
                    if let vc = R.storyboard.main.errorDialogViewControllerId() {
                        
                        vc.setValues(description : "Looks like you forgot to complete your response! Add some text or stickers to complete!")
                        vc.modalPresentationStyle = .overCurrentContext
                        present(vc, animated: false, completion: nil)
                        return
                        
                    }
                    
                }
                
                tapToTypeHint.isHidden = true
                AnalyticsManager.Post.trackEditNextPressed(responseType: productionState, challengeId: challengeId)
                
                editorVideoComposition?.finalEditedImage = editorVideoComposition?.prepareImageComposition(image: UIImage(view: imagePreviewView))
                saveCoverImage(image: editorVideoComposition!.finalEditedImage!)
                
                startFinalPostCoordinator()
                
            }
            
        }
        
    }
    
    /**
     Navigates the user to the systems settings
     */
    @IBAction func enablePermissionsTapped(_ sender: Any) {
        
        guard let settingsUrl = URL(string: UIApplicationOpenSettingsURLString) else {
            return
        }
        
        if UIApplication.shared.canOpenURL(settingsUrl) {
            UIApplication.shared.open(settingsUrl, options: [:], completionHandler: nil)
        }
        
    }
    
    /**
     Return to the root post flow and reset state
     */
    @IBAction func unwindSegueToRecordAndReset(_ sender: UIStoryboardSegue) {
        reset()
    }
    
    /**
     This segue assumes a new asset was inserted from the photo library.
     Update the composition and enable recording again.
     */
    @IBAction func unwindSegueToRecordAndRefreshComposition(_ sender: UIStoryboardSegue) {
        
        super.handleSaveDraft()
    
        // Disable segments for now
        editorVideoComposition?.beginPlayback()

        // Refresh timeline
        recordingTimelineView.clearAndResetTimeline()
        recordingTimelineView.layoutTimeline(withSegmentDurations: cameraManager?.getDurationsForAllSessionSegment() ?? [],
                                             maxRecordingLimit: CGFloat(cameraManager?.maxRecordingDuration ?? 30))

        // Enable the next step
        nextButton.isHidden = false
        removeSegmentButton.isHidden = false

        reloadFilterPreviewImage()
        
    }
    
    /**
     This segue assumes a new asset was inserted from the photo library.
     Update the composition and switch to the editor.
     */
    @IBAction func unwindSegueToRecordingEditAndRefreshComposition(_ sender: UIStoryboardSegue) {
        
        recordingTimelineView.clearAndResetTimeline()
        recordingTimelineView.layoutTimeline(withSegmentDurations: cameraManager?.getDurationsForAllSessionSegment() ?? [],
                                             maxRecordingLimit: CGFloat(cameraManager?.maxRecordingDuration ?? 30))
        
        reloadFilterPreviewImage()
        isRecordingActive = false
        
    }
    
    /**
     Return to the root post flow
     */
    @IBAction func unwindSegueToRecordingRoot(_ sender: UIStoryboardSegue) {
        
    }
    
    /**
     Return to the root post flow and set `lastCapturedImage` from the Composition
     */
    @IBAction func unwindSegueToRecordingAndReloadLibraryImage(_ sender: UIStoryboardSegue) {
        
        editorOptionsView.filterOptionsView.defaultPreviewImage = editorVideoComposition?.lastCapturedImage
        imagePreviewView.image = editorVideoComposition?.lastCapturedImage
        isRecordingActive = false
        
    }
    
    // MARK: - Private Properties
    
    /// The delay before triggering the recording session
    private var timeToBeginRecording: Int = 0
    
    /// Timer associated with the countdown
    private var countdownTimer: Timer?
    
    /// The selected state for the timer
    private var timerState: TimerState = .none
    
    /// Location of the cover image on disk
    fileprivate var coverImageURL: URL?
    
    /// Preview of the selected cover image
    fileprivate var coverImage: UIImage?
    
    /// Has the view setup saved flash, device and timer options
    fileprivate var hasSetupSavedControlState: Bool = false
    
    private var isBouncing = false
    private var bounceAmplitude : CGFloat = 7.5
    private var bounceOrigin : CGFloat = 7.5
    
    private var tapGestureRecognizer: UITapGestureRecognizer!
    
    private var finalPostCoordinator: FinalPostCoordinator?
    
    
    // MARK: - Public Properties
    
    
    /// The selected font to use for input
    open var defaultFontStyle: UIFont = R.font.openSansBold(size: 20.0)!
    
    /// The selected color to use for drawing or text
    open var defaultColorStyle: UIColor = .black
    
    /// The selected brush size
    open var defaultBrushSize: Constants.RecordingBrushSize = .size3
    
    /// The selected brush type
    open var defaultBrushType: Constants.RecordingBrushType = .brush
    
    /// Adjusts layout based on recording and editor
    var isRecordingActive: Bool = true {
        
        didSet {
            refreshSelectedLayoutMode()
        }
        
    }
    
    /// Whether the flow was loaded from the detail view
    var loadedFromDetailsView: Bool = false
    
    /// Session metadata that should be restored on load
    var restoreSessionMetadata: [AnyHashable: Any]?
    
    /// Flag to indicate whether editing is occurring for an avatar image
    var forAvatar: Bool = false
    
    /// Flag to indicate whether editing is occurring for a profile cover
    var forProfileCover: Bool = false
    
    weak var delegate: PostRecordViewControllerDelegate?
    
    // MARK: - Lifecycle
    
    deinit {
        log.verbose("💥")
        UIApplication.shared.isIdleTimerDisabled = false
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        configureView()
        
        if forAvatar {
            configureViewForAvatar()
        } else if forProfileCover {
            configureViewForProfileCover()
        }
        
        validateAuthorization()
        
        if (forAvatar || forProfileCover) {
            updateResponseType(toType: .image, forLaunch: true)
        } else {
            updateDefaultHomeTabPosition()
        }
        
        editorOptionsView.optionSelectorViewDelegate = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        cameraManager?.previewFrameNeedsUpdated()
        
        refreshSavedControlState()
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(applicationWillResign(_:)),
                                               name: .UIApplicationWillResignActive,
                                               object: nil)
        
        
    }

    override func viewDidLayoutSubviews() {
        
        super.viewDidLayoutSubviews()
        
        editorVideoComposition?.masterOverlayView?.refreshContentLayout()
        
        NotificationCenter.default.removeObserver(self, name: .UIApplicationWillResignActive, object: nil)
        
    }
    
    /**
     Handle preparing the video editor and verifying that a recording is valid
     */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let vc = R.segue.postRecordViewController.postImageMetadataSegue(segue: segue)?.destination {
            
            cameraManager?.sessionCoverImage = coverImage
            cameraManager?.sessionCoverImageURL = coverImageURL
            
            super.handleSaveDraft()
            
            vc.services = services
            vc.cameraManager = cameraManager
            vc.challengeId = challengeId
            vc.editorVideoComposition = editorVideoComposition
            vc.productionState = productionState
            
        }
        
    }
    
    // MARK: - Private Methods
    
    
    private func startFinalPostCoordinator() {
        
        guard let cameraManager = cameraManager else { return }
        
        previewPlayer?.pause()
        playButton.isSelected = !playButton.isSelected
        
        cameraManager.sessionCoverImage = coverImage
        cameraManager.sessionCoverImageURL = coverImageURL
        super.handleSaveDraft()
        
        guard let parentNavController = self.navigationController else { return }
        guard let maverickComposition = editorVideoComposition else { return }
        
        finalPostCoordinator = FinalPostCoordinator(navigationController: parentNavController, cameraManager: cameraManager, challengeId: challengeId, challengeTitle: challengeTitle, maverickComposition: maverickComposition, productionState: productionState)
        
        guard let finalPostCoordinator = finalPostCoordinator else { return }
        finalPostCoordinator.finalPostCoordinatorDelegate = self
        finalPostCoordinator.start()
        
    }
    
    /**
     Initialize the layout
     */
    override func configureView() {
        
        super.configureView()
        
        nextButton.addShadow()
        segmentControl.plain = false
        segmentControl.setTitle("VIDEO", forSegmentAt: 0)
        segmentControl.setTitle("IMAGE", forSegmentAt: 1)
        segmentControl.setTitle("TEXT", forSegmentAt: 2)
        segmentControl.selectedSegmentIndex = 0
        
        if DBManager.sharedInstance.shouldSeeTutorial(tutorialVersion: .textPost) {
        
            bounceOrigin = coachMarkTopConstraint.constant
            textPostNewCoachmark.addShadow(alpha: 0.3)
            showTextCoachMark(delay: 0.0)
            coachmarkTrailingConstraint.constant = -(UIScreen.main.bounds.width / 3 / 2 - textPostNewCoachmark.frame.width / 2)
        
        } else {
            
            textPostNewCoachmark.isHidden = true
        
        }
        
        UIApplication.shared.isIdleTimerDisabled = true
        
        // Configure navigation
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        libraryButton.applyBorder(.white, width: 1.0)
        
        recordingTimelineView.recordingIndicatorButton = recordingIndicatorButton
        
        timerCountdownLabel.alpha = 0.0
        timerCountdownLabel.isHidden = true
        timerCountdownLabel.applyDefaultDarkShadow()
        
        editorOptionsView.textOptionsView.delegate = self
        editorOptionsView.stickerOptionsView.delegate = self
        editorOptionsView.backgroundOptionsView.delegate = self
        editorOptionsView.filterOptionsView.delegate = self
    
        refreshLastPreviewImage()
        
        imagePreviewScrollView.maximumZoomScale = 10.0
        imagePreviewScrollView.minimumZoomScale = 1.0
        
        isRecordingActive = true
        flashButton.isHidden = true
        
        setupTapGestureRecognizer()
        
    }
    
    /**
     Perform additional view configuration for the layout when editing an avatar image.
     */
    func configureViewForAvatar() {
        
        segmentControl.removeAllSegments()
        segmentControl.insertSegment(withTitle: "IMAGE", at: 0, animated: true)
        segmentControl.insertSegment(withTitle: "TEXT", at: 1, animated: true)
        segmentControl.selectedSegmentIndex = 0
        
        imagePreviewView.contentMode = .scaleAspectFit
        let newConstraintForHeight = (view.frame.size.height - (recordControlsContentView.bounds.height + view.frame.width)) / 2
        cameraViewTopConstraint.constant = newConstraintForHeight
        recordControlsTopConstraint.constant = newConstraintForHeight
        aspectRatio = changeMultiplier(toNewValue: 1, forConstraint: aspectRatio)
        
        view.layoutIfNeeded()
        
    }
    
    /**
     Perform additional view configuration for the layout when editing a profile cover.
     */
    func configureViewForProfileCover() {
        
        segmentControl.removeAllSegments()
        segmentControl.insertSegment(withTitle: "IMAGE", at: 0, animated: true)
        segmentControl.insertSegment(withTitle: "TEXT", at: 1, animated: true)
        segmentControl.selectedSegmentIndex = 0
        
        imagePreviewView.contentMode = .scaleAspectFit
        let availableHeight = view.frame.size.height - recordControlsContentView.bounds.height
        let contentHeight = view.frame.width * 3/4
        let newConstraintForHeight = (availableHeight - contentHeight) / 2
        cameraViewTopConstraint.constant = newConstraintForHeight
        recordControlsTopConstraint.constant = newConstraintForHeight
        aspectRatio = changeMultiplier(toNewValue: 4/3, forConstraint: aspectRatio)
        
        view.layoutIfNeeded()
        
    }
    
    func changeMultiplier(toNewValue multiplierValue: CGFloat, forConstraint constraint: NSLayoutConstraint) -> NSLayoutConstraint {
        
        NSLayoutConstraint.deactivate([constraint])
        
        let newConstraint = NSLayoutConstraint(
            item: constraint.firstItem!,
            attribute: constraint.firstAttribute,
            relatedBy: constraint.relation,
            toItem: constraint.secondItem,
            attribute: constraint.secondAttribute,
            multiplier: multiplierValue,
            constant: constraint.constant)
        
        newConstraint.priority = constraint.priority
        
        NSLayoutConstraint.activate([newConstraint])
        return newConstraint
        
    }
    
    /**
     Save existing session when being sent to the background
    */
    @objc func applicationWillResign(_ notification: Notification) {
        super.handleSaveDraft()
    }
    
    /**
     Adjust layout based on if the recording mdoe is active via `isRecordingActive`
     */
    fileprivate func refreshSelectedLayoutMode() {
        
        if productionState == .video {
            filterButton.setImage(R.image.recordIconEditFilter(), for: .normal)
            filterButton.setImage(R.image.recordIconEditFilterActive(), for: .selected)
            filterButton.shouldShowBorder = false
            segmentControl.selectedSegmentIndex = 0
            // VIDEO PRODUCTION [record, edit modes]
            
            if isRecordingActive {
                
                undoButton.isHidden = true
                removeSegmentButton.isHidden = true
                editorContentView.isHidden = true
                cameraControlsView.isHidden = false
                recordControlsContentView.isHidden = false
                playButton.isHidden = true
                playButton.isSelected = false
                
                previewPlayer?.pause()
                cameraManager?.startRunning()
                
            } else {
                
                
                imagePreviewView.image = nil
                undoButton.isHidden = false
                removeSegmentButton.isHidden = false
                editorContentView.isHidden = false
                cameraControlsView.isHidden = true
                recordControlsContentView.isHidden = true
                playButton.isHidden = false
                
                cameraManager?.stopRunning()
                
                // Switch to the selected filter for the selected index
                if let filter = editorVideoComposition?.filterForSelectedIndex() {
                    cameraFilterSwitcherView.scroll(to: filter, animated: false)
                }
                
            }
            
            recordButton.setImage(R.image.recordButton(), for: .normal)
            recordButton.setImage(R.image.recordButtonStop(), for: .selected)
            
            // Reset
            recordingIndicatorButton.isHidden = true
            timerCountdownLabel.isHidden = true
            recordingTimelineView.isHidden = false
            imagePreviewScrollView.isHidden = true
            nextButton.isHidden = true
            
            // Show the 'NEXT' action if there are segments
            if let count = editorVideoComposition?.session.segments.count, count > 0 {
                nextButton.isHidden = false
                removeSegmentButton.isHidden = false
            }
            
        } else if productionState == .image  {
            
            filterButton.setImage(R.image.recordIconEditFilter(), for: .normal)
            filterButton.setImage(R.image.recordIconEditFilterActive(), for: .selected)
            filterButton.shouldShowBorder = false
           
            
            // IMAGE PRODUCTION
            segmentControl.selectedSegmentIndex = (forAvatar || forProfileCover) ? 0 : 1
            if isRecordingActive {
                
                editorOptionsView.filterOptionsView.defaultPreviewImage = nil
                undoButton.isHidden = true
                cameraControlsView.isHidden = false
                imagePreviewView.isHidden = true
                editorContentView.isHidden = true
                imagePreviewScrollView.isHidden = true
                recordControlsContentView.isHidden = false
                
            } else {
                
                undoButton.isHidden = false
                cameraControlsView.isHidden = true
                imagePreviewView.isHidden = false
                editorContentView.isHidden = false
                imagePreviewScrollView.isHidden = false
                removeSegmentButton.isHidden = true
                recordControlsContentView.isHidden = true
                
            }
            
            recordButton.setImage(R.image.photoButton(), for: .normal)
            recordButton.setImage(nil, for: .selected)
            
            recordingIndicatorButton.isHidden = true
            recordingTimelineView.isHidden = true
            nextButton.isHidden = true
            
            // Show the 'NEXT' action if there is a saved image
            if editorVideoComposition?.lastCapturedImage != nil {
                nextButton.isHidden = false
            }
            
        } else if productionState == .text  {
            
            
            nextButton.isHidden = false
            filterButton.setImage(R.image.background_tab(), for: .normal)
            filterButton.setImage(R.image.background_tab(), for: .selected)
            filterButton.shouldShowBorder = true
            filterButton.isSelected = true
            
            
            if let color = Variables.Content.getPostTextBackgroundColors()[safe: 0] {
                
                editorVideoComposition?.backgroundColor = color
                imagePreviewView.backgroundColor = color
                filterButton.tintColor = color
                
            }
            
            imagePreviewView.image = nil
            
            undoButton.isHidden = false
            cameraControlsView.isHidden = true
            imagePreviewView.isHidden = false
            editorContentView.isHidden = false
            imagePreviewScrollView.isHidden = false
            removeSegmentButton.isHidden = true
            recordControlsContentView.isHidden = true
            
            
        }
        
        editorOptionsView.isHidden = false
        countdownCancelButton.isHidden = true
        navContainerView.isHidden = false
        libraryButton.isHidden = false
        recordControlModeSelectorView.isHidden = false
        countdownButton.isHidden = false
        editorVideoComposition?.masterOverlayView.isHidden = false
        
        // Don't allow selection
        recordingTimelineView.isUserInteractionEnabled = false
        
        // Refresh flash state if it's on
        if UserDefaults.standard.isRecordFlashOn && !flashButton.isHidden {
            
            if isRecordingActive {
                if productionState == .image {
                    cameraManager?.toggleTorchMode(mode: .on)
                } else if productionState == .video {
                    cameraManager?.toggleTorchMode(mode: .light)
                } else {
                    cameraManager?.toggleFlashMode(mode: .off)
                }
            } else {
                cameraManager?.toggleTorchMode(mode: .off)
            }
            
        } else {
            cameraManager?.toggleTorchMode(mode: .off)
        }
        
    }
    
    /**
     Initialize the camera manager and restore a previous session if `restoreSessionMetadata`
     exists.
     */
    func configureCameraManager() {
        
        // Setup the camera manager
        cameraManager = CameraManager(withPreviewView: cameraPreviewView)
        cameraManager?.delegate = self
        cameraManager?.sessionChallengeId = challengeId
        cameraManager?.sessionChallengeTitle = challengeTitle
        
        recordingTimelineView.delegate = self
        
        // Restore session?
        if let metadata = restoreSessionMetadata {
            
            nextButton.isHidden = false
            
            cameraManager?.prepareRecordingSession(withSavedMetadata: metadata)
            
            if let _ = metadata["sessionImageName"] as? String {
                
                productionState = .image
                
            } else if let _ = metadata["sessionTextColor"] as? String {
            
                productionState = .text
            
            } else {
                
                cameraManager?.startRunning()
                
                // Layout the timeline
                recordingTimelineView.layoutTimeline(withSegmentDurations: cameraManager?.getDurationsForAllSessionSegment() ?? [],
                                                     maxRecordingLimit: CGFloat(cameraManager?.maxRecordingDuration ?? 30))
                
            }
            
        } else {
            
            cameraManager?.prepareRecordingSession()
            cameraManager?.startRunning()
            
        }
        
        // Hide flash button if flash isn't available for the device
        if let hasFlash = cameraManager?.deviceHasFlash() {
            flashButton.isEnabled = hasFlash
        }
        
    }
    
    /**
     Initialize the camera manager for editing not in the post flow.
     */
    func configureCameraManagerForNonPostFlow() {
    
        cameraManager = CameraManager(withPreviewView: cameraPreviewView)
        cameraManager?.delegate = self
        cameraManager?.prepareRecordingSession()
        cameraManager?.startRunning()
        
        // Hide flash button if flash isn't available for the device
        if let hasFlash = cameraManager?.deviceHasFlash() {
            flashButton.isEnabled = hasFlash
        }
        
    }
    
    /**
     Initialize a `MaverickComposition` that will be used to stich together the
     recorded segments along with exporting the composition out for publishing.
     
     This will also check for an `existingSessionMetadata` within the `CameraManager`
     and layout any saved content within.
     */
    func configureComposition() {
        
        // Is already configured?
        if editorVideoComposition != nil { return }
        
        // Camera manager needs to be setup first
        guard let session = cameraManager?.session else {
            
            // TODO: Handle Error
            return
            
        }
        
        previewPlayer = SCPlayer()
        editorVideoComposition = MaverickComposition(withSession: session,
                                                     previewPlayer: previewPlayer!,
                                                     recordViewController: self)
        
        cameraFilterSwitcherView.contentMode = .scaleAspectFill
        cameraFilterSwitcherView.filters = editorVideoComposition!.filters
//
//        // Set preview image in the filter editor
        editorOptionsView.filterOptionsView.filters = editorVideoComposition!.filters
        
        if let metadata = cameraManager?.existingSessionMetadata {
            
            cameraManager?.sessionChallengeId = (metadata["challengeId"] as? String ?? "")
            cameraManager?.sessionChallengeTitle = (metadata["challengeTitle"] as? String ?? "")
            cameraManager?.sessionDescription = (metadata["description"] as? String ?? "")
            
            if productionState == .video {
                
                if let coverImagePath = metadata["coverImagePath"] as? String,
                    let url = URL(string: coverImagePath)
                {
                    cameraManager?.sessionCoverImageURL = url
                }
                
                editorVideoComposition?.reloadSessionComposition()
                
                // Initialize overlays for an existing segment
                var idx = 0
                for _ in session.segments {
                    _ = editorVideoComposition?.getOverlay(forIndex: idx)
                    idx += 1
                }
                
            } else if productionState == .image {
                
                // Photo Session
                if let name = metadata["sessionImageName"] as? String,
                    let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                    
                    let docPath = dir.appendingPathComponent(name).appendingPathExtension("jpg").path
                    let image = UIImage(contentsOfFile: docPath)
                    
                    editorOptionsView.filterOptionsView.defaultPreviewImage = image
                    editorVideoComposition?.lastCapturedImage = image
                    imagePreviewView.image = image
                    
                }
                
            } else {
                
                // Photo Session
                if let color = metadata["sessionTextColor"] as? String {
                    
                    editorOptionsView.filterOptionsView.defaultPreviewImage = nil
                    editorVideoComposition?.lastCapturedImage = nil
                    imagePreviewView.image = nil
                    imagePreviewView.backgroundColor = UIColor(rgba: color)
                    editorVideoComposition?.backgroundColor = imagePreviewView.backgroundColor
                    filterButtonTapped(self)
                    
                }
                
            }
            
            // Load overlays
            if let metadata = metadata["overlays"] as? [String: Any] {
                editorVideoComposition?.loadOverlayContent(withState: metadata)
            }
            
            // Reload filter preview image
            reloadFilterPreviewImage()
            
            isRecordingActive = false
            
        }
        
        // Start preview
        previewPlayer?.scImageView = cameraFilterSwitcherView
        previewPlayer?.loopEnabled = true

        
    }
    
    /**
     Initialize a `MaverickComposition` that will be used to stich together the
     recorded segments along with exporting the composition out for publishing.
     
     This will also check for an `existingSessionMetadata` within the `CameraManager`
     and layout any saved content within.
     */
    func configureCompositionForNonPostFlow() {
        
        // Is already configured?
        if editorVideoComposition != nil { return }
        
        // Camera manager needs to be setup first
        guard let session = cameraManager?.session else {
            
            // TODO: Handle Error
            return
            
        }
        
        previewPlayer = SCPlayer()
        editorVideoComposition = MaverickComposition(withSession: session,
                                                     previewPlayer: previewPlayer!,
                                                     recordViewController: self)
        
        cameraFilterSwitcherView.contentMode = .scaleAspectFill
        cameraFilterSwitcherView.filters = editorVideoComposition!.filters
        editorOptionsView.filterOptionsView.filters = editorVideoComposition!.filters
        
        // Start preview
        previewPlayer?.scImageView = cameraFilterSwitcherView
        previewPlayer?.loopEnabled = true
        
        //
        didSelectColor(UIColor.maverickVideoColors.first!)
        
    }
    
    /**
     Saves the image to disk
     */
    func saveCoverImage(image: UIImage) {
        
        let randomFilename = "\(cameraManager!.session!.identifier)_coverImage" + ".jpg"
        let data = UIImageJPEGRepresentation(image, 0.8)
        let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last!
        coverImageURL = dir.appendingPathComponent(randomFilename)
        coverImage = image
        FileManager.default.createFile(atPath: coverImageURL!.path, contents: data, attributes: nil)
        
    }
    
    /**
     Change the production state from Video or Photo
     */
    func updateResponseType(toType type: Constants.UploadResponseType, forLaunch: Bool = false) {
        
        productionState = type
        
        if forLaunch {
            reset(forInitialLaunch: true)
        } else {
            reset()
        }
        
        refreshSelectedLayoutMode()
        refreshLastPreviewImage()
        
    }
    
    // MARK: - Private Methods
    
    private func updateDefaultHomeTabPosition() {
        
        if cameraManager?.existingSessionMetadata == nil {
            
            let lpIndexForHomeTab = Variables.Features.postFlowHomeTabIndex.integerValue()
            
            let mediaTypeForHomeTab: Constants.UploadResponseType =
                lpIndexForHomeTab == 0 ? .video :
                    lpIndexForHomeTab == 1 ? .image : .video
            
            if productionState != mediaTypeForHomeTab {
                updateResponseType(toType: mediaTypeForHomeTab, forLaunch: true)
            }
            
        }
        
    }
    
    
    /**
     Reset the camera manager and view state
     */
    fileprivate func reset(forInitialLaunch: Bool = false) {
        
        filterButtonTapped(self)
        
        cameraManager?.resetSCSession()
        cameraManager?.delegate = self
        cameraManager?.scPreviewView = cameraPreviewView
        cameraManager?.prepareRecordingSession()
        cameraManager?.startRunning()
        cameraManager?.recorder.captureSessionPreset = productionState == .video ?  SCRecorderTools.bestCaptureSessionPresetCompatibleWithAllDevices() : AVCaptureSession.Preset.photo.rawValue
        recordingTimelineView.reset()
        recordingTimelineView.clearAndResetTimeline()
        
        if !forInitialLaunch {
            editorVideoComposition?.prepareForReuse(shouldDeleteLocalAssets: true)
        }
        
        editorOptionsView.filterOptionsView.defaultPreviewImage = nil
        editorVideoComposition?.lastCapturedImage = nil
        imagePreviewView.image = nil
        isRecordingActive = true
        
    }
    
    /**
     Sets the layout of the option selector and shows it
     */
    fileprivate func showOptionSelector(forMode mode: SelectorMode) {
        
        filterButton.isSelected = false
        stickersButton.isSelected = false
        textButton.isSelected = false
        drawingButton.isSelected = false
        undoButton.isHidden = false
        
        
        // Update mode layout
        editorOptionsView.mode = mode
          
    }
    
    /**
     Begin recording after the provided time (in seconds)
     */
    private func beginRecording(after time: Int) {
        
        timeToBeginRecording = time
        
        navContainerView.isHidden = true
        libraryButton.isHidden = true
        recordControlModeSelectorView.isHidden = true
        recordControlsContentView.isHidden = true
        editorOptionsView.isHidden = true
        navContainerView.isHidden = true
        countdownCancelButton.isHidden = false
        timerCountdownLabel.isHidden = false
        timerCountdownLabel.text = "\(time)"
        UIView.animate(withDuration: 0.225) {
            self.timerCountdownLabel.alpha = 1.0
        }
        
        countdownTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            
            self.timeToBeginRecording -= 1
            self.updateCountdownLabel(remaining: self.timeToBeginRecording)
            
            if self.timeToBeginRecording == 0 {
                
                self.countdownTimer?.invalidate()
                
                UIView.animate(withDuration: 0.225, animations: {
                    self.timerCountdownLabel.alpha = 0.0
                }) { done in
                    self.timerCountdownLabel.isHidden = true
                }
                
                // Start recording
                let original = self.timerState
                self.timerState = .none
                self.recordButtonPressed(self.recordButton)
                self.timerState = original
                
            }
            
        }
        
    }
    
    /**
     Show a countdown label
     */
    private func updateCountdownLabel(remaining: Int) {
        
        UIView.animate(withDuration: 0.225, animations: {
            self.timerCountdownLabel.alpha = 0.0
        }) { done in
            
            if self.countdownTimer?.isValid ?? false {
                
                self.timerCountdownLabel.text = "\(remaining)"
                UIView.animate(withDuration: 0.225) {
                    self.timerCountdownLabel.alpha = 1.0
                }
                
            }
        }
        
    }
    
    /**
     Begin or end a recording
     */
    fileprivate func handleRecordingStateChanged(isRecording: Bool) {
        
        if isRecording {
            
            navContainerView.isHidden = false
            libraryButton.isHidden = false
            recordControlsContentView.isHidden = false
            recordControlModeSelectorView.isHidden = false
            recordButton.isSelected = false
            removeSegmentButton.isHidden = false
            
            // Stop recording this segment and save the current progress
            cameraManager?.stopRecording {
                
                super.handleSaveDraft()
            
            }
            
        } else {
            
            if cameraManager?.canBeginRecording() ?? false {
                
                navContainerView.isHidden = true
                recordControlsContentView.isHidden = false
                recordControlModeSelectorView.isHidden = true
                recordButton.isHidden = false
                recordButton.isSelected = true
                libraryButton.isHidden = true
                removeSegmentButton.isHidden = true
                countdownCancelButton.isHidden = true
                cameraManager?.startRecording()
                
            }
            
        }
        
    }
    
    /**
     Switches the editor to photo mode, video mode, or text mode
     */
    fileprivate func handlePhotoModeToggle(goToText : Bool = false) {
        
        guard let editorVideoComposition = editorVideoComposition else { return }
        
        let handlePhotoModeSwitch: ((_ photoMode: Bool) -> Void) = { photoMode in
            if goToText {
              
                self.updateResponseType(toType: .text)
                
            } else {
            
                self.updateResponseType(toType:  photoMode ? .image : .video)
            
            }
        }
        
        if productionState == .video {
            
            
            if editorVideoComposition.session.segments.count > 0 {
                
                let topSpacer = MaverickActionSheetMessage(text: " ", font: R.font.openSansRegular(size: 20.0)!, textColor: .black)
                
                let message = MaverickActionSheetMessage(text: R.string.maverickStrings.recordFlowPhotoModeToggleActionSheetMessage(), font: R.font.openSansRegular(size: 20.0)!, textColor: UIColor.black)
                
                let middleSpacer = MaverickActionSheetMessage(text: " ", font: R.font.openSansRegular(size: 20.0)!, textColor: .black)
                
                let action = MaverickActionSheetButton(text: R.string.maverickStrings.recordFlowPhotoModeToggleActionSheetButton(), font: R.font.openSansRegular(size: 20.0)!, action: { handlePhotoModeSwitch(true) }, textColor: UIColor.MaverickPrimaryColor)
                
                let bottomSpacer = MaverickActionSheetMessage(text: " ", font: R.font.openSansRegular(size: 20.0)!, textColor: .black)
                
                let maverickActionSheetViewModel = MaverickActionSheetViewModel(title: R.string.maverickStrings.recordFlowPhotoModeToggleActionSheetTitle(), maverickActionSheetItems: [topSpacer, message, middleSpacer, action, bottomSpacer], alignment: .center)
               
                let maverickActionSheetViewController = MaverickActionSheetVC(viewModel: maverickActionSheetViewModel)
                
                let maverickActionSheetTransitioningDelegate = MaverickActionSheetTransitioningDelegate()
                maverickActionSheetViewController.transitioningDelegate = maverickActionSheetTransitioningDelegate
                transitioningDelegate = maverickActionSheetTransitioningDelegate
                
                present(maverickActionSheetViewController, animated: true, completion: nil)
                return
                
            }
            
            handlePhotoModeSwitch(true)
            
        }
        else {
       
            handlePhotoModeSwitch(false)
        }
        
    }
    
    /**
     Make the image scrollable based on it's dimensions
     TODO: Improve/test this (remove equal constraints on the scroll view)
     */
    fileprivate func updateImagePreview(withImage image: UIImage?) {
        
        if image == nil {
            
            imagePreviewView.image = nil
            return
        
        }
        
        let size = image!.size
        
        let imageWidth = size.width
        let imageHeight = size.height
        
        let maxWidth = imagePreviewScrollView.bounds.size.width
        let maxHeight =  imagePreviewScrollView.bounds.size.height
        
        view.setNeedsUpdateConstraints()
        if imageWidth < imageHeight {
            
            imagePreviewContentViewWidth.constant = maxWidth
            imagePreviewContentViewHeight.constant = (imageHeight / imageWidth) * maxWidth
            
        } else {
            
            imagePreviewContentViewWidth.constant = (imageWidth / imageHeight) * maxHeight
            imagePreviewContentViewHeight.constant = maxHeight
            
        }
        view.layoutIfNeeded()
        
        imagePreviewView.image = image
        
    }
    
    /**
     Checks video and audio permissions
     */
    fileprivate func validateAuthorization() {
        
        if (forAvatar || forProfileCover) {
            
            configureCameraManagerForNonPostFlow()
            configureCompositionForNonPostFlow()
            return
            
        }
        
        
        // Verify video and audio status on load
        if AVCaptureDevice.authorizationStatus(for: .video) == .authorized &&
            AVCaptureDevice.authorizationStatus(for: .audio) == .authorized {
            
            configureCameraManager()
            configureComposition()
            
        } else {
            
            // Request video permission
            AVCaptureDevice.requestAccess(for: .video, completionHandler: { granted in
                
                if !granted {
                    
                    DispatchQueue.main.async {
                        self.view.addSubview(self.enableAccessContentView)
                        self.enableAccessContentView.autoPinEdgesToSuperviewEdges()
                    }
                    return
                    
                }
                
                // Request audio permission
                AVCaptureDevice.requestAccess(for: .audio, completionHandler: { granted in
                    
                    DispatchQueue.main.async {
                        
                        if granted {
                            
                            self.configureCameraManager()
                            self.configureComposition()
                            
                        } else {
                            
                            self.view.addSubview(self.enableAccessContentView)
                            self.enableAccessContentView.autoPinEdgesToSuperviewEdges()
                            
                        }
                        
                    }
                    
                    // Request library permission if needed
                    if PHPhotoLibrary.authorizationStatus() != .authorized {
                        
                        PHPhotoLibrary.requestAuthorization({ status in
                            
                            if status == .authorized {
                                
                                DispatchQueue.main.async {
                                    self.refreshLastPreviewImage()
                                }
                                
                            }
                            
                        })
                        
                    }
                    
                })
                
            })
            
        }
        
    }
    
    /**
     Refresh the library preview image based on the current `productionState`
     */
    fileprivate func refreshLastPreviewImage() {
        
        let mediaType: PHAssetMediaType = productionState == .video ? .video : .image
        UIImage.getLastPhotoLibraryImage(mediaType: mediaType) { image, _ in
            self.libraryButton.setBackgroundImage(image, for: .normal)
        }
        
    }
    
   
    /**
     Adjusts the flash, device and timer controls based on saved state
     */
    fileprivate func refreshSavedControlState() {
        
        if hasSetupSavedControlState {
            return
        }
        hasSetupSavedControlState = true
        
        // Configure existing options
        if UserDefaults.standard.isRecordFlashOn && !UserDefaults.standard.isRecordBackDeviceActive {
            flashButton.isSelected = true
            flashButton.isHidden = false
            
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.225, execute: {
                self.cameraManager?.toggleTorchMode()
            })
        }
        
        if UserDefaults.standard.isRecordBackDeviceActive {
            cameraManager?.toggleCameraPosition()
            flashButton.isSelected = false
            flashButton.isHidden = false
        } else {
            flashButton.isHidden = true
        }
        
        let timerNum = UserDefaults.standard.recordTimerState
        if timerNum != 0 {
            
            if timerNum == 5 {
                timerState = .five
                countdownButton.setTitle("5", for: .normal)
            } else if timerNum == 10 {
                timerState = .ten
                countdownButton.setTitle("10", for: .normal)
            }
            countdownButton.setTitleColor(.white, for: .normal)
            
        }
        
    }
    
    /**
     Sets up the tap gesture recognizer.
     */
    private func setupTapGestureRecognizer() {
        
        tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.tappableMinimizerViewWasTapped(_:)))
        
        editStickerOptionsViewTappableMinimizerView.addGestureRecognizer(tapGestureRecognizer)
        tapGestureRecognizer.cancelsTouchesInView = false
        
    }
    
    /**
     Minimizes the Edit Sticker Options View when the tappable view is pressed.
     */
    @objc
    func tappableMinimizerViewWasTapped(_ sender: UITapGestureRecognizer) {
        editorOptionsView.minimizeHeight()
    }
    
    // MARK: - Overrides
    
    override func handleSaveDraft() {
        
        super.handleSaveDraft()
        
        performSegue(withIdentifier: R.segue.postRecordViewController.unwindSegueToHomeId, sender: self)
        
    }
    
    override func handleBackButtonTapped(recordingState recording: Bool, forNonPostFlow flow: Bool) {
        
        if !isRecordingActive {
            
            if let _ = editorVideoComposition?.lastCapturedImage {
                super.handleBackButtonTapped(recordingState: isRecordingActive, forNonPostFlow: flow)
                return
            }
            
            isRecordingActive = true
            editorVideoComposition?.session.recorder?.refocus()
            
        } else {
            super.handleBackButtonTapped(recordingState: isRecordingActive, forNonPostFlow: flow)
        }
        
    }
    
    override func handleRestart() {
        
        super.handleRestart()
        
        reset()
        
    }
    
}

extension PostRecordViewController: CameraManagerDelegate {
    
    /// The camera manager failed
    func cameraManagerDidFail(withError error: CameraManagerError) {
        
    }
    
    /// The camera manager began recording at the provided path
    func cameraManagerDidBeginRecording(atFileURL url: URL) {
        recordingTimelineView.startAnimation(withDuration: Int(cameraManager!.maxRecordingDuration))
    }
    
    /// The camera manager completed recording at the provided path
    func cameraManagerDidCompleteRecording(atOutputURL url: URL, segmentDuration: Double, totalDuration: Double) {
        
        if totalDuration >= Double(cameraManager!.maxRecordingDuration) {
            recordButton.isSelected = false
            cameraControlsView.isHidden = true
        }
        
        navContainerView.isHidden = false
        nextButton.isHidden = false
        removeSegmentButton.isHidden = false
        
        recordingTimelineView.stopAnimation(segmentDuration: segmentDuration, totalDuration: totalDuration)
        editorVideoComposition?.insertSegmentOverlay()
        editorVideoComposition?.reloadSessionComposition()
        
        // Layout the preview for the filter options
        reloadFilterPreviewImage()
        
    }
    
    /// Camera manager completed configuration
    func cameraManagerDidCompleteSessionSetup() {
        
    }
    
    /// Capture session status changed
    func cameraManagerSessionStatusChanged(isRunning: Bool) {
        
    }
    
    /**
     Reloads the filter selector with the first frame of the composition
     */
    fileprivate func reloadFilterPreviewImage() {
        
        // Layout the preview for the filter options
        if editorOptionsView.filterOptionsView.defaultPreviewImage == nil {
            
            if let asset = editorVideoComposition?.session.segments.first?.asset {
                
                editorVideoComposition?.getFirstFrame(fromAsset: asset, completionHandler: { image in
                    
                    self.editorOptionsView.filterOptionsView.defaultPreviewImage = image
                    
                    // Set selected filter
                    if let masterFilter = self.editorVideoComposition?.masterOverlayFilter {
                        self.didSelectFilter(masterFilter)
                    }
                    
                })
                
            }
            
            
        } else {
            
            // Set selected filter for an image post
            if let masterFilter = self.editorVideoComposition?.masterOverlayFilter {
                didSelectFilter(masterFilter)
            }
            
            
        }
        
    }
    
}

extension PostRecordViewController: PostEditorDelegate {
    func lockedRewardTapped(rewardType: Reward.RewardTypes) {
        
        if let vc = R.storyboard.progression.gameWallViewControllerId(), let reward = services?.globalModelsCoordinator.isRewardAvailable(rewardKey: rewardType.rawValue) {
            
            vc.reward = reward
            vc.modalPresentationStyle = .overFullScreen
            present(vc, animated: false, completion: nil)
        
        }
         
    }
    
    func isRewardLocked(rewardType: Reward.RewardTypes) -> Bool {
        
        return !(services.globalModelsCoordinator.isRewardAvailable(rewardKey: rewardType.rawValue)?.completed ?? false)
    
    }
    
    
    
    func didSelectBackgroundColor(_ color: UIColor) {
        
        editorVideoComposition?.backgroundColor = color
        filterButton.tintColor = color
        imagePreviewView.image = nil
        imagePreviewView.backgroundColor = color
        tapToTypeHint.textColor = UIColor.textColor(bgColor: color)
        
    }
    
    
    func adjustOptionSelectorViewOffset(_ offset: CGFloat, newAlpha: CGFloat) {
        
    }
    
    func didCompleteOptionSelection(withTags tags: [String]?) {
        
    }
    
    func didSelectFilter(_ filter: SCFilter) {
        
        if let filterName = filter.name {
            
            AnalyticsManager.Post.trackEditFilterSelected(responseType: productionState, challengeId: challengeId, filterName: filterName)
            
        }
        
        // Register undo with the active overlay
        let lastFilter = editorVideoComposition?.masterOverlayFilter
        let overlay = editorVideoComposition?.getActiveOverlay()
        overlay?.undoManager.registerUndo(withTarget: self) { this in
            
            let filter: SCFilter?
            if lastFilter == nil {
                filter = this.editorVideoComposition!.filters.first!
            } else {
                filter = lastFilter!
            }
            
            this.didSelectFilter(filter!)
            this.editorVideoComposition?.setFilterForSelectedIndex(filter!)
            this.editorOptionsView.filterOptionsView?.setSelectedFilter(withFilter: filter!)
            
        }
        overlay?.undoManager.setActionName("Set Filter")
        
        // Apply filter
        editorVideoComposition?.setFilterForSelectedIndex(filter)
        updateSubfilters(withFilterValues: editorVideoComposition!.filterParamsForSelectedIndex(), subfilters: filter.subFilters)
        
       
        
        if productionState == .video {
            cameraFilterSwitcherView.scroll(to: filter, animated: false)
        } else {
            applyFilterWithLastCapturedImageForPreview(filter: filter)
        }
        
        super.handleSaveDraft()
        
    }
    
    func didSelectSticker(_ image: UIImage, stickerName: String) {
        
        AnalyticsManager.Post.trackEditStickerSelected(responseType: productionState, challengeId: challengeId, stickerName: stickerName)
        
        editorVideoComposition?.insertImageView(withImage: image, stickerName: stickerName)
        
        super.handleSaveDraft()
        
    }
    
    func setInitialColor(_ color: UIColor) {
        defaultColorStyle = color
    }
    
    func didSelectColor(_ color: UIColor) {
        
        defaultColorStyle = color
        editorVideoComposition?.getActiveOverlay()?.setDrawingColor(color: color)
        
        if let field = editorVideoComposition?.getActiveOverlay()?.lastSelectedInputField {
            field.textColor = color
        }
        
        if textButton.isSelected {
            
            AnalyticsManager.Post.trackEditTextSelected(responseType: productionState, challengeId: challengeId, fontName: defaultFontStyle, fontColor: defaultColorStyle)
            
        } else if drawingButton.isSelected {
            
            AnalyticsManager.Post.trackEditPenSelected(responseType: productionState, challengeId: challengeId, brushType: defaultBrushType, brushSize: defaultBrushSize, brushColor: defaultColorStyle)
            
        }
        
    }
    
    func didSelectFont(_ font: UIFont) {
        
        defaultFontStyle = font
        
        if let overlay = editorVideoComposition?.getActiveOverlay(),
            let lastSelectedInputField = overlay.lastSelectedInputField {
            
            overlay.setInputFont(font: UIFont(name: font.fontName,
                                              size: lastSelectedInputField.font!.pointSize)!)
            
        }
        
        AnalyticsManager.Post.trackEditTextSelected(responseType: productionState, challengeId: challengeId, fontName: defaultFontStyle, fontColor: defaultColorStyle)
        
        super.handleSaveDraft()
        
    }
    
    func didSelectUndoAction() {
        editorVideoComposition?.getActiveOverlay()?.undoLastDrawingStroke()
    }
    
    func didSelectRedoAction() {
        editorVideoComposition?.getActiveOverlay()?.redoLastDrawingStroke()
    }
    
    func didSelectBrushType(_ type: Constants.RecordingBrushType) {
        
        defaultBrushType = type
        editorVideoComposition?.getActiveOverlay()?.setDrawingBrushType(type: type,
                                                                        withColor: defaultColorStyle,
                                                                        size: defaultBrushSize)
        
        AnalyticsManager.Post.trackEditPenSelected(responseType: productionState, challengeId: challengeId, brushType: defaultBrushType, brushSize: defaultBrushSize, brushColor: defaultColorStyle)
        
    }
    
    func didSelectBrushSize(_ type: Constants.RecordingBrushSize) {
        
        defaultBrushSize = type
        editorVideoComposition?.getActiveOverlay()?.setDrawingPointSize(size: type)
        
        AnalyticsManager.Post.trackEditPenSelected(responseType: productionState, challengeId: challengeId, brushType: defaultBrushType, brushSize: defaultBrushSize, brushColor: defaultColorStyle)
        
    }
    
    func didUpdateFilter(withFilterValues values: [Constants.FilterParameter: CGFloat]) {
        
        editorVideoComposition?.updateParamsForSegment(params: values)
        updateSubfilters(withFilterValues: values, subfilters: editorVideoComposition?.masterOverlayFilter?.subFilters)
        
        if productionState == .image {
            
            if let filter = editorVideoComposition?.masterOverlayFilter {
                applyFilterWithLastCapturedImageForPreview(filter: filter)
            }
            
        }
        
    }
    
    fileprivate func applyFilterWithLastCapturedImageForPreview(filter: SCFilter) {
        
        guard let capturedImage = editorVideoComposition?.lastCapturedImage else { return }
        
        editorVideoComposition?.finalEditedImage = filter.uiImage(byProcessingUIImage: capturedImage)
        imagePreviewView.image = editorVideoComposition?.finalEditedImage
        
    }
    
    fileprivate func updateSubfilters(withFilterValues values: [Constants.FilterParameter: CGFloat], subfilters: [Any]? = nil) {
        
        if let filters = (subfilters ?? cameraFilterSwitcherView.selectedFilter?.subFilters) as? [SCFilter] {
            
            for s in filters {
                
                if let name = s.name, name == "CIColorControls" {
                    
                    if let brightness = values[.inputBrightness] {
                        s.setParameterValue(brightness, forKey: Constants.FilterParameter.inputBrightness.rawValue)
                    }
                    
                    if let saturation = values[.inputSaturation] {
                        s.setParameterValue(saturation, forKey: Constants.FilterParameter.inputSaturation.rawValue)
                    }
                    
                } else if let name = s.name, name == "CIHueAdjust" {
                    
                    if let angle = values[.inputAngle] {
                        s.setParameterValue(angle, forKey: Constants.FilterParameter.inputAngle.rawValue)
                    }
                    
                }
                
            }
            
        }
        
        cameraFilterSwitcherView.setNeedsDisplay()
        
    }
    
}

extension PostRecordViewController: PostTimelineDelegate {
    
    func didSelectSegment(atIndex index: Int) {
        
        if let segment = self.editorVideoComposition!.segment(forIndex: index) {
            self.editorVideoComposition!.beginPlayback(forSegment: segment)
        }
        // Highlight selection
        recordingTimelineView.setSelectedIndex(atIndex: index)
        
        // Show filter
        cameraFilterSwitcherView.scroll(to: editorVideoComposition!.filterForSelectedIndex(),
                                        animated: false)
        
        // Force edit to end
        endEffectEditingTapped(self)
        
        // Make sure editing mode is on
        if isRecordingActive {
            isRecordingActive = false
        }
        
    }
    
}

extension PostRecordViewController: UIScrollViewDelegate {
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imagePreviewContentView
    }
    
}

class RoundSelectedButton : UIButton {
    
    var shouldShowBorder = false
    override var isSelected: Bool {
      
        didSet {
            
            if !shouldShowBorder {
                imageView?.layer.borderColor = UIColor.clear.cgColor
                return
            }
            guard let imageView = imageView else { return }
            
            if isSelected {
                
                imageView.layer.cornerRadius = imageView.frame.height / 2
                imageView.layer.borderColor = UIColor(rgba: "F1495B")?.cgColor
                imageView.layer.borderWidth = 2
                
            } else {
                
                imageView.layer.cornerRadius = imageView.frame.height / 2
                imageView.layer.borderColor = UIColor(rgba: "C2C2C2")?.cgColor
                imageView.layer.borderWidth = 2
                
                
            }
            
        }
  
    }
    
}


extension PostRecordViewController {
    
    private func lowerCoachMark( delay : CGFloat = 0) {
        
        self.coachMarkTopConstraint.constant = bounceOrigin + bounceAmplitude
        
        UIView.animateKeyframes(withDuration: 0.5, delay: TimeInterval(delay), options: [], animations: {
            
            self.textPostNewCoachmark.alpha = 1
            self.view.layoutIfNeeded()
            
        }) { (result) in
            
            if self.isBouncing {
                
                self.raiseCoachmark()
                
            } else {
                
                UIView.animate(withDuration: 0.5, animations: {
                    
                    self.textPostNewCoachmark.alpha = 0
                    
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
                    
                    self.textPostNewCoachmark.alpha = 0
                    
                }, completion: nil)
                
            }
            
        }
        
    }
    
    
    func showTextCoachMark(delay : CGFloat) {
        
        if !isBouncing {
            
            isBouncing = true
            lowerCoachMark(delay: delay)
            
        }
        
    }
    
}

extension PostRecordViewController: OptionSelectorViewDelegate {
    
    func enableTappableMinimizerView(_ enabled: Bool) {
        editStickerOptionsViewTappableMinimizerView.isHidden = !enabled
    }
    
}

extension PostRecordViewController: FinalPostCoordinatorDelegate {
    
    func finalPostFlowHasClosed() {
        
        finalPostCoordinator = nil
        performSegue(withIdentifier: R.segue.postRecordViewController.unwindSegueToHomeId, sender: self)
        
    }
    
    func finalPostCoordinatorDidPressBackButton() {
        finalPostCoordinator = nil
    }
    
}

extension PostRecordViewController: MaverickPickerDelegate {
    
    func imageSelected(image: UIImage) {
        
        DispatchQueue.main.async {
            self.editorVideoComposition?.lastCapturedImage = image
            self.editorOptionsView.filterOptionsView.defaultPreviewImage = self.editorVideoComposition?.lastCapturedImage
            self.imagePreviewView.image = self.editorVideoComposition?.lastCapturedImage
            self.isRecordingActive = false
        }
        
    }
    
}
