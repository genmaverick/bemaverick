//
//  FinalPostViewModel.swift
//  Maverick
//
//  Created by Chris Garvey on 8/7/18.
//  Copyright © 2018 BeMaverick. All rights reserved.
//

import Foundation
import CoreMedia
import AVFoundation
import SCRecorder

protocol FinalPostViewModelVideoDelegate: class {
    func didUpdateProgess(withValue: Float)
    func didFinishProcessingVideo(success: Bool, withError: String?)
    func didUpdatePreviewImage()
}

typealias VideoProcessingCompletionHandler = (UIImage?, String?) -> Void

class FinalPostViewModel {
    
    // MARK: - Public Properties
    /// Identifier used for the share functionality.
    public private(set) var localIdentifier: String?
    
    /// The response to a challenge created by the user.
    public private(set) var response: Response?
    
    /// The name of the challenge to which the response is created.
    public private(set) var challengeTitle: String?
    
    /// The preview image for the response.
    public private(set) var previewImage: UIImage?
    
    /// The description for the response created by the user.
    public private(set) var description: String?
    
    /// The production state of the user's response.
    public private(set) var productionState: Constants.UploadResponseType
    
    /// The coordinator that instantiated the view model.
    public weak var coordinator: FinalPostCoordinator?
    
    /// The view controller delegate that receives messages from the view model.
    public weak var finalPostViewModelVideoDelegate: FinalPostViewModelVideoDelegate?
    
    
    // MARK: - Private Properties
    
    // The services container used for networking.
    private var services: GlobalServicesContainer = (UIApplication.shared.delegate as! AppDelegate).services
    
    /// The id for the challenge to which the user is responding.
    private var challengeId: String?
    
    /// The camera manager for the post session.
    private var cameraManager: CameraManager
    
    /// The MaverickComposition for the post session.
    private var maverickComposition: MaverickComposition
    
    
    // MARK: - Lifecycle
    
    init(coordinator: FinalPostCoordinator, cameraManager: CameraManager, challengeId: String?, challengeTitle: String?, maverickComposition: MaverickComposition, productionState: Constants.UploadResponseType) {
    
        self.coordinator = coordinator
        self.cameraManager = cameraManager
        self.challengeId = challengeId
        self.challengeTitle = challengeTitle
        self.maverickComposition = maverickComposition
        self.productionState = productionState
        
        populateDataForViewModel()
        
    }
    
    deinit {
        log.verbose("💥")
    }
    
    
    // MARK: - Public Functions
    
    /**
     Starts the video preparation process.
     */
    public func prepareVideo() {
        
        maverickComposition.prepareVideoCompositionForSegments(sessionId: cameraManager.session!.identifier)
        
        checkProgress()
        
    }

    /**
     Starts the share functionality for share services.
     */
    public func shareButtonTapped(forChannel channel: SocialShareChannels) {
        
        guard let response = response else { return }
        share(response, throughChannel: channel)
        
    }
    
    /**
     Starts ths share functionality for a link.
     */
    public func shareButtonTappedForLink() {
        
        guard let response = response else { return }
        shareLink(response)
        
    }
    
    /**
     Informs the coordinator that the change cover button has been tapped.
     */
    public func changeCoverButtonTapped() {
        
        AnalyticsManager.Post.trackDetailsChangeCoverPressed(responseType: productionState, challengeId: challengeId)
        coordinator?.changeCoverButtonTapped()
    }
    
    /**
     Saves the current state of the response by the user as a draft.
     */
    public func saveDraftButtonTapped() {
        
        trackSaveDraftButtonTapped()
        saveDraft()
        coordinator?.finalPostFlowHasClosed()
        
    }
    
    /**
     Starts the process to upload a response.
     */
    public func postButtonTapped(completion: @escaping (String?) -> ()) {
        
        trackPostButtonTapped()
        
        switch productionState {
            
        case .image, .text:
            
            guard let image = maverickComposition.finalEditedImage else {
                AnalyticsManager.Post.trackPostFail(responseType: productionState, challengeId: challengeId, postFailureError: Constants.Analytics.Post.Properties.POST_FAILURE_REASON.assetLoadingFailure)
                
                completion("Unable to export. Couldn't find the edited image. Please try again.")
                return
                
            }
            
            completion(nil)
            
            let imageUrl = URL(fileURLWithPath: maverickComposition.saveImageForUpload(withImage: image))
            
            uploadResponse(forAssetAt: imageUrl)
            
        case .video:
                        
            maverickComposition.assetURLRepresentingExport(completionHandler: { assetURL in
                
                guard let assetURL = assetURL else {
                    
                    completion("Unable to export. Couldn't find the asset. Please try again.")
                    return
                    
                }
                
                completion(nil)
                
                self.uploadResponse(forAssetAt: assetURL)
                
            })
            
        }
        
    }
    
    /**
     Informs the coordinator that the back button has been tapped.
     */
    public func backButtonTapped() {
        
        AnalyticsManager.Post.trackDetailsBackPressed(responseType: productionState, challengeId: challengeId)
        
        if let description = description {
            cameraManager.sessionDescription = description
        }
        
        coordinator?.backButtonTapped()
    }
    
    /**
     Updates the post description.
     - parameter text: The new text from the description field.
    */
    public func descriptionUpdated(withText text: String) {
        description = text
    }
    
    /**
     Informs the delegate that the cover image has been updated.
     */
    public func updateCoverImage() {
        
        previewImage = cameraManager.sessionCoverImage
        finalPostViewModelVideoDelegate?.didUpdatePreviewImage()
        
    }
    
    /**
     Informs the coordinator that the dialog for processing the video has been closed.
     */
    public func endDisplay() {
        
        guard let sessionId = cameraManager.session?.identifier else { return }
        maverickComposition.clearDraftToPost(sessionId: sessionId, cameraManager: cameraManager, services: services)
        coordinator?.finalPostFlowHasClosed()
        
    }
    
    
    // MARK: - Private Functions
    
    /**
     Recursive check on the progress of the video processing to determine its progress and whether it has been completed or not.
     */
    private func checkProgress() {
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) { [weak self] in
            
            guard let sessionId = self?.cameraManager.session?.identifier else { return }
            let (checkState, progress) = MaverickComposition.getProgress(sessionId: sessionId)
            guard let state = checkState else { return }
            
            if state == .failed {
                
                self?.finalPostViewModelVideoDelegate?.didFinishProcessingVideo(success: false, withError: "Something went wrong when prepraing the video for upload.")
                
                return
                
            } else if state == .success {
                
                guard let masterOverlayView = self?.maverickComposition.masterOverlayView else {
                    
                    self?.finalPostViewModelVideoDelegate?.didFinishProcessingVideo(success: false, withError: "Something went wrong when prepraing the video for upload.")
                    
                    return
                    
                }
                
                self?.maverickComposition.prepareOverlayView(withMasterView: masterOverlayView, masterDrawingImage: nil, segmentView: nil, completionHandler: { (overlay, overlayAsImage) in
                    
                    self?.maverickComposition.assetURLRepresentingExport(completionHandler: { assetURL in
                        
                        guard let assetURL = assetURL else {
                            
                            self?.finalPostViewModelVideoDelegate?.didFinishProcessingVideo(success: false, withError: "Something went wrong when prepraing the video for upload.")
                            
                            return
                            
                        }
                        
                        let merge = Merge(config: .standard)
                        let asset = AVAsset(url: assetURL)
                        
                        log.verbose("⚙️ Beginning overlay merge for asset \(assetURL.absoluteString)")
                        
                        merge.overlayVideo(video: asset, overlayImage: overlayAsImage, completion: { url in
                            
                            guard let url = url else {
                            
                                self?.finalPostViewModelVideoDelegate?.didFinishProcessingVideo(success: false, withError: "Something went wrong when prepraing the video for upload.")
                                
                                return
                                
                            }
                            
                            log.verbose("⚙️ Merge for asset \(assetURL.absoluteString) completed and located at \(url.absoluteString)")
                            
                            let filename = "\(self!.maverickComposition.session.identifier)SCVideo-Overlay.Merged.\(self!.maverickComposition.session.fileExtension ?? "mp4")"
                            let fileToBeReplaced = SCRecordSessionSegment.segmentURL(forFilename: filename, andDirectory: (self!.maverickComposition.session.segmentsDirectory))
                            
                            do {
                                
                                log.verbose("⚙️ Replacing file at \(fileToBeReplaced.absoluteString) with file at \(url.absoluteString)")
                                
                                let resultURL = try FileManager.default.replaceItemAt(fileToBeReplaced, withItemAt: url)
                                log.verbose("⚙️ Resulting url for replacement is \(resultURL!.absoluteString)")
                                guard resultURL == fileToBeReplaced else {
                                    
                                    self?.finalPostViewModelVideoDelegate?.didFinishProcessingVideo(success: false, withError: "Something went wrong when prepraing the video for upload.")
                                    
                                    return
                                    
                                }
                            } catch {
                                self?.finalPostViewModelVideoDelegate?.didFinishProcessingVideo(success: false, withError: "Something went wrong when prepraing the video for upload.")
                                
                                return
                            }
                            
                            self?.finishVideoProcessing()
                            return
                        
                        }) { progress in
                            
                            let newProgressValue = ( progress / 2 ) + 0.5
                            
                            self?.finalPostViewModelVideoDelegate?.didUpdateProgess(withValue: newProgressValue)
                            
                        }
        
                    })
                    
                })
                
            } else {
                
                self?.finalPostViewModelVideoDelegate?.didUpdateProgess(withValue: progress / 2)
                self?.checkProgress()
                
            }
            
        }
        
    }
    
    func finishVideoProcessing() {
        
        maverickComposition.generateCoverImage(completionHandler: { image in
            
            self.saveCoverImage(image: image)
            self.previewImage = image
            self.finalPostViewModelVideoDelegate?.didFinishProcessingVideo(success: true, withError: nil)
            
        })
    }
    
    /**
     Saves the image to disk
     */
    func saveCoverImage(image: UIImage) {
        
        let randomFilename = "\(cameraManager.session!.identifier)_coverImage" + ".jpg"
        let data = UIImageJPEGRepresentation(image, 1.0)
        let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last!
        let coverImageURL = dir.appendingPathComponent(randomFilename)
        
        cameraManager.sessionCoverImage = image
        cameraManager.sessionCoverImageURL = coverImageURL
        
        FileManager.default.createFile(atPath: coverImageURL.path, contents: data, attributes: nil)
        
    }
    
    /**
     Saves the draft of the response to the camera manager.
     */
    private func saveDraft() {
        
        if let description = description {
            cameraManager.sessionDescription = description
        }
        
        cameraManager.saveRecordSession(withComposition: maverickComposition)
        
    }
    
    /**
     Uploads the user's response.
     - parameter outputUrl: The location of the user's asset to be uploaded.
     */
    private func uploadResponse(forAssetAt outputUrl: URL) {
        
        saveDraft()
        
        let shareChannels: [SocialShareChannels] = []
        
        services.globalModelsCoordinator.uploadContentResponse(withFileURL: outputUrl,
                                                               forChallengeId: cameraManager.sessionChallengeId,
                                                               description: cameraManager.sessionDescription,
                                                               coverImage: cameraManager.sessionCoverImageURL,
                                                               responseType: productionState,
                                                               sessionId: cameraManager.session!.identifier,
                                                               shareChannels: shareChannels)
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) { 
            self.coordinator?.finalPostFlowHasClosed()
        }
        
    }
    
    /// Sets the initial values for the view model from the camera manager.
    private func populateDataForViewModel() {
        
        description = cameraManager.sessionDescription
        previewImage = cameraManager.sessionCoverImage
        
    }
    
    /**
     Starts the sharing functionality.
     - parameter response: The response to be shared.
     - parameter channel: The channel through which to share.
     */
    private func share(_ response: Response, throughChannel channel: SocialShareChannels) {
        
        guard let rootVc = UIApplication.shared.keyWindow?.rootViewController else { return }
        
        if services.shareService.isShareAvailable(forChannel: channel) != true {
            
            services.shareService.login(fromViewController: rootVc, channel: channel) { error in
                
                if let error = error {
                    
                    let alert = UIAlertController(title: "Whoops!", message: "Something went wrong. Please try again. \(error.localizedDescription)", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    rootVc.present(alert, animated: true, completion: nil)
                    return
                    
                }
                
            }
            
        }
        
        services.shareService.share(response: response,
                                    throughChannel: channel,
                                    localIdentifier: localIdentifier,
                                    fromViewController: rootVc)
        
    }
    
    /**
     Generate a shareable link for a response.
     - parameter response: The response to be shared.
     */
    private func shareLink(_ response: Response) {
        
        var link: String?
        
        link = services.shareService.generateShareLink(forResponse: response)?.path
        
        if let link = link {
            
            UIPasteboard.general.string = link
            
            if let vc = UIApplication.shared.keyWindow?.rootViewController {
                
                vc.view.makeToast("Link Copied")
                
            }
            
        }
        
    }
    
    
    // MARK: - Private Functions: Analytics Events
    
    /**
     Sends an analytics event when the user taps the save draft button.
     */
    private func trackSaveDraftButtonTapped() {
        
        let hasDescription = !description!.isEmpty
        let hasTags = ((description!.count) - (description!.replacingOccurrences(of: "#", with: "").count) > 0)
        
        AnalyticsManager.Post.trackDetailsSavePressed(responseType: productionState, challengeId: challengeId, hasTags: hasTags, hasDescription: hasDescription)
        
    }
    
    /**
     Sends an analytics event when the user taps the post button.
     */
    private func trackPostButtonTapped() {
        
        let hasDescription = !description!.isEmpty
        let hasTags = ((description!.count) - (description!.replacingOccurrences(of: "#", with: "").count) > 0)
        
        let hasMultipleSegments: Bool? = {
            if productionState == .video {
                return (maverickComposition.session.segments.count) > 1 ? true : false
            } else {
                return nil
            }
        }()
        
        let views = maverickComposition.masterOverlayView.componentsView?.subviews
        let hasStickers: Bool = (views?.filter { $0.isKind(of: UIImageView.self) }.count)! > 0 ? true : false
        
        let stickerNames: [String]? = {
            
            if hasStickers {
                
                let stickerViews = views?.filter { $0.isKind(of: UIImageView.self) } as! [UIImageView]
                return stickerViews.compactMap { $0.accessibilityIdentifier }
                
            } else {
                return nil
            }
            
        }()
        
        let hasText: Bool = (views?.filter { $0.isKind(of: UITextView.self) }.count)! > 0 ? true : false
        
        let hasFilter: Bool = {
            if let _ = maverickComposition.masterOverlayFilter {
                return true
            } else {
                return false
            }
        }()
        
        let hasDoodle: Bool = {
            if (maverickComposition.masterOverlayView.paperState?.everyVisibleStroke().count)! > 0 {
                return true
            } else {
                return false
            }
        }()
        
        let lengthOfUpload: Float64? = {
            if productionState == .video {
                return CMTimeGetSeconds(maverickComposition.session.segmentsDuration)
            } else {
                return nil
            }
        }()
        
        AnalyticsManager.Post.trackUploadPressed(responseType: productionState, challengeId: challengeId, hasTags: hasTags, hasDescription: hasDescription, hasMultipleSegments: hasMultipleSegments, hasStickers: hasStickers, stickerNames: stickerNames, hasText: hasText, hasDoodle: hasDoodle, hasFilter: hasFilter, length: lengthOfUpload)
        
    }
    
    /// Sends an analytics event when the user taps the post button.
    public func trackDescriptionBeganEditing() {
        AnalyticsManager.Post.trackDetailsDescriptionEntryStarted(responseType: productionState, challengeId: challengeId)
    }
    
}
