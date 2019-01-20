//
//  MaverickComposition+Export.swift
//  BeMaverick
//
//  Created by David McGraw on 2/3/18.
//  Copyright © 2018 BeMaverick. All rights reserved.
//

import Foundation
import AVFoundation
import SCRecorder

extension MaverickComposition {
    
    /**
     Merges the overlay with the image
    */
    open func prepareImageComposition(image: UIImage) -> UIImage {
        
        // Make sure the delete button isn't visible
        masterOverlayView.deleteObjectButton?.tag = -1
        masterOverlayView.deleteObjectButton?.isHidden = true
        
        let container = UIView(frame: masterOverlayView.bounds)
        container.backgroundColor = .clear
        
        let imageView = UIImageView(frame: masterOverlayView.bounds)
        
        if let filter = masterOverlayFilter,
            let filteredImage = applyFilter(filter: filter, toImage: image) {
            imageView.image = filteredImage
        } else {
            imageView.image = image
        }
        
        let overlayImage = masterOverlayView.imageFromView()
        let overlayImageView = UIImageView(frame: masterOverlayView.bounds)
        overlayImageView.image = overlayImage
        
      
        container.addSubview(imageView)
        container.addSubview(overlayImageView)

        return UIImage(view: container)
        
    }
    
    /**
     Apply the filter to the provided image
    */
    open func applyFilter(filter: SCFilter, toImage image: UIImage) -> UIImage? {
        return filter.uiImage(byProcessingUIImage: image)
    }
    
    
    func clearDraftToPost(sessionId : String, cameraManager : CameraManager, services : GlobalServicesContainer) {
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.0) { 
            
           let (checkState, _) = MaverickComposition.getProgress(sessionId: sessionId)
           guard let state = checkState else { return }
            
            if state == .cancelled {
            
                return
            
            } else if state == .failed {
                
                self.prepareVideoCompositionForSegments(sessionId: sessionId)
                
            } else if state == .success {
                
                guard let masterOverlayView = self.masterOverlayView else { return }
                
                self.prepareOverlayView(withMasterView: masterOverlayView, masterDrawingImage: nil, segmentView: nil, completionHandler: { (overlay, overlayAsImage) in
                    
                    self.assetURLRepresentingExport(completionHandler: { assetURL in
                        
                        guard let assetURL = assetURL else { return }
                        
                        let merge = Merge(config: .standard)
                        let asset = AVAsset(url: assetURL)
                        
                        log.verbose("⚙️ Beginning overlay merge for asset \(assetURL.absoluteString)")
                        
                        merge.overlayVideo(video: asset, overlayImage: overlayAsImage, completion: { url in
                            
                            guard let url = url else { return }
                            
                            log.verbose("⚙️ Merge for asset \(assetURL.absoluteString) completed and located at \(url.absoluteString)")
                            
                            let filename = "\(self.session.identifier)SCVideo-Overlay.Merged.\(self.session.fileExtension ?? "mp4")"
                            let fileToBeReplaced = SCRecordSessionSegment.segmentURL(forFilename: filename, andDirectory: (self.session.segmentsDirectory))
                            
                            do {
                                
                                log.verbose("⚙️ Replacing file at \(fileToBeReplaced.absoluteString) with file at \(url.absoluteString)")
                                
                                let resultURL = try FileManager.default.replaceItemAt(fileToBeReplaced, withItemAt: url)
                                log.verbose("⚙️ Resulting url for replacement is \(resultURL!.absoluteString)")
                                guard resultURL == fileToBeReplaced else { return }
                                
                            } catch {
                                return
                            }
                            
                            self.generateCoverImage(completionHandler: { image in
                                
                                let randomFilename = "\(sessionId)_coverImage" + ".jpg"
                                let data = UIImageJPEGRepresentation(image, 0.8)
                                let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last!
                                cameraManager.sessionCoverImageURL = dir.appendingPathComponent(randomFilename)
                                cameraManager.sessionCoverImage = image
                                
                                if let path = cameraManager.sessionCoverImageURL?.path {
                                    FileManager.default.createFile(atPath: path , contents: data, attributes: nil)
                                }
                                
                                services.globalModelsCoordinator.uploadContentResponse(withFileURL: assetURL,
                                                                                       forChallengeId: cameraManager.sessionChallengeId,
                                                                                       description: cameraManager.sessionDescription,
                                                                                       coverImage: cameraManager.sessionCoverImageURL,
                                                                                       responseType: .video,
                                                                                       sessionId: sessionId,
                                                                                       shareChannels: [])
                                
                            })
                        }) { progress in
                            // not necessary to follow the progress
                        }
                    })
                    
                })
                
            } else {
                self.clearDraftToPost(sessionId: sessionId, cameraManager: cameraManager, services: services)
            }
            
        }
        
    }
    
    
    static func getProgress(sessionId : String) -> (Constants.DraftProcessingState?, Float) {
        
        var progress : Float = -1.0
        
        if let session = MaverickComposition.processingSession[sessionId] {
            
            progress = session.progress
            
            if progress == 1 {
                
                if let error = session.error {
                
                    MaverickComposition.processingState[sessionId] = .failed
                    
                } else {
                    
                    MaverickComposition.processingState[sessionId] = .success
                    
                }
                
            }
            
        }
        
        return (MaverickComposition.processingState[sessionId], progress)
        
    }
    /**
     Creates a copy of the original recordings with an overlay applied.
     
     */
    open func prepareVideoCompositionForSegments(sessionId : String)
    {
        
        MaverickComposition.processingState[sessionId] = .processing
        
        operationQueue.maxConcurrentOperationCount = 3
        
        let asset = self.session.assetRepresentingSegments()
        
        let currentExportSession = SCAssetExportSession(asset: asset)
        MaverickComposition.processingSession[sessionId] = currentExportSession
        currentExportSession.outputFileType = AVFileType.mp4.rawValue
        
        currentExportSession.videoConfiguration.filter = self.masterOverlayFilter
        
        currentExportSession.videoConfiguration.size = Constants.CameraManagerExportSize
        currentExportSession.videoConfiguration.bitrate = 6000000
        
        currentExportSession.audioConfiguration.preset = SCPresetMediumQuality
        currentExportSession.shouldOptimizeForNetworkUse = true
        let filename = "\(self.session.identifier)SCVideo-Overlay.Merged.\(self.session.fileExtension ?? "mp4")"
        currentExportSession.outputUrl = SCRecordSessionSegment.segmentURL(forFilename: filename, andDirectory: self.session.segmentsDirectory)
        
        let operation = SCRecordExportOperation(withExportSession: currentExportSession)
        
        operationQueue.addOperation(operation)
        
    }

    /**
     Combines a segment's overlay with the master overlay.
    */
    open func prepareOverlayView(withMasterView master: FilterTextOverlayView,
                                 masterDrawingImage: UIImage?,
                                 segmentView: FilterTextOverlayView?,
                                 completionHandler: @escaping (_ combinedOverlay: FilterTextOverlayView, _ overlayAsUIImage: UIImage) -> Void) {
        
        let exportFrame = CGRect(x: 0, y: 0, width: Constants.CameraManagerExportSize.width, height: Constants.CameraManagerExportSize.height)
        
        let finalOverlay = FilterTextOverlayView()
        finalOverlay.hasInitDrawingProxy     = true
        finalOverlay.frame                   = master.bounds
        
        // --
        
        let size = Constants.CameraManagerExportSize
        let factor  = size.width / master.bounds.size.width
        
        let overlay = FilterTextOverlayView()
        overlay.translatesAutoresizingMaskIntoConstraints = false
        overlay.autoresizesSubviews = false
        overlay.autoresizingMask = []
        
        // Skip layout for the jot view
        overlay.hasInitDrawingProxy     = true
        overlay.frame                   = exportFrame
        
        master.deleteObjectButton?.tag = -1
        master.deleteObjectButton?.isHidden = true
        
        var components: [UIView] = []
        
        // Add Master Components
        if let subviews = master.componentsView?.subviews {
            components.append(contentsOf: subviews)
        }
        
        // Add Secondary overlay components
        if segmentView != nil {
            
            segmentView!.deleteObjectButton?.tag = -1
            segmentView!.deleteObjectButton?.isHidden = true
            
            if let subviews = segmentView!.componentsView?.subviews {
                components.append(contentsOf: subviews)
            }
            
        }
        
        if masterDrawingImage != nil {
            
            let v = UIImageView()
            v.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
            v.image = masterDrawingImage!
            overlay.addSubview(v)
            overlay.sendSubview(toBack: v)
            
        }
        
        DispatchQueue.main.async {

            master.drawingView!.exportToImage(onComplete: { image in

                DispatchQueue.main.async {

                    for subview in components {
            
                        if let item = subview as? UITextView {
            
                            let v = UITextView()
                            v.bounds = item.bounds
                            v.center = item.center
                            v.transform = item.transform
                            v.text = item.text
                            v.font = item.font
                            v.tintColor = item.tintColor
                            v.textColor = item.textColor
                            v.isScrollEnabled = item.isScrollEnabled
                            v.textAlignment = item.textAlignment
                            v.backgroundColor = item.backgroundColor
                            overlay.addSubview(v)
            
                            v.center = CGPoint(x: v.center.x * factor, y: v.center.y * factor)
                            v.transform = v.transform.scaledBy(x: factor, y: factor)
                            
                        } else if let item = subview as? UIImageView {
            
                            let v = UIImageView(image: item.image)
                            v.bounds = item.bounds
                            v.center = item.center
                            v.transform = item.transform
                            v.backgroundColor = item.backgroundColor
                            overlay.addSubview(v)
            
                            v.center = CGPoint(x: v.center.x * factor, y: v.center.y * factor)
                            v.transform = v.transform.scaledBy(x: factor, y: factor)
                            
                        }
                        
                    }
                    
                    // Add master drawing
                    let v = UIImageView()
                    v.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
                    v.image = image
                    overlay.addSubview(v)
                    overlay.sendSubview(toBack: v)
                    
 
                    let overlayImage = UIImage(view: overlay)
                    let overlayImageView = UIImageView(image: overlayImage)
                    overlayImageView.frame = finalOverlay.bounds
                    finalOverlay.addSubview(overlayImageView)
                    
                    finalOverlay.layer.shouldRasterize = true
                    let finalOverlayImage = finalOverlay.asOverlayImage()
                    completionHandler(finalOverlay, finalOverlayImage)

                }

            }, withScale: factor)

        }

    }
    
    /**
     Generates an asset representing the composition
    */
    func generateCoverImage(completionHandler: @escaping (_ image: UIImage) -> Void) {
        
        assetRepresentingExportWithOverlay { asset in
            
            if asset == nil {
                // TODO: ERR
                return
            }
            
            self.getFirstFrame(fromAsset: asset!, completionHandler: completionHandler)
            
        }
        
    }
    
    /**
     Retrieve the first frame from the provided asset
    */
    func getFirstFrame(fromAsset asset: AVAsset, completionHandler: @escaping (_ image: UIImage) -> Void) {
        
        let start = NSValue(time: CMTime(value: 0, timescale: 1000))
        let generator = AVAssetImageGenerator(asset: asset)
        generator.appliesPreferredTrackTransform = true
        generator.generateCGImagesAsynchronously(forTimes: [start]) { (_, cgImage, _, result, error) in
            
            if let cgImage = cgImage, error == nil && result == .succeeded {
                
                DispatchQueue.main.async {
                    completionHandler(UIImage(cgImage: cgImage))
                }
                
            }
            
        }
        
    }
    
    /**
     Get a saved overlay asset if it exists on disk.
    */
    func savedOverlayAsset(forIndex index: Int) -> AVAsset? {
        
        let filename = "\(self.session.identifier)SCVideo-Overlay.\(index).\(self.session.fileExtension ?? "mp4")"
        let url = SCRecordSessionSegment.segmentURL(forFilename: filename,
                                                    andDirectory: self.session.segmentsDirectory)
        
        if FileManager.default.fileExists(atPath: url.path) {
            return AVAsset(url: url)
        }
        return nil
        
    }
    
    /**
     Create an asset based on the files that have been exported with effects applied
     to them.
     */
    func assetRepresentingExportWithOverlay(completionHandler: @escaping (_ asset: AVAsset?) -> Void) {
        
        session.dispatchSync {
        
            let filename = "\(self.session.identifier)SCVideo-Overlay.Merged.\(self.session.fileExtension ?? "mp4")"
            let url = SCRecordSessionSegment.segmentURL(forFilename: filename,
                                                        andDirectory: self.session.segmentsDirectory)
            
            if FileManager.default.fileExists(atPath: url.path) {
                self.videoAssetWithOverlay = AVAsset(url: url)
            }
            
            completionHandler(self.videoAssetWithOverlay)
            
        }
        
    }
    
    /**
     Create a URL based on the file that has been exported with a filter.
     */
    func assetURLRepresentingExport(completionHandler: @escaping (_ url: URL?) -> Void) {
        
        session.dispatchSync {
            
            let filename = "\(self.session.identifier)SCVideo-Overlay.Merged.\(self.session.fileExtension ?? "mp4")"
            let url = SCRecordSessionSegment.segmentURL(forFilename: filename,
                                                        andDirectory: self.session.segmentsDirectory)
            
            if FileManager.default.fileExists(atPath: url.path) {
                completionHandler(url)
            } else {
                completionHandler(nil)
            }
    
        }
        
    }
    
    /**
     Append the asset to the provided composition at `currentTime`
    */
    fileprivate func append(asset: AVAsset, toComposition: AVMutableComposition, currentTime: CMTime) {
        
        var audioTrack: AVMutableCompositionTrack? = nil
        var videoTrack: AVMutableCompositionTrack? = nil
        
        let audioAssetTracks = asset.tracks(withMediaType: .audio)
        let videoAssetTracks = asset.tracks(withMediaType: .video)
        
        var maxBounds: CMTime = kCMTimeInvalid
        var videoTime = currentTime
        
        for videoAssetTrack in videoAssetTracks {
            
            if videoTrack == nil {
                let videoTracks = toComposition.tracks(withMediaType: .video)
                
                if videoTracks.count > 0 {
                    videoTrack = videoTracks.first
                } else {
                    videoTrack = toComposition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid)
                    videoTrack?.preferredTransform = videoAssetTrack.preferredTransform
                }
                
            }
            
            if let videoTrack = videoTrack {
                videoTime = self.appendTrack(track: videoAssetTrack, toCompositionTrack: videoTrack, time: videoTime, bounds: maxBounds)
                maxBounds = videoTime
            }
            
        }
        
        var audioTime = currentTime
        for audioAssetTrack in audioAssetTracks {
            
            if audioTrack == nil {
                
                let audioTracks = toComposition.tracks(withMediaType: .audio)
                
                if audioTracks.count > 0 {
                    audioTrack = audioTracks.first
                } else {
                    audioTrack = toComposition.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid)
                }
                
            }
            
            if let audioTrack = audioTrack {
                audioTime = self.appendTrack(track: audioAssetTrack, toCompositionTrack: audioTrack, time: audioTime, bounds: maxBounds)
            }
            
        }
        
    }
    
    /**
     Append a provided asset track to the composition
    */
    func appendTrack(track: AVAssetTrack,
                     toCompositionTrack compositionTrack: AVMutableCompositionTrack,
                     time: CMTime,
                     bounds: CMTime) -> CMTime
    {
        
        var timeRange = track.timeRange
        var inputTime = time
        inputTime = CMTimeAdd(inputTime, timeRange.start)
        
        if CMTIME_IS_VALID(bounds) {
            
            let currentBounds = CMTimeAdd(time, timeRange.duration)
            
            if currentBounds > bounds {
                timeRange = CMTimeRangeMake(timeRange.start, CMTimeSubtract(timeRange.duration, CMTimeSubtract(currentBounds, bounds)))
            }
            
        }
        
        if timeRange.duration > kCMTimeZero {
            
            do {
                try compositionTrack.insertTimeRange(timeRange, of: track, at: inputTime)
            } catch {
                log.error("Error appending track! \(error)")
            }
            
            return CMTimeAdd(time, timeRange.duration)
            
        }
        
        return inputTime
        
    }
    
    /**
     Create a composition with an adjusted transform based on our preferred transform.
     This step is needed due to how videos are recorded on iOS.
     
     This is used when a new clip is being trimmed and will be written to disk.
     */
    open func createComposition(forAsset asset: AVAsset, atRect: CGRect? = nil) -> (composition: AVMutableComposition, videoComposition: AVMutableVideoComposition) {
        
        var originalSize: CGSize = .zero
        let exportSize = Constants.CameraManagerExportSize
        let composition: AVMutableComposition = AVMutableComposition()
        var orientation: (orientation: UIImageOrientation, isPortrait: Bool)?

        append(asset: asset, toComposition: composition, currentTime: kCMTimeZero)
        
        /// Build video composition
        let videoComposition = AVMutableVideoComposition()
        
        // Apply video track layer instruction
        if let videoCompositionTrack = composition.tracks(withMediaType: .video).first {
            
            /// Track original size
            orientation = MaverickComposition.orientationFromTransform(transform: videoCompositionTrack.preferredTransform)
            if orientation!.isPortrait {
                originalSize = CGSize(width: videoCompositionTrack.naturalSize.height, height: videoCompositionTrack.naturalSize.width)
            } else {
                originalSize = videoCompositionTrack.naturalSize
            }
            
            /// Transform the content based on the destination size and cropping rect.
            let instruction = AVMutableVideoCompositionInstruction()
            instruction.timeRange = CMTimeRangeMake(kCMTimeZero, asset.duration)
            
            let layerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: videoCompositionTrack)
            
            if orientation!.isPortrait {
                
                let ratio = exportSize.width / originalSize.width
                let translate = CGAffineTransform(translationX: exportSize.width-(atRect?.origin.x ?? 0),
                                                  y: -(atRect?.origin.y ?? 0))
                
                let v = CGAffineTransform(a: 1.0, b: 0.0, c: 0.0, d: 1.0, tx: 0.0, ty: 0.0)
                let t = v.concatenating(CGAffineTransform.makeRotation(90, scale: ratio))
                layerInstruction.setTransform(t.concatenating(translate), at: kCMTimeZero)
                
            } else {
                
                let heightScale = exportSize.height / originalSize.height
                let widthScale = exportSize.width / originalSize.width
                let maxs = max(heightScale, widthScale)
                let mins = min(heightScale, widthScale)
                
                let scale = CGAffineTransform(scaleX: maxs, y: maxs)
                let t1 = videoCompositionTrack.preferredTransform.concatenating(scale)
                let t2 = t1.concatenating(CGAffineTransform(translationX: -(atRect?.origin.x ?? 0) * mins,
                                                            y: -(atRect?.origin.y ?? 0)))
                
                layerInstruction.setTransform(t2, at: kCMTimeZero)
                
            }
            
            instruction.layerInstructions = [layerInstruction]
            videoComposition.instructions = [instruction]
            
        }
        
        videoComposition.renderSize = exportSize
        videoComposition.frameDuration = CMTimeMake(1, 30)
        
        return (composition, videoComposition)
        
    }
    
}

extension UIView {
    
    func asOverlayImage() -> UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: bounds)
        return renderer.image { rendererContext in
            layer.render(in: rendererContext.cgContext)
        }
    }
}

