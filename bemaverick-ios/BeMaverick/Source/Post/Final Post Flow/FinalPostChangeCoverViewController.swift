//
//  FinalPostChangeCoverViewController.swift
//  Maverick
//
//  Created by Chris Garvey on 8/16/18.
//  Copyright © 2018 BeMaverick. All rights reserved.
//


import AVFoundation

protocol FinalPostChangeCoverViewControllerDelegate: class {
    func didUpdateCoverImage()
}

class FinalPostChangeCoverViewController: UIViewController {
    
    // MARK: - IBOutlets
    
    /// A scroll view containing a preview image
    @IBOutlet weak var scrollView: UIScrollView!
    
    /// The content view for the preview image
    @IBOutlet weak var previewContentView: UIView!
    
    /// Display for a selected preview image
    @IBOutlet weak var previewImage: UIImageView!
    
    /// An overlay showing where the selected image will be cropped
    @IBOutlet weak var cropView: UIView!
    
    /// A stack view containing the preview frames
    @IBOutlet weak var frameStackView: UIStackView!
    
    
    // MARK: - Private Properties
    
    /// An image generation instance
    private var generator: AVAssetImageGenerator?
    
    /// The selected image view from the `frameStackView`
    private var selectedButon: UIButton?
    
    /// Location of the cover image on disk
    private var coverImageURL: URL?
    
    /// Whether the timeline has had a layout pass
    private var didLayoutTimeline: Bool = false
    
    /// Whether the user has touched a preview image
    private var didTouchPreviewImage: Bool = false
    
    /// The camera manager for the post session
    private var cameraManager: CameraManager!
    
    /// The challenge id for the response
    private var challengeId: String!
    
    /// The MaverickComposition for the post session
    fileprivate var maverickComposition: MaverickComposition!
    
    /// The production state of the response
    private var productionState: Constants.UploadResponseType!
    
    
    // MARK: - Public properties
    
    /// The coordinator that instantiated the view controller
    public weak var coordinator: FinalPostCoordinator?
    
    
    // MARK: - IBActions
    
    /**
     Return to the final post view without saving.
     */
    @IBAction func cancelButtonTapped(_ sender: Any) {
        
        if didTouchPreviewImage {
            AnalyticsManager.Post.trackCoverSelectorBackPressed(responseType: productionState, challengeId: challengeId, touchedState: .hasTouchedPreviewImage)
        } else {
            AnalyticsManager.Post.trackCoverSelectorBackPressed(responseType: productionState, challengeId: challengeId, touchedState: .hasNotTouchedPreviewImage)
        }
        
        dismiss(animated: true, completion: nil)
        
    }
    
    /**
     Return to the final post view after saving.
     */
    @IBAction func saveButtonTapped(_ sender: Any) {
        
        if didTouchPreviewImage {
            AnalyticsManager.Post.trackCoverSelectorSavePressed(responseType: productionState, challengeId: challengeId, touchedState: .hasTouchedPreviewImage)
        } else {
            AnalyticsManager.Post.trackCoverSelectorSavePressed(responseType: productionState, challengeId: challengeId, touchedState: .hasNotTouchedPreviewImage)
        }
        
        let croppedImage = getCroppedPreviewImage()
        
        let randomFilename = "\(cameraManager.session!.identifier)_coverImage" + ".jpg"
        
        let data = UIImageJPEGRepresentation(croppedImage, 0.8)
        let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last!
        coverImageURL = dir.appendingPathComponent(randomFilename)
        FileManager.default.createFile(atPath: coverImageURL!.path, contents: data, attributes: nil)
        
        cameraManager.sessionCoverImage = croppedImage
        cameraManager.sessionCoverImageURL = coverImageURL
        cameraManager.saveRecordSession()
        
        coordinator?.didUpdateCoverImage()
        
        dismiss(animated: true, completion: nil)
        
    }
    
    
    
    // MARK: - Lifecycle
    
    init(coordinator: FinalPostCoordinator, cameraManager: CameraManager, challengeId: String?, maverickComposition: MaverickComposition, productionState: Constants.UploadResponseType) {
        super.init(nibName: nil, bundle: nil)
        
        self.coordinator = coordinator
        self.cameraManager = cameraManager
        self.challengeId = challengeId
        self.maverickComposition = maverickComposition
        self.productionState = productionState
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        log.verbose("💥")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        // Select all segments
        didSelectSegment(atIndex: -1)
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureView()
    }
    
    
    // MARK: - Private Methods
    
    /// Configure the initial view of the view controller.
    func configureView() {
        
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 6.0
        scrollView.contentSize = previewImage.bounds.size
        
    }
    
    /**
     Reloads the view with the provided asset. Removes previous thumbnails.
     */
    fileprivate func reload(withAsset asset: AVAsset) {
        
        let timestamps = generateTimestamps(forAsset: asset, count: 10)
        
        for v in frameStackView.arrangedSubviews {
            frameStackView.removeArrangedSubview(v)
        }
        
        generateImages(forAsset: asset, atTimes: timestamps)
        
    }
    
    /**
     Get a cropped image based on where the mask overlay
     */
    fileprivate func getCroppedPreviewImage() -> UIImage {
        
        var rect: CGRect = .zero
        rect.origin = scrollView.contentOffset
        rect.size = scrollView.bounds.size
        
        UIGraphicsBeginImageContext(rect.size)
        
        let ctx = UIGraphicsGetCurrentContext()!
        ctx.translateBy(x: -rect.origin.x, y: -rect.origin.y)
        
        scrollView.layer.render(in: ctx)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image!
        
    }
    
    /**
     Create an image preview and add it to the stack view
     */
    fileprivate func handleGeneratedImage(image: CGImage, atIndex index: Int) {
        
        let v = UIButton(type: .custom)
        v.frame = CGRect(x: 0, y: 0, width: 84, height: 130)
        v.setImage(UIImage(cgImage: image), for: .normal)
        v.addTarget(self, action: #selector(didSelectPreviewImage(_:)), for: .touchUpInside)
        v.tag = index
        v.alpha = 0.75
        
        if index == 0 {
            
            previewImage.image = UIImage(cgImage: image)
            v.alpha = 1.0
            v.layer.borderColor = UIColor.white.cgColor
            v.layer.borderWidth = 4
            selectedButon = v
            
        }
        
        frameStackView.addArrangedSubview(v)
        v.autoSetDimension(.width, toSize: 84)
        v.autoPinEdge(toSuperviewEdge: .top)
        v.autoPinEdge(toSuperviewEdge: .bottom)
        
    }
    
    /**
     Generate a list of images based on the asset
     */
    fileprivate func generateImages(forAsset asset: AVAsset, atTimes times: [NSValue]) {
        
        generator = AVAssetImageGenerator(asset: asset)
        generator?.appliesPreferredTrackTransform = true
        
        var index = 0
        generator?.generateCGImagesAsynchronously(forTimes: times) { (_, cgImage, _, result, error) in
            
            if let cgImage = cgImage, error == nil && result == .succeeded {
                
                DispatchQueue.main.async { [weak self] () -> Void in
                    
                    self?.handleGeneratedImage(image: cgImage, atIndex: index)
                    index += 1
                    
                }
                
            }
            
        }
        
    }
    
    /**
     Create a list of timestamps based on the duration of the asset.
     */
    fileprivate func generateTimestamps(forAsset asset: AVAsset, count: Int) -> [NSValue] {
        
        let increment = (asset.duration.seconds * 1000) / Double(count)
        
        var timestamps: [NSValue] = []
        for idx in 0..<count {
            
            let value = NSValue(time: CMTime(value: Int64(CGFloat(increment) * CGFloat(idx)), timescale: 1000))
            timestamps.append(value)
            
        }
        return timestamps
        
    }
    
    /**
     Handle the selection of a preview item
     */
    @objc fileprivate func didSelectPreviewImage(_ sender: Any) {
        
        if let sender = sender as? UIButton {
            
            didTouchPreviewImage = true
            
            selectedButon?.layer.borderWidth = 0
            selectedButon?.alpha = 0.75
            
            sender.alpha = 1.0
            sender.layer.borderWidth = 4
            sender.layer.borderColor = UIColor.MaverickBadgePrimaryColor.cgColor
            selectedButon = sender
            
            previewImage.image = sender.image(for: .normal)
            scrollView.zoomScale = scrollView.minimumZoomScale
            
        }
        
    }
    
}

extension FinalPostChangeCoverViewController: UIScrollViewDelegate {
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return previewContentView
    }
    
}

extension FinalPostChangeCoverViewController: PostTimelineDelegate {
    
    func didSelectSegment(atIndex index: Int) {
        
        if index == -1 {
            
            maverickComposition.assetRepresentingExportWithOverlay { asset in
                
                if asset == nil {
                    // TODO: ERR
                    return
                }
                self.reload(withAsset: asset!)
            }
            
        } else {
            
            guard let asset = maverickComposition.savedOverlayAsset(forIndex: index) else { return }
            reload(withAsset: asset)
            
        }
        
    }
    
}
