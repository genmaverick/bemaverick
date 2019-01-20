//
//  MediaPlayerView.swift
//  BeMaverick
//
//  Created by David McGraw on 9/11/17.
//  Copyright © 2017 BeMaverick. All rights reserved.
//

import UIKit
import SCRecorder
import AVFoundation

/**
 View built for video playback
 */
class MediaPlayerView: SCVideoPlayerView {
    
    // MARK: - Lifecycle
    
    deinit {
        
        log.verbose("💥")
        player?.endSendingPlayMessages()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)

        /// Ignore the Ring/Silent switch
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback, with: AVAudioSessionCategoryOptions.defaultToSpeaker)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            
        }
        
        /// Initialize SCPlayer instance
        let obj = SCPlayer()
        obj.beginSendingPlayMessages()
        obj.isMuted = false
        obj.volume = 0.5
        player = obj
        
        /// Enable tap-to-pause
        tapToPauseEnabled = true
        
    }
    
    // MARK: - Public Methods
    
    /**
     Clear the media player and load the provided path
     */
    open func setup(withUrl url: URL?) {
        
        if let url = url, let cached = MediaPlayerCache.default.item(forKey: url), cached.isPlayable == true {
            
            /// Set the item if no current item exists
            guard let urlAsset = player?.currentItem?.asset as? AVURLAsset else {
                player?.setItemBy(cached)
                return
            }
            
            /// Set the item if the current item and cached item do not match
            if url != urlAsset.url {
                player?.setItemBy(cached)
            }
            
        } else {
            player?.setItemBy(url)
        }
    }
    
    /**
     Set the volume on the video player
    */
    open func setVolume(volume: Double) {
        player?.volume = Float(volume)
    }
    
    /*
     Begin playback from the start
     */
    open func playFromBeginning() {
        
        player?.pause()
        player?.seek(to: kCMTimeZero)
        player?.play()
        
    }
    
    /*
     Begin playback from wherever we left off
     */
    open func playFromCurrentTime() {
        player?.play()
    }
    
    /**
     Stop the active playback in the media player
     */
    open func pause() {
        player?.pause()
    }
    
    /**
     Prepares the loaded media player to be reused; clearing any existing data
     */
    open func prepareForReuse() {
        
        player?.pause()
        player?.setItem(nil)
        
    }
    
}
