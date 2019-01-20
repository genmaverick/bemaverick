//
//  MediaPlayerFillMode.swift
//  BeMaverick
//
//  Created by David McGraw on 9/11/17.
//  Copyright © 2017 BeMaverick. All rights reserved.
//

import AVFoundation

enum MediaPlayerFillMode {
    
    /// Stretch to fill
    case resize
    
    /// Preserve aspect ratio, filling bounds
    case aspectFill
    
    /// Preserve aspect ratio, fill within bounds
    case aspectFit
    
    /// Raw value from the AVFoundation type
    var avFoundationType: String {
        
        get {
            
            switch self {
            case .resize:
                return AVLayerVideoGravity.resize.rawValue
            case .aspectFill:
                return AVLayerVideoGravity.resizeAspectFill.rawValue
            case .aspectFit:
                return AVLayerVideoGravity.resizeAspect.rawValue
            }
            
        }
        
    }
    
}

