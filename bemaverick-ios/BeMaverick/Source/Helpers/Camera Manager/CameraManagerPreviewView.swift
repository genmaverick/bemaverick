//
//  CameraManagerPreviewView.swift
//  BeMaverick
//
//  Created by David McGraw on 9/13/17.
//  Copyright © 2017 BeMaverick. All rights reserved.
//

import UIKit
import AVFoundation

class CameraManagerPreviewView: UIView {
    
    // MARK: - Public Properties
    
    /// The layer responsible for displaying the capture preview
    var videoPreviewLayer: AVCaptureVideoPreviewLayer {
        
        guard let layer = layer as? AVCaptureVideoPreviewLayer else {
            fatalError("Expected 'AVCaptureVideoPreviewLayer' type for layer")
        }
        return layer
        
    }
    
    /// The session managing the recording, managed by the camera manager
    weak var session: AVCaptureSession? {
        
        get {
            return videoPreviewLayer.session
        }
        set {
            videoPreviewLayer.session = newValue
        }
        
    }
    
    /// The video orientation
    var videoOrientation: AVCaptureVideoOrientation? {
        
        get {
            return videoPreviewLayer.connection?.videoOrientation
        }
        set {
            
            if newValue != nil {
                videoPreviewLayer.connection?.videoOrientation = newValue!
            }
            
        }
        
    }
    
    // MARK: - Overrides
    
    /// The layer class for the view is 'AVCaptureVideoPreviewLayer'
    override class var layerClass: AnyClass {
        return AVCaptureVideoPreviewLayer.self
    }
    
}
