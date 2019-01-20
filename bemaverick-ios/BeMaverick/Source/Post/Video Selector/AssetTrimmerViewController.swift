//
//  AssetTrimmerViewController.swift
//  BeMaverick
//
//  Created by David McGraw on 12/18/17.
//  Copyright © 2017 BeMaverick. All rights reserved.
//

import UIKit
import Photos
import SCRecorder
import ICGVideoTrimmer

class AssetTrimmerViewController: PostRecordParentViewController {
    
    // MARK: - IBOutlet
    
    /// Main scroll view
    @IBOutlet weak var scrollView: UIScrollView!
    
    /// Scroll view content width
    @IBOutlet weak var scrollViewContentWidth: NSLayoutConstraint!
    
    /// Scroll view content height
    @IBOutlet weak var scrollViewContentHeight: NSLayoutConstraint!
    
    /// View used to trim the selected asset
    @IBOutlet weak var trimmerView: ICGVideoTrimmerView!
    
    /// Trim the asset and add it to the composition
    @IBOutlet weak var timeRemainingLabel: UILabel!
    
    @IBOutlet weak var previewContentImage: UIView!
    /// Trim the asset and add it to the composition
    @IBOutlet weak var doneButton: UIButton!
    
    /// Play the content
    @IBOutlet weak var playButton: UIButton!
    
    /// Move to the next segment
    @IBOutlet weak var nextButton: UIButton!
    
    /// Move to the previous segment
    @IBOutlet weak var previousButton: UIButton!
    
    /// Delete this segment
    @IBOutlet weak var deleteButton: UIButton!
    
    /// Replay the content
    @IBOutlet weak var replayButton: UIButton!
    
    /// Main scroll view
    @IBOutlet weak var trimmerContainer: UIView!
    
    /// Trimmer options view
    @IBOutlet weak var trimmerOptionsContainer: UIView!
    
    // MARK: - IBActions
    
    @IBAction func backButtonTapped(_ sender: Any) {
        
        AnalyticsManager.Post.trackTrimmerBackPressed(challengeId: challengeId, mediaType: asset != nil ? .video : .image)
        videoPreviewView?.player?.pause()
        navigationController?.popViewController(animated: true)
        
    }
    
    @IBAction func doneButtonTapped(_ sender: Any) {
        
        AnalyticsManager.Post.trackTrimmerDonePressed(challengeId: challengeId, mediaType: asset != nil ? .video : .image)
        doneButton.isEnabled = false
        loadingView.titleLabel.text = "One Moment"
        loadingView.startAnimating()
        
        if let asset = asset {
            
            let startTime = CMTime(seconds: Double(currentStartTime),
                                   preferredTimescale: trimmerView.asset.duration.timescale)
            let endTime = CMTime(seconds: Double(currentEndTime),
                                 preferredTimescale: trimmerView.asset.duration.timescale)
            
            editorVideoComposition?.insertAsset(asset: asset,
                                                atIndex: editingSegmentAtIndex,
                                                atRect: getCropRectForVideoContent(),
                                                startTime: startTime,
                                                endTime: endTime)
            { error in
                
                self.completeAssetInsertion(withError: error)
                self.doneButton.isEnabled = true

            }
            
        } else if let _ = photo {
            
            let image = getCroppedPreviewImage()
            editorVideoComposition?.lastCapturedImage = image
            
            performSegue(withIdentifier: R.segue.assetTrimmerViewController.unwindToRecordingForImage,
                         sender: self)
            
            doneButton.isEnabled = true
            
        }
        
    }
    
    fileprivate func completeAssetInsertion(withError error: MaverickError?) {
        
        self.loadingView.stopAnimating()
        
        if error != nil {
            
            let alert = UIAlertController(title: "Video Exceeds Maximum Length", message: "\(error?.localizedDescription ?? "")", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
            
            return
        }
        
        videoPreviewView?.player?.pause()
        if editorVideoComposition!.reloadSessionComposition() == false {
            
            let alert = UIAlertController(title: "Whoops!", message: "Something went wrong while reloading the session. \(error?.localizedDescription ?? "")", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                
                self.performSegue(withIdentifier: R.segue.assetTrimmerViewController.unwindToRecordAndRefresh,
                                  sender: self)
                
            }))
            present(alert, animated: true, completion: nil)
            return
            
        }
        
        performSegue(withIdentifier: R.segue.assetTrimmerViewController.unwindToRecordingEditAndRefresh,
                     sender: self)
        
    }
    
    @IBAction func playButtonTapped(_ sender: Any) {
        
        playButton.isSelected = !playButton.isSelected
        
        if playButton.isSelected {
            
            videoPreviewView?.player?.play()
            AnalyticsManager.Post.trackTrimmerPlayPressed(challengeId: challengeId)
            
        } else {
            
            videoPreviewView?.player?.pause()
            AnalyticsManager.Post.trackTrimmerPausePressed(challengeId: challengeId)
            
        }
        
    }

    @IBAction func nextButtonTapped(_ sender: Any) {
        
        AnalyticsManager.Post.trackTrimmerNextPressed(challengeId: challengeId)
        
        var segments = editorVideoComposition?.session?.segments ?? []

        if editingSegmentAtIndex == segments.count - 1 {
            editingSegmentAtIndex = 0
        } else {
            editingSegmentAtIndex += 1
        }
        
        asset = segments[editingSegmentAtIndex].asset
        setSelectedAsset(asset: asset!)
        
    }
    
    @IBAction func previousButtonTapped(_ sender: Any) {
        
        AnalyticsManager.Post.trackTrimmerPreviousPressed(challengeId: challengeId)
        
        var segments = editorVideoComposition?.session?.segments ?? []

        if editingSegmentAtIndex == 0 {
            editingSegmentAtIndex = segments.count - 1
        } else {
            editingSegmentAtIndex -= 1
        }
        
        asset = segments[editingSegmentAtIndex].asset
        setSelectedAsset(asset: asset!)
        
    }
    
    @IBAction func deleteButtonTapped(_ sender: Any) {
        
        AnalyticsManager.Post.trackTrimmerDeletePressed(challengeId: challengeId)
        
        if editingSegmentAtIndex != -1 {
            
            editorVideoComposition?.session?.removeSegment(at: editingSegmentAtIndex, deleteFile: true)
            performSegue(withIdentifier: R.segue.assetTrimmerViewController.unwindToRecordingRoot,
                         sender: self)
            
        }
        
    }
    
    @IBAction func replayButtonTapped(_ sender: Any) {
        
        AnalyticsManager.Post.trackTrimmerReplayPressed(challengeId: challengeId)
        
        videoPreviewView?.player?.seek(to: CMTime(seconds: Double(currentStartTime), preferredTimescale: trimmerView.asset.duration.timescale),
                                       toleranceBefore: kCMTimeZero,
                                       toleranceAfter: kCMTimeZero)
        
    }
    
    // MARK: - Public Properties
    
    /// The asset that needs to be trimmed
    open var asset: AVAsset?
    
    /// A photo that can be cropped
    open var photo: UIImage?
    
    /// The size of the `AVAsset`
    open var assetSize: CGSize = .zero
    
    /// The amount of time available in seconds
    open var maxSecondsAvailable: Int = 30
    
    /// The index being trimmed
    open var editingSegmentAtIndex: Int = -1

    /// Monitor looping
    fileprivate var playbackTimeCheckerTimer: Timer?
    
    ///
    fileprivate var currentStartTime: CGFloat = 0
    fileprivate var currentEndTime: CGFloat = 30
    
    // MARK: - Lifecycle

    deinit {
        log.verbose("💥")
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        configureView()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        
        // Need trimmer layout pass before our pass
        configurePreview()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        super.viewWillDisappear(animated)
        
        playbackTimeCheckerTimer?.invalidate()
        trimmerView.delegate = nil
        
    }
    
    
    // MARK: - Private Methods
    
    override func configureView() {

        super.configureView()
        
        trimmerContainer.isHidden = true
        imagePreviewView.image = nil
                
        navigationController?.setNavigationBarClear()
        
        // No need to display this
        trimmerView.borderWidth = 4
        trimmerView.themeColor = .white
        trimmerView.leftThumbImage = R.image.trimmerRecordBar()
        trimmerView.rightThumbImage = R.image.trimmerRecordBar()
        
        // Configure playback
        videoPreviewView?.player?.loopEnabled = true
        
        // Hide by default
        trimmerOptionsContainer.isHidden = true
        
    }
    
    /**
     Update the time remaining label and provide a visual indication that the
     user is good to go to clip the content
    */
    fileprivate func updateTimeRemaining(withSeconds seconds: Int) {

        timeRemainingLabel.text = "\(Int(seconds)) / \(maxSecondsAvailable)"
        
        if seconds <= maxSecondsAvailable {
            timeRemainingLabel.textColor = .MaverickPrimaryColor
        } else {
            timeRemainingLabel.textColor = .MaverickBadgePrimaryColor
        }
        
    }
    
    /**
     Configure a preloaded asset from Asset Selection or from an index tapped
     on a timeline view
    */
    fileprivate func configurePreview() {
        
        scrollView.zoomScale = 1.0
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 1.0
        
        if asset != nil {
            
            titleLabel?.text = "TRIM"
            trimmerOptionsContainer.isHidden = false
            trimmerContainer.isHidden = false
            
            videoPreviewView?.alpha = 0.0
            videoPreviewView?.playerLayer?.videoGravity = .resizeAspectFill
            videoPreviewView?.playerLayer?.needsDisplayOnBoundsChange = true
            videoPreviewView?.player?.setItemBy(asset)
            videoPreviewView?.player?.play()
            playButton.isSelected = true
            
            // Need to set this here vs. the trimmer directly
            let trackerColor = UIColor.MaverickBadgePrimaryColor
            
            trimmerView.delegate = self
            trimmerView.asset = asset
            trimmerView.maxLength = CGFloat(asset?.duration.seconds ?? Double(Constants.CameraManagerMaxRecordDuration))
            trimmerView.minLength = 3.0
            trimmerView.trackerColor = trackerColor
            trimmerView.resetSubviews()
         
            // Loop handling
            playbackTimeCheckerTimer = Timer.scheduledTimer(timeInterval: 0.05,
                                                            target: self,
                                                            selector: #selector(onPlaybackTimeChecker),
                                                            userInfo: nil,
                                                            repeats: true)
            
            // Get asset size
            guard let track = asset!.tracks(withMediaType: AVMediaType.video).first else { return }
            let trackSize = track.naturalSize.applying(track.preferredTransform)
            assetSize = CGSize(width: fabs(trackSize.width), height: fabs(trackSize.height))
            
            let ratio = assetSize.width / assetSize.height
            if assetSize.width < assetSize.height {
            
                scrollViewContentWidth.constant = scrollView.bounds.width
                scrollViewContentHeight.constant = scrollViewContentWidth.constant / ratio

            } else {
                
                scrollViewContentHeight.constant = scrollView.bounds.height
                scrollViewContentWidth.constant = assetSize.width / ratio
                
            }
            
            // Artificial delay to avoid seeing any frame animate/resizing
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.225, execute: {
                self.videoPreviewView.alpha = 1.0
            })
            
        } else {
            
            titleLabel?.text = "CROP"
            trimmerOptionsContainer.isHidden = true
            trimmerContainer.isHidden = true
            imagePreviewView.image = photo
            
            scrollView.minimumZoomScale = 1.0
            scrollView.maximumZoomScale = 5.0
            
            if let size = photo?.size {
         
                if size.width < size.height {
         
                    let ratio = size.height / size.width
                    scrollViewContentWidth.constant = scrollView.bounds.width
                    scrollViewContentHeight.constant = scrollViewContentWidth.constant * ratio
                    
                } else {
                    
                    let ratio = size.width / size.height
                    scrollViewContentHeight.constant = scrollView.bounds.height
                    scrollViewContentWidth.constant = scrollView.bounds.height * ratio
                    
                }
                
            }
            
        }
        
    }

    /**
     Update the selected asset
     */
    fileprivate func setSelectedAsset(asset: AVAsset) {
        
        self.asset = asset
        videoPreviewView?.player?.setItemBy(asset)
        trimmerView.asset = asset
        trimmerView.resetSubviews()
        
    }
    
    /**
     If the playback time exceeds the endTime, loop the content
    */
    @objc fileprivate func onPlaybackTimeChecker() {
        
        guard let player = videoPreviewView?.player else {
            return
        }
        
        if !player.isPlaying {
            return
        }
        
        UIView.animate(withDuration: 0.25, delay: 0.0, options: [.beginFromCurrentState, .curveLinear], animations: {
            
            let playBackTime = player.currentTime()
            self.trimmerView.seek(toTime: CGFloat(playBackTime.seconds))
            
            let startTime = CMTime(seconds: Double(self.currentStartTime),
                                   preferredTimescale: self.trimmerView.asset.duration.timescale)
            
            let endTime = CMTime(seconds: Double(self.currentEndTime),
                                 preferredTimescale: self.trimmerView.asset.duration.timescale)
            
            if playBackTime >= endTime {
                
                player.seek(to: startTime,
                            toleranceBefore: kCMTimeZero,
                            toleranceAfter: kCMTimeZero)
                self.trimmerView.seek(toTime: self.currentStartTime)
                
            }
            
        }, completion: nil)
        
    }
    
    /**
     Get a cropped image based on where the mask overlay
     */
    fileprivate func getCroppedPreviewImage() -> UIImage {

        
        return UIImage(view: previewContentImage)
        
        
    }
    
    /**
     Get the visible crop rect factoring in adjustments that will be made on the
     composition export step.
    */
    fileprivate func getCropRectForVideoContent() -> CGRect? {
        
        var rect: CGRect = .zero
        
        let sw = scrollView.contentOffset.x * ((Constants.CameraManagerExportSize.width + scrollView.bounds.size.width) / scrollView.bounds.size.width)
        let sh = scrollView.contentOffset.y * (Constants.CameraManagerExportSize.height / scrollView.bounds.size.height)
        
        rect.origin = CGPoint(x: sw, y: sh)
        rect.size = scrollView.contentSize
        
        return rect
        
    }
    
}

extension AssetTrimmerViewController: UIScrollViewDelegate {
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return editorContentView
    }
    
}

extension AssetTrimmerViewController: ICGVideoTrimmerDelegate {
    
    func trimmerView(_ trimmerView: ICGVideoTrimmerView!,
                     didChangeLeftPosition startTime: CGFloat,
                     rightPosition endTime: CGFloat)
    {
        
        currentStartTime = startTime
        currentEndTime = endTime
        
        videoPreviewView?.player?.seek(to: CMTime(seconds: Double(startTime), preferredTimescale: trimmerView.asset.duration.timescale),
                                       toleranceBefore: kCMTimeZero,
                                       toleranceAfter: kCMTimeZero)
    
        if videoPreviewView?.player?.isPlaying ?? true {
            
            UIView.animate(withDuration: 0.25,
                           delay: 0.0,
                           options: [.beginFromCurrentState, .curveLinear],
                           animations:
            {
                self.trimmerView.seek(toTime: self.currentStartTime)
            }, completion: nil)
            
        } else {
            trimmerView.seek(toTime: currentStartTime)
        }
        
        let duration = endTime - startTime
        updateTimeRemaining(withSeconds: Int(ceil(duration)))
        
    }
    
}

