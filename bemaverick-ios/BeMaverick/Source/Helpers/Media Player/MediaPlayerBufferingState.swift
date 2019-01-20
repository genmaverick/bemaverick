//
//  MediaPlayerBufferingState.swift
//  BeMaverick
//
//  Created by David McGraw on 9/11/17.
//  Copyright © 2017 BeMaverick. All rights reserved.
//

enum MediaPlayerBufferingState: Int {
    
    case unknown
    
    case ready
   
    case delayed
   
}

extension MediaPlayerBufferingState: CustomStringConvertible {
    
    public var description: String {
        
        get {
            
            switch self {
            case .unknown: return "Unknown"
            case .ready: return "Ready"
            case .delayed: return "Delayed"
            }
            
        }
        
    }
    
}
