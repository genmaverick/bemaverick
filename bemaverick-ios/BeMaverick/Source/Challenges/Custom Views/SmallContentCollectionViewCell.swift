//
//  ChallengeItemCollectionViewCell.swift
//  Maverick
//
//  Created by Garrett Fritz on 7/19/18.
//  Copyright © 2018 BeMaverick. All rights reserved.
//

import Foundation

@objc
protocol SmallContentCollectionViewCellDelegate : class {
    
    @objc func cellTapped(cell : SmallContentCollectionViewCell)
    
    @objc func avatarTapped(userId : String)
    
}

class SmallContentCollectionViewCell : UICollectionViewCell {
    
    @IBOutlet var titleAdditionalConstraint: NSLayoutConstraint!
    @IBOutlet weak var linkAttachmentIndicator: UIImageView!
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var favoriteIcon: UIImageView!
    
    @IBOutlet weak var commentButton: UIButton!
    
    @IBOutlet weak var draftContainer: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var draftProcessProgressBar: UIProgressView!
    /// Image for draft indication
    @IBOutlet weak var draftButton: UIButton!
    @IBOutlet weak var countContainer: UIStackView!
    @IBOutlet weak var responseBadgeButton: UIButton!
    @IBOutlet weak var creatorHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var challengeTitleHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var selectedBadgeImageView: UIImageView!
    @IBOutlet weak var shadowContainer: UIView!
    @IBOutlet weak var usernameLabel: BadgeLabel!
    @IBOutlet weak var videoPlayerView: VideoPlayerView!
    @IBOutlet weak var midAndLowerSectionContainer: UIView!
    
    @IBOutlet weak var avatarImageView: UIImageView!
    
    @IBOutlet weak var completeIcon: UIImageView!
    
    @IBOutlet weak var titleLabel: UILabel!
    
   
    @IBAction func avatarTapped(_ sender: Any) {
    
        if let challenge = challenge, let userId = challenge.userId {
        
            delegate?.avatarTapped(userId: userId)
        
        }
        
        if let response = response, let userId = response.userId {
            
            delegate?.avatarTapped(userId: userId)
            
        }
        
    }
    
    @IBOutlet weak var playThumbnail: UIImageView!
    @IBAction func cellTapped(_ sender: Any) {
    
       delegate?.cellTapped(cell: self)
        
    }
    
    static let lowerSectionHeight : CGFloat = 44.0
    static let upperSectionHeight : CGFloat = 44.0
    
    var contentType : Constants.ContentType?
    var contentId : String?
    var draftId : String?
    
    override func prepareForReuse() {
     
        super.prepareForReuse()
        avatarImageView.image = nil
        usernameLabel.text = nil
        imageView?.image = nil
        completeIcon.isHidden = true
        titleAdditionalConstraint.isActive = false
        linkAttachmentIndicator.isHidden = true
        draftId = nil
        favoriteIcon.isHidden = true
        contentId = nil
        
    }
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
      
        favoriteIcon.isHidden = true
        titleAdditionalConstraint.isActive = false
        linkAttachmentIndicator.isHidden = true
        commentButton.addShadow()
        responseBadgeButton.addShadow()
        playThumbnail.addShadow()
        draftButton.backgroundColor = UIColor.MaverickBadgePrimaryColor.withAlphaComponent(0.5)
        draftButton.semanticContentAttribute = .forceRightToLeft
        draftProcessProgressBar.isHidden = true
        draftProcessProgressBar.addShadow()
        activityIndicator.backgroundColor = UIColor.darkGray.withAlphaComponent(0.75)
        activityIndicator.stopAnimating()
        
        draftProcessProgressBar.progressTintColor = UIColor.MaverickPrimaryColor
        
        selectedBadgeImageView.isHidden = true
        usernameLabel.imageOffset = CGPoint(x: 0.0, y: -3.0)
        avatarImageView.layer.cornerRadius = avatarImageView.frame.height / 2
        avatarImageView.clipsToBounds = true
        avatarImageView.layer.borderWidth = 0.5
        avatarImageView.layer.borderColor = UIColor(rgba: "D3D3D3ff")?.cgColor
        
        shadowContainer.addShadow(color: .black, alpha: 0.24, x: 0, y: 0.5, blur: 4, spread: 0)
        imageView?.kf.indicatorType = .activity
        midAndLowerSectionContainer.layer.cornerRadius = 2
        midAndLowerSectionContainer.clipsToBounds = true
        shadowContainer.layer.cornerRadius = 2
        clipsToBounds = false
        contentView.clipsToBounds = false
    }
    
    weak var delegate : SmallContentCollectionViewCellDelegate?
    private var challenge : Challenge?
    private var response : Response?
    
    
    private func checkProgress() {
        
        if let draftId = draftId {
            let (state, progress) = MaverickComposition.getProgress(sessionId : draftId)
            
            if state == .processing {
                
                draftProcessProgressBar.isHidden = false
                draftProcessProgressBar.progress = progress
                draftButton.setTitle("PREPARING", for: .normal)
                draftButton.setImage(nil, for: .normal)
                if state == .processing {
                    
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) { [ weak self ] in
                        
                        self?.checkProgress()
                        
                    }
                    
                }
                
                return
                
            } 
            
        }
        
        draftButton.setImage(R.image.edit(), for: .normal)
        draftButton.setTitle(R.string.maverickStrings.draft(), for: .normal)
        activityIndicator.stopAnimating()
        draftProcessProgressBar.isHidden = true
        
    }
    
    func configure(withDraft draftId: String, andChallenge challenge: Challenge?, isUploading : Bool) {
        
       
        draftContainer.isHidden = false
        countContainer.isHidden = true
        selectedBadgeImageView.isHidden = true
        completeIcon.isHidden = true
        usernameLabel.isHidden = true
        avatarImageView.isHidden = true
        creatorHeightConstraint.constant = 0
        self.draftId = draftId
        self.challenge = challenge
        self.contentId = challenge?.challengeId
        self.contentType = .response
        videoPlayerView.isHidden = true
        videoPlayerView.prepareForReuse(removeMedia : true)
        
        if isUploading {
            
            draftButton.setTitle(R.string.maverickStrings.uploading(), for: .normal)
            draftButton.setImage(nil, for: .normal)
            draftProcessProgressBar.isHidden = true
            activityIndicator.startAnimating()
            
        } else {
            
            checkProgress()
            
        }
        
        draftButton.isHidden = false
        
        
        if let imageObject = challenge?.imageChallengeMedia {
            
            if let path = imageObject.getUrlForSize(size: LargeContentCollectionViewCell.getCellSize()), let url = URL(string: path) {
                
                imageView?.kf.setImage(with: url, placeholder: nil, options: [.transition(.fade(UIImage.fadeInTime))], progressBlock: nil, completionHandler: nil)
                
            }
            
            imageView?.contentMode = .scaleAspectFill
            
        } else if let imageObject = challenge?.mainImageMedia {
            
            if let path = imageObject.getUrlForSize(size: LargeContentCollectionViewCell.getCellSize()), let url = URL(string: path) {
                imageView?.kf.setImage(with: url, placeholder: nil, options: [.transition(.fade(UIImage.fadeInTime))], progressBlock: nil, completionHandler: nil)
                
            }
            
            imageView?.contentMode = .scaleAspectFill
            
        } else {
            
            imageView?.image = R.image.splash_logo()
            imageView?.tintColor = .white
            imageView?.contentMode = .scaleAspectFit
            
        }
        
        titleLabel.text = challenge?.title ?? "Draft Post"
        playThumbnail.isHidden = true
        
    }
    
    
    func configure(with challenge : Challenge, isComplete: Bool, hideCreator : Bool = false) {
        
            titleAdditionalConstraint.isActive = challenge.linkURL != nil
            linkAttachmentIndicator.isHidden = challenge.linkURL == nil
            
        
        draftContainer.isHidden = true
        response = nil
        self.challenge = challenge
        contentType = .challenge
        contentId = challenge.challengeId
        completeIcon.isHidden = !isComplete
        setMedia()
        setData()
        setOwner()
        creatorHeightConstraint.constant = hideCreator ? 0 : 44
        usernameLabel.isHidden = hideCreator
        avatarImageView.isHidden = hideCreator
        selectedBadgeImageView.isHidden = true
        countContainer.isHidden = false
    }
    
    func configure(with response : Response, hideChallengeTitle : Bool = true, hideCreator : Bool = false, badgeGiven : MBadge? = nil) {
        
        favoriteIcon.isHidden = !response.favorite
        draftContainer.isHidden = true
        challenge = nil
        contentType = .response
        contentId = response.responseId
        self.response = response
        completeIcon.isHidden = true
        setMedia()
        setData()
        setOwner()
       
        titleLabel.isHidden = hideChallengeTitle
        challengeTitleHeightConstraint.constant = hideChallengeTitle ? 0 : 44
        creatorHeightConstraint.constant = hideCreator ? 0 : 44
        usernameLabel.isHidden = hideCreator
        avatarImageView.isHidden = hideCreator
        
        if let badge = badgeGiven {
            
            
            if let path = badge.secondaryImageUrl, let url = URL(string: path) {
                
                selectedBadgeImageView.kf.setImage(with: url)
                
            }
            
            selectedBadgeImageView.isHidden = false
            countContainer.isHidden = true
            
            
        } else {
            
            selectedBadgeImageView.isHidden = true
            countContainer.isHidden = false
        }
        
    }
    
    
    func play() {
        
        let mediaType = challenge?.mediaType ?? response?.mediaType
        
        guard let media = mediaType, media == .video else { return }
        videoPlayerView.play()
        
    }
    
    func setData() {
        
        titleLabel.text = challenge?.title ?? response?.challengeOwner.first?.title
        if titleLabel.text == nil {
         
            if let response = response {
                
              titleLabel.text =  R.string.maverickStrings.postTitle(response.getCreator()?.username ?? "")
                
            } else {
                
                titleLabel.text = R.string.maverickStrings.challengeTitle(challenge?.getCreator()?.username ?? "")
                
            }
       
        }
        
        if let response = response {
            
            var count = 0
            for stat in response.badgeStats {
                
                count += stat.numReceived
                
            }
            responseBadgeButton.setTitle("\(count)", for: .normal)
            responseBadgeButton.setImage(R.image.smallBadgeIcon(), for: .normal)
            
            responseBadgeButton.isHidden = count == 0
            
        } else if let responses = challenge?.numResponses, responses > 0 {
        
            responseBadgeButton.isHidden = false
            responseBadgeButton.setTitle("\(responses)", for: .normal)
                 responseBadgeButton.setImage(R.image.small_responses_indicator(), for: .normal)
            
        } else {
        
            responseBadgeButton.isHidden = true
        
        }
        
        let commentDescriptor = challenge?.commentDescriptor ?? response?.commentDescriptor
        
        if let comments = commentDescriptor?.numMessages, comments > 0 {
            
            commentButton.isHidden = false
            commentButton.setTitle("\(comments)", for: .normal)
            
            
        } else {
            
            commentButton.isHidden = true
            
        }
        
      
    }
    
    func setMedia() {
        
        imageView.isHidden = false
        playThumbnail.isHidden = true
        if let response = response {
            
            if response.mediaType == .video {
                
                var path = response.videoCoverImageMedia?.getUrlForSize(size: LargeContentCollectionViewCell.getCellSize())
                if path == nil {
                    
                    path = response.videoMedia?.URLThumbnail
                    
                }
                
                if let videoImagePath = path, let url = URL(string: videoImagePath) {
                    
                    imageView?.kf.setImage(with: url, placeholder: nil, options: [.transition(.fade(UIImage.fadeInTime))], progressBlock: nil, completionHandler: nil)
                    
                }
                
                if Variables.Features.allowGridAutoplay.boolValue() {
                    
                    videoPlayerView.configure(with: response.videoMedia, allowAutoplay: true)
                    videoPlayerView.play()
                
                } else {
                    
                    videoPlayerView.isHidden = true
                    videoPlayerView.prepareForReuse(removeMedia : true)
                    playThumbnail.isHidden = false
                    
                }
                
            } else {
                
                videoPlayerView.isHidden = true
                videoPlayerView.prepareForReuse(removeMedia : true)
                
                if let path = response.imageMedia?.getUrlForSize(size: LargeContentCollectionViewCell.getCellSize()), let url = URL(string: path) {
                    
                    imageView?.kf.setImage(with: url, placeholder: nil, options: [.transition(.fade(UIImage.fadeInTime))], progressBlock: nil, completionHandler: nil)
                    
                }
            
            }
            
        }
        
        guard let challenge = challenge else { return }
      
        if challenge.mediaType == .video {
            
            videoPlayerView.isHidden = false
            var path = challenge.mainImageMedia?.getUrlForSize(size: LargeContentCollectionViewCell.getCellSize() )
            if path == nil {
                path = challenge.mainImageMedia?.URLThumbnail
            }
            if let videoImagePath = path, let url = URL(string: videoImagePath) {
                
                imageView?.kf.setImage(with: url, placeholder: nil, options: [.transition(.fade(UIImage.fadeInTime))], progressBlock: nil, completionHandler: nil)
                
            }
            
              if Variables.Features.allowGridAutoplay.boolValue() {
                
                videoPlayerView.configure(with: challenge.videoMedia, allowAutoplay: true)
                videoPlayerView.play()
              
              } else {
                
                videoPlayerView.isHidden = true
                videoPlayerView.prepareForReuse(removeMedia : true)
                playThumbnail.isHidden = false
                
            }
            
        } else {
            
            
            videoPlayerView.isHidden = true
            videoPlayerView.prepareForReuse(removeMedia : true)
            
            var path = challenge.imageChallengeMedia?.getUrlForSize(size: LargeContentCollectionViewCell.getCellSize() )
            
            if path == nil {
              
                path = challenge.mainImageMedia?.getUrlForSize(size: LargeContentCollectionViewCell.getCellSize() )
            
            }
            
            if let imagePath = path, let url = URL(string: imagePath) {
                
                imageView?.kf.setImage(with: url, placeholder: nil, options: [.transition(.fade(UIImage.fadeInTime))], progressBlock: nil, completionHandler: nil)
                
            }
            
        }
        
    }
    
    func stopPlayback() {
        
        videoPlayerView.pause()
        
    }
    
    func setOwner() {
        
        
        let creator = response?.getCreator() ?? challenge?.getCreator()
       
        guard let user = creator else {
            
            print("⛔️ failed to show user on challenge: \(challenge?.challengeId ?? "no id") : \(challenge?.userId ?? "no userId")")
            
            
            return
            
        }
        
        usernameLabel.image = user.isVerified ? R.image.verified() : nil
        usernameLabel.text = user.username
        if let imagePath = user.profileImage?.getUrlForSize(size: avatarImageView.frame), let url = URL(string: imagePath) {
            
            avatarImageView.kf.setImage(with: url, placeholder: R.image.defaultMaverickAvatar(), options: [.transition(.fade(UIImage.fadeInTime))])
       
        } else {
            
            avatarImageView.image = R.image.defaultMaverickAvatar()
            
        }
        
    }
    
   
    
}
