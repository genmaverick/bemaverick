//
//  VideoPlayerView.swift
//  Maverick
//
//  Created by Garrett Fritz on 2/21/18.
//  Copyright © 2018 BeMaverick. All rights reserved.
//

import Foundation
import AVKit

protocol VideoPlayerViewDelegate: class {
    
    func toggleOverlay(isVisible visible : Bool)
    func mainAreaTapped()
    func didReachEnd(media: MaverickMedia, isMuted: Bool)
    func didStartReplaying(isMuted: Bool)
    func didCrossInterval(interval: Int, isMuted: Bool)
    func didStartPlaying(startTime: Float64, isMuted: Bool, bufferTime: UInt64)
    func didStopPlaying(stopTime: Float64, playDuration: Float64, isMuted: Bool)
    func didResumePlaying(startTime: Float64, isMuted: Bool)
    
}

/// buffering flag
private var playbackLikelyToKeepUpContext = 0

class VideoPlayerView: UIView {
    
    private let greedyLoad = true
    // MARK: - IBOutlets
    
    /// The player view
    @IBOutlet weak var playerView: PlayerView!
    /// Main View
    @IBOutlet weak var view: UIView!
    /// Loading indicator
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    /// play/pause button
    @IBOutlet weak var playPauseButton: UIImageView!
    /// controls container
    @IBOutlet weak var controlView: UIView!
    
    
    // MARK: - IBActions
    
    /**
     Tapping main section
     */
    @IBAction func mainScreenTapped(_ sender: Any) {
        
        showUI()
        delegate?.mainAreaTapped()
        
    }
    
    
    // MARK: - Private Properties
    
    private var currentUrl = ""
    /// bool switch to indicate video has played
    private var hasPlayed = false
    /// avplayer object
    private let avPlayer = AVPlayer()
    private var lastMediaURLLoaded = ""
    private var avAsset: AVURLAsset?
    /// Player item for AVPlayer
    private var playerItem : AVPlayerItem! {
        didSet {
            self.observer = playerItem.observe(\.status, options:  [.new, .old], changeHandler: { (playerItem, change) in
                if playerItem.status == .readyToPlay {
                    self.addBoundaryTimeObserver()
                    self.observer?.invalidate()
                    self.observer = nil
                }
            })
        }
    }
    private var shouldLoop = true
    /// Media item to play
    private var media: MaverickMedia?
    
    var allowAutoplay = false
    /// Tap delegate
    weak var delegate: VideoPlayerViewDelegate?
    
    private var timeObserverToken: Any?
    
    private var nextBoundary: Int = 25
    
    private var observer: NSKeyValueObservation?
    
    private var startTime: Float64 = 0
    
    private var replayCount = 0
    
    private var startVideoBufferTime: DispatchTime?
    
    private var endVideoBufferTime: DispatchTime?
    
    // MARK: - Lifecycle
    
    static func prefetchVideo(media : MaverickMedia?) {
        
        guard let path = media?.URLOriginal, let url = URL(string: path) else { return }
        
        
        #if DEVELOPMENT
        VideoPlayerView.remoteFileExists(url: url)
        #endif
        
        if url.pathExtension == "mp4" || url.pathExtension == "mov" {
            
            let result = CacheManager.shared.getFileWith(stringUrl: path, ignoreMax: true)
            
        }
        
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
        
    }
    
    required init?(coder: NSCoder) {
        
        super.init(coder: coder)
        setup()
        
    }
    
    private func setup() {
        
        view = instanceFromNib()
        addSubview(view)
        view.frame = self.bounds
        view.backgroundColor = UIColor.clear
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.playerItemDidReachEnd(notification:)),
                                               name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
                                               object: avPlayer.currentItem)
        
        setUpClickHandlers()
        controlView.isHidden = true
        avPlayer.actionAtItemEnd = .none
        playerView.playerLayer.player = avPlayer
        setUpValueObservers()
        
    }
    
    func instanceFromNib() -> UIView {
        return R.nib.videoPlayerView.firstView(owner: self)!
    }
    
    deinit {
        
        log.verbose("💥")
        removeObservers()
        
    }
    
    private func removeObservers() {
        
        if let token = timeObserverToken {
            avPlayer.removeTimeObserver(token)
            timeObserverToken = nil
        }
        
        avPlayer.removeObserver(self, forKeyPath: "currentItem.playbackLikelyToKeepUp")
        avPlayer.removeObserver(self, forKeyPath: "status")
        avPlayer.removeObserver(self, forKeyPath: "rate")
        
    }
    
    // MARK: - Public Methods
    
    /**
     setup data from maverick media object
     */
    func configure(with media: MaverickMedia?, muteState : Bool = true, allowAutoplay : Bool? = nil, shouldLoop : Bool = true) {
        
        guard let mediaUrl = media?.URLOriginal else { return }
        isHidden = false
        
        if let allowAutoplay = allowAutoplay {
            
            self.allowAutoplay = allowAutoplay
            
        }
        self.shouldLoop = shouldLoop
        avPlayer.volume = muteState ? 0 : 3
        
        if currentUrl != mediaUrl  {
            
//            print("👯‍♀️ configure: \(mediaUrl)")
            activityIndicator.startAnimating()
            self.media = media
            currentUrl = mediaUrl
            
            playerView.playerLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
            avPlayer.replaceCurrentItem(with: nil)
            
            if greedyLoad {
                
                loadMedia()
                
            }
            
        } else if self.allowAutoplay {
            
//            print("👯‍♀️ skipping configure: \(currentUrl)")
            
            play()
            
        }
        
    }
    
    
    
    func isMuted() -> Bool {
        return avPlayer.volume == 0
    }
    
    /**
     Mute toggle
     */
    @discardableResult
    func muteToggle() -> Bool {
        
        avPlayer.volume = avPlayer.volume == 0 ? 3 : 0
        return isMuted()
        
    }
    
    /**
     Deliberately set mute state of the video
     */
    func setMuteState(muted : Bool) {
        
        avPlayer.volume = muted ? 0 : 3
        
    }
    
    /**
     Autoplay if not playing already
     TODO: save previous position
     */
    func attemptAutoplay() {
        play()
    }
    
    /**
     Is video currently playing
     */
    func isPlaying() -> Bool {
        
        return avPlayer.rate > 0
        
    }
    
    /**
     Reset view
     */
    func prepareForReuse(removeMedia : Bool = false) {
        
        avPlayer.pause()
        
        if removeMedia {
            
            activityIndicator.stopAnimating()
            currentUrl = ""
            avPlayer.replaceCurrentItem(with: nil)
            
        }
        
    }
    
    private func loadMedia(fromConfig : Bool = true) {
        
        
        let mediaUrl = currentUrl
        
        guard let path = media?.URLOriginal, let url = URL(string: path) else { return }
        guard lastMediaURLLoaded != path else {
            
            if greedyLoad {
                
                if fromConfig {
                    
                    play()
                    
                }
            }
            
            
            return
            
            
        }
        
        
        lastMediaURLLoaded = path
//         print("👯‍♀️ load media: \(mediaUrl)")
        #if DEVELOPMENT
        VideoPlayerView.remoteFileExists(url: url)
        #endif
        if url.pathExtension.caseInsensitiveCompare("mp4") == .orderedSame || url.pathExtension.caseInsensitiveCompare("mov") == .orderedSame {
            
            let result = CacheManager.shared.getFileWith(stringUrl: path)
            
            startVideoBufferTime = DispatchTime.now()
            
            switch result {
                
            case .success(let cacheUrl):
                CacheManager.log("playing cached video \(url.absoluteString.suffix(10))")
                self.playerItem = AVPlayerItem(url: cacheUrl)
                self.avPlayer.replaceCurrentItem(with: self.playerItem)
                
            case .downloading:
                CacheManager.log("downloading streamed video \(url.absoluteString.suffix(10))")
                self.avPlayer.replaceCurrentItem(with: nil)
                self.avAsset?.cancelLoading()
                self.avAsset = AVURLAsset(url: url)
                self.avAsset?.loadValuesAsynchronously(forKeys: ["playable"], completionHandler: {
                    CacheManager.log("playing streamed video \(url.absoluteString.suffix(10))")
                    DispatchQueue.main.async {
                        
                        guard self.currentUrl == mediaUrl else { return }
                        guard let asset = self.avAsset  else { return }
                        
                        self.playerItem = AVPlayerItem(asset: asset)
                        
                        self.avPlayer.replaceCurrentItem(with: self.playerItem)
                        
                    }
                    
                })
                
            }
            
        } else {
            
            self.playerItem = AVPlayerItem(url: url)
            self.avPlayer.replaceCurrentItem(with: self.playerItem)
            
        }
        
        
    }
    /**
     Play Video
     */
    func play() {
        
        if !greedyLoad || avPlayer.currentItem == nil {
            
            lastMediaURLLoaded = ""
            loadMedia(fromConfig: false)
            
        }
        
//        guard avPlayer.rate == 0 else { return }
        if avPlayer.currentItem == nil {
        
//            print("👯‍♀️ dead play: \(currentUrl)")
        
        }
        
        avPlayer.play()
        hasPlayed = true
        playPauseButton.image = R.image.play()
        
    }
    
    /**
     Pause Video
     Returns current elapsed time
     */
    func pause(allowAuto : Bool? = nil)  {
        
        avPlayer.pause()
        playPauseButton.image = R.image.badgebag()
        
        if let allowAuto = allowAuto {
            
            allowAutoplay = allowAuto
            
        }
        
    }
    
    /**
     Play/Paused button tapped
     */
    @objc func playPausePressed() {
        
        if avPlayer.rate > 0 {
            
            _ = pause()
            
        } else {
            
            attemptAutoplay()
            
        }
        
    }
    
    // A notification is fired and seeker is sent to the beginning to loop the video again
    @objc func playerItemDidReachEnd(notification: Notification) {
        
        if let media = media {
            
            if let item = notification.object as? AVPlayerItem {
                
                if item == avPlayer.currentItem {
                    
                    delegate?.didReachEnd(media: media, isMuted: isMuted())
                    
                }
                
            }
            
        }
        
        guard let p: AVPlayerItem = notification.object as? AVPlayerItem, p == playerItem else { return }
        
        if shouldLoop {
            
            p.seek(to: kCMTimeZero)
            
            delegate?.didStartReplaying(isMuted: isMuted())
            replayCount += 1
            
        }
        
        
        
    }
    
    // MARK: - Private Methods
    
    /**
     Initialize value observers
     */
    private func setUpValueObservers() {
        
        avPlayer.addObserver(self, forKeyPath: "currentItem.playbackLikelyToKeepUp",
                             options: .new, context: &playbackLikelyToKeepUpContext)
        
        avPlayer.addObserver(self, forKeyPath: "status",
                             options: [.new, .initial], context: &playbackLikelyToKeepUpContext)
        
        avPlayer.addObserver(self, forKeyPath: "rate", options: [.new, .old], context: nil)
        
    }
    
    /**
     Observers
     */
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        if keyPath == "status" && context == &playbackLikelyToKeepUpContext && change != nil
        {
            /*
             Handle `NSNull` value for `NSKeyValueChangeNewKey`, i.e. when
             `player.currentItem` is nil.
             */
            let newStatus: AVPlayerItemStatus
            
            if let newStatusAsNumber = change?[NSKeyValueChangeKey.newKey] as? NSNumber {
                newStatus = AVPlayerItemStatus(rawValue: newStatusAsNumber.intValue)!
            }
            else {
                newStatus = .unknown
            }
            
            if newStatus == .failed {
                
                isHidden = true
                
            }
            
            
            if newStatus == .readyToPlay && allowAutoplay {
                play()
            }
            
        }
        
        if context == &playbackLikelyToKeepUpContext {
            
            if avPlayer.currentItem?.isPlaybackLikelyToKeepUp ?? false {
                
                activityIndicator.stopAnimating()
                if !hasPlayed && allowAutoplay {
                    play()
                }
                
            } else if currentUrl != "" {
                
                activityIndicator.startAnimating()
                
            }
            
        }
        
        if keyPath == "rate" {
            
            guard let changeDictionary = change else { return }
            
            guard let newValue = changeDictionary[NSKeyValueChangeKey.newKey] as? NSNumber else { return }
            
            guard let oldValue = changeDictionary[NSKeyValueChangeKey.oldKey] as? NSNumber else { return }
            
            let currentTimeInSeconds = CMTimeGetSeconds(avPlayer.currentTime()).isNaN ? 0 : CMTimeGetSeconds(avPlayer.currentTime())
            
            if oldValue == 1 && newValue == 0 {
                
                let playDuration: Float64 = {
                    
                    if replayCount > 0 {
                        
                        let durationOfAssetInSeconds = CMTimeGetSeconds(avPlayer.currentItem!.asset.duration)
                        
                        if startTime > 0 {
                            
                            return(Double(replayCount - 1) * durationOfAssetInSeconds) + (durationOfAssetInSeconds - startTime) + currentTimeInSeconds
                            
                        } else {
                            
                            return (Double(replayCount) * durationOfAssetInSeconds) + currentTimeInSeconds
                            
                        }
                        
                    } else {
                        return CMTimeGetSeconds(avPlayer.currentTime()) - startTime
                    }
                    
                }()
                
                if playDuration != 0 && !playDuration.isNaN {
                    
                    delegate?.didStopPlaying(stopTime: currentTimeInSeconds, playDuration: playDuration, isMuted: isMuted())
                }
                
                
            } else if oldValue == 0 && newValue == 1 {
                
                replayCount = 0
                startTime = currentTimeInSeconds
                
                if startTime == 0 && !hasPlayed {
                    
                    endVideoBufferTime = DispatchTime.now()
                    
                    let bufferTimeInMilliseconds: UInt64 = {
                        
                        guard let endVideoBufferTime = endVideoBufferTime, let startVideoBufferTime = startVideoBufferTime else { return 0 }
                        
                        return (endVideoBufferTime.rawValue - startVideoBufferTime.rawValue) / 1_000_000
                        
                    }()
                    
                    delegate?.didStartPlaying(startTime: startTime, isMuted: isMuted(), bufferTime: bufferTimeInMilliseconds)
                    
                } else if startTime > 0 {
                    
                    delegate?.didResumePlaying(startTime: startTime, isMuted: isMuted())
                    
                }
                
            }
            
        }
        
    }
    
    private func addBoundaryTimeObserver() {
        
        var times = [NSValue]()
        
        // Set initial time to zero
        var currentTime = kCMTimeZero
        
        // Set the percentage
        let percentage: Float64 = 0.25
        
        // Divide the asset's duration into quarters.
        let interval = CMTimeMultiplyByFloat64(playerItem.asset.duration, percentage)
        
        // Build boundary times at 25%, 50%, 75%
        for _ in 0 ..< 3 {
            currentTime = currentTime + interval
            times.append(NSValue(time:currentTime))
        }
        
        // Queue on which to invoke the callback
        let mainQueue = DispatchQueue.main
        
        // Add time observer
        timeObserverToken = avPlayer.addBoundaryTimeObserver(forTimes: times, queue: mainQueue) {
            [weak self] in
            
            if let strongSelf = self {
                
                strongSelf.delegate?.didCrossInterval(interval: strongSelf.nextBoundary, isMuted: strongSelf.avPlayer.volume == 0)
                strongSelf.nextBoundary = strongSelf.nextBoundary == 75 ? 25 : strongSelf.nextBoundary + 25
                
            }
            
        }
        
    }
    
    /**
     Initialize Click Handlers
     TODO: change to button
     */
    private func setUpClickHandlers() {
        
        let tapPlayPauseGestureRecognizer = UITapGestureRecognizer(target: self, action:  #selector(playPausePressed))
        playPauseButton.isUserInteractionEnabled = true
        playPauseButton.addGestureRecognizer(tapPlayPauseGestureRecognizer)
        
    }
    
    /**
     Show UI
     */
    private func showUI() {
        
        UIView.animate(withDuration: 0.5, animations: {
            self.controlView.alpha = 1
        })
        
        self.delegate?.toggleOverlay(isVisible: true)
        
    }
    
    static func remoteFileExists(url: URL, completionHandler: ((_ success : Bool) -> Void)? = nil) {
        
        var request = URLRequest(url: url)
        request.httpMethod = "HEAD"
        
        let task = URLSession(configuration: .default).dataTask(with: request) { (data, response, error) in
            
            if let httpResponse = response as? HTTPURLResponse {
                
                if httpResponse.statusCode == 200 {
                    
                    completionHandler?(true)
                    
                } else{
                    
                    completionHandler?(false)
                    print("⛔️ unabled to load video : \(url.absoluteString)")
                    
                }
                
            } else {
                
                completionHandler?(false)
                print("⛔️ unabled to load video : \(url.absoluteString)")
            
            }
            
        }
        
        task.resume()
        
        
        
    }
    
}
