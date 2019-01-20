//
//  AssetPickerViewController.swift
//  BeMaverick
//
//  Created by David McGraw on 12/18/17.
//  Copyright © 2017 BeMaverick. All rights reserved.
//

import UIKit
import Photos

enum PresentedFromScreen {
    case record, editor
}

class AssetPickerViewController: UIViewController {
    
    // MARK: - IBOutlets
    
    /// A collection view used to display the fetched content
    @IBOutlet weak var collectionView: UICollectionView!
    
    /// Loading view for fetching networked assets
    @IBOutlet weak var loadingView: LoadingView!
    
    /// A view containing a video and photo switcher
    @IBOutlet weak var optionView: UIView!
    
    /// An overlay to display when options are shown
    @IBOutlet weak var optionOverlayView: UIView!
    
    /// A recognizer to dismiss the overlay
    @IBOutlet var optionOverlayTapGesture: UITapGestureRecognizer!
    
    /// A preview image for a video
    @IBOutlet weak var previewVideoImageView: UIImageView!
    
    /// A preview image for a photo
    @IBOutlet weak var previewPhotoImageView: UIImageView!
    
    /// A button that acts as the title for the view and a toggle for `optionView`
    @IBOutlet weak var optionTitleButton: UIButton!
    
    /// A selector for video
    @IBOutlet weak var videoButton: UIButton!
    
    /// A selector for photo
    @IBOutlet weak var photoButton: UIButton!
    
    /// The video count
    @IBOutlet weak var videoCountLabel: UILabel!
    
    /// The image count
    @IBOutlet weak var photoCountLabel: UILabel!
    
    /// The top constraint for `optionView`
    @IBOutlet weak var optionSelectorTopConstraint: NSLayoutConstraint!
    
    // MARK: - IBActions
    
    /**
     Leave the asset selector
     */
    @IBAction func backButtonTapped(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    /**
     Dismiss the option selector
     */
    @IBAction func optionOverlayTapped(_ sender: Any) {
        
        view.setNeedsUpdateConstraints()
        UIView.animate(withDuration: 0.225) {
            
            self.optionOverlayTapGesture.isEnabled = false
            self.optionOverlayView.alpha = 0.0
            self.optionSelectorTopConstraint.constant = -self.optionView.frame.size.height
            self.view.layoutIfNeeded()
            
        }
        
    }
    
    /**
     Display the option selector
     */
    @IBAction func optionSelectorTapped(_ sender: Any) {
        
        view.setNeedsUpdateConstraints()
        UIView.animate(withDuration: 0.225,
                       delay: 0.0,
                       usingSpringWithDamping: 10,
                       initialSpringVelocity: 10,
                       options: [.curveEaseIn], animations: {
                        
                        self.optionOverlayTapGesture.isEnabled = true
                        self.optionOverlayView.alpha = 1.0
                        self.optionSelectorTopConstraint.constant = 0
                        self.view.layoutIfNeeded()
                        
        }, completion: nil)
        
    }
    
    /**
     Switch the editing mode to video
     */
    @IBAction func videoButtonTapped(_ sender: Any) {
        
        optionOverlayTapped(sender)
        postRecordViewController?.updateResponseType(toType: .video)
        productionState = .video
        fetchContentAssets()
        
    }
    
    /**
     Switch the editing mode to image
     */
    @IBAction func photoButtonTapped(_ sender: Any) {
        
        optionOverlayTapped(sender)
        postRecordViewController?.updateResponseType(toType: .image)
        productionState = .image
        fetchContentAssets()
        
    }
    
    // MARK: - Public Properties
    
    /// Whether `maxVideoLength` should be respected or not
    open var shouldRestrictVideoLength: Bool = true
    
    /// The length of a video in seconds
    open var maxVideoLength: TimeInterval = 30
    
    /// A custom title of the view
    open var titleLabel: UILabel?
    
    /// The type of content to fetch
    open var productionState: Constants.UploadResponseType = .video
    
    /// The challenge id associated with the asset request
    open var challengeId: String?
    
    /// A composition of the video under edit
    open weak var editorVideoComposition: MaverickComposition?
    
    /// The parent record view that needs to know when `productionState` changes
    open weak var postRecordViewController: PostRecordViewController?
    
    /// The result set fetched from the `Photos` framework
    fileprivate(set) var results: PHFetchResult<PHAsset>!
    
    // MARK: - Private Properties
    
    /// Caching image manager for the content previews
    fileprivate let imageManager = PHCachingImageManager()
    
    /// The selected asset the user is adding
    fileprivate var selectedAsset: AVAsset?
    
    // MARK: - Lifecycle
    
    deinit {
        PHPhotoLibrary.shared().unregisterChangeObserver(self)
        log.verbose("💥")
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        configureView()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        validateLibraryPermissionAndFetch()
        
        selectedAsset = nil
        editorVideoComposition?.lastCapturedImage = nil
        
        trackScreen()
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let vc = R.segue.assetPickerViewController.assetTrimmerSegue(segue: segue)?.destination {
            
            vc.maxSecondsAvailable = getRemainingTime()
            vc.editorVideoComposition = editorVideoComposition
            vc.asset = selectedAsset
            vc.photo = editorVideoComposition?.lastCapturedImage
            
            if let segments = editorVideoComposition?.session?.segments.count {
                vc.editingSegmentAtIndex = segments
            }
            
             vc.challengeId = challengeId
            
            
        }
        
    }
    
    
    // MARK: - Private Methods
    
    /**
     Track that the user has started viewing this class.
     */
    private func trackScreen() {
        AnalyticsManager.trackScreen(location: self)
    }
    
    fileprivate func configureView() {
        
        // Monitor for changes
        PHPhotoLibrary.shared().register(self)
        
        // Fetch videos
        validateLibraryPermissionAndFetch()
        
        // Refresh previews
        refreshLatestPreviewImages()
        
    }
    
    /**
     Checks system photo library permissions and fetches video assets upon
     success
     */
    fileprivate func validateLibraryPermissionAndFetch() {
        
        let status = PHPhotoLibrary.authorizationStatus()
        if status == .authorized {
            
            fetchContentAssets()
            refreshTitle()
            
        } else {
            
            PHPhotoLibrary.requestAuthorization { status in
                self.validateLibraryPermissionAndFetch()
            }
            
        }
        
    }
    
    /**
     Fetch a list of video assets by `creationDate`
     */
    fileprivate func fetchContentAssets() {
        
        let options = PHFetchOptions()
        options.sortDescriptors = [ NSSortDescriptor(key: "creationDate", ascending: false) ]
        
        options.predicate = NSPredicate(format: "mediaType = %d || mediaType = %d", PHAssetMediaType.video.rawValue, PHAssetMediaType.image.rawValue)
        
        if productionState == .image {
            options.predicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.image.rawValue)
            optionTitleButton.setTitle("PHOTO", for: .normal)
        } else {
            options.predicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.video.rawValue)
            optionTitleButton.setTitle("VIDEO", for: .normal)
        }
        
        results = PHAsset.fetchAssets(with: options)
        
        collectionView.reloadData()
        
    }
    
    /**
     Get the remaining time for the loaded session
     */
    fileprivate func getRemainingTime() -> Int {
        
        if let duration = editorVideoComposition?.composition?.duration.seconds {
            return Int(Constants.CameraManagerMaxRecordDuration) - Int(duration)
        }
        return Int(Constants.CameraManagerMaxRecordDuration)
        
    }
    
    /**
     Set the option selector preview images based on the last item for each media type
     */
    fileprivate func refreshLatestPreviewImages() {
        
        UIImage.getLastPhotoLibraryImage(mediaType: .image) { image, count in
            self.previewPhotoImageView.image = image
            self.photoCountLabel.text = "\(count) photo\(count == 1 ? "": "s")"
        }
        
        UIImage.getLastPhotoLibraryImage(mediaType: .video) { image, count in
            self.previewVideoImageView.image = image
            self.videoCountLabel.text = "\(count) video\(count == 1 ? "": "s")"
        }
        
    }
    
    /**
     Refresh the title state based on the production type. If a recording has started
     the option selector will be disabled.
     */
    fileprivate func refreshTitle() {
        
        // Update the ability to toggle between content
        if let segmentCount = editorVideoComposition?.session.segments.count, segmentCount > 0 {
            optionTitleButton.setImage(nil, for: .normal)
            optionTitleButton.isUserInteractionEnabled = false
        } else {
            optionTitleButton.setImage(R.image.downTriangle(), for: .normal)
            optionTitleButton.isUserInteractionEnabled = true
        }
        
    }
    
}


extension AssetPickerViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int
    {
        return results?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: R.reuseIdentifier.assetId,
                                                            for: indexPath) else
        {
            fatalError("Unexpected cell in asset selector collection view")
        }
        
        let asset = results.object(at: indexPath.item)
        
        cell.stringIdentifier = asset.localIdentifier
        
        imageManager.requestImage(for: asset,
                                  targetSize: CGSize(width: 100, height: 100),
                                  contentMode: .aspectFill,
                                  options: nil)
        { (image, _) in
            
            if cell.stringIdentifier == asset.localIdentifier && image != nil {
                cell.imageView?.image = image
            }
            
        }
        
        return cell
        
    }
    
}

extension AssetPickerViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
        
        let asset = results.object(at: indexPath.item)
        
        if asset.mediaType == .video {
            
            let options = PHVideoRequestOptions()
            options.isNetworkAccessAllowed = true
            
            loadingView.startAnimating()
            
            imageManager.requestAVAsset(forVideo: asset, options: options)
            { asset, mix, _ in
                
                DispatchQueue.main.async {
                    
                    self.loadingView.stopAnimating()
                    
                    if asset == nil {
                        
                        AnalyticsManager.Post.trackAssetPickerAssetSelected(responseType: self.productionState, challengeId: self.challengeId, retrievalResult: .failure)
                        
                        let alert = UIAlertController(title: "Whoops!", message: "Unable the load this selection. Please try again.", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                        return
                        
                    }
                    
                    self.selectedAsset = asset
                    
                    AnalyticsManager.Post.trackAssetPickerAssetSelected(responseType: self.productionState, challengeId: self.challengeId, retrievalResult: .success)
                    
                    self.performSegue(withIdentifier: R.segue.assetPickerViewController.assetTrimmerSegue,
                                      sender: self)
                }
                
            }
            
        } else {
            
            let options = PHImageRequestOptions()
            options.deliveryMode = .highQualityFormat
            options.resizeMode = .exact
            options.isNetworkAccessAllowed = true
            
            imageManager.requestImage(for: asset,
                                      targetSize: CGSize(width: Constants.CameraManagerExportSize.width, height: Constants.CameraManagerExportSize.height),
                                      contentMode: PHImageContentMode.aspectFit,
                                      options: options)
            { (image, _) in
                
                DispatchQueue.main.async {
                    
                    if image == nil {
                        
                            AnalyticsManager.Post.trackAssetPickerAssetSelected(responseType: self.productionState, challengeId: self.challengeId, retrievalResult: .failure)
                        
                        let alert = UIAlertController(title: "Whoops!", message: "Unable the load this selection. Please try again.", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                        return
                        
                    }
                    
                    self.editorVideoComposition?.lastCapturedImage = image
                    
                    
                        AnalyticsManager.Post.trackAssetPickerAssetSelected(responseType: self.productionState, challengeId: self.challengeId, retrievalResult: .success)
                    
                    self.performSegue(withIdentifier: R.segue.assetPickerViewController.assetTrimmerSegue,
                                      sender: self)
                    
                }
                
            }
            
        }
        
    }
    
}

extension AssetPickerViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        let width = (view.bounds.size.width / 3) - 1
        return CGSize(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat
    {
        return 1
    }
    
}

extension AssetPickerViewController: PHPhotoLibraryChangeObserver {
    
    /**
     Change notifications may be made on a background queue. Re-dispatch to the
     main queue before acting on the change as we'll be updating the UI.
     */
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        
        DispatchQueue.main.sync {
            
            // Something for the future... insert/reload items if user leaves/returns
            
        }
    }
}
