//
//  MaverickComposition.swift
//  BeMaverick
//
//  Created by David McGraw on 1/27/18.
//  Copyright © 2018 BeMaverick. All rights reserved.
//

import Foundation
import SCRecorder
import CoreImage
import Rswift

/**
 A helper class for managing the composition of a recorded video
 */
class MaverickComposition: NSObject {
    
    // MARK: - Public Properties
    
    /// The active session under edit that's owned by a `CameraManager`
    weak var session: SCRecordSession!
    
    /// The object responsibile for the overall tracks and time management
    var composition: AVAsset?
    
    /// The object outlining the instructions
    weak var videoComposition: AVMutableVideoComposition?
    
    /// An asset representing the final product
    var videoAssetWithOverlay: AVAsset?
    
    /// The primary view that plays the video
    weak var editorContentView: UIView!
    
    var backgroundColor: UIColor?
    /// A content view on top of `editorContentView` for overlays
    weak var editorOverlayContentView: UIView!
    
    /// The master overlay for the composition
    weak var masterOverlayView: FilterTextOverlayView!
    
    /// A filter for the master overlay
    open var masterOverlayFilter: SCFilter?
    
    /// The available filters for use
    open var filters: [SCFilter] = []
    
    /// Sub filters params to apply to a filter being used
    open var segmentFilterParams: [Int: [Constants.FilterParameter: CGFloat]] = [:]
    
    /// The parent editor controller
    weak var recordViewController: PostRecordViewController!
    
    /// A reference to the parent's player object
    weak var previewPlayer: SCPlayer?
    
    /// The original image captured by the user
    open var lastCapturedImage: UIImage?
    
    /// The final image consisting the filter and overlay
    open var finalEditedImage: UIImage?
    
    /// A dict describing what filter should be applied to a segment
    var segmentsFilters: [Int: SCFilter] = [:]
    
    /// Overlays on a per-segment basis
    var segmentOverlays: [Int: FilterTextOverlayView] = [:]
    
    /// The selected segment being played. If playing all, -1
    var selectedSegmentIndex = -1
    
    /// The index of the segment being played
    var playingSegmentIndex = 0
    
    /// Track the segments that've been exported
    var exportedSegmentCount: Int = 0
    
    /// The max amount of time for video recording
    let maxRecordingDuration = Constants.CameraManagerMaxRecordDuration
    
 ///
    let operationQueue: OperationQueue = OperationQueue()
    
   static var processingSession : [String : SCAssetExportSession] = [:]
   static var processingState : [String : Constants.DraftProcessingState] = [:]
    
    // MARK: - Private Properties
    
    /// A reference to the time boundary observer
    fileprivate var timeBoundaryObserverRef: Any?
    
    /// Skip the time observer when seeking in order to avoid a boundary from continuously being hit
    fileprivate var skipBoundarySeek: Bool = false
    
    // MARK: - Lifecycle

    init(withSession session: SCRecordSession,
         previewPlayer player: SCPlayer,
         recordViewController: PostRecordViewController)
    {
        
        super.init()
        
        self.session = session
        self.previewPlayer = player
        self.recordViewController = recordViewController
        self.editorContentView = recordViewController.editorContentView
        self.editorOverlayContentView = recordViewController.editorOverlayContentView
        
        self.configureView()
        
    }
    
    /**
     Provides no session behavior.
    */
    override init() {
       super.init()
    }
    
    deinit {
        log.verbose("💥")
    }
    
    // MARK: - Public Methods
    
    /**
    */
    open func prepareForReuse(shouldDeleteLocalAssets: Bool = false) {
        
        if shouldDeleteLocalAssets {
            
            CameraManager.removeSavedData(forSessionId: session.identifier)
            deleteDirectoryPathForDrawing()
            
        }
        
        backgroundColor = nil
        lastCapturedImage = nil
        finalEditedImage = nil
        exportedSegmentCount = 0
        playingSegmentIndex = 0
        selectedSegmentIndex = -1
        
        masterOverlayView.reset()
        for (_, overlay) in segmentOverlays {
            overlay.removeFromSuperview()
        }
        
        session.removeAllSegments()
        
        segmentOverlays = [:]
        segmentsFilters = [:]
        segmentFilterParams = [:]
        
    }
    
    /**
     Removes the last recorded segment from the session
     */
    func removeLastSegment() {
        session?.removeLastSegment()
    }
    
    /**
     Removes the last recorded segment from the session and deletes the file
     from disk.
     */
    func removeSegment(atIndex index: Int) {
        
        if let count = session?.segments.count, index < count {
            session?.removeSegment(at: index, deleteFile: true)
        }
        
    }
    
    /**
     Seek `previewPlayer` based on the index of the segment
    */
    open func seekToSegmentIndex(index: Int) {
        
        let i = index == -1 ? 0 : index
        if let value = getTimeRangesForSegments()[safe: i] {
            
            previewPlayer?.seek(to: value.timeRangeValue.start,
                                toleranceBefore: kCMTimeZero,
                                toleranceAfter: kCMTimeZero)
            previewPlayer?.play()
            previewPlayer?.pause()
            
        }
        
    }
    
    /**
     Get the index for the segment at the provided time
    */
    open func segmentIndex(forTime time: CMTime) -> Int {
        
        var idx = 0
        for value in getTimeRangesForSegments() {
            
            if value.timeRangeValue.containsTime(time) {
                return idx
            }
            idx += 1
            
        }
        return idx
        
    }
    
    /**
 
    */
    open func setFilterForSelectedIndex(_ filter: SCFilter) {
        
        if selectedSegmentIndex == -1 {
            masterOverlayFilter = filter
            return
        }
        segmentsFilters[selectedSegmentIndex] = filter
        
    }
    
    /**
 
    */
    open func filterForSelectedIndex() -> SCFilter {
        
        if selectedSegmentIndex == -1 {
            
            if masterOverlayFilter != nil {
                return masterOverlayFilter!
            }
            return filters.first!
            
        }
        return segmentsFilters[selectedSegmentIndex] ?? filters.first!
        
    }
    
    /**
     */
    open func filterParamsForSelectedIndex() -> [Constants.FilterParameter: CGFloat] {
        
        if selectedSegmentIndex == -1 {
            return [:]
        }
        return segmentFilterParams[selectedSegmentIndex] ?? [:]
        
    }
    
    
    /**
     Load the provided segment into the preview player and play it. If `nil` is
     passed in an asset will be created from the entire composition.
    */
    open func beginPlayback(forSegment segment: SCRecordSessionSegment? = nil) {
        
        if timeBoundaryObserverRef == nil {
            refreshPreviewPlayerBoundaryObserver()
        }
        
        // Reference file history when segments are brought back into the picture
        masterOverlayView.isHidden = false
        
        // Seek to the selected segment (or all)
        if let _ = segment?.asset {
            
//            selectedSegmentIndex = index(forSegment: segment!)
            skipBoundarySeek = true
            
        }
        
        seekToSegmentIndex(index: selectedSegmentIndex)
        
        log.debug("Begin playback at index \(selectedSegmentIndex)")
        
    }
    
    /**
     Get a still image from the first segment in the `SCRecordSession`
    */
    open func getStillPreviewImage() -> UIImage? {
        
        if let asset = session.segments.first?.asset {
        
            let imageGenerator = AVAssetImageGenerator(asset: asset)
            do {
                let ref = try imageGenerator.copyCGImage(at: CMTimeMake(1, 60), actualTime: nil)
                return UIImage(cgImage: ref)
            } catch { }
        
        }
        return R.image.defaultPreviewImage()
        
    }
    
    /**
     Get the default set of filters that can be applied to a composition
    */
    open func getFiltersAvailableForComposition() -> [SCFilter] {
        
        var filters: [SCFilter] = []
        
        let emptyFilter = SCFilter()
        emptyFilter.name = "None"
        filters.append(emptyFilter)
        
        for index in 1...18 {
        
            if let fileURL = Bundle.main.url(forResource: "Filter\(index)", withExtension: "cisf") {
                
                let filter = SCFilter(contentsOf: fileURL)

                    if let subfilters = filter.subFilters as? [SCFilter] {
                        
                        for sf in subfilters {
                        
                            let center = CIVector(x: Constants.CameraManagerExportSize.width / 2.0,
                                                  y: Constants.CameraManagerExportSize.height / 2.0)
                            
                            if sf.name == "CIVignetteEffect" {
                                sf.setParameterValue(center, forKey: "inputCenter")
                            }
                            
                        }
                        
                    }
        
                    filter.name = "Filter \(index)"
                    filters.append(filter)
        
            }
            
        }
    
        return filters
        
    }
    
    /**
     Retrieve a filter based on the name
    */
    open func getFilter(usingName name: String) -> SCFilter? {
        
        for filter in filters {
            
            if filter.name == name {
                return filter
            }
            
        }
        
        return nil
        
    }
    
    /**
    */
    open func updateParamsForSegment(params: [Constants.FilterParameter: CGFloat]) {
        
        if selectedSegmentIndex == -1 {
            return
        }
        
        segmentFilterParams[selectedSegmentIndex] = params
        
    }
    
    /**
     Calculates the time ranges for each segment within the session
    */
    open func getTimeRangesForSegments() -> [NSValue] {
        
        var ranges: [NSValue] = []
        var cursorTime = kCMTimeZero
        
        for segment in session.segments {
        
            if let asset = segment.asset {
            
                let timeRange = CMTimeRangeMake(cursorTime, asset.duration)
                cursorTime = CMTimeAdd(cursorTime, asset.duration)
                ranges.append(NSValue(timeRange: timeRange))
                
            }
            
        }
        
        return ranges
        
    }
    
    /**
     Get the time boundaries for each segment within the session
     */
    open func getTimeBoundariesForSegments() -> [NSValue] {
        
        var ranges: [NSValue] = []
        for range in getTimeRangesForSegments() {
            ranges.append(NSValue(time: CMTimeSubtract(range.timeRangeValue.end, CMTimeMake(1, 30))))
        }
        return ranges
        
    }
    
    /**
     Get the segment for the provided index
     */
    open func segment(forIndex index: Int) -> SCRecordSessionSegment? {
        
        if let segment = session.segments[safe: index] {
            return segment
        }
        return nil
        
    }
    
    /**
     Get the index of the recorded segment
     */
    open func index(forSegment segment: SCRecordSessionSegment) -> Int {
        return session.segments.index(of: segment) ?? -1
    }
    
    /**
     Insert a new text field within a segment overlay
    */
    open func insertTextField(withFont font: UIFont? = nil, color: UIColor = .black) {
        
        let overlay = getActiveOverlay()
        overlay?.insertNewTextField()
        
    }
    
    /**
     Insert a new image view within a segment overlay
     */
    open func insertImageView(withImage image: UIImage, stickerName: String?) {
        
        let overlay = getActiveOverlay()
        overlay?.insertNewImageView(image: image, stickerName: stickerName)
        
    }
    
    /**
     Disable drawing and hide the active overlay
    */
    open func deselectActiveOverlay() {
        
        let overlay = getActiveOverlay()
        overlay?.deselectActiveOverlay()
        
    }
    
    /**
     Retrieve the active overlay based on the playing segment
    */
    open func getActiveOverlay() -> FilterTextOverlayView? {
        
        if selectedSegmentIndex == -1 {
            return masterOverlayView
        }
        return getOverlay(forIndex: selectedSegmentIndex)
        
    }
    
    /**
     Retrive an overlay for the provided index. This will create an overlay for
     the index if it doesn't exist.
    */
    open func getOverlay(forIndex index: Int) -> FilterTextOverlayView? {
        
        if let overlay = segmentOverlays[index] {
            return overlay
        }
        
        let overlay = createTextOverlayView(atIndex: index)
        editorOverlayContentView.addSubview(overlay)
        overlay.autoPinEdgesToSuperviewEdges()
        
        segmentOverlays[index] = overlay
        segmentFilterParams[index] = [:]
        return segmentOverlays[index]
        
    }
    
    /**
     Retrieve the duration of each segment within the session
     */
    func getDurationsForAllSessionSegment() -> [Double] {
        
        guard let segments = session?.segments else { return [] }
        return segments.map { CMTimeGetSeconds($0.duration) }
        
    }
    
    /**
     Removes an existing segment at the provided index and replaces it with a
     trimmed version of the provided asset. Removal will be skipped if index
     is -1.
    */
    open func replaceAsset(asset: AVAsset,
                           atIndex index: Int,
                           startTime: CMTime,
                           endTime: CMTime,
                           completionHandler: @escaping (_ error: MaverickError?) -> Void)
    {
        
        // TODO: Move this to the side so we can recover it if something goes wrong
        if index != -1 {
            session.removeSegment(at: index, deleteFile: true)
        }
        
        insertAsset(asset: asset,
                    atIndex: index,
                    startTime: startTime,
                    endTime: startTime,
                    completionHandler: completionHandler)
        
    }
    
    /**
     Inserts a the provided asset into the existing composition. This assumes the
     asset is NOT part of the current `SCSession`
     */
    open func insertAsset(asset: AVAsset,
                          atIndex index: Int = -1,
                          atRect: CGRect? = nil,
                          startTime: CMTime,
                          endTime: CMTime,
                          completionHandler: @escaping (_ error: MaverickError?) -> Void)
    {
        
        
        // Verify there's enough time
        let duration = (endTime - startTime)
        let timeCombinedWithComposition = CMTimeAdd(duration, composition?.duration ?? kCMTimeZero)
        if CGFloat(timeCombinedWithComposition.seconds) > (Constants.CameraManagerMaxRecordDuration + 0.5) {

            let remaining = Int(Constants.CameraManagerMaxRecordDuration) - Int(composition?.duration.seconds ?? 0)
            let err = MaverickError.recordingEditorFailed(reason: .exceedsMaxTimeBoundary(secondsRemaining: remaining))
            completionHandler(err)
            return

        }
        
        // Create and append segment
        let idx = session.segments.count
        
        // Create an original version that will be treated as a new segment
        let filename = "\(self.session.identifier)SCVideo.\(idx).\(self.session.fileExtension ?? "mp4")"
        let url = SCRecordSessionSegment.segmentURL(forFilename: filename,
                                                    andDirectory: self.session.segmentsDirectory)
        
        let comp = createComposition(forAsset: asset, atRect: atRect)
        
        exportSessionToDisk(withAsset: comp.composition,
                            videoComposition: comp.videoComposition,
                            url: url,
                            startTime: startTime,
                            endTime: endTime)
        { status in
            
            switch status {
                
            case .completed:
            
                let segment = SCRecordSessionSegment(url: url, info: nil)
                self.session.addSegment(segment)
                
                // Track a filter for the segment
                self.segmentsFilters[idx] = self.filters.first
                
                // Track overlay for the new segment
                let overlay = self.createTextOverlayView(atIndex: idx)
                self.editorOverlayContentView.addSubview(overlay)
                overlay.autoPinEdgesToSuperviewEdges()
                overlay.isHidden = true
                
                self.segmentOverlays[idx] = overlay
                self.segmentFilterParams[idx] = [:]
                
                // Party on Wayne
                completionHandler(nil)
                
                self.logDebugSession()
            
            case .failed:
              completionHandler(MaverickError.recordingEditorFailed(reason: .exportSessionFailed()))
            
            default:
                break
                
            }
            
        }
        
    }
   
    /**
     Creates an overlay base on how many segments are in the session
     */
    open func insertSegmentOverlay() {
        setupOverlay(atIndex: session.segments.count - 1)
    }
    
    /**
     Remove an overlay for the segment at the provided index
    */
    open func removeSegmentOverlay(atIndex index: Int) {
        
        // Remove overlay data
        segmentsFilters[index] = nil
        segmentFilterParams[index] = nil
        segmentOverlays[index]?.removeFromSuperview()
        segmentOverlays[index] = nil
        
        // Remove the segment
        session.removeSegment(at: index, deleteFile: true)
        
    }
    
    /**
     Export the provided composition to disk. If an item exists at `url` it will
     be removed before the export begins.
     
     - parameter composition:      The primary composition
     - parameter videoComposition: The video composition
     - parameter url:              The destination to be written to
     - parameter startTime:        The beginning of the time range to export
     - parameter endTime:          The end of the time range being exported
     */
    open func exportSessionToDisk(withAsset composition: AVMutableComposition,
                                  videoComposition: AVMutableVideoComposition,
                                  url: URL,
                                  startTime: CMTime,
                                  endTime: CMTime,
                                  completionHandler: @escaping (_ status: AVAssetExportSessionStatus) -> Void) {
        
        guard let export = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetHighestQuality) else {
            
            completionHandler(.failed)
            return
            
        }
        
        // Cannot save over an existing file
        if FileManager.default.fileExists(atPath: url.path) {
            
            do {
                try FileManager.default.removeItem(at: url)
            } catch { }
        }
        
        export.outputURL = url
        export.outputFileType = .mp4
        export.timeRange = CMTimeRange(start: startTime, end: endTime)
        export.videoComposition = videoComposition
        
        export.exportAsynchronously {
            
            DispatchQueue.main.async {
                completionHandler(export.status)
            }
            
        }
        
    }
    
    // MARK: - Private Methods
    
    /**
     Prepares filters and overlays for usage
     */
    fileprivate func configureView() {
        
        filters = self.getFiltersAvailableForComposition()
        
        // Setup master overlay
        masterOverlayView = createTextOverlayView(atIndex: -1)
        editorOverlayContentView.addSubview(masterOverlayView)
        masterOverlayView.autoPinEdgesToSuperviewEdges()
        
    }
    
    /**
     Prepares the data structures to support an overlay for the segment
    */
    fileprivate func setupOverlay(atIndex index: Int) {
        
        // Track a filter for the segment
        segmentsFilters[index] = filters.first
        
        // Track overlay for the new segment
        let overlay = createTextOverlayView(atIndex: index)
        self.editorOverlayContentView.addSubview(overlay)
        overlay.autoPinEdgesToSuperviewEdges()
        overlay.isHidden = true
        
        segmentOverlays[index] = overlay
        segmentFilterParams[index] = [:]
        
    }
    
    /**
     Reload `editorComposition` based on the current segments within the `SCRecord` session.
     
     This composition cannot have layer instructions due to video effects being
     applied to frames.
     */
    @discardableResult
    func reloadSessionComposition() -> Bool {
        
        if session.segments.count == 0 {
            previewPlayer?.setItem(nil)
            composition = nil
            videoComposition = nil
            return false
        }
        
        composition = session.assetRepresentingSegments()
        
        videoComposition = AVMutableVideoComposition(asset: composition!, applyingCIFiltersWithHandler: { request in
            
            let time = request.compositionTime
            let index = self.segmentIndex(forTime: time)
            
            // Process Filter Request
            self.processVideoCompositionFilterRequest(request: request, atSegmentIndex: index)
            
        })
        
        if videoComposition == nil {
            return false
        }
        
        videoComposition!.renderSize = Constants.CameraManagerExportSize
        videoComposition!.frameDuration = CMTimeMake(1, 30)
     
        let item = AVPlayerItem(asset: composition!)
        item.videoComposition = videoComposition!
        
        previewPlayer?.setItem(item)
        
        return true
        
    }
    
    /**
    */
    fileprivate func processVideoCompositionFilterRequest(request: AVAsynchronousCIImageFilteringRequest, atSegmentIndex index: Int) {
        
        var outputImage: CIImage? = request.sourceImage
        
        let filter = segmentsFilters[index]
        let filterParams = segmentFilterParams[index]
        
        if let filters = filter?.subFilters as? [SCFilter] {
            
            for s in filters {
                
                if let name = s.name, name == "CIColorControls" {
                    
                    if let brightness = filterParams?[.inputBrightness] {
                        s.setParameterValue(brightness, forKey: Constants.FilterParameter.inputBrightness.rawValue)
                    }
                    
                    if let saturation = filterParams?[.inputSaturation] {
                        s.setParameterValue(saturation, forKey: Constants.FilterParameter.inputSaturation.rawValue)
                    }
                    
                } else if let name = s.name, name == "CIHueAdjust" {
                    
                    if let angle = filterParams?[.inputAngle] {
                        s.setParameterValue(angle, forKey: Constants.FilterParameter.inputAngle.rawValue)
                    }
                    
                }
                
            }
            
        }
        
        outputImage = filter?.image(byProcessingImage: outputImage, atTime: CMTimeGetSeconds(request.compositionTime))
//        outputImage = outputImage?.oriented(forExifOrientation: 2)
        
        if let outputImage = outputImage {
            request.finish(with: outputImage, context: nil)
        } else {
            request.finish(with: request.sourceImage, context: nil)
        }
        
    }
    
    /**
     Check the visible index at the provided time and adjust the overlay visibility
     accordingly
    */
    fileprivate func refreshOverlayVisibility(atTime time: CMTime, atSegmentIndex index: Int) {
        
        if time.value < 0 { return }
        
        // Skip overlay check if the player isn't playing (not a reliable check as it's not
        // called when switching to the master overlay)
        if !self.previewPlayer!.isPlaying { return }
        
        if index == playingSegmentIndex {
            return
        }
        
        if index <= segmentOverlays.count {
            
            segmentOverlays[index]?.isHidden = false
            segmentOverlays[playingSegmentIndex]?.isHidden = true
            
            playingSegmentIndex = index
            
        }
        
    }
    
    /**
    */
    open func applyFilter(filter: CIFilter, toSegment segment: SCRecordSessionSegment) {
        
        guard let asset = segment.asset else { return }
        
        previewPlayer?.currentItem?.videoComposition = AVVideoComposition(asset: asset, applyingCIFiltersWithHandler: { request in
        
            let source = request.sourceImage
            filter.setValue(source, forKey: kCIInputImageKey)
            
            if let output = filter.outputImage {
                request.finish(with: output, context: nil)
            }
            
        })
        
    }
    
    /**
     Get the length of time for the provided segment
     */
    fileprivate func timeRange(forSegment segment: SCRecordSessionSegment) -> CMTimeRange {
        return CMTimeRangeMake(kCMTimeZero, segment.duration)
    }
    
    /**
     Observer monitors the composition playback and handles looping content based on the segment selection
     */
    fileprivate func refreshPreviewPlayerBoundaryObserver() {
        
        timeBoundaryObserverRef = previewPlayer!.addBoundaryTimeObserver(forTimes: getTimeBoundariesForSegments(),
                                                                                    queue: .main)
        { [weak self] in
            
            guard let strongSelf = self else { return }
            
            if strongSelf.skipBoundarySeek {
                strongSelf.skipBoundarySeek = false
                return
            }
            
            if strongSelf.selectedSegmentIndex != -1 {
                
                strongSelf.skipBoundarySeek = true
                strongSelf.seekToSegmentIndex(index: strongSelf.selectedSegmentIndex)
                
            }
            
        }
        
    }
    
    /**
     Initialize an overlay with default brush and color types
    */
    fileprivate func createTextOverlayView(atIndex index: Int) -> FilterTextOverlayView {
        
        let overlay = FilterTextOverlayView.instanceFromNib()
        overlay.parentViewController = recordViewController
        overlay.indexIdentifier = index
        overlay.setDrawingColor(color: recordViewController.defaultColorStyle)
        overlay.setDrawingBrushType(type: recordViewController.defaultBrushType,
                                    withColor: recordViewController.defaultColorStyle,
                                    size: recordViewController.defaultBrushSize)
        overlay.isHidden = true
        overlay.backgroundColor = .clear
        overlay.clipsToBounds = true
        return overlay
        
    }
    
    /**
     Verify if the asset can be exported using the provided `preset`. If unable
     the completion handler will return `AVAssetExportPresetPassthrough`
     */
    fileprivate func getValidExportPreset(forAsset asset: AVAsset,
                                          preset: String = AVAssetExportPresetHighestQuality,
                                          completionHandler: @escaping (_ preset: String) -> Void) {
        
        AVAssetExportSession.determineCompatibility(ofExportPreset: preset, with: asset, outputFileType: .mp4) { isValid in
            
            if isValid {
                completionHandler(preset)
            } else {
                completionHandler(AVAssetExportPresetPassthrough)
            }
            
        }
        
    }
    
    /**
     Log information about the current maverick composition
     */
    fileprivate func logDebugSession() {
        
        log.debug("Total segments \(session.segments.count) with a duration of \(session.segmentsDuration.seconds)")
        
        var idx = 1
        for segment in session.segments {
            log.debug("Segment \(idx) duration is \(segment.duration.seconds)")
            idx += 1
        }
        
    }
    
    /**
     Get the orientation from the provided transform.
     */
    static func orientationFromTransform(transform: CGAffineTransform) -> (orientation: UIImageOrientation, isPortrait: Bool) {
        
        var assetOrientation = UIImageOrientation.up
        var isPortrait = false
        
        if transform.a == 0 && transform.b == 1.0 && transform.c == -1.0 && transform.d == 0 {
            assetOrientation = .right
            isPortrait = true
        } else if transform.a == 0 && transform.b == -1.0 && transform.c == 1.0 && transform.d == 0 {
            assetOrientation = .left
            isPortrait = true
        } else if transform.a == 1.0 && transform.b == 0 && transform.c == 0 && transform.d == 1.0 {
            assetOrientation = .up
        } else if transform.a == -1.0 && transform.b == 0 && transform.c == 0 && transform.d == -1.0 {
            assetOrientation = .down
        }
        
        return (assetOrientation, isPortrait)
        
    }
    
}
