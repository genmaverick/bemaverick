//
//  DevelopmentViewController.swift
//  Development
//
//  Created by David McGraw on 10/26/17.
//  Copyright © 2017 BeMaverick. All rights reserved.
//

import UIKit
import SCRecorder

/**
 NOTES
 
 30fps
 606x1080       432x768
 5.32 Mbits/s   690 kbits/s
     3.5s       1.1s
     2.8s       1.0s
     2.8s       1.0s
 
     0.7s when local
 
 */
class DevelopmentViewController: UIViewController {
    
    // 59.6 MB
    static let ChallengePath = "https://d32424o5gwcij1.cloudfront.net/challenge-2-7d255d9831d98738780fddae600c2de5.mp4"
    
    // 500kb -- 5s
    static let ResponsePath = "https://d32424o5gwcij1.cloudfront.net/iOS_video_0AFF307E-450C-4D71-956D-B7FEA7BCCCA8_1508966392.mp4"
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var statusLabel: UILabel!
    
    @IBOutlet weak var primaryActionButton: UIButton?
    
    @IBOutlet weak var secondaryActionButton: UIButton?
    
    @IBOutlet weak var mediaPlayer: MediaPlayerView?
    
    // MARK: - IBActions
    
    @IBAction func primaryActionTapped(_ sender: Any) {
        benchmarkAndLoadVideo(atPath: DevelopmentViewController.ChallengePath)
    }
    
    @IBAction func secondaryActionTapped(_ sender: Any) {
        benchmarkAndLoadVideo(atPath: DevelopmentViewController.ResponsePath)
    }
    
    // MARK: - Private Properties
    
    fileprivate var benchmarkStartTime: CFAbsoluteTime? = CFAbsoluteTimeGetCurrent()
    
    fileprivate var benchmarkEndTime: CFAbsoluteTime = CFAbsoluteTimeGetCurrent() {
        
        didSet {
            
            statusLabel?.text = "\(Double(benchmarkEndTime).rounded(toPlaces: 1))s"
            log.verbose("⏰ Time to begin video playback took \(statusLabel?.text ?? "UNK")")
            
        }
        
    }
    
    // MARK: - Private Methods
    
    fileprivate func benchmarkAndLoadVideo(atPath path: String) {
        
        mediaPlayer?.player?.loopEnabled = true
        mediaPlayer?.player?.automaticallyWaitsToMinimizeStalling = false
        mediaPlayer?.player?.delegate = self
        
        if let url = URL(string: path) {
            mediaPlayer?.setup(withUrl: url)
            mediaPlayer?.playFromBeginning()
        }
        
    }
    
}

extension DevelopmentViewController: SCPlayerDelegate {
    
    /**
     Called when the player begins playing frames
     */
    func player(_ player: SCPlayer, didPlay currentTime: CMTime, loopsCount: Int) {
        
        if benchmarkStartTime != nil && currentTime != kCMTimeZero {
            benchmarkEndTime = CFAbsoluteTimeGetCurrent() - benchmarkStartTime!
            benchmarkStartTime = nil
        }
        
    }
    
    /**
     Called when a new item was loaded into the player
     */
    func player(_ player: SCPlayer, didChange item: AVPlayerItem?) {
        
        benchmarkStartTime = CFAbsoluteTimeGetCurrent()
        
    }
    
}
