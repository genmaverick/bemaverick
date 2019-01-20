//
//  OnboardFirstChallengeViewController.swift
//  BeMaverick
//
//  Created by David McGraw on 9/27/17.
//  Copyright © 2017 BeMaverick. All rights reserved.
//

import UIKit
import AVKit

class OnboardFirstChallengeViewController: OnboardParentViewController {
    
    // MARK: - IBOutlets
    
    /// skip button
    @IBOutlet weak var skipButton: UIButton!
    /// view to play videos
    @IBOutlet weak var videoPlayerView: VideoPlayerView!
    /// mute button
    @IBOutlet weak var muteButton: UIButton!
    
    @IBAction func unwindSegueToHome(_ sender: UIStoryboardSegue) {
       
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            
            self.skipTapped(sender)
            
        }
        
    }
    
    /// The `GlobalServicesContainer` that maintains access to global services
    var services: GlobalServicesContainer!
    /// Has this screen been seen before
    private var launchDoYourThing = false
    /// Challenge object
    
    private var completedWatching = false
    @IBAction func mainAreaTapped(_ sender: Any) {
        
        videoPlayerView.playPausePressed()
        
    }
    
    
    @IBAction func skipTapped(_ sender: Any) {
        
        services.globalModelsCoordinator.fromSignup = true
        if !completedWatching {
        
            AnalyticsManager.Onboarding.trackSkipVideo()
        
        }
        
        let tabBarNav = R.storyboard.main.instantiateInitialViewController()!
        let _ = videoPlayerView.pause()
        // Inject services into the default tab
        let delegate = UIApplication.shared.delegate as! AppDelegate
        delegate.transitionRootViewController(to: tabBarNav)
        
        
    }
    
    @IBAction func muteButtonTapped(_ sender: Any) {
   
        let muteState = !videoPlayerView.muteToggle()
        (sender as? UIButton)?.isSelected = muteState
        
    }
    
    
    @IBAction func ctaTapped(_ sender: Any) {
        
       
        let _ = videoPlayerView.pause()
        if  let loggedinuser = services.globalModelsCoordinator.loggedInUser, loggedinuser.shouldShowVPC() {
            
            if let vc = R.storyboard.general.onboardVPCNavViewControllerId() {
                
                vc.modalPresentationStyle = .overFullScreen
                present(vc, animated: true, completion: nil)
                
            }
            
            return
        
        }
        
        guard let vc = R.storyboard.post.instantiateInitialViewController(),
            let postVC = vc.viewControllers.first as? PostRecordViewController else { return }
      
        postVC.services = services
        navigationController?.present(vc, animated: true, completion: nil)
        launchDoYourThing = true
  
    }
    
    override func viewWillDisappear(_ animated: Bool) {
    
        super.viewWillDisappear(true)
        let _ = videoPlayerView.pause()
        videoPlayerView.prepareForReuse()
   
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: false)
        
    }
    
    override func viewDidLayoutSubviews() {
        
        super.viewDidLayoutSubviews()
        drawBackgroundShapes()
      
    }
    
    /**
     Initialize views
    */
    override func configureView() {
      
        super.configureView()
        skipButton.setTitleColor(UIColor.MaverickPrimaryColor, for: .normal)
        skipButton.setTitle(R.string.maverickStrings.skip(), for: .normal)
        
        ctaButton?.addShadow(alpha: 0.75)
        
        view.backgroundColor = .white
         ctaButton?.isHidden = true
        
        guard let path = Variables.Features.onboardVideoPath.stringValue() else {
            log.verbose("onboard.mov not found")
            return
        }
 
        
        let maverickMedia = MaverickMedia(id: "onboarding", type: .video)
        maverickMedia.URLOriginal = path
        videoPlayerView.delegate = self
        videoPlayerView.configure(with: maverickMedia, muteState: false, allowAutoplay: true, shouldLoop: false)
        
    }
    
    
    /**
     Draws a skewed rectangle from the right side of the video off the screen
     */
    func getFirstPath() -> UIBezierPath {
        
        let aPath = UIBezierPath()
        
        let widthOfBorder = (UIScreen.main.bounds.width - videoPlayerView.frame.width) / 2
        
        let originX = UIScreen.main.bounds.width - widthOfBorder
        let originY = videoPlayerView.frame.origin.y
        
        let maxHeight = videoPlayerView.frame.origin.y + videoPlayerView.frame.height + widthOfBorder
        
        aPath.move(to: CGPoint(x:originX  , y:originY))
        aPath.addLine(to: CGPoint(x:originX , y:maxHeight - widthOfBorder ))
        aPath.addLine(to: CGPoint(x:originX + widthOfBorder, y:maxHeight ))
        aPath.addLine(to: CGPoint(x:originX + widthOfBorder, y:originY + widthOfBorder))
        aPath.addLine(to: CGPoint(x:originX   , y:originY))
        
        aPath.stroke()
        aPath.fill()
        aPath.close()
        return aPath
        
    }
    
    /**
     Draws a skewed rectangle from the bottom of the video off the screen to the right
     */
    func getSecondPath() -> UIBezierPath {
        
        let aPath = UIBezierPath()
        
        let originX = videoPlayerView.frame.origin.x
        let originY = videoPlayerView.frame.origin.y + videoPlayerView.frame.height
        
        let heightOfBorder = (UIScreen.main.bounds.height - videoPlayerView.frame.height) / 2
        
        let smallWidthOfBorder = (UIScreen.main.bounds.width - videoPlayerView.frame.width) / 2
        
        let maxHeight = UIScreen.main.bounds.height
        
        let origin = CGPoint(x:originX  , y:originY)
        let second = CGPoint(x:originX + heightOfBorder , y: maxHeight )
        let third = CGPoint(x:UIScreen.main.bounds.width, y: maxHeight)
        let fourth = CGPoint(x:UIScreen.main.bounds.width, y: originY + smallWidthOfBorder )
        let fifth = CGPoint(x:UIScreen.main.bounds.width - smallWidthOfBorder, y: originY )
        
        aPath.move(to: origin)
        aPath.addLine(to: second)
        aPath.addLine(to: third)
        aPath.addLine(to: fourth)
        aPath.addLine(to: fifth)
        aPath.addLine(to: origin)
        
        aPath.stroke()
        aPath.fill()
        aPath.close()
        return aPath
        
    }
    
    
    /**
     Draws the background shapes to the screen
     */
    func drawBackgroundShapes() {
        
        let shapeLayer = CAShapeLayer()
        
        // The Bezier path that we made needs to be converted to
        // a CGPath before it can be used on a layer.
        shapeLayer.path = getFirstPath().cgPath
        
        shapeLayer.fillColor = UIColor.MaverickBadgePrimaryColor.cgColor
        shapeLayer.lineWidth = 0.0
        shapeLayer.position = CGPoint(x: 0, y: 0)
        
        // add the new layer to our custom view
        view.layer.addSublayer(shapeLayer)
        let otherShape = CAShapeLayer()
        
        // The Bezier path that we made needs to be converted to
        // a CGPath before it can be used on a layer.
        otherShape.path = getSecondPath().cgPath
        
        otherShape.fillColor = UIColor.black.cgColor
        otherShape.lineWidth = 0.0
        otherShape.position = CGPoint(x: 0, y: 0)
        
        // add the new layer to our custom view
        view.layer.insertSublayer(otherShape, at: 0)
   
    }
    
}

extension OnboardFirstChallengeViewController: VideoPlayerViewDelegate {
    
    func didStartPlaying(startTime: Float64, isMuted: Bool, bufferTime: UInt64) {
        
      
    
    }
    
    func didResumePlaying(startTime: Float64, isMuted: Bool) {
        
      
        
    }
    
    func didStopPlaying(stopTime: Float64, playDuration: Float64, isMuted: Bool) {
        
       
        
    }
    
    func didReachEnd(media: MaverickMedia, isMuted: Bool) {
        
        completedWatching = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
        
            self.skipTapped(media)
      
        }
        
      
        
    }
    
    func didStartReplaying(isMuted: Bool) {
        
        

    }
    
    func didCrossInterval(interval: Int, isMuted: Bool) {
        
      
        
    }
    
    func toggleOverlay(isVisible visible : Bool) {
        
    }
    func mainAreaTapped() {
        
    }
    
}
