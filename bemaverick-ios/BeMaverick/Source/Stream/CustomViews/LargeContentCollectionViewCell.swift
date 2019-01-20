//
//  FeaturedContentLargeCollectionViewCell.swift
//  Maverick
//
//  Created by Garrett Fritz on 3/2/18.
//  Copyright © 2018 BeMaverick. All rights reserved.
//

import Foundation
import CoreMedia



class LargeContentCollectionViewCell : UICollectionViewCell {
    
    /// favorite icon displayed if response favorited
    @IBOutlet weak var favoriteIcon: UIImageView!
    /// Main Image View
    @IBOutlet weak var imageView: UIImageView!
    /// Challenge title for responses
    @IBOutlet weak var lowerChallengeTitle: UILabel!
    /// content creators username
    @IBOutlet weak var usernameLabel: BadgeLabel!
    /// Do your thing button
    @IBOutlet weak var ctaButton: UIButton!
    /// Player for video + hidden for image responses
    @IBOutlet weak var videoPlayerView: VideoPlayerView!
    
    @IBOutlet weak var coachMarkBottom: NSLayoutConstraint!
    
    /// content creators username
    @IBOutlet weak var coachMark: UIView!
    /// content creators username
    @IBOutlet weak var coachMarkLabel: UILabel!
    /// Mute button for challenges
    @IBOutlet weak var lowerMuteButton: UIButton!
    
    @IBOutlet weak var avatarImageVie: UIImageView!
    
    /// animated badge selection view
    @IBOutlet var badgerView: BadgerView!
    /// button to open badger view
    @IBOutlet weak var badgeButton: UIButton!
    
    /**
     Mute button tapped (bottom left of card)
     */
    @IBAction func muteButton(_ sender: Any) {
        
        let muteState = !videoPlayerView.muteToggle()
        (sender as? UIButton)?.isSelected = muteState
        Video.appUserMuted = !muteState
        delegate?.didTapMuteButton(cell: self, forContentType: contentType, withId: contentId, contentStyle: .full, isMuted: !muteState)
        
    }
    
    @IBAction func shareButtonTapped(_ sender: Any) {
        
        delegate?.didTapShareButton(forContentType: contentType, withId: contentId, contentStyle: .large)
    }
    
    @IBAction func moreButtonTapped(_ sender: Any) {
        
        
    }
    
    func mute () {
        
        if  lowerMuteButton.isSelected {
            
            let muteState = !videoPlayerView.muteToggle()
            lowerMuteButton.isSelected = muteState
            Video.appUserMuted = !muteState
            
        }
        
    }
    
    /**
     Main image view tapped, only works when image content type
     */
    @IBAction func mainImagetapped(_ sender: Any) {
        
        delegate?.didTapMainArea(cell : self, forContentType: contentType, withId: contentId, contentStyle: .large)
        
    }
    
    /**
     badge selection tapped
     */
    @IBAction func badgeButtonTapped(_ sender: Any) {
        
        dismissCoachmark()
        AnalyticsManager.Content.trackBadgesOpened(contentType, contentId: contentId, contentStyle: .large)
        
        animateBadgeBagTapped()
        
        
    }
    
    private func animateBadgeBagTapped() {
        
        if let button = badgeButton {
            
            UIView.animate(withDuration: 0.15, animations: {
                
                button.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
                
            }) { (finished) in
                
                UIView.animate(withDuration: 0.25, animations: {
                    
                    button.transform = CGAffineTransform.identity
                    
                })
                
            }
        }
        
        badgerView.collapsed =  !badgerView.collapsed
        
        
    }
    
    
    /**
     Tapping the challenge title
     */
    @IBAction func challengeTitleTapped(_ sender: Any) {
        
        guard let challengeId = challenge?.challengeId, let contentType = contentType, let contentId = contentId else { return }
        delegate?.didTapChallengeTitleButton(forChallenge: challengeId, fromContentType: contentType, withId: contentId, contentStyle: .large)
        
    }
    
    /**
     Tapping the content creators username
     */
    @IBAction func usernameTappedButton(_ sender: Any) {
        
        guard let contentType = contentType, let contentId = contentId else { return }
        switch contentType {
        case .response:
            guard let userId = response?.creator.first?.userId else { return }
            delegate?.didTapShowProfileButton(forUserId: userId, fromContentType: contentType, withId: contentId, contentStyle: .large)
        case .challenge:
            guard let userId = challenge?.getCreator()?.userId else { return }
            delegate?.didTapShowProfileButton(forUserId: userId, fromContentType: contentType, withId: contentId, contentStyle: .large)
            
        }
        
    }
    
    /**
     Do your thing tapped
     */
    @IBAction func ctaButtonTapped(_ sender: Any) {
        
        dismissCoachmark()
        guard let challengeId = challenge?.challengeId, let contentType = contentType, let contentId = contentId else { return }
        delegate?.didTapCTAButton(forChallenge: challengeId, fromContentType: contentType, withId: contentId, contentStyle: .large)
        
    }
    
    /// tap delegate
    weak var delegate : BasicContentDelegate?
    private var isBouncing = false
    private var bounceAmplitude : CGFloat = 7.5
    private var bounceOrigin : CGFloat = -7.5
    /// response object
    private var response : Response?
    /// challenge object
    private var challenge : Challenge?
    /// content id
    var contentId : String!
    /// content type
    private var contentType: Constants.ContentType!
    
    static func getMainImageUrl(primaryImage : MaverickMedia?, fallbackImage : MaverickMedia?) -> URL? {
        
        let maverickMedia = primaryImage ?? fallbackImage
        guard let imageMedia = maverickMedia else { return nil }
        let maxAspectratio = Variables.Content.maxStreamAspectRatio.cgFloatValue()
        let size = getCellSize()
        let screenWidth = size.width
        let maxHeight = size.width / maxAspectratio
        
        let calcSize =  CGSize(width: screenWidth, height: maxHeight)
        if let stringPath = imageMedia.getUrlForSize(size: CGRect(origin: CGPoint.zero, size: calcSize)) {
            
            return URL(string : stringPath)
            
        }
        
        return nil
        
    }
    
    override func prepareForReuse() {
        
        super.prepareForReuse()
        
        favoriteIcon.isHidden = true
        videoPlayerView.prepareForReuse()
        setOverlayAlpha(1)
        lowerMuteButton.isSelected = false
        imageView.image = nil
        lowerChallengeTitle.text = nil
        usernameLabel.text = nil
        badgeButton.glowView = nil
        isBouncing = false
        coachMark.alpha = 0
        self.coachMarkBottom.constant = bounceOrigin
    }
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        clipsToBounds = false
        contentView.clipsToBounds = false

        ctaButton.addShadow()
        
        usernameLabel.imageOffset = CGPoint(x: 0.0, y: -3.0)
        videoPlayerView.delegate = self
        badgeButton.addShadow()
        badgerView.delegate = self
        badgerView.setSize(small  : true)
        badgerView.collapsed = true
        avatarImageVie.layer.cornerRadius = avatarImageVie.frame.height / 2
        avatarImageVie.clipsToBounds = true
        avatarImageVie.layer.borderWidth = 0.5
        avatarImageVie.layer.borderColor = UIColor.MaverickSecondaryTextColor.cgColor
        bounceOrigin = coachMarkBottom.constant
        coachMark.alpha = 0
        coachMark.addShadow(alpha: 0.3)
        imageView.kf.indicatorType = .activity
        
    }
    
    static func getCellSize() -> CGRect {
        
        let width = Constants.MaxContentScreenWidth
        let height = width / Variables.Content.gridAspectRatio.cgFloatValue()
        
        let rect = CGRect(origin: CGPoint.zero, size: CGSize(width: Constants.MaxContentScreenWidth, height: height))
        
        return rect
        
    }
    
    func setOwner(user : User) {
        
        
        usernameLabel.image = user.isVerified ? R.image.verified() : nil
        usernameLabel.text = user.username
        if let imagePath = user.profileImage?.getUrlForSize(size: avatarImageVie.frame), let url = URL(string: imagePath) {
            avatarImageVie.kf.setImage(with: url, placeholder: R.image.defaultMaverickAvatar(), options: [.transition(.fade(UIImage.fadeInTime))])
        } else {
            
            avatarImageVie.image = R.image.defaultMaverickAvatar()
            
        }
        
    }
    /**
     Set up view with response
     */
    func configure(withResponse response: Response) {
        
        self.response = response
        self.contentId = response.responseId
        self.contentType = .response
        self.challenge = response.challengeOwner.first
        setViewVisibility()
        favoriteIcon.isHidden = !response.favorite
        
        
        if response.mediaType == .video {
            
            videoPlayerView.isHidden = false
            var path = response.videoCoverImageMedia?.getUrlForSize(size: LargeContentCollectionViewCell.getCellSize() )
            if path == nil {
                path = response.videoMedia?.URLThumbnail
            }
            if let videoImagePath = path, let url = URL(string: videoImagePath) {
                
                
                imageView.kf.setImage(with: url,placeholder: nil, options: [.transition(.fade(0.2))], progressBlock: nil, completionHandler: nil)
                
            }
            
        } else {
            
            lowerMuteButton.isHidden = true
            videoPlayerView.isHidden = true
            videoPlayerView.prepareForReuse(removeMedia : true)
            
            if let path = response.imageMedia?.getUrlForSize(size: LargeContentCollectionViewCell.getCellSize() ), let url = URL(string: path) {
                
                imageView.kf.setImage(with: url, placeholder: nil, options: [.transition(.fade(UIImage.fadeInTime))], progressBlock: nil, completionHandler: nil)
                
            }
        }
        
        videoPlayerView.configure(with: response.videoMedia, allowAutoplay: false)
        
        lowerChallengeTitle.text = response.challengeOwner.first?.title
        
        if let owner = response.creator.first {
            setOwner(user: owner)
        }
        setBadgeValues()
        
        
    }
    
    /**
     Called on scroll to dismiss badger view
     */
    func dismissBadger() {
        
        badgerView.collapsed = true
        
    }
    
    /**
     Called on scroll to dismiss badger view
     */
    func dismissCoachmark() {
        
        
        isBouncing = false
        
        
        
    }
    
    /**
     Set up view to show a challenge
     */
    func configure(withChallenge challenge: Challenge) {
        
        self.challenge = challenge
        self.contentId = challenge.challengeId
        self.contentType = .challenge
        
        setViewVisibility()
        
        
        if let owner = challenge.getCreator() {
            setOwner(user: owner)
        }
        lowerChallengeTitle.text = challenge.title
        
        if challenge.mediaType == .video {
            
            
            videoPlayerView.isHidden = false
            var path = challenge.mainImageMedia?.getUrlForSize(size: LargeContentCollectionViewCell.getCellSize() )
            if path == nil {
                path = challenge.mainImageMedia?.URLThumbnail
            }
            if let videoImagePath = path, let url = URL(string: videoImagePath) {
                
                imageView.kf.setImage(with: url, placeholder: nil, options: [.transition(.fade(UIImage.fadeInTime))], progressBlock: nil, completionHandler: nil)
                
            }
            
            videoPlayerView.configure(with: challenge.videoMedia, allowAutoplay: false)
            
        } else {
            
            lowerMuteButton.isHidden = true
            videoPlayerView.isHidden = true
            videoPlayerView.prepareForReuse(removeMedia : true)
            
            var path = challenge.imageChallengeMedia?.getUrlForSize(size: LargeContentCollectionViewCell.getCellSize() )
            if path == nil {
                path = challenge.mainImageMedia?.getUrlForSize(size: LargeContentCollectionViewCell.getCellSize() )
            }
            if let imagePath = path, let url = URL(string: imagePath) {
                
                imageView.kf.setImage(with: url, placeholder: nil, options: [.transition(.fade(UIImage.fadeInTime))], progressBlock: nil, completionHandler: nil)
                
            }
            
        }
        
    }
    
    /**
     Cell left the screen, so stop playing
     */
    func stopPlayback() {
        
        videoPlayerView.pause()
        dismissCoachmark()
        
    }
    
    /**
     Scrolling has stopped so try to autoplay
     */
    func attemptAutoplay() {
        
        
        videoPlayerView.allowAutoplay = true
        videoPlayerView.attemptAutoplay()
        
    }
    
    
    private func lowerCoachMark( delay : CGFloat = 0) {
        self.coachMarkBottom.constant = bounceOrigin + bounceAmplitude
        
        UIView.animateKeyframes(withDuration: 0.5, delay: TimeInterval(delay), options: [], animations: {
            
            self.coachMark.alpha = 1
            self.layoutIfNeeded()
            
        }) { (result) in
            
            if self.isBouncing {
                
                self.raiseCoachmark()
                
            } else {
                
                UIView.animate(withDuration: 0.5, animations: {
                    
                    self.coachMark.alpha = 0
                    
                }, completion: nil)
                
            }
            
        }
        
    }
    
    private func raiseCoachmark() {
        
        self.coachMarkBottom.constant = bounceOrigin 
        UIView.animate(withDuration: 0.5, animations: {
            
            self.layoutIfNeeded()
            
        }) { (result) in
            
            if self.isBouncing {
                
                self.lowerCoachMark()
                
            }  else {
                
                UIView.animate(withDuration: 0.5, animations: {
                    
                    self.coachMark.alpha = 0
                    
                }, completion: nil)
                
            }
            
        }
        
    }
    
    
    func showCTACoachMark(text : String, delay : CGFloat) {
        
        if contentType == .response && badgeButton.isSelected {
            return
        }
        if !isBouncing {
            
            coachMarkLabel.text = text
            isBouncing = true
            lowerCoachMark(delay: delay)
            
        }
        
    }
    /**
     Set number received to populate ranks on the badger view
     TODO: put this logic inside the badger view
     */
    private func setBadgeValues() {
        
        guard let response = response else { return }
        badgeButton.isHidden = false
        let firstBadge = BadgeStats(badgeTypeId: MBadge.getFirstBadge().badgeId)
        let secondBadge = BadgeStats(badgeTypeId: MBadge.getSecondBadge().badgeId)
        let thirdBadge = BadgeStats(badgeTypeId: MBadge.getThirdBadge().badgeId)
        let fourthBadge = BadgeStats(badgeTypeId: MBadge.getFourthBadge().badgeId)
        
        for badge in response.badgeStats {
            switch badge.badgeId {
            case firstBadge.badgeId:
                firstBadge.setValues(badge: badge)
                
            case secondBadge.badgeId:
                secondBadge.setValues(badge: badge)
                
            case thirdBadge.badgeId:
                thirdBadge.setValues(badge: badge)
                
            case fourthBadge.badgeId:
                fourthBadge.setValues(badge: badge)
            default:
                break
            }
        }
        
        
        badgerView.setValues(first: firstBadge.numReceived,
                             second: secondBadge.numReceived,
                             third: thirdBadge.numReceived,
                             fourth: fourthBadge.numReceived)
        
    }
    
    /**
     Sets selected badge state to the badger view
     TODO: same thing we did for comment descriptor would be nice
     */
    func setSelectedBadge(selected badge : MBadge?) {
        
        BadgerView.setBadgeImage(badge: badge, primary : false, button: badgeButton, for: .selected)
        badgerView.setSelected(badge: badge)
        badgeButton.isSelected = badgerView.isItemSelected() != nil
        
    }
    
    /**
     Toggle items on and off based on content type
     */
    private func setViewVisibility() {
        
        ctaButton.isHidden = contentType != .challenge
        lowerMuteButton.isHidden = false
        badgeButton.isHidden = contentType != .response
        badgerView.isHidden =  contentType != .response
        
    }
    
    /**
     Called when playback gets going to free up items over the video
     */
    private func setOverlayAlpha(_ alpha : CGFloat) {
        
        
    }
    
}


extension LargeContentCollectionViewCell: VideoPlayerViewDelegate {
    
    func didStartPlaying(startTime: Float64, isMuted: Bool, bufferTime: UInt64) {
        
        if contentType == .challenge {
            
            guard let challenge = challenge else { return }
            
            AnalyticsManager.Viewing.trackVideoStart(contentType: .challenge, contentID: challenge.challengeId, isMuted: isMuted, startTime: startTime, bufferTime: bufferTime)
            
        } else if contentType == .response {
            
            guard let response = response else { return }
            
            AnalyticsManager.Viewing.trackVideoStart(contentType: .response, contentID: response.responseId, isMuted: isMuted, startTime: startTime, bufferTime: bufferTime)
            
        }
        
    }
    
    func didResumePlaying(startTime: Float64, isMuted: Bool) {
        
        if contentType == .challenge {
            
            guard let challenge = challenge else { return }
            
            AnalyticsManager.Viewing.trackVideoResume(contentType: .challenge, contentID: challenge.challengeId, isMuted: isMuted, startTime: startTime)
            
        } else if contentType == .response {
            
            guard let response = response else { return }
            
            AnalyticsManager.Viewing.trackVideoResume(contentType: .response, contentID: response.responseId, isMuted: isMuted, startTime: startTime)
            
        }
        
    }
    
    func didStopPlaying(stopTime: Float64, playDuration: Float64, isMuted: Bool) {
        
        if contentType == .challenge {
            
            guard let challenge = challenge else { return }
            
            AnalyticsManager.Viewing.trackVideoStop(contentType: .challenge, contentID: challenge.challengeId, isMuted: isMuted, stopTime: stopTime, viewingDuration: playDuration)
            
        } else if contentType == .response {
            
            guard let response = response else { return }
            
            AnalyticsManager.Viewing.trackVideoStop(contentType: .response, contentID: response.responseId, isMuted: isMuted, stopTime: stopTime, viewingDuration: playDuration)
            
        }
        
    }
    
    func didReachEnd(media: MaverickMedia, isMuted: Bool) {
        
        if contentType == .challenge {
            
            guard let challenge = challenge else { return }
            
            AnalyticsManager.Viewing.trackVideoComplete(contentType: .challenge, contentID: challenge.challengeId, isMuted: isMuted)
            
        } else if contentType == .response {
            
            guard let response = response else { return }
            
            AnalyticsManager.Viewing.trackVideoComplete(contentType: .response, contentID: response.responseId, challengeID: response.challengeId, isMuted: isMuted)
            
        }
        
    }
    
    func didStartReplaying(isMuted: Bool) {
        
        if contentType == .challenge {
            
            guard let challenge = challenge else { return }
            
            AnalyticsManager.Viewing.trackVideoReplay(contentType: .challenge, contentID: challenge.challengeId, isMuted: isMuted)
            
        } else if contentType == .response {
            
            guard let response = response else { return }
            
            AnalyticsManager.Viewing.trackVideoReplay(contentType: .response, contentID: response.responseId, challengeID: response.challengeId, isMuted: isMuted)
            
        }
    }
    
    
    func didCrossInterval(interval: Int, isMuted: Bool) {
        
        if contentType == .challenge {
            
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
            
        } else if contentType == .response {
            
            guard let response = response else { return }
            
            switch interval {
            case 25:
                AnalyticsManager.Viewing.trackVideoProgress25(contentType: .response, contentID: response.responseId, challengeID: response.challengeId, isMuted: isMuted)
            case 50:
                AnalyticsManager.Viewing.trackVideoProgress50(contentType: .response, contentID: response.responseId, challengeID: response.challengeId, isMuted: isMuted)
            case 75:
                AnalyticsManager.Viewing.trackVideoProgress75(contentType: .response, contentID: response.responseId, challengeID: response.challengeId, isMuted: isMuted)
            default:
                return
            }
            
        }
        
    }
    
    
    func mainAreaTapped() {
        
        delegate?.didTapMainArea(cell : self, forContentType: contentType, withId: contentId, contentStyle: .large)
        
    }
    
    func toggleOverlay(isVisible visible : Bool) {
        
        UIView.animate(withDuration: 0.5) {
            
            self.setOverlayAlpha( self.videoPlayerView.isPlaying() && !visible ? 0 : 1)
            
        }
        
    }
    
}


extension LargeContentCollectionViewCell : BadgerViewDelegate {
    
    func badgeSelected(badge : MBadge, isSelected : Bool) {
        
        if let imageView = badgeButton.imageView {
            UIView.transition(with: imageView,
                              duration: 0.25,
                              options: .transitionCrossDissolve,
                              animations: {
                               
                                BadgerView.setBadgeImage(badge: badge, primary: false, button: self.badgeButton, for: .selected)
                               
            },
                              completion: nil)
        }
        
        badgeButton.isSelected = isSelected
        
        guard let contentType = contentType, let id = contentId else { return }
        delegate?.didTapBadgeButton(cell : self, forContentType: contentType, withId: id, badge: badge, remove: !isSelected, contentStyle: .large)
        
    }
    
}

