//
//  ChallengeDetailsHeader.swift
//  Maverick
//
//  Created by Garrett Fritz on 3/4/18.
//  Copyright © 2018 BeMaverick. All rights reserved.
//

import Foundation
import AVKit

protocol ChallengeDetailsHeaderDelegate : class {
    
    func didTapThreeDotMenuButton()
    func didTapMainArea()
    func didTapShareButton()
    func didTapMuteButton()
    func didTapSaveButton(isSaved : Bool)
    func didTapCreatorButton()
    func didTapShowCommentsButton()
    func didTapShowResponsesButton()
    func didTapCTAButton()
    func didTapBackButton()
    func didTapEditInviteButton()
    func didTapLink(url : URL)
    
}

class ChallengeDetailsHeader : UICollectionViewCell {
    @IBOutlet weak var usernameTopConstraint: NSLayoutConstraint!
    
    
    @IBOutlet weak var addCommentButton: UIButton!
    @IBOutlet weak var commentButton: UIButton!
    @IBOutlet weak var responseButton: UIButton!
    
    @IBOutlet weak var linkButton: UIButton!
    @IBOutlet weak var editInviteChallengeButton: UIButton!
    /// view that plays the challenge video
    @IBOutlet weak var videoPlayerView: VideoPlayerView!
    /// Main image view
    @IBOutlet weak var challengeCardImageView : UIImageView!
    /// Back Button
    @IBOutlet weak var backButton: UIButton!
    
    /// Title of challenge
    @IBOutlet weak var challengeTitleLabel: UILabel!
    
    @IBOutlet weak var linkContainer: UIView!
    /// Width of view -> set to screen width
    @IBOutlet weak var usernameLabel: BadgeLabel!
    
    @IBOutlet weak var linkPreviewImage: UIImageView!
    
    @IBOutlet weak var linkAttachImage: UIImageView!
    
    @IBOutlet var descriptionAdditionalWidthConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var completeIcon: UIImageView!
    /// challenge description label
    @IBOutlet weak var challengeDescriptionLabel: MaverickNoUsernameActiveLabel?
    /// Do your thing button
    @IBOutlet weak var ctaButton: UIButton!
    /// The mute button
    @IBOutlet weak var muteButton: UIButton!
    
    @IBOutlet weak var saveButton: UIButton!
    
    deinit {
        
        log.verbose("💥")
    
    }
    
   
    
    @IBAction func editInviteTapped(_ sender: Any) {
        
        delegate?.didTapEditInviteButton()
        
    }
    
    
    @IBAction func threeDotMenuButtonTapped(_ sender: UIButton) {
        
        delegate?.didTapThreeDotMenuButton()
    
    }
    
    @IBAction func saveTapped(_ sender: Any) {
        
        saveButton.isSelected = !saveButton.isSelected
        delegate?.didTapSaveButton(isSaved : saveButton.isSelected)
        
    }
    
    /**
     Back button tapped
     */
    @IBAction func backButtonTapped(_ sender: Any) {
        
        delegate?.didTapBackButton()
        
    }
    
    /**
     Share button tapped
     */
    @IBAction func shareButtonTapped(_ sender: Any) {
        
        videoPlayerView.pause()
        delegate?.didTapShareButton()
        
    }
    
    @IBAction func muteButtonTapped(_ sender: UIButton) {
        
        videoPlayerView.muteToggle()
        muteButton.isSelected = !muteButton.isSelected
        isMuted = !isMuted
        delegate?.didTapMuteButton()
        
    }
    
    
    /**
     Main area tapped
     */
    @IBAction func didTapMainButton(_ sender: Any) {
        
        if challenge?.mediaType == .video {
           
            videoPlayerView.playPausePressed()
                
                
            }
        
        
        delegate?.didTapMainArea()
        
    }
  
    
    /**
     View comments button tapped
     */
    @IBAction func viewAllCommentsTapped(_ sender: Any) {
        
        delegate?.didTapShowCommentsButton()
        
    }
    
    /**
     Do your thing button tapped
     */
    @IBAction func ctaTapped(_ sender: Any) {
        
        delegate?.didTapCTAButton()
        
    }
    
    /**
     Username button tapped
     */
    @IBAction func usernameTapped(_ sender: Any) {
        
        delegate?.didTapCreatorButton()
        
    }
    @IBAction func viewResponsesTapped(_ sender: Any) {
        
        delegate?.didTapShowResponsesButton()
        
    }
    
    private var _expanded = false
    private var challenge : Challenge?
    weak var delegate : ChallengeDetailsHeaderDelegate?
    weak var labelDelegate : MaverickActiveLabelDelegate? {
        
        didSet {
            
            challengeDescriptionLabel?.maverickDelegate = labelDelegate
            
        }
        
    }
    
    private var isMuted = false
    private var pausedFromController = false
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        linkPreviewImage.backgroundColor = UIColor(rgba: "F5F5F5")
        linkPreviewImage.kf.indicatorType = .activity
        linkButton.addShadow()
          usernameLabel.imageOffset = CGPoint(x: 0.0, y: -2.0)
        ctaButton.addShadow()
         if #available(iOS 11.0, *) {
           
            let window = UIApplication.shared.keyWindow
            let topPadding = window?.safeAreaInsets.top ?? 0
            usernameTopConstraint.constant = usernameTopConstraint.constant + topPadding
        
        } else {
            // Fallback on earlier versions
        }
        
        usernameLabel.addShadow()
        
    }
    
    private func configureImageChallenge() {
        
        videoPlayerView.prepareForReuse(removeMedia: true)
        
        muteButton.isHidden = true
        layoutIfNeeded()
        
    }
    
    private func configureVideoChallenge() {
        
        videoPlayerView.delegate = self
        
            muteButton.isHidden = false
            muteButton.isSelected = !isMuted
            
            if !pausedFromController {
                
                videoPlayerView.allowAutoplay = true
                videoPlayerView.play()
                
            } else {
                
                videoPlayerView.allowAutoplay = false
                videoPlayerView.pause()
            
            }
        
        videoPlayerView.alpha = 1
            
        
        
        videoPlayerView.configure(with: challenge?.videoMedia, muteState: isMuted)
        
    }
    
    private var linkUrl : URL? = nil
    
    @IBAction func linkImageTapped(_ sender: Any) {
        
        guard let linkUrl = linkUrl else { return }
        delegate?.didTapLink(url: linkUrl)
        
    }
    
    func configureLink(link : String?) {
        
        guard let urlString = link, let url = URL(string: urlString) else {
           
            linkPreviewImage.isHidden = true
            linkAttachImage.isHidden = true
            descriptionAdditionalWidthConstraint.isActive = false
            return
            
        }
        linkUrl = url
        OpenGraph.fetch(url: url) { og, error in
        
            DispatchQueue.main.async {
            
                self.linkPreviewImage.isHidden = false
                self.linkAttachImage.isHidden = false
                self.descriptionAdditionalWidthConstraint.isActive = true
            
                if let path = og?[.image], let imageUrl = URL(string: path) {
                    
                    self.linkPreviewImage.kf.setImage(with: imageUrl) { (image, error, cache, url) in
                        
                        if error != nil {
                            
                            self.linkPreviewImage.image = R.image.link_placeholder()
                            
                        }
                    }
                    
                } else {
                    
                     self.linkPreviewImage.image = R.image.link_placeholder()
                    
                }
            }
        }
    }
    /**
     Setup view with a challenge item and inital saved state
     */
    func configure(withChallenge challenge: Challenge, isSaved : Bool, hasResponded : Bool, isMuted : Bool, isLoggedInUser : Bool) {
        
        
        configureLink(link: challenge.linkURL)
        
        let showBadge = challenge.getCreator()?.isVerified ?? false
        usernameLabel.image = showBadge ? R.image.verified() : nil
       
        completeIcon.isHidden = !hasResponded
        saveButton.isSelected = isSaved
        
        guard challenge.userId != nil else {
            
            challengeTitleLabel.text = ""
            challengeDescriptionLabel?.text = ""
         
            muteButton.isHidden = true
            
            return
            
        }
        
        
        if challenge.numResponses > 0 {
            
            responseButton.isHidden = false
            responseButton.setTitle("\(challenge.numResponses)", for: .normal)
            
        } else {
            
            responseButton.isHidden = false
            responseButton.setTitle(nil, for: .normal)
            
        }
        
        
        
        if let comments = challenge.commentDescriptor?.numMessages, comments > 0 {
            
            commentButton.setTitle("\(comments)", for: .normal)
           commentButton.imageEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, 0.0, -18.0)
            commentButton.contentEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, 0.0, 10.0)
            addCommentButton.isHidden = true
            
        } else {
            
            commentButton.imageEdgeInsets = .zero
            commentButton.contentEdgeInsets = .zero
            commentButton.setTitle("", for: .normal)
            addCommentButton.isHidden = false
            
        }
  
        
        editInviteChallengeButton.isHidden = !isLoggedInUser
            
       
        
        self.challenge = challenge
        
        if let path = challenge.mainImageMedia?.getUrlForSize(size: LargeContentCollectionViewCell.getCellSize()), let url = URL(string: path) , challenge.mediaType == .video {
            
            challengeCardImageView.kf.setImage(with: url, placeholder: nil, options: [.transition(.fade(UIImage.fadeInTime))], progressBlock: nil, completionHandler: nil)
            
        } else if let path = challenge.imageChallengeMedia?.getUrlForSize(size: LargeContentCollectionViewCell.getCellSize()), let url = URL(string: path) {
            
            challengeCardImageView.kf.setImage(with: url, placeholder: nil, options: [.transition(.fade(UIImage.fadeInTime))], progressBlock: nil, completionHandler: nil)
            
        } else if let path = challenge.mainCardMedia?.getUrlForSize(size: LargeContentCollectionViewCell.getCellSize()), let url = URL(string: path) {
            
            challengeCardImageView.kf.setImage(with: url, placeholder: nil, options: [.transition(.fade(UIImage.fadeInTime))], progressBlock: nil, completionHandler: nil)
            
        }
        
        
        
        challengeTitleLabel.text = challenge.title
        if challengeTitleLabel.text == nil {
            
            challengeTitleLabel.text = R.string.maverickStrings.challengeTitle(challenge.getCreator()?.username ?? "")
            
        }

        challengeDescriptionLabel?.text = challenge.label
          challengeDescriptionLabel?.textColor = UIColor.MaverickDarkSecondaryTextColor
        usernameLabel.text = challenge.getCreator()?.username
        
        if challenge.mediaType == .video {
            
            configureVideoChallenge()
            
        } else {
            
            configureImageChallenge()
            
        }

        
    }
    
    /**
     Stop video, usually because we scrolled off the screen
     */
    func pauseVideo() {
        
        videoPlayerView.allowAutoplay = false
        videoPlayerView.pause()
        pausedFromController = true
        setOverlayAlpha(1)
        
    }
    
    /**
     Called when playback gets going to free up items over the video
     */
    private func setOverlayAlpha(_ alpha : CGFloat) {
        
        challengeTitleLabel.alpha = alpha
        
    }
    
}

extension ChallengeDetailsHeader :  TwoSectionStreamCollectionViewControllerHeaderDelegate {
    
    func getFrame() -> CGRect {
        
        return frame
        
    }
    
    func preferredLayoutSizeFittingSize(targetSize:CGSize) -> CGSize {
        
        let originalFrame = self.frame
        var frame = self.frame
        frame.size = targetSize
        self.frame = frame
        self.setNeedsLayout()
        self.layoutIfNeeded()
        let computedSize = self.systemLayoutSizeFitting(UILayoutFittingCompressedSize)
        let newSize = CGSize(width:targetSize.width,height:computedSize.height)
        self.frame = originalFrame
        return newSize
        
    }
    
}

extension ChallengeDetailsHeader: VideoPlayerViewDelegate {
    
    func didStartPlaying(startTime: Float64, isMuted: Bool, bufferTime: UInt64) {
        
        guard let challenge = challenge else { return }
        
        AnalyticsManager.Viewing.trackVideoStart(contentType: .challenge, contentID: challenge.challengeId, isMuted: isMuted, startTime: startTime, bufferTime: bufferTime)
    }
    
    func didStopPlaying(stopTime: Float64, playDuration: Float64, isMuted: Bool) {
        
        guard let challenge = challenge else { return }
        
        AnalyticsManager.Viewing.trackVideoStop(contentType: .challenge, contentID: challenge.challengeId, isMuted: isMuted, stopTime: stopTime, viewingDuration: playDuration)
        
    }
    
    func didResumePlaying(startTime: Float64, isMuted: Bool) {
        
        guard let challenge = challenge else { return }
        
        AnalyticsManager.Viewing.trackVideoResume(contentType: .challenge, contentID: challenge.challengeId, isMuted: isMuted, startTime: startTime)
        
    }
    
    func didReachEnd(media: MaverickMedia, isMuted: Bool) {
        
        guard let challenge = challenge else { return }
        
        AnalyticsManager.Viewing.trackVideoComplete(contentType: .challenge, contentID: challenge.challengeId, isMuted: isMuted)
        
    }
    
    func didStartReplaying(isMuted: Bool) {
        
        guard let challenge = challenge else { return }
        
        AnalyticsManager.Viewing.trackVideoReplay(contentType: .challenge, contentID: challenge.challengeId, isMuted: isMuted)
        
    }
    
    func didCrossInterval(interval: Int, isMuted: Bool) {
        
        guard let challenge = challenge else { return }
        
        switch interval {
        case 25:
            AnalyticsManager.Viewing.trackVideoProgress25(contentType: .challenge, contentID: challenge.challengeId, isMuted: isMuted)
        case 50:
            AnalyticsManager.Viewing.trackVideoProgress50(contentType: .challenge, contentID: challenge.challengeId, isMuted: isMuted)
        case 75:
            AnalyticsManager.Viewing.trackVideoProgress75(contentType: .challenge, contentID: challenge.challengeId, isMuted: isMuted)
        default:
            return
        }
        
    }
    
    func mainAreaTapped() {
        
        delegate?.didTapMainArea()
        videoPlayerView?.playPausePressed()
        
    }
    
    
    func toggleOverlay(isVisible visible : Bool) {
        
        UIView.animate(withDuration: 0.5) {
            
            self.setOverlayAlpha( (self.videoPlayerView?.isPlaying() ?? false) && !visible ? 0 : 1)
            
        }
        
    }
    
}
