//
//  ContentTableViewCell.swift
//  Maverick
//
//  Created by Garrett Fritz on 2/21/18.
//  Copyright © 2018 BeMaverick. All rights reserved.
//

import Foundation
import AVKit


class ContentTableViewCell : UITableViewCell {
    
    @IBOutlet weak var responseChallengeTitleDecoration: UILabel!
    
    @IBOutlet weak var linkContainer: UIView!
    
    @IBOutlet var additionalCaptionBlockLinkConstraint: NSLayoutConstraint!
    @IBOutlet weak var linkAttachmentImage: UIImageView!
    @IBOutlet weak var linkPreviewImage: UIImageView!
    @IBOutlet weak var favoriteIndicator: UIImageView!
    // MARK: - IBOutlets
    
    @IBOutlet weak var addCommentButton: UIButton!
    @IBOutlet weak var commentCountButton: UIButton!
    @IBOutlet weak var responsesBadgesCountButton: UIButton!
    @IBOutlet weak var challengerFavoriteButton: UIButton!
    @IBOutlet weak var creatorImageView: UIImageView!
    @IBOutlet weak var usernameLabel: BadgeLabel!
    /// height of the content cell - this is the most dynamic part of the cell height
    @IBOutlet weak var contentHeightConstraint: NSLayoutConstraint!
    /// View responsible for video playback and UI controls
    @IBOutlet weak var videoPlayerView: VideoPlayerView?
    /// mute button
    @IBOutlet weak var muteButton: UIButton!
    /// share button - challenge only
    @IBOutlet weak var shareButton: UIButton!
    /// save button - challenge only - gone for now
    @IBOutlet weak var saveButton: UIButton?
    /// top label for creator's username, tapping sends to profile
    @IBOutlet weak var authorTitle: UIButton!
    /// main image in content
    @IBOutlet weak var contentImage: UIImageView!
    /// View that shows the badger + animation
    @IBOutlet var badgerView: BadgerView!
    /// Button to open badger
    @IBOutlet weak var badgerButton: UIButton!
    /// 'Do Your Thing' Button
    @IBOutlet weak var ctaButton: UIButton!
    /// View all challenges or time remaining on Challenge
    @IBOutlet weak var challengeTitleButton: UIButton!
    /// 'View all badges' or 'View Responses' button
   
    @IBOutlet weak var firstCommentVerifiedOverlay: BadgeLabel!
    @IBOutlet weak var secondCommentVerifiedOverlay: BadgeLabel!
    
    /// The description or caption of the content item, appears in the commentStackView
    @IBOutlet var contentDescription: MaverickActiveLabel!
    /// second comment on response
    @IBOutlet var secondCommentLabel: MaverickActiveLabel!
    /// first comment on response
    @IBOutlet var firstCommentLabel: MaverickActiveLabel!
    /// Button that launches actions menu
    @IBOutlet weak var overFlowButton: UIButton!
    
    /// Back button used for single item display
    @IBOutlet weak var backButton: UIButton!
    /// Width constraint used to hide/show back button
    @IBOutlet var backButtonWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var topRightStackView: UIStackView!
    
    @IBOutlet weak var editInviteChallengeButton: UIButton!
    @IBAction func saveButtonTapped(_ sender: Any) {
        
        guard let saveButton = saveButton else { return }
        saveButton.isSelected = !saveButton.isSelected
        delegate?.didTapSaveButton(forContentType: contentType, withId: contentId, isSaved: saveButton.isSelected, contentStyle: .full)
        
    }
    
    @IBAction func linkTapped(_ sender: Any) {
        
        delegate?.didTapLink(link: linkUrl, forContentType: contentType, withId: contentId, contentStyle: .full)
        
    }
    private var showVerifiedComments = false
        private var linkUrl : URL? = nil
    // MARK: - IBActions
    
    /**
     Back Button Tapped
     */
    @IBAction func backButtonTapped(_ sender: Any) {
        
        delegate?.didTapBackButton()
        
    }
    
    /**
     Overflow button pressed - report/share/delete
     */
    @IBAction func overflowPressed(_ sender: Any) {
        
        delegate?.didTapOverflowButton(forContentType: contentType, withId: contentId, contentStyle: .full)
        
    }
    
    /**
     Username of the creator tapped (top of card)
     */
    @IBAction func authorPressed(_ sender: Any) {
        
        guard let creatorId = creator?.userId else { return }
        delegate?.didTapShowProfileButton(forUserId: creatorId, fromContentType: contentType, withId: contentId, contentStyle: .full)
        
    }
    
    /**
     Mute button tapped (bottom left of card)
     */
    @IBAction func muteButton(_ sender: Any) {
        
        
        let muteState = !(videoPlayerView?.muteToggle() ?? false)
        (sender as? UIButton)?.isSelected = muteState
        
        Video.appUserMuted = !muteState
        
        delegate?.didTapMuteButton(cell: self, forContentType: contentType, withId: contentId, contentStyle: .full, isMuted: !muteState)
        
    }
    
    /**
     Deliberately set mute state of the video
     */
    func setMuteState(muted : Bool) {
        
        muteButton.isSelected = !muted
        videoPlayerView?.setMuteState(muted: muted)
        
    }
    
    /**
     Share Button Tapped
     */
    @IBAction func shareButtonTapped(_ sender: Any) {
        
        setMuteState(muted: true)
        delegate?.didTapShareButton(forContentType: contentType, withId: contentId, contentStyle: .full)
        
    }
    
    
    
    /**
     Do your thing button tapped, only available on Challenge content
     */
    @IBAction func ctaButtonTapped(_ sender: Any) {
        
        isBouncing = false
        guard let challengeId = challenge?.challengeId else { return }
        delegate?.didTapCTAButton(forChallenge: challengeId, fromContentType: contentType, withId: contentId, contentStyle: .full)
        
    }
    
    /**
     Challenge title tapped, bottom of central content on Responses and top left
     for challenges
     */
    @IBAction func challengeTitleTapped(_ sender: Any) {
        
        guard let challengeId = challenge?.challengeId else { return }
        delegate?.didTapChallengeTitleButton(forChallenge: challengeId, fromContentType: contentType, withId: contentId, contentStyle: .full)
        
    }
    
    /**
     Tap on any of the comments or 'view all comments' area
     */
    @IBAction func commentAreaPressed(_ sender: Any) {
        
        if recentComments.count > 0 {
            
            delegate?.didTapShowCommentButton(forContentType: contentType, withId: contentId, contentStyle: .full)
            
        } else {
            
            delegate?.didTapAddCommentButton(forContentType: contentType, withId: contentId, cell: self, contentStyle: .full)
        }
        
    }
    
    @IBAction func responsesBadgesCountTapped(_ sender: Any) {
        
        if contentType == .response {
            
            delegate?.didTapShowBadgesButton(forContentType: contentType, withId: contentId, contentStyle: .full)
            
        } else if contentType == .challenge {
            
            guard let challengeId = challenge?.challengeId else { return }
            delegate?.didTapChallengeResponsesButton(forChallenge: challengeId, fromContentType: contentType, withId: contentId, contentStyle: .full)
            
        }
        
    }
    
    /**
     Tapping the central badge button, expands/collapses badger view
     */
    @IBAction func badgerButtonPressed(_ sender: Any) {
        
        isBouncing = false
        if let button = sender as? UIButton {
            
            UIView.animate(withDuration: 0.15, animations: {
                
                button.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
                
            }) { (finished) in
                
                UIView.animate(withDuration: 0.25, animations: {
                    
                    button.transform = CGAffineTransform.identity
                    
                })
                
            }
        }
        
        badgerView.collapsed =  !badgerView.collapsed
        if let responseId = response?.responseId {
            
            AnalyticsManager.Content.trackBadgesOpened(.response, contentId: responseId, contentStyle: .full)
            
        }
        
    }
    
    
    
    @IBAction func favoriteResponseTapped(_ sender: Any) {
        
        guard let challenge = challenge else { return }
        
        if contentType == .response {
            
            if challenge.userId == ContentTableViewCell.loggedInUserId {
                
                challengerFavoriteButton.isSelected = !challengerFavoriteButton.isSelected
                delegate?.didTapFavoriteResponseButton(forContentType: contentType, withId: contentId, contentStyle: .full, isFavorited: challengerFavoriteButton.isSelected )
                
            } else {
                
                delegate?.didTapChallengeTitleButton(forChallenge: challenge.challengeId, fromContentType: contentType, withId: contentId, contentStyle: .full)
                
            }
            
        }
        
    }
    
    
    @IBAction func editInviteChallengeTapped(_ sender: Any) {
        
        delegate?.didTapInviteChallengeButton(forChallenge: contentId, contentStyle: .full)
        
    }
    // MARK: - Properties
    
    /// maximum aspect ratio of any content item, things get cropped if larger
    private static var maxAspectratio : CGFloat = 3 / 4
    /// storage object for the recent comments, probably can phase this out now
    private var recentComments : [Comment] = []
    
    /// The user who created this content item
    private var creator : User?
    /// The challenge this content item is associated with
    private var challenge : Challenge?
    /// The response of this item
    private var response: Response? = nil
    /// delegate for click actions
    weak var delegate: AdvancedContentDelegate?
    /// content type for this item
    var contentType: Constants.ContentType = .response
    /// String id for this item
    var contentId = ""
    /// Static path to logged in user Avatar
    static var loggedInUserAvatarURL : MaverickMedia?
    static var loggedInUserId : String?
    private var isBouncing = false
    
    
    // MARK: - Lifecycle
    
    weak var labelDelegate : MaverickActiveLabelDelegate? {
        
        didSet {
            
            firstCommentLabel.maverickDelegate = labelDelegate
            secondCommentLabel.maverickDelegate = labelDelegate
            contentDescription.maverickDelegate = labelDelegate
            
        }
        
    }
    
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        linkPreviewImage.backgroundColor = UIColor(rgba: "F5F5F5")
        linkPreviewImage.kf.indicatorType = .activity
        usernameLabel.imageOffset = CGPoint(x: 0.0, y: -2.0)
        authorTitle.tintColor = .white
        videoPlayerView?.delegate = self
        badgerView.delegate = self
        
        backButton.tintColor = UIColor.MaverickBadgePrimaryColor
        
        ctaButton.addShadow()
        
        badgerButton.addShadow()
        
        badgerView.setSize(small  : false)
        badgerView.collapsed = true
        
        creatorImageView.layer.cornerRadius = creatorImageView.frame.height / 2
        creatorImageView.clipsToBounds = true
        creatorImageView.layer.borderWidth = 0.5
        creatorImageView.layer.borderColor = UIColor(rgba: "D3D3D3ff")?.cgColor
        
        editInviteChallengeButton.isHidden = true
        challengerFavoriteButton.isHidden = true
        configureLink(nil)
        
    }
    
    
    override func prepareForReuse() {
        
        super.prepareForReuse()
        
        configureLink(nil)
        usernameLabel.text = nil
        videoPlayerView?.prepareForReuse()
        setOverlayAlpha(1)
        muteButton.isSelected = false
        imageView?.image = nil
        editInviteChallengeButton.isHidden = true
        challengerFavoriteButton.isHidden = true
        removeHeightConstraints()
        
    }
    
    
    
    func configureLink(_ link : String?) {
        
        guard let urlString = link, let url = URL(string: urlString) else {
            
            linkContainer.isHidden = true
            linkPreviewImage.isHidden = true
            linkAttachmentImage.isHidden = true
            additionalCaptionBlockLinkConstraint.isActive = false
            return
            
        }
        
        linkContainer.isHidden = false
        linkUrl = url
        OpenGraph.fetch(url: url) { og, error in
            
            DispatchQueue.main.async {
                
                self.linkPreviewImage.isHidden = false
                self.linkAttachmentImage.isHidden = false
                self.additionalCaptionBlockLinkConstraint.isActive = true
                
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
    
    // MARK: - Public Methods
    
    /**
     Build out cell for a challenge item
     */
    func configure(with challenge: Challenge, isSaved : Bool, hasResponded : Bool) {
        
        configureLink(challenge.linkURL)
        favoriteIndicator.isHidden = true
        
        responseChallengeTitleDecoration.isHidden = true
        challengeTitleButton.setImage(nil, for: .normal)
        
        if challenge.userId == ContentTableViewCell.loggedInUserId {
            
            editInviteChallengeButton.isHidden = false
            
        }
        
        contentHeightConstraint.constant = CGFloat(Constants.MaxContentScreenWidth) / ContentTableViewCell.maxAspectratio
        self.challenge = challenge
        
        
        saveButton?.isHidden = false
        saveButton?.isSelected = isSaved
        contentImage.kf.indicatorType = challenge.mediaType == .image ? .activity : .none
        contentId = challenge.challengeId
        creator = challenge.getCreator()
        contentType = .challenge
        challengeTitleButton.setTitle(challenge.title ?? R.string.maverickStrings.challengeTitle(creator?.username ?? ""), for: .normal)
        
        
        let showBadge = creator?.isVerified ?? false
        usernameLabel.image = showBadge ? R.image.verified() : nil
        
        usernameLabel.text = creator?.username
        
        setComments(descriptor: challenge.commentDescriptor)
        setViewVisibility()
        
        responsesBadgesCountButton.setImage(R.image.bigger_response_icon(), for: .normal)
        if challenge.numResponses > 0 {
            
            responsesBadgesCountButton.setTitle("\(challenge.numResponses)", for: .normal)
            responsesBadgesCountButton.isHidden = false
            
        } else {
            
            responsesBadgesCountButton.setTitle(nil, for: .normal)
            responsesBadgesCountButton.isHidden = false
            
        }
        
        muteButton.isHidden = challenge.mediaType != .video
        if challenge.mediaType == .video {
            
            videoPlayerView?.isHidden = false
            configureVideo(media: challenge.videoMedia)
            
        } else {
            
            videoPlayerView?.prepareForReuse(removeMedia : true)
            videoPlayerView?.isHidden = true
            
        }
        
        if let url = ContentTableViewCell.getMainImageUrl(primaryImage: challenge.imageChallengeMedia, fallbackImage : challenge.mainImageMedia) {
            
            contentImage.kf.setImage(with: url, placeholder: nil, options: [.transition(.fade(UIImage.fadeInTime))], progressBlock: nil, completionHandler: nil)
            
        } else {
            
            contentImage.image = nil
            
        }
        if let user = challenge.getCreator() {
            
            setCreatorAvatar(withUser: user)
            
        }
        
        startBouncing()
        
        addHeightConstraints()
        
        layoutIfNeeded()
        
    }
    
    func setCreatorAvatar(withUser user : User) {
        
        if let imagePath = user.profileImage?.getUrlForSize(size: creatorImageView.frame), let url = URL(string: imagePath) {
            
            creatorImageView.kf.setImage(with: url, placeholder: R.image.defaultMaverickAvatar(), options: [.transition(.fade(UIImage.fadeInTime))])
            
        } else {
            
            creatorImageView.image = R.image.defaultMaverickAvatar()
            
        }
        
        
    }
    
    /**
     Build out cell for a response item
     */
    func configure(with response: Response) {
        
        
        favoriteIndicator.isHidden = !response.favorite
 
        
        contentHeightConstraint.constant = CGFloat(Constants.MaxContentScreenWidth) / ContentTableViewCell.maxAspectratio
        self.response = response
        saveButton?.isHidden = true
        contentImage.kf.indicatorType = response.mediaType == .image ? .activity : .none
        contentId = response.responseId
        creator = response.creator.first
        challenge = response.challengeOwner.first
        contentType = .response
        
        setComments(descriptor: response.commentDescriptor)
        let numBadges = setBadgeValues()
        responsesBadgesCountButton.setImage(R.image.bigger_badge_icon(), for: .normal)
        if numBadges > 0 {
            
            responsesBadgesCountButton.setTitle("\(numBadges)", for: .normal)
            responsesBadgesCountButton.isHidden = false
            
        } else {
            
            responsesBadgesCountButton.setTitle(nil, for: .normal)
            responsesBadgesCountButton.isHidden = false
           
        
        }
        
        if let user = response.getCreator() {
            
            setCreatorAvatar(withUser: user)
            
        }
        let showBadge = creator?.isVerified ?? false
        usernameLabel.image = showBadge ? R.image.verified() : nil
        
        usernameLabel.text = creator?.username
        
        let challengeCreator = challenge?.getCreator()?.username
        if let unwrapChallenge = challenge {
            
            challengeTitleButton.setTitle(unwrapChallenge.title ?? R.string.maverickStrings.challengeTitle(challengeCreator ?? ""), for: .normal)
            
            responseChallengeTitleDecoration.isHidden = false
            challengeTitleButton.setImage(R.image.challengeTitleCarat(), for: .normal)
            
            
        } else {
            
            
            responseChallengeTitleDecoration.isHidden = true
            challengeTitleButton.setImage(nil, for: .normal)
            challengeTitleButton.setTitle(R.string.maverickStrings.postTitle(creator?.username ?? ""), for: .normal)
            
        }
       
       
        
        muteButton.isHidden = response.mediaType != .video
       
        setViewVisibility()
        
        if challenge?.userId == ContentTableViewCell.loggedInUserId {
            
            challengerFavoriteButton.isHidden = false
            
        }
        challengerFavoriteButton.isSelected = response.favorite
        
        
        if response.mediaType == .video {
            
            videoPlayerView?.isHidden = false
            configureVideo(media: response.videoMedia)
            
        } else {
            
            videoPlayerView?.prepareForReuse(removeMedia : true)
            videoPlayerView?.isHidden = true
            
        }
        
        if let url = ContentTableViewCell.getMainImageUrl(primaryImage: response.imageMedia, fallbackImage : response.videoCoverImageMedia) {
            
            contentImage.kf.setImage(with: url, placeholder: nil, options: [.transition(.fade(UIImage.fadeInTime))], progressBlock: nil, completionHandler: nil)
            
        } else {
            
            contentImage.image = nil
            
        }
        
        startBouncing()
        
        addHeightConstraints()
        
        layoutIfNeeded()
        
    }
    
    func allowAutoStart(enabled : Bool) {
        
        videoPlayerView?.allowAutoplay = enabled
        
    }
    
    /**
     Cell left the screen, so stop playing
     */
    func stopPlayback() {
        
        videoPlayerView?.pause(allowAuto : false)
        
    }
    
    /**
     Scrolling has stopped so try to autoplay
     */
    func attemptAutoplay() {
        
        if contentType == .challenge, let challenge = challenge {
            
            if challenge.mediaType == .video {
                
                videoPlayerView?.attemptAutoplay()
                
            }
            
        }
        
        if contentType == .response, let response = response {
            
            if response.mediaType == .video {
                
                videoPlayerView?.attemptAutoplay()
                
            }
            
        }
        
    }
    
    /**
     Set visibility of back button
     plus, push out the upper author username label if this is a response (since it is left justified) otherwise, keep it centered
     */
    func setBackButton(hidden : Bool) {
        
        backButtonWidthConstraint.constant = hidden ? 0 : 50
        
        
        
    }
    
    /**
     Called on scroll to dismiss badger view
     */
    func dismissBadger() {
        
        badgerView.collapsed = true
        
    }
    
    /**
     Sets selected badge state to the badger view
     TODO: same thing we did for comment descriptor would be nice
     */
    func setSelectedBadge(badge : MBadge?) {
        
        badgerView.setSelected(badge: badge)
        badgerButton.isSelected = badgerView.isItemSelected() != nil
        BadgerView.setBadgeImage(badge: badge, primary: false, button: badgerButton, for: .selected)
        
    }
    
    // MARK: - Private Methods
    
    /**
     Set view visibility based on content type
     */
    private func setViewVisibility() {
        
        badgerButton.isHidden = contentType != .response
        
        ctaButton.isHidden = contentType != .challenge
        
        if contentType == .response {
            
            contentImage.superview?.addSubview(badgerView)
            badgerView.autoPinEdgesToSuperviewEdges()
            
            
        } else if badgerView.superview != nil {
            
            badgerView.removeFromSuperview()
            
        }
        
    }
    
    /**
     Called when playback gets going to free up items over the video
     */
    private func setOverlayAlpha(_ alpha : CGFloat) {
        
        overFlowButton.alpha = alpha
        saveButton?.alpha = alpha
        shareButton.alpha = alpha
        
    }
    
    /**
     Sets the label or caption the creator entered for this item - appears like a comment
     add or remove item from stackview as needed
     */
    private func setContentCaption() {
        
        
        var label : String? = nil
        
        switch contentType {
            
        case .challenge:
            
            guard let challengeToDisplay = challenge else { return }
            
            label = challengeToDisplay.label
         
            
        case .response:
            
            guard let responseToDisplay = response else { return }
            
            label = responseToDisplay.label
            
        }
        
        
        contentDescription.isHidden = !(label != nil)
      contentDescription.text = label
        
    }
    
    /**
     Set the recent comments on the item (or remove them from the stackview)
     */
    private func setComments(descriptor: CommentDescriptor?) {
        
        setContentCaption()
        
        var comments: [Comment] = []
        
        if let comment = descriptor?.peekedComments[safe: 0], comment.creator.first?.username != nil, comment.body != nil {
            
            comments.append(comment)
            
        }
        
        if let comment = descriptor?.peekedComments[safe: 1], comment.creator.first?.username != nil, comment.body != nil {
            
            comments.append(comment)
            
        }
        
        recentComments = comments
        
        if recentComments.count > 0 {
            
            let count = descriptor?.numMessages ?? recentComments.count
            commentCountButton.setTitle("\(count)", for: .normal)
            setComment(forLabel: firstCommentLabel, verifiedBadgerOverlay: firstCommentVerifiedOverlay, withUsername: recentComments[0].creator.first?.username ?? "", andBody: recentComments[0].body ?? "", mentions: Array(recentComments[0].mentions), isVerified: recentComments[0].creator.first?.isVerified ?? false)
            commentCountButton.imageEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, 0.0, -18.0)
            commentCountButton.contentEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, 0.0, 10.0)
            firstCommentLabel.isHidden = false
            addCommentButton.isHidden = true
            
        } else {
            
            addCommentButton.isHidden = false
            commentCountButton.setTitle(nil, for: .normal)
            commentCountButton.imageEdgeInsets = .zero
            commentCountButton.contentEdgeInsets = .zero
            firstCommentLabel.isHidden = true
            
        }
        
        if recentComments.count > 1 {
            
            setComment(forLabel: secondCommentLabel, verifiedBadgerOverlay: secondCommentVerifiedOverlay, withUsername: recentComments[1].creator.first?.username ?? "", andBody: recentComments[1].body ?? "", mentions: Array(recentComments[1].mentions), isVerified: recentComments[0].creator.first?.isVerified ?? false)
            
            secondCommentLabel.isHidden = false
            
        } else {
            
            secondCommentLabel.isHidden = true
            
        }
        
        firstCommentVerifiedOverlay.isHidden = firstCommentLabel.isHidden
        secondCommentVerifiedOverlay.isHidden = secondCommentLabel.isHidden
        
        
    }
    
    /**
     Utility function to style comment label
     */
    private func setComment(forLabel commentLabel: MaverickActiveLabel, verifiedBadgerOverlay: BadgeLabel, withUsername username: String, andBody body: String, mentions : [Mention]?, isVerified: Bool) {
        
        
        let author = username
        let body = body
        
     
        verifiedBadgerOverlay.image = (showVerifiedComments && isVerified) ? R.image.verified() : nil
        let spacer = (showVerifiedComments && isVerified) ? "     " : " "
        commentLabel.mentions = mentions ?? []
        commentLabel.text = "\(author) \(spacer)\(body)"
        verifiedBadgerOverlay.setAsOverlay(first: author, last: body)
        
    }
    
    static func getMainImageUrl(primaryImage : MaverickMedia?, fallbackImage : MaverickMedia?) -> URL? {
        
        let maverickMedia = primaryImage ?? fallbackImage
        guard let imageMedia = maverickMedia else { return nil }
        maxAspectratio = Variables.Content.maxStreamAspectRatio.cgFloatValue()
        let screenWidth = CGFloat(Constants.MaxContentScreenWidth)
        let maxHeight = screenWidth / maxAspectratio
        
        let size =  CGSize(width: screenWidth, height: maxHeight)
        if let stringPath = imageMedia.getUrlForSize(size: CGRect(origin: CGPoint.zero, size: size)) {
            
            return URL(string : stringPath)
            
        }
        
        return nil
        
    }
    
    
    /**
     Set values to the video view and content image
     */
    private func configureVideo(media : MaverickMedia?) {
        
        videoPlayerView?.configure(with: media, muteState : Video.appUserMuted)
        muteButton.isSelected = !(videoPlayerView?.isMuted() ?? false)
        setNeedsUpdateConstraints()
        
    }
    
    /**
     Set number received to populate ranks on the badger view
     TODO: returns : has badges
     */
    private func setBadgeValues(addedBadge : MBadge? = nil) -> Int {
        
        guard let response = response else { return 0 }
        
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
        
        return firstBadge.numReceived + secondBadge.numReceived + thirdBadge.numReceived + fourthBadge.numReceived
    }
    
    /**
     function to add small badge icon to badge bag indicator
     */
    private func createSmallBadgeImage(badge : MBadge) -> UIImageView {
        
        
        let imageView = UIImageView()
        BadgerView.setBadgeImage(badge: badge, primary: false, imageView: imageView)
        let imageWidthConstraint = NSLayoutConstraint (item: imageView,
                                                       attribute: NSLayoutAttribute.width,
                                                       relatedBy: NSLayoutRelation.equal,
                                                       toItem: nil,
                                                       attribute: NSLayoutAttribute.notAnAttribute,
                                                       multiplier: 1,
                                                       constant: 34)
        
        let imageHeightConstraint = NSLayoutConstraint (item: imageView,
                                                        attribute: NSLayoutAttribute.height,
                                                        relatedBy: NSLayoutRelation.equal,
                                                        toItem: nil,
                                                        attribute: NSLayoutAttribute.notAnAttribute,
                                                        multiplier: 1,
                                                        constant: 34)
        imageView.addConstraint(imageWidthConstraint)
        imageView.addConstraint(imageHeightConstraint)
        imageView.contentMode = .scaleAspectFit
        
        return imageView
    }
    
    
    
    
    
    
    
    private func bounce(button: UIView, delay : CGFloat = 0) {
        
        DispatchQueue.main.asyncAfter(deadline: .now() + Double(delay)) { [weak self] in
            
            if self?.isBouncing ?? false {
                
                UIView.animate(withDuration: 0.15, animations: {
                    
                    button.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
                    
                }) { (finished) in
                    
                    UIView.animate(withDuration: 0.25, animations: {[weak self] in
                        
                        button.transform = CGAffineTransform.identity
                        self?.bounce(button : button, delay: Variables.Features.ctaBounceSpace_s.cgFloatValue())
                        
                    })
                    
                }
                
            }
            
        }
        
    }
    
    func startBouncing() {
        
        if contentType == .response && badgerButton.isSelected {
            isBouncing = false
            return
        }
        
        if contentType == .challenge  {
            isBouncing = false
            return
        }
        if !isBouncing {
            
            isBouncing = true
            bounce(button: contentType == .response ? badgerButton : ctaButton)
            
        }
        
    }
    
    private func addHeightConstraints() {
        
        let labelsToAdjust: [MaverickActiveLabel] = [firstCommentLabel, secondCommentLabel, contentDescription]
        
        labelsToAdjust.forEach {
            
            if $0.numberOfVisibleLines == 1 {
                
                $0.addConstraint(NSLayoutConstraint(item: $0, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 17))
                
            }
            
        }
        
    }
    
    
    private func removeHeightConstraints() {
        
        let labelsToAdjust = [firstCommentLabel, secondCommentLabel, contentDescription]
        
        labelsToAdjust.forEach {
            
            var constraintsToRemove = [NSLayoutConstraint]()
            
            $0?.constraints.forEach { constraint in
                
                if constraint.firstAttribute == .height && constraint.constant == 17 {
                    constraintsToRemove.append(constraint)
                }
                
            }
            
            $0?.removeConstraints(constraintsToRemove)
            
        }
        
    }
    
    
}

extension ContentTableViewCell: VideoPlayerViewDelegate {
    
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
        
        delegate?.didTapMainArea(cell : self, forContentType: contentType, withId: contentId, contentStyle: .full)
        videoPlayerView?.playPausePressed()
        
    }
    
    
    func toggleOverlay(isVisible visible : Bool) {
        
        UIView.animate(withDuration: 0.5) {
            
            self.setOverlayAlpha( (self.videoPlayerView?.isPlaying() ?? false) && !visible ? 0 : 1)
            
        }
        
    }
    
}

extension ContentTableViewCell : BadgerViewDelegate {
    
    func badgeSelected(badge : MBadge, isSelected : Bool) {
        
        
        if let imageView = badgerButton.imageView {
            UIView.transition(with: imageView,
                              duration: 0.25,
                              options: .transitionCrossDissolve,
                              animations: {
                                
                                BadgerView.setBadgeImage(badge: badge, primary: false, button: self.badgerButton, for : .selected)
                                
            },
                              completion: nil)
        }
        
        badgerButton.isSelected = isSelected
        
        delegate?.didTapBadgeButton(cell : self, forContentType: contentType, withId: contentId, badge: badge, remove: !isSelected, contentStyle: .full)
        //this will update the badge bag ui
        
        
        let numBadges = setBadgeValues(addedBadge: isSelected ? badge : nil)
        responsesBadgesCountButton.setImage(R.image.bigger_badge_icon(), for: .normal)
        if numBadges > 0 {
            
            responsesBadgesCountButton.setTitle("\(numBadges)", for: .normal)
            responsesBadgesCountButton.isHidden = false
            
        } else {
            
            responsesBadgesCountButton.isHidden = true
        }
        
        
    }
    
}

extension UILabel {
    var numberOfVisibleLines: Int {
        let textSize = CGSize(width: CGFloat(self.frame.size.width), height: CGFloat(MAXFLOAT))
        let rHeight: Int = lroundf(Float(self.sizeThatFits(textSize).height))
        let charSize: Int = lroundf(Float(self.font.pointSize))
        return rHeight / charSize
    }
}
