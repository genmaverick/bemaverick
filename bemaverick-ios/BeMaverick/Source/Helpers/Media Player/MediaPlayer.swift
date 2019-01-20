//
//  MediaPlayer.swift
//  BeMaverick
//
//  Created by David McGraw on 9/11/17.
//  Copyright © 2017 BeMaverick. All rights reserved.
//

import Foundation
import AVFoundation

protocol MediaPlayerDelegate {
    
    /// Frames began moving
    func mediaPlayerDidBeginPlayback()

    /// Player reached the end and will stop or loop back to the first frame
    func mediaPlayerDidReachEnd()
    
    /// Volume changed on the loaded item
    func mediaPlayerVolumeChanged(volume: CGFloat)
    
    ///
    func mediaPlayerLoadingContent()
    
}


/**
 Media player responsible for managing playback
 */
class MediaPlayer: NSObject {
    
    // MARK: - Public Properties
    
    /// The local or remote URL to be played
    open var url: URL? {
        
        didSet {
            setup(withUrl: url)
        }
        
    }
    
    /// Current playback state of the Player
    open var playerState: MediaPlayerState = .uninitialized {
        
        didSet {
            if oldValue != playerState {
                log.verbose("📽 Player state updated \(playerState.description) [\(player?.rate ?? 0)] | \(providedContentPath)")
            }
        }
        
    }
    
    /// The object that acts as the delegate of the media player
    open var delegate: MediaPlayerDelegate?
    
    /// Player was paused by user interaction
    open var isPausedByUser: Bool = false
    
    /// Whether the player is playing
    open var isPlaying: Bool = false
    
    /// Whether the player is buffering
    open var isBuffering: Bool = false
    
    /// Whether the content should loop playback
    open var loop: Bool = false
    
    /// Whether the loaded content should immediately begin playback
    open var autoplay: Bool = false
    
    /// Whether the playback is muted
    open var muted: Bool = false
    
    /// The player volume ranging from 0.0 to 1.0
    open var volume: Float = 1.0
    
    /// Player behavior once a video completes playing
    open var playerActionAtEnd: AVPlayerActionAtItemEnd = .pause
    
    /// Buffering state of the player
    fileprivate(set) var playerBufferingState: MediaPlayerBufferingState = .unknown
    
    /// The loaded asset to play
    fileprivate(set) var asset: AVAsset?
    
    // MARK: - Private Properties
    
    /// A player object from the parent view
    fileprivate weak var player: AVPlayer?
    
    /// The parent view responsible for displaying the playback
    fileprivate weak var playerView: MediaPlayerView?
    
    /// The loaded player item
    fileprivate var playerItem: AVPlayerItem?
    
    /// Observer for looping playback
    fileprivate var loopChangeObserver: NSObjectProtocol?
    
    /// The last time value with respect to the player time ranges
    fileprivate var lastBufferTime: Double = 0
    
    /// Playback buffering size in seconds.
    fileprivate var bufferSize: Double = 2
    
    /// The path to the media that's loaded
    fileprivate var providedContentPath: String = ""
    
    // MARK: - Lifecycle
    
    deinit {
        
        log.verbose("💥")
        removePlayerObservers()
        removePlayerItemObservers()
        
    }
    
    init(withPlayer player: AVPlayer, playerView: MediaPlayerView) {
        
        self.player = player
        self.player?.isMuted = muted
        self.player?.volume = volume
        self.player?.actionAtItemEnd = playerActionAtEnd
        self.playerView = playerView
        
        super.init()
        
        // Add observers on the player
        addPlayerObservers()
        
    }
    
    // MARK: - Public Methods
    
    open func autoPlay() {
        
        if !isPausedByUser {
            play()
        }
        
    }
    
    open func playFromBeginning() {
        
        player?.pause()
        player?.seek(to: kCMTimeZero)
        playFromCurrentTime()
        
    }
    
    open func playFromCurrentTime() {
        play()
    }
    
    open func pause() {
        
        player?.pause()
        isPausedByUser = true
        isPlaying = false
        
    }
    
    /**
     Cleans up the media player. Resets default values and the content loaded
     within the player
     */
    open func prepareForReuse() {

        delegate = nil
        
        isPlaying = false
        isPausedByUser = false
        loop = false
        autoplay = false
        
        playerState = .uninitialized
        player?.pause()
        removePlayerItemObservers()
        
        url = nil
        providedContentPath = ""
        
        playerItem = nil
        player?.replaceCurrentItem(with: nil)
        
    }
    
    // MARK: - Private Methods
    
    fileprivate func play() {
        
        isPlaying = true
        isPausedByUser = false
        player?.play()
        
    }
    
    fileprivate func setup(withUrl url: URL?, autoPlay: Bool = false) {
        
        if let url = url {

            providedContentPath = url.absoluteString
            setup(url: url)

        }
        
    }
    
    fileprivate func setup(url: URL, autoPlay: Bool = false) {
        
        if let cached = MediaPlayerCache.default.item(forKey: url), cached.isPlayable == true {
            
            self.asset = cached
            setup(withPlayerItem: AVPlayerItem(asset: cached))
            
        } else {
        
            self.asset = AVURLAsset(url: url, options: .none)
            
            delegate?.mediaPlayerLoadingContent()
            
            let keys = [PlayerTracksKey, PlayerPlayableKey, PlayerDurationKey]
            self.asset?.loadValuesAsynchronously(forKeys: keys) {
             
                /// Check the status of the provided keys
                for key in keys {
                    
                    var err: NSError? = nil
                    
                    if self.asset?.statusOfValue(forKey: key, error: &err) == .failed {
                        
                        self.playerState = .failed
                        log.error("Failed to load video for \(key) \(err?.localizedDescription ?? "")")
                        return
                        
                    }
                    
                }
                
                /// Setup player if it's playable
                if let asset = self.asset {
                    
                    if !asset.isPlayable {
                        
                        self.playerState = .failed
                        log.error("Failed to load asset. It's not playable at \(self.providedContentPath)")
                        return
                        
                    }
                    
                    let item = AVPlayerItem(asset: asset)
                    MediaPlayerCache.default.cache(withKey: url, item: asset)
                    
                    self.setup(withPlayerItem: item)
                    
                }
                
            }
            
        }
        
    }
    
    fileprivate func setup(withPlayerItem item: AVPlayerItem) {
        
        // Remove observers from existing item
        removePlayerItemObservers()

        // Track item
        playerItem = item

        // Add observers to new item
        addPlayerItemObservers()

        // Setup player
        player?.replaceCurrentItem(with: playerItem)
        player?.seek(to: kCMTimeZero)
        player?.actionAtItemEnd = playerActionAtEnd
        
    }
    
    @objc fileprivate func playerItemDidPlayToEndTime(_ notification: Notification) {
        
        isPlaying = false
        
        if loop {
            playFromBeginning()
        }
        
    }
    
    @objc fileprivate func playerItemFailedToPlayToEndTime(_ notification: Notification) {
        
        log.warning("📽 Media player failed to play \(notification.debugDescription)")
        playerState = .failed
        
    }

    fileprivate func addPlayerObservers() {
        
        player?.addObserver(self, forKeyPath: PlayerRateKey, options: [.new, .old], context: &PlayerObserverContext)
        
    }
    
    fileprivate func addPlayerItemObservers() {
        
        playerItem?.addObserver(self, forKeyPath: PlayerStatusKey, options: [.new, .old], context: &PlayerItemObserverContext)
        playerItem?.addObserver(self, forKeyPath: PlayerKeepUpKey, options: [.new, .old], context: &PlayerItemObserverContext)
        playerItem?.addObserver(self, forKeyPath: PlayerLoadedTimeRangesKey, options: [.new, .old], context: &PlayerItemObserverContext)
        
        if let updatedPlayerItem = playerItem {
            NotificationCenter.default.addObserver(self, selector: #selector(playerItemDidPlayToEndTime(_:)), name: .AVPlayerItemDidPlayToEndTime, object: updatedPlayerItem)
            NotificationCenter.default.addObserver(self, selector: #selector(playerItemFailedToPlayToEndTime(_:)), name: .AVPlayerItemFailedToPlayToEndTime, object: updatedPlayerItem)
        }
        
    }
    
    fileprivate func removePlayerObservers() {
        
        player?.removeObserver(self, forKeyPath: PlayerRateKey, context: &PlayerObserverContext)
        
    }
    
    fileprivate func removePlayerItemObservers() {
        
        playerItem?.removeObserver(self, forKeyPath: PlayerStatusKey, context: &PlayerItemObserverContext)
        playerItem?.removeObserver(self, forKeyPath: PlayerKeepUpKey, context: &PlayerItemObserverContext)
        playerItem?.removeObserver(self, forKeyPath: PlayerLoadedTimeRangesKey, context: &PlayerItemObserverContext)
        
        if let currentPlayerItem = playerItem {
            NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: currentPlayerItem)
            NotificationCenter.default.removeObserver(self, name: .AVPlayerItemFailedToPlayToEndTime, object: currentPlayerItem)
        }
        
    }
    
}

// MARK: - KVO

// KVO contexts
fileprivate var PlayerObserverContext = 0
fileprivate var PlayerItemObserverContext = 0
fileprivate var PlayerLayerObserverContext = 0

// KVO player keys
fileprivate let PlayerTracksKey = "tracks"
fileprivate let PlayerPlayableKey = "playable"
fileprivate let PlayerDurationKey = "duration"
fileprivate let PlayerRateKey = "rate"

// KVO player item keys
fileprivate let PlayerStatusKey = "status"
fileprivate let PlayerEmptyBufferKey = "playbackBufferEmpty"
fileprivate let PlayerKeepUpKey = "playbackLikelyToKeepUp"
fileprivate let PlayerLoadedTimeRangesKey = "loadedTimeRanges"

extension MediaPlayer {
    
    override func observeValue(forKeyPath keyPath: String?,
                               of object: Any?,
                               change: [NSKeyValueChangeKey : Any]?,
                               context: UnsafeMutableRawPointer?)
    {
                
        if context == &PlayerItemObserverContext {
            
            if keyPath == #keyPath(AVPlayerItem.status) {
            
                if player?.status == .readyToPlay {
                    playerState = .ready
                    
                    if !isPausedByUser {
                        play()
                    }
                
                } else if player?.status == .failed {
                    playerState = .failed
                    
                }
            
                
            } else if keyPath == #keyPath(AVPlayerItem.isPlaybackBufferEmpty) {
                
                if playerItem!.isPlaybackBufferEmpty {
                    
                    playerState = .buffering
                    playerShouldBuffer()
                    
                }
                
            } else if keyPath == #keyPath(AVPlayerItem.loadedTimeRanges) {
               
                
                
                
               
            }
 
        } else if context == &PlayerObserverContext {
            
            // Track the player rate and maintain playback
            if keyPath == #keyPath(AVPlayer.rate) {

                guard let rate = player?.rate,
                      let item = playerItem,
                      let currentPlayer = player else { return }

                if item.isPlaybackLikelyToKeepUp || item.isPlaybackBufferFull {
                    playerState = .bufferingComplete
                    delegate?.mediaPlayerDidBeginPlayback()
                } else {
                    playerState = .buffering
                    playerShouldBuffer()
                }
                
                if rate == 0.0 {
                    
                    if currentPlayer.error != nil {
                        playerState = .failed
                    
                    }
                    
                }

            }
            
        }
        
    }
    
    /**
     Allow the player to buffer a period of time before kicking off playback
     */
    fileprivate func playerShouldBuffer() {
        
        playerState = .buffering
        
        if isBuffering { return }
        isBuffering = true
        
        player?.pause()
        
        let time = DispatchTime.now() + Double(Int64(Double(NSEC_PER_SEC) * 1.0)) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: time) {
            
            self.isBuffering = false
            
            if let item = self.playerItem, self.isPausedByUser == false {
                
                if item.isPlaybackLikelyToKeepUp {
                    self.playerState = .bufferingComplete
                    self.play()
                } else {
                    self.playerShouldBuffer()
                }
                
            }
            
        }
    
    }
    
}
