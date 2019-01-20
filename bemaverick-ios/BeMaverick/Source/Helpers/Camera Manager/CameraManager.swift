//
//  CameraManager.swift
//  BeMaverick
//
//  Created by David McGraw on 9/13/17.
//  Copyright © 2017 BeMaverick. All rights reserved.
//

import UIKit
import SCRecorder
import AVFoundation

protocol CameraManagerDelegate: class {
    
    /// The camera manager failed
    func cameraManagerDidFail(withError error: CameraManagerError)
    
    /// The camera manager began recording at the provided path
    func cameraManagerDidBeginRecording(atFileURL url: URL)
    
    /// The camera manager completed recording at the provided path
    func cameraManagerDidCompleteRecording(atOutputURL url: URL, segmentDuration: Double, totalDuration: Double)
    
    /// Camera manager completed configuration
    func cameraManagerDidCompleteSessionSetup()
    
    /// Capture session status changed
    func cameraManagerSessionStatusChanged(isRunning: Bool)
        
}

class CameraManager: NSObject {
    
    // MARK: - Public Properties
    
    /// Object responsibile for handling the recording
    let recorder: SCRecorder = SCRecorder.shared()
    
    /// The object representing the recording
    var session: SCRecordSession?
    
    /// Previously saved metadata
    var existingSessionMetadata: [AnyHashable: Any]?
    
    /// The challenge title
    var sessionChallengeTitle: String?
    
    /// The challenge being responded to
    var sessionChallengeId: String?
    
    /// The cover image for the recording
    var sessionCoverImage: UIImage?
    
    /// The cover image location on disk
    var sessionCoverImageURL: URL?
    
    /// The description for the recording
    var sessionDescription: String = ""
    
    /// The max amount of time for video recording
    let maxRecordingDuration = Constants.CameraManagerMaxRecordDuration
    
    /// Camera manager delegate
    weak var delegate: CameraManagerDelegate!
    
    /// A preview view for SCRecorder
    weak var scPreviewView: UIView?
    
    // MARK: - Lifecycle
    
    deinit {
        log.verbose("💥")
    }
    
    override init() {
        super.init()
    }
    
    init(withPreviewView view: UIView) {
        
        super.init()
        
        // Keep track of the preview layer for necessary UI updates (orientation updates)
        scPreviewView = view
        
        // Setup the video recorder
        recorder.captureSessionPreset = SCRecorderTools.bestCaptureSessionPresetCompatibleWithAllDevices()
        recorder.device = .front
        recorder.maxRecordDuration = CMTimeMake(Int64(maxRecordingDuration), 1)
        recorder.delegate = self
        recorder.previewView = view
        recorder.mirrorOnFrontCamera = true
        recorder.keepMirroringOnWrite = false
        recorder.focusCenter()
        
        // Configure video
        let video = recorder.videoConfiguration
        video.enabled = true
        
        video.size = Constants.CameraManagerExportSize
        video.scalingMode = AVVideoScalingModeResizeAspectFill
        video.timeScale = 1
        video.bitrate = 6000000

        // Configure audio
        let audio = recorder.audioConfiguration
        audio.enabled = true
        audio.bitrate = 128000      // 128kbit /s
        audio.channelsCount = 1     // mono
        audio.sampleRate = 0
        audio.format = Int32(kAudioFormatMPEG4AAC)
        
        // Prepare the recorder if a session doesn't exist
        if recorder.session != nil { return }
        do {
            try recorder.prepare()
        } catch {
            log.error("Failed to prepare SCRecorder: \(error.localizedDescription)")
        }
        
    }
    
    // MARK: - Public Methods

    /**
     Cancels the current session and and resets the manager
     */
    func resetSCSession() {
        
        recorder.session?.cancel({
            self.prepareRecordingSession()
        })
        
    }
    
    /**
     Get the recording state
    */
    func isRecording() -> Bool {
        return recorder.isRecording
    }
    
    /**
     Determines if a recording can begin. A recording cannot be made if the
     session is already at the max duration.
    */
    func canBeginRecording() -> Bool {
        
        guard let duration = session?.duration else { return false }
        
        if CMTimeGetSeconds(duration) > Double(maxRecordingDuration) {
            return false
        }
        return true
        
    }
    
    /**
     Begins recording a new segment
     */
    func startRecording() {
        recorder.record()
    }
    
    /**
     Capture an image
    */
    func captureImage(completionHandler: @escaping (_ image: UIImage?) -> Void) {
        
        recorder.capturePhoto { (error, image) in
            
            if var cgImage = image?.cgImage {
                
                let rect = self.recorder.previewLayer.metadataOutputRectConverted(fromLayerRect: self.recorder.previewLayer.bounds)
                let width = CGFloat(cgImage.width)
                let height = CGFloat(cgImage.height)
                let cropRect = CGRect(x: rect.origin.x * width,
                                      y: rect.origin.y * height,
                                      width: rect.size.width * width,
                                      height: rect.size.height * height)
                
                cgImage = cgImage.cropping(to: cropRect)!
                
                if self.recorder.device == .front {
                    completionHandler(UIImage(cgImage: cgImage, scale: image!.scale, orientation: .leftMirrored))
                } else {
                    completionHandler(UIImage(cgImage: cgImage, scale: image!.scale, orientation: .right))
                }
                
            } else {
                completionHandler(nil)
            }
            
        }
        
    }
    
    /**
     Pauses the recording for the session and creates a segment.
     */
    func stopRecording(completionHandler: @escaping () -> Void) {
        
        recorder.pause {
            
            log.verbose("Total Segments: \(self.session!.segments.count)")
            log.verbose("Total Segments Duration: \(CMTimeGetSeconds(self.session!.segmentsDuration))")
            log.verbose("Output: \(self.session!.outputUrl)")
            
            completionHandler()
            
        }
        
    }

    /**
     Retrieve the duration of each segment within the session
     */
    func getDurationsForAllSessionSegment() -> [Double] {
        
        guard let segments = session?.segments else { return [] }
        return segments.map { CMTimeGetSeconds($0.duration) }
        
    }
    
    /**
     Get the cover image of the first segment or a custom image
    */
    func getSessionCoverImage() -> UIImage? {
    
        if sessionCoverImage != nil {
            return sessionCoverImage
        }
        
        if let segment = session?.segments.first {
            sessionCoverImage = segment.thumbnail
        }
        return sessionCoverImage
        
    }
    
    /**
     */
    func exportRecording(withAsset asset: AVAsset,
                         completionHandler: @escaping (_ outputUrl: URL?) -> Void) {
        
        guard let session = session else {
            
            log.error("Failed to export the recording. No session found!")
            completionHandler(nil)
            return
            
        }
        
        stopRunning()
        
        let export = SCAssetExportSession(asset: asset)
        export.outputUrl = session.outputUrl
        export.outputFileType = AVFileType.mp4.rawValue
        export.audioConfiguration.preset = SCPresetMediumQuality
        
        export.videoConfiguration.size = Constants.CameraManagerExportSize
        export.videoConfiguration.scalingMode = AVVideoScalingModeResizeAspectFill
        export.videoConfiguration.timeScale = 1
        export.videoConfiguration.preset = SCPresetHighestQuality
        
        export.exportAsynchronously {
            
            guard export.error == nil else {
                
                log.error("Error exporting session from SCRecorder: \(export.error!.localizedDescription)")
                completionHandler(nil)
                return
                
            }
            
            completionHandler(session.outputUrl)
            
            self.delegate?.cameraManagerDidCompleteRecording(atOutputURL: session.outputUrl,
                                                             segmentDuration: self.getDurationsForAllSessionSegment().last ?? 0,
                                                             totalDuration: CMTimeGetSeconds(session.segmentsDuration))
            
        }
        
    }
    
    /**
     */
    func startRunning() {
        recorder.startRunning()
    }
    
    /**
     */
    func stopRunning() {
        recorder.stopRunning()
    }
    
    /**
     */
    func previewFrameNeedsUpdated() {
        recorder.previewViewFrameChanged()
    }
    
    /**
     */
    func prepareRecordingSession() {
        
        if session == nil {
            
            session = SCRecordSession()
            session!.fileType = AVFileType.mp4.rawValue
            recorder.session = session!
            
        } else {
            session?.removeAllSegments(true)
        }
        
    }
        
    /**
     Swap the camera position from it's current state
     */
    func toggleCameraPosition() {
        recorder.switchCaptureDevices()
    }
    
    /**
     */
    func toggleFlashMode(mode: SCFlashMode) {
        recorder.flashMode = mode
    }
    
    /**
     */
    func toggleTorchMode(mode: SCFlashMode? = nil) {
        
        if let mode = mode {
            recorder.flashMode = mode
            return
        }
        
        if recorder.flashMode == .light {
            recorder.flashMode = .off
        } else {
            recorder.flashMode = .light
        }
        
    }
    
    /**
     */
    func deviceHasFlash() -> Bool {
        return recorder.deviceHasFlash
    }
    
    // MARK: - Private Methods
    
    /**
     Add observers
     */
    fileprivate func addObservers() {
        
    }
    
    /**
     Remove observers
     */
    fileprivate func removeObservers() {
        
    }
    
}

extension CameraManager: SCRecorderDelegate {
    
    func recorder(_ recorder: SCRecorder,
                  didComplete session: SCRecordSession) {
        
    }
    
    func recorder(_ recorder: SCRecorder,
                  didBeginSegmentIn session: SCRecordSession,
                  error: Error?) {
        
        delegate?.cameraManagerDidBeginRecording(atFileURL: session.outputUrl)
    }
    
    func recorder(_ recorder: SCRecorder,
                  didComplete segment: SCRecordSessionSegment?,
                  in session: SCRecordSession,
                  error: Error?) {
        
        guard let outputUrl = segment?.url else { return }
        
        delegate?.cameraManagerDidCompleteRecording(atOutputURL: outputUrl,
                                                    segmentDuration: getDurationsForAllSessionSegment().last ?? 0,
                                                    totalDuration: CMTimeGetSeconds(session.segmentsDuration))
        
    }
    
    func createSegmentInfo(for recorder: SCRecorder) -> [AnyHashable : Any]? {
        return [:]
    }
    
}

