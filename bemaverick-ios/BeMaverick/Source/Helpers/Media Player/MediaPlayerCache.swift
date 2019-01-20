//
//  MediaPlayerCache.swift
//  BeMaverick
//
//  Created by David McGraw on 10/11/17.
//  Copyright © 2017 BeMaverick. All rights reserved.
//

import UIKit
import AVFoundation

class MediaPlayerCache: NSObject {
    
    // MARK: - Static
    
    /// A default instance of `MediaPlayerCache`, used across video players
    open static let `default`: MediaPlayerCache = {
        return MediaPlayerCache()
    }()
    
    // MARK: - Public Properties
    
    open let maxTotalCachedItems: Int = 20
    
    // MARK: - Private Properties
    
    fileprivate var cache: [URL: AVAsset] = [:]

    fileprivate var queueURL: [URL] = []
    
    // MARK: - Public Methods
    
    func cache(withKey key: URL, item: AVAsset) {
        
        if cache.keys.count >= maxTotalCachedItems {
            
            if let k = queueURL.first {
                remove(key: k)
            }
            
        }
        
        queueURL.append(key)
        cache[key] = item
        
    }
    
    func item(forKey key: URL) -> AVAsset? {
        return cache[key]
    }
    
    func remove(key: URL) {
        
        if let idx = queueURL.index(of: key) {
            queueURL.remove(at: idx)
        }
        cache.removeValue(forKey: key)
        
    }
    
    func reset() {
        
        queueURL.removeAll()
        cache.removeAll()
        
    }

}
