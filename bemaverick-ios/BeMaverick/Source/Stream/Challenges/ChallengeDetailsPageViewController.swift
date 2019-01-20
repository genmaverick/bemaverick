//
//  ChallengeDetailsViewController.swift
//  BeMaverick
//
//  Created by David McGraw on 10/18/17.
//  Copyright © 2017 BeMaverick. All rights reserved.
//

import UIKit
import RealmSwift

class ChallengeDetailsPageViewController: StreamCollectionViewController {
    
    @IBOutlet weak var sizerLinkTrailingConstraint
    : NSLayoutConstraint!
    @IBOutlet weak var sizerDescription: MaverickNoUsernameActiveLabel!
    @IBOutlet weak var sizerTitle: UILabel!
    @IBOutlet weak var sizerAddComment: UIButton!
    @IBOutlet weak var lowerSizer: UIView!
    @IBOutlet weak var summaryCardImageView: UIImageView!
    @IBOutlet weak var summaryBackgroundCap: UIView!
    @IBOutlet weak var summaryTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var summaryHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var summaryResponseButton: UIButton!
    @IBOutlet weak var summaryCommentButton: UIButton!
    @IBOutlet weak var summaryDescription: MaverickNoUsernameActiveLabel!
    @IBOutlet weak var summaryTitle: UILabel!
    @IBOutlet weak var challengeSummaryHeader: UIView!
    /// Challenge object to display
    private var challenge : Challenge?
    /// user updated notification
    private var notificationToken : NotificationToken?
    weak var delegate : ContentPageViewControllerDelegate?
    
    private var isEmpty = false
    var firstLoad = false
    
    var padding : CGFloat = 28.0
    var gutters : CGFloat = 16.0
    
    private var mute = false
    private var startMinimized = false
    
    var  scrollViewSwipeGestureRecognzier : UISwipeGestureRecognizer?
    
    override func refreshCompleted() {
        
        super.refreshCompleted()
        firstLoad = true
        
    }
    
    override func getTransitionAlphaView() -> [UIView] {
        
        return [collectionView]
        
    }
    
    
    override func getTransitionFrame() -> CGRect? {
        
        let frameWidth = Constants.MaxContentScreenWidth
        let offset = initialOffset ?? .zero
        let xOrigin = UIScreen.main.bounds.width / 2 - Constants.MaxContentScreenWidth / 2
        let newOffsetY = offset.y - collectionView.contentOffset.y
        let frameHeight = frameWidth * 4 / 3
        
        if -newOffsetY > frameHeight {
            if isHeaderVisible {
                
                return view.convert(summaryCardImageView.frame, to: nil)
            
            }
            return .zero
        }
        
        return CGRect(origin: CGPoint(x: xOrigin, y: newOffsetY), size: CGSize(width: frameWidth, height: frameHeight ))
        
    }
    
    override var prefersStatusBarHidden: Bool {
        
        return true
        
    }
    
    @IBAction func headerCloseTapped(_ sender: Any) {
        
        didTapBackButton()
        
    }
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        if delegate == nil {
         
            tabBarController?.setTabBarVisible(visible: false, duration: 0.0, animated: false)
        
        }
        
    }
    
  
   
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        
        if delegate == nil {
            
            tabBarController?.setTabBarVisible(visible: true, duration: 0.0, animated: false)
            
        }
    }
    
   
    
    @IBAction func summaryTapped(_ sender: Any) {
        
        guard let challenge = challenge else { return }
        AnalyticsManager.Challenge.trackSummaryHeaderPressed(challengeId: challenge.challengeId)
        scrollToTop()
        
    }
    
    
    deinit {
     
        notificationToken?.invalidate()
        
    }
    
    func configure(with challenge : Challenge, startMinimized : Bool = false) {
        
        self.challenge = challenge
        self.startMinimized = startMinimized
    }
    
    
    override func viewDidLayoutSubviews() {
        
        super.viewDidLayoutSubviews()
        if startMinimized {
        
            minimizeToResponses(animated: false)
            startMinimized = false
            
        }
        
    }
    
    func minimizeToResponses(animated : Bool = true) {
        
        let topOffset = CGPoint(x: collectionView.contentOffset.x, y: -collectionView.contentInset.top + getHeaderSize().height - challengeSummaryHeader.frame.height)
        collectionView.setContentOffset(topOffset, animated: animated)
        stopHeaderPlayback()
        
    }
    
    private func getHeaderSize() -> CGSize {
        
        let height = collectionView.frame.width * 4 / 3 + lowerSizer.frame.height
        return CGSize(width: collectionView.frame.width, height : height)
        
    }
    
    private func showDisplayFailure() {
        
        if let id = challenge?.challengeId {
        
            services.globalModelsCoordinator.toggleSaveChallenge(withId: id, isSaved: false)
        
        }
        if let vc = R.storyboard.main.errorDialogViewControllerId() {
            
            vc.delegate = self
            vc.setValues(description : "Sorry, this Challenge has been deleted")
            vc.modalPresentationStyle = .overCurrentContext
            present(vc, animated: false, completion: nil)
            return
            
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        if section == 0 {
            
            return UIEdgeInsets.zero
        
        }
        
        return UIEdgeInsetsMake(gutters, gutters, gutters + 49, gutters)
        
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if section == 0 || !firstLoad {
            
            return 1
        
        }
        
        
        return super.collectionView(collectionView, numberOfItemsInSection: section)
    
    }
    
    /**
     Autoplay the largest cell in view
     */
    override func autoPlay() {
        // only autoplay if viewcontroller is visisble
        guard isVisible else { return }
        
        for cell in collectionView?.visibleCells ?? [] {
            
            if let contentCell = cell as? SmallContentCollectionViewCell {
                
                contentCell.play()
                
            }
            
        }
        
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        initializeGestures()
        streamDelegate = self
        
        guard let challenge = challenge else {
            
            showDisplayFailure()
            return
        
        }
        
        if challenge.isDeleted() {
            
            showDisplayFailure()
            return
            
        }
        
        if #available(iOS 11.0, *) {
            collectionView.contentInsetAdjustmentBehavior = .never
        } else {
            // Fallback on earlier versions
        }
        
        sizerLinkTrailingConstraint.constant = challenge.linkURL != nil ? 86 : 16
        sizerTitle.text = challenge.title ?? "some title"
        sizerDescription.text = challenge.label ?? " "
        sizerAddComment.isHidden = challenge.commentDescriptor?.numMessages ?? 0 > 0
        collectionView.bounces = false
        
    }
    
    override func configureView() {
        
        super.configureView()
        challengeSummaryHeader.addShadow()
        configureView(withCustomLayout: collectionView.collectionViewLayout)
        
        collectionView.register(R.nib.challengeDetailsHeader)
        collectionView.register(R.nib.smallContentCollectionViewCell)
        collectionView.register(R.nib.pagingCollectionViewCell)
        
        
        title = challenge?.title
        summaryTopConstraint.constant = summaryHeightConstraint.constant
        challengeSummaryHeader.alpha = 0.0
        summaryBackgroundCap.alpha = 0.0
        collectionView.refreshControl = nil
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        self.animateHeader(visible: scrollView.contentOffset.y > UIScreen.main.bounds.height * 0.45)
        
    }
    
    private var isAnimatingHeader = false
    private var isHeaderVisible = false
    
    override func autoStop() {
        
        super.autoStop()
        stopHeaderPlayback()
        
    }
    
  
    private func stopHeaderPlayback(headerVisible : Bool = true) {
        
        if let headerCell = collectionView.cellForItem(at: IndexPath(item: 0, section: 0)) as? ChallengeDetailsHeader {
            
            if headerVisible {
                
                headerCell.pauseVideo()
                
            } else {
                
                headerCell.videoPlayerView.play()
                
            }
            
        }
        
    }
    private func animateHeader(visible : Bool) {
        
        guard !isAnimatingHeader && visible != isHeaderVisible else { return }
        
        
        stopHeaderPlayback(headerVisible: visible)
        
        summaryTopConstraint.constant = visible ? 0.0 : summaryHeightConstraint.constant
       
        UIView.animate(withDuration: 0.25, animations: {
            
            self.summaryBackgroundCap.alpha = visible ? 1.0 : 0.0
            self.challengeSummaryHeader.alpha = visible ? 1.0 : 0.0
            self.view.layoutIfNeeded()
            
        }) { (result) in
            
            self.isHeaderVisible = visible
            self.isAnimatingHeader = false
        
        }
       
        
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        return 2
        
    }
   
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        
        return padding
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        
        return gutters
        
    }
    
    func configureSummary(challenge : Challenge) {
        
        
        if let path = challenge.mainCardMedia?.getUrlForSize(size: summaryCardImageView.frame), let url = URL(string: path) , challenge.mediaType == .video {
            
            summaryCardImageView.kf.setImage(with: url, placeholder: nil, options: [.transition(.fade(UIImage.fadeInTime))], progressBlock: nil, completionHandler: nil)
            
        } else if let path = challenge.mainImageMedia?.getUrlForSize(size: summaryCardImageView.frame), let url = URL(string: path) {
            
            summaryCardImageView.kf.setImage(with: url, placeholder: nil, options: [.transition(.fade(UIImage.fadeInTime))], progressBlock: nil, completionHandler: nil)
            
        } else if let path = challenge.imageChallengeMedia?.URLOriginal, let url = URL(string: path) {
            
            summaryCardImageView.kf.setImage(with: url, placeholder: nil, options: [.transition(.fade(UIImage.fadeInTime))], progressBlock: nil, completionHandler: nil)
            
        }
        
        
        summaryTitle.text = challenge.title
        if summaryTitle.text == nil {
            
            summaryTitle.text = R.string.maverickStrings.challengeTitle(challenge.getCreator()?.username ?? "")
            
        }
        summaryDescription.text = challenge.label
        
        if  challenge.numResponses > 0 {
            
            summaryResponseButton.isHidden = false
            summaryResponseButton.setTitle("\(challenge.numResponses)", for: .normal)
            
            
        } else {
            
            summaryResponseButton.isHidden = true
            
        }
        
        if let comments = challenge.commentDescriptor?.numMessages, comments > 0 {
            
            summaryCommentButton.isHidden = false
            summaryCommentButton.setTitle("\(comments)", for: .normal)
            
        } else {
            
            summaryCommentButton.isHidden = true
            
        }
        
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if indexPath.section == 0 {
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: R.reuseIdentifier.challengeHeaderId,
                                                          for: indexPath)!
            
            cell.labelDelegate = self
            cell.delegate = self
            guard let challenge = challenge else { return cell }
            let isSaved = services.globalModelsCoordinator.isSaved(contentType: .challenge, withId: challenge.challengeId)
            let hasResponded = services.globalModelsCoordinator.isChallengeResponded(challengeId : challenge.challengeId)
            let isLoggedInUser = services.globalModelsCoordinator.loggedInUser?.userId ?? "" == challenge.userId
            cell.configure(withChallenge: challenge, isSaved: isSaved, hasResponded: hasResponded, isMuted: mute, isLoggedInUser: isLoggedInUser)
            configureSummary(challenge: challenge)
            
            return cell
            
        }
        
        if isEmpty {
            
            let titleString = R.string.maverickStrings.challengesResponsesEmptyTitle()
            
            let subtitleString = R.string.maverickStrings.challengesResponsesEmptySubTitle()
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: R.reuseIdentifier.emptyCollectionCellId, for: indexPath)
            {
                cell.emptyView.configure(title: titleString, subtitle: subtitleString, dark: false)
                return cell
                
            }
        }
        
        if firstLoad {
          
            if  !hasReachedEnd && indexPath.row >= getMainSectionItemCount() - 1 {
                
                loadNextPage()
                
            }
            
            if let response = challenge?.responses[safe: indexPath.row], let cell = collectionView.dequeueReusableCell(withReuseIdentifier: R.reuseIdentifier.smallContentCollectionViewCellId, for: indexPath)
            {
                
                cell.delegate = self
                cell.configure(with: response)
                return cell
                
            }
       
        }
       
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: R.reuseIdentifier.pagingCollectionViewCellId,
                                                         for: indexPath) {
            
            cell.activityIndicator.startAnimating()
            return cell
            
        }
        
        
        return UICollectionViewCell()
        
    }
    
}

extension ChallengeDetailsPageViewController : StreamRefreshControllerDelegate {
    
    func refreshDataRequest() {
        
        guard let challenge = challenge else { return }
        
        services.globalModelsCoordinator.getResponses(forChallengeId: challenge.challengeId) { [weak self]  result in
            
            self?.refreshCompleted()
            
        }
        
    }
    
    func configureData() {
        guard let challenge = challenge else { return }
        
        notificationToken = challenge.observe({ [weak self] (changes) in
            
            guard self?.isVisible ?? false else { return }
            self?.sizerTitle.text = self?.challenge?.title ?? "some title"
            self?.sizerDescription.text = self?.challenge?.label ?? " "
            self?.sizerAddComment.isHidden = self?.challenge?.commentDescriptor?.numMessages ?? 0 > 0
            self?.collectionView.reloadData()
            
        })
        
        services.globalModelsCoordinator.getResponses(forChallengeId: challenge.challengeId) { result in
            
            self.firstLoad = true
        
        }
        
    }
    
    func loadNextPageRequest() {
        
       guard let challenge = challenge else { return }
        services.globalModelsCoordinator.getResponses(forChallengeId: challenge.challengeId, offset: challenge.responses.count ) { [weak self] result in
            
            self?.nextPageLoadCompleted()
            
        }
        
    }
    
    func getMainSectionItemCount() -> Int {
        
        var count = challenge?.responses.count ?? 0
        if count > 0 {
           
            count = count + (hasReachedEnd ? 0 : 1)
            isEmpty = false
            return count
            
        } else {
            
            isEmpty = true
            return 1
            
        }
        
    }
    
}

extension ChallengeDetailsPageViewController : ChallengeDetailsHeaderDelegate {
    func didTapLink(url: URL) {
        
           AnalyticsManager.Content.trackLinkPressed(.challenge, contentId: challenge?.challengeId ?? "", location: self)
        
        if let webViewController = R.storyboard.general.webViewControllerId() {
        
            webViewController.linkUrl = url
            navigationController?.pushViewController(webViewController, animated: true)
            
        }
        
    }
    
    
    func didTapEditInviteButton() {
        
        guard let challenge = challenge else { return }
        
        AnalyticsManager.Challenge.trackEditInvitePressed(challengeId: challenge.challengeId)
        
        showEditChallenge(for: challenge)
    
    }
    
    
    func didTapShowResponsesButton() {
       
        guard let challenge = challenge else { return }
        
        AnalyticsManager.Challenge.trackShowResponsesPressed(challengeId: challenge.challengeId)
        minimizeToResponses()
        
    }
    
    
    func didTapThreeDotMenuButton() {
        
     
        if let id = challenge?.challengeId {
             AnalyticsManager.Challenge.trackOverflowMenuPressed(challengeId: id)
            launchActionSheetForChallenge(contentId: id)
        }
        
    }
    
    func didTapSaveButton(isSaved : Bool) {
        
        guard let challenge = challenge else { return }
        toggleSaveChallenge(challengeId: challenge.challengeId, isSaved: isSaved)
        AnalyticsManager.Challenge.trackSavePressed(challengeId : challenge.challengeId, isSaved : isSaved)
    }
    
    func didTapMainArea() {
        
        
        guard let challenge = challenge else { return }
        AnalyticsManager.Challenge.trackMainPressed(challengeId: challenge.challengeId)
        
    }
    
    func didTapShareButton() {
        
       guard let challenge = challenge else { return }
        AnalyticsManager.Challenge.trackSharePressed(challengeId: challenge.challengeId)
        
        shareContent(ofType: .challenge, andId: challenge.challengeId)
        
    }
    
    func didTapCreatorButton() {
        
        guard let challenge = challenge else { return }
        guard let userId = challenge.getCreator()?.userId else { return }
        AnalyticsManager.Challenge.trackAuthorPressed(challengeId: challenge.challengeId, authorId: userId)
        showProfile(forUserId: userId)
        
    }
    
    func didTapShowCommentsButton() {
        
        guard let challenge = challenge else { return }
        AnalyticsManager.Challenge.trackShowCommentsPressed(challengeId: challenge.challengeId)
        showComments(forContentType : .challenge, withId : challenge.challengeId, openKeyboard: false)
        
    }
    
    func didTapCTAButton() {
        
        guard let challenge = challenge else { return }
        AnalyticsManager.Main.trackRespondToChallengePressed(challengeId: challenge.challengeId, location: self)
        launchPostFlow(forChallenge : challenge.challengeId)
        
    }
    
    func didTapMuteButton() {
        
        mute = !mute
        
    }
    
    func didTapBackButton() {
        
        AnalyticsManager.Main.trackChallengeDetailsDismmised(source: .BUTTON)
        navigationController?.popViewController(animated: true)
        
    }
    
}

extension ChallengeDetailsPageViewController : UICollectionViewDelegateFlowLayout, UICollectionViewDataSourcePrefetching {
    
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if indexPath.section == 0 {
          
            return getHeaderSize()
          
        }
        
        if isEmpty {
            
            let cellWidth = Constants.MaxContentScreenWidth
            let cellHeight = Variables.Content.emptyViewHeight.cgFloatValue()
            return CGSize(width: cellWidth,
                          height: cellHeight)
        }
        
       
        
        let width = collectionView.frame.width / 2 - gutters  * 3 / 2
        let height = width / Variables.Content.maxStreamAspectRatio.cgFloatValue() + SmallContentCollectionViewCell.lowerSectionHeight
        
        let itemCount = collectionView.numberOfItems(inSection: collectionView.numberOfSections - 1)
        
        if loadingNewPage && (itemCount - 1) == indexPath.row {
            
            if (itemCount % 2) == 0 {
                
                return CGSize(width: width, height: height)
                
            } else {
                
                return CGSize(width: width, height: height)
                
            }
            
        }
        
        return CGSize(width: width, height: height)
        
    }
    
}

extension ChallengeDetailsPageViewController : MaverickActiveLabelDelegate {
    
    func userTapped(user: User) {
        
        guard let challenge = challenge else { return }
        AnalyticsManager.Profile.trackMentionPressed(userId: user.userId, source: .contentDescription, contentType: .challenge, contentId: challenge.challengeId)
        
        guard let vc = R.storyboard.profile.profileViewControllerId() else { return }
        
        vc.services = services
        vc.userId =  user.userId
        
        navigationController?.pushViewController(vc, animated: true)
        
    }
    
    func hashtagTapped(tag: Hashtag) {
        
        guard let challenge = challenge, let name = tag.name else { return }
        AnalyticsManager.Profile.trackHashtagPressed(tagName: name, source: .contentDescription, contentType: .challenge, contentId: challenge.challengeId)
        guard let vc = R.storyboard.general.hashtagGroupViewControllerId() else { return }
        
        vc.services = services
        vc.tagName =  name
        
        navigationController?.pushViewController(vc, animated: true)
        
        
    }
    
    func linkTapped(url: URL) {
        
        UIApplication.shared.open(url, options: [:], completionHandler: { _ in
            
            
        })
        
    }
    
}


extension ChallengeDetailsPageViewController : SmallContentCollectionViewCellDelegate {
    
    func cellTapped(cell cellItem : SmallContentCollectionViewCell) {
        
      
        cellItem.imageView.isHidden = true
        selectedImage = cellItem.imageView.image
          selectedFrame = cellItem.convert(cellItem.midAndLowerSectionContainer.convert(cellItem.imageView.frame, to: cellItem), to : nil)
        
        
        selectedFrame = CGRect(origin: CGPoint(x: selectedFrame!.origin.x, y: selectedFrame!.origin.y ) , size: selectedFrame!.size)
        
        
        delegate?.transitionItemSelected(selectedImage: selectedImage, selectedFrame: selectedFrame)
        guard  let contentType = cellItem.contentType, let contentId = cellItem.contentId else { return }
        
        if contentType == .response {
            
            guard let challenge = challenge else { return }
            if let vc = R.storyboard.feed.challengeResponseStreamViewControllerId() {
                
                let index = collectionView.indexPath(for: cellItem)
                vc.services = services
                vc.configure(challengeId: challenge.challengeId, initialScrollPosition: index?.row ?? 0)
                navigationController?.pushViewController(vc, animated: true)
                AnalyticsManager.Content.trackSmallItemPressed(.response, contentId : contentId, location: self)
                
            }
            
        } else {
            
            
        }
        
    }
    
    func avatarTapped(userId : String) {
        
        showProfile(forUserId: userId)
        
    }
    
    
}


extension ChallengeDetailsPageViewController : UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        
        guard collectionView.contentOffset.y == 0 else { return false }
        
            let point = touch.location(in: view)
            if point.y < Constants.MaxContentScreenWidth * 4 / 3 {
                
                return true
                
            }
        
        return false
        
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        
        return true
        
    }
    
    /**
     Handle dragging the view closest to the touch point
     */
    @objc func handleSwipeGesture(_ gesture: UISwipeGestureRecognizer) {
        
        
        AnalyticsManager.Main.trackChallengeDetailsDismmised(source: .PULL)
            navigationController?.popViewController(animated: true)
        
        
    }
    
    private func initializeGestures() {
        
        for subView in view.subviews {
            if let scroll = subView as? UIScrollView {
                scrollViewSwipeGestureRecognzier = UISwipeGestureRecognizer(target: self,
                                                                        action: #selector(handleSwipeGesture(_:)))
                scrollViewSwipeGestureRecognzier?.direction = .down
                scrollViewSwipeGestureRecognzier?.delegate = self
                scroll.addGestureRecognizer(scrollViewSwipeGestureRecognzier!)
                
            }
        }
        
    }
    
    
}


