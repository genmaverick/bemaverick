//
//  MediaPlayerState.swift
//  BeMaverick
//
//  Created by David McGraw on 9/11/17.
//  Copyright © 2017 BeMaverick. All rights reserved.
//

enum MediaPlayerState: Int {
    
    case uninitialized
    
    case buffering
    
    case bufferingComplete
    
    case ready
    
    case failed
    
}

extension MediaPlayerState: CustomStringConvertible {
    
    var description: String {
        
        get {
            
            switch self {
            case .uninitialized: return "URL Not Set"
            case .buffering: return "Buffering"
            case .bufferingComplete: return "Buffering Complete"
            case .ready: return "Ready To Play"
            case .failed: return "Failed"
            }
            
        }
        
    }
    
}
