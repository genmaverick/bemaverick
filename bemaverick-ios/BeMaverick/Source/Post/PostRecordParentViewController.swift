//
//  PostRecordBaseViewController.swift
//  BeMaverick
//
//  Created by David McGraw on 12/20/17.
//  Copyright © 2017 BeMaverick. All rights reserved.
//

import UIKit
import SCRecorder
import Kingfisher

enum RecordState {
    case video, image
}

class PostRecordParentViewController: UIViewController {
    
    // MARK: - IBOutlet
    
    /// A view containing the record action and progress tracking
    @IBOutlet weak var videoPreviewView: SCVideoPlayerView!
    
    /// A view containing a preview of the video
    @IBOutlet weak var cameraPreviewView: UIView!
    
    /// A view containing the video preview and editor components
    @IBOutlet weak var editorContentView: UIView!
    
    /// A view sitting above the recording containing the overlays for each segment
    @IBOutlet weak var editorOverlayContentView: UIView!
    
    /// A preview of a selected image
    @IBOutlet weak var imagePreviewView: UIImageView!
    
    /// A preview layer below the content view
    @IBOutlet weak var cameraFilterSwitcherView: SCSwipeableFilterView!
    
    /// A view containing the record action and progress tracking
    @IBOutlet weak var recordingTimelineView: PostTimelineView!
        
    /// An option selector view revealing filters and tags
    @IBOutlet weak var editorOptionsView: OptionSelectorView!
    
    /// Used when preparing the edited content for upload
    @IBOutlet weak var loadingView: LoadingView!
    
    /// A custom title for this view
    @IBOutlet weak var titleLabel: UILabel?
    
    // MARK: - Public Properties
    
    /// The `GlobalServicesContainer` that maintains access to global services
    open var services: GlobalServicesContainer! = (UIApplication.shared.delegate as! AppDelegate).services
    
    /// Camera manager responsible for managing the recording process
    open var cameraManager: CameraManager?
    
    /// A composition of the video under edit
    open var editorVideoComposition: MaverickComposition?
    
    /// A player object for previewing
    open var previewPlayer: SCPlayer?
    
    /// The selected challenge that the user is responding to
    open var challenge: Challenge?
    
    /// The title of the challenge
    open var challengeTitle: String = "Challenge Title" {
        
        didSet {
            
            titleLabel?.text = challengeTitle
        
        }
        
    }
    
    /// The challenge that's being responded to
    open var challengeId: String? = nil
    
    /// The type of content the user is working on
    open var productionState: Constants.UploadResponseType = .video
        
    // MARK: - Lifecycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        trackScreen()
    }
    
    deinit {
        
        previewPlayer?.scImageView = nil
        log.verbose("💥")
        #if targetEnvironment(simulator)
        return
        #endif
        cameraFilterSwitcherView?.filters = nil
        
    }
        
    /**
     Adjust the camera manager frame
     */
    override func viewDidLayoutSubviews() {
        
        super.viewDidLayoutSubviews()
        
        cameraManager?.previewFrameNeedsUpdated()
        
    }
    
    
   
    
    // MARK: - Private Methods
    
    /**
     Track that the user has started viewing this class.
     */
    private func trackScreen() {
        AnalyticsManager.trackScreen(location: self)
    }
    
    // MARK: - Public Methods
    
    /**
     Default view configuration
    */
    func configureView() {
        
        
        
    }
    
    /**
     Default configuration for the navigation right bar button item
    */
    open func configureNavigationRightBarItem(target: Any?,
                                              action: Selector?,
                                              text: String = "EDIT",
                                              image: UIImage? = nil,
                                              color: UIColor = .white)
    {
        
        if image != nil {
            
            navigationItem.rightBarButtonItem = UIBarButtonItem(image: image,
                                                                style: .plain,
                                                                target: target,
                                                                action: action)
            return
            
        }
        
        let barItem = UIBarButtonItem(title: text,
                                      style: .plain,
                                      target: target,
                                      action: action)
        
        let attributedStringShadow = NSShadow()
        attributedStringShadow.shadowOffset = CGSize(width: 0.0, height: 0.0)
        attributedStringShadow.shadowBlurRadius = 1.0
        attributedStringShadow.shadowColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.4)
        
        var attributes: [NSAttributedStringKey : Any] = [ : ]
        attributes[NSAttributedStringKey.foregroundColor] = color
        attributes[NSAttributedStringKey.shadow] = attributedStringShadow
        if let font = R.font.openSansBold(size: 12.0) {
            attributes[NSAttributedStringKey.font] = font
        }
        barItem.setTitleTextAttributes(attributes, for: .normal)
        barItem.setTitleTextAttributes(attributes, for: .selected)
        
        navigationItem.rightBarButtonItem = barItem
        
    }
    
  
    
    func handleBackButtonTapped(recordingState recording: Bool, forNonPostFlow: Bool) {
        
        let photo = editorVideoComposition?.lastCapturedImage
        let color = editorVideoComposition?.backgroundColor
        let count = editorVideoComposition?.session.segments.count ?? 0
        
        // Check for saved session and prompt to confirm
        if count > 0 || photo != nil || color != nil{
            
            if recording {
                AnalyticsManager.Post.trackCameraBackPressed(responseType: productionState,
                                                             challengeId: challengeId,
                                                             sessionState: .yes)
            } else {
                AnalyticsManager.Post.trackEditBackPressed(responseType: productionState,
                                                           challengeId: challengeId)
            }
            
            let saveDraftAction = { [unowned self] in
                
                AnalyticsManager.Post.trackCameraSaveDraftPressed(responseType: self.productionState, challengeId: self.challengeId, challengeTitle: self.challengeTitle)
                self.handleSaveDraft()
                
                }
            
            let startOverAction = { [unowned self] in
                
                if self.productionState == .text {
                    
                    if forNonPostFlow {
                        self.productionState = .image
                    } else {
                        self.productionState = .video
                    }
                
                }
                AnalyticsManager.Post.trackCameraStartOverPressed(responseType: self.productionState, challengeId: self.challengeId)
                self.handleRestart()
                
                }
            
            let cancelAction = { [unowned self] in
                
                AnalyticsManager.Post.trackCameraCancelPressed(responseType: self.productionState, challengeId: self.challengeId)
                // Otherwise ignore
                
                }
            
            let goBackCustomActionSheetItem = forNonPostFlow ?  GoBackCustomActionSheetItem(startOverAction: startOverAction, cancelAction: cancelAction) : GoBackCustomActionSheetItem(saveDraftAction: saveDraftAction, startOverAction: startOverAction, cancelAction: cancelAction)
            
            let maverickActionSheetViewModel = MaverickActionSheetViewModel(title: R.string.maverickStrings.recordFlowGoBackActionSheetTitle(), maverickActionSheetItems: [goBackCustomActionSheetItem], alignment: .center)
            let maverickActionSheetViewController = MaverickActionSheetVC(viewModel: maverickActionSheetViewModel)
            
            let maverickActionSheetTransitioningDelegate = MaverickActionSheetTransitioningDelegate()
            maverickActionSheetViewController.transitioningDelegate = maverickActionSheetTransitioningDelegate
            transitioningDelegate = maverickActionSheetTransitioningDelegate
            
            present(maverickActionSheetViewController, animated: true, completion: nil)
            
        } else {
            
            AnalyticsManager.Post.trackCameraBackPressed(responseType: productionState,
                                                         challengeId: challengeId,
                                                         sessionState: .no)
            
            cameraManager?.removeRecordSegmentsFromSession()
            dismiss(animated: true, completion: nil)
            
        }
        
    }
    
    func handleSaveDraft() {
        
        cameraManager?.saveRecordSession(withComposition: editorVideoComposition)
    
    }
    
    func handleRestart() {
        
        editorVideoComposition?.prepareForReuse(shouldDeleteLocalAssets: true)
        cameraManager?.removeRecordSegmentsFromSession()
  
    }
    
    /**
     Display an activity indicator
     */
    open func showLoadingIndicator(withMessage message: String = "Preparing For Upload") {
        
        if loadingView == nil {
            loadingView = LoadingView.instanceFromNib()
            view.addSubview(loadingView!)
            
            loadingView?.autoAlignAxis(toSuperviewAxis: .vertical)
            loadingView?.autoAlignAxis(.horizontal, toSameAxisOf: view, withOffset: -50)
            loadingView?.autoSetDimension(.width, toSize: 240)
            loadingView?.autoSetDimension(.height, toSize: 128)
            
        }
        
        view.isUserInteractionEnabled = false
        
        loadingView?.titleLabel.text = message
        loadingView?.startAnimating()
        
    }
    
    /**
     Hide an activity indicator
     */
    open func hideLoadingIndicator() {
        
        loadingView?.superview?.isUserInteractionEnabled = true
        loadingView?.stopAnimating()
        loadingView?.removeFromSuperview()
        loadingView = nil
        
    }
    
    // MARK: - Overrides
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .none
    }

}
