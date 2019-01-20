//
//  StreamTableViewController.swift
//  BeMaverick
//
//  Created by David McGraw on 1/11/18.
//  Copyright © 2018 BeMaverick. All rights reserved.
//

import UIKit
import RealmSwift
import AVKit


/**
 Displays a feed content in an autosizing tableview
 */
class StreamTableViewController : StreamRefreshController {
    
    /// Main Table View object
    @IBOutlet weak var tableView: UITableView?
    private var isInitialized = false
    var initialOffset : CGPoint?
    
    var initialScrollPosition : Int = 0
    /// Whether the view has scrolled to the default scroll position
    var hasScrolledToInitialRow: Bool = false
    
    // MARK: - Lifecycle
    
    override func viewWillDisappear(_ animated: Bool) {
        
        super.viewWillDisappear(animated)
        
        autoStop()
    
    }
    
    override func viewDidLayoutSubviews() {
        
        super.viewDidLayoutSubviews()
        if !isInitialized {
           
            tableView?.reloadData()
            isInitialized = true
       
        }
         checkInitialScrollPosition()
  
    }
    
    /**
     Attempt to scroll to the provided position if a cell at `defaultScrollRow`
     exists and is greater than 0
     */
    func checkInitialScrollPosition() {
        
        guard let tableView = tableView else { return }
        /// On load scroll to the default scroll position if it's been set
        if !hasScrolledToInitialRow && initialScrollPosition != 0  && tableView.numberOfRows(inSection: 0) > 0 {
            
            hasScrolledToInitialRow = true
            if initialScrollPosition < tableView.numberOfRows(inSection: 0) {
                
                tableView.scrollToRow(at: IndexPath(row: initialScrollPosition, section: 0),
                                      at: .top,
                                      animated: false)
                longAutoplay()
                
            }
            
        }
        
    }
    
    override func scrollToTop() {
        
        tableView?.scrollToTop(animated: true)
        
    }
    /**
     Called on view did load, initialize views
     */
    override func configureView() {
        
        guard let tableView = tableView else { return }
        tableView.backgroundColor = UIColor.MaverickBackgroundColor
        tableView.showsVerticalScrollIndicator = false
        tableView.showsHorizontalScrollIndicator = false
        tableView.allowsSelection = false
        tableView.register(R.nib.horizontalUserListTableViewCell)
        tableView.register(R.nib.contentTableViewCell)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorColor = .clear
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(refresh(_:)), for: .valueChanged)
        tableView.refreshControl = refreshControl
        view.backgroundColor = UIColor.MaverickBackgroundColor
        ContentTableViewCell.loggedInUserAvatarURL = services.globalModelsCoordinator.loggedInUser?.profileImage
        ContentTableViewCell.loggedInUserId = services.globalModelsCoordinator.loggedInUser?.userId ?? ""
    
    }
    
    /**
     Notify cells that scrolling has occured
     */
    override func notifyScroll() {
        
        guard let tableView = tableView else { return }
        
        for cell in tableView.visibleCells {
            
            if let contentCell = cell as? ContentTableViewCell{
                
                contentCell.dismissBadger()
                
            }
            
        }
        
    }
    
    /**
     Attempt to play videos when scrolling ends
     */
    override func scrollStopped() {
        
        autoPlay()
        
    }
    
    override func getTransitionAlphaView() -> [UIView] {
       
        guard let tableView = tableView else { return [] }
        return [tableView]
        
    }

    override func transitionCompleted() {
        
        super.transitionCompleted()
        guard isInitialized else { return }
       
        if initialOffset == nil {
        
            initialOffset = tableView?.contentOffset ?? .zero
        
        }
        
    }
    
    
    override func getTransitionFrame() -> CGRect? {
        
        let origin = view.frame.origin
        let xOrigin = UIScreen.main.bounds.width / 2 - Constants.MaxContentScreenWidth / 2
        let navBarSpacing = navigationController?.navigationBar.frame.height ?? 0
        let statusHeight : CGFloat = 20.0
        let frameWidth = Constants.MaxContentScreenWidth
        let contentHeaderHeight : CGFloat = 56.0
        let frameHeight = frameWidth * 4 / 3
        
        let offset = initialOffset ?? .zero
        let newOffsetY = offset.y - (tableView?.contentOffset.y ?? 0.0)
        
        if -newOffsetY > frameHeight {
          
            return .zero
        
        }
        
        let rect = CGRect(origin: CGPoint(x: xOrigin, y: origin.y + navBarSpacing + statusHeight + contentHeaderHeight + newOffsetY), size: CGSize(width: frameWidth, height: frameHeight))
        return rect
        
    }
    
    /**
     Attempt to play video after a new refresh
     */
    override func refreshCompleted() {
        
        super.refreshCompleted()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            
            self.longAutoplay()
            
        }
        
    }
    
    private func longAutoplay() {
        
        self.autoPlay()
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.25, execute: {
            
            self.autoPlay()
            
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.75, execute: {
               
                self.autoPlay()
            
            })
            
        })
        
    }
    
    /**
     Autoplay the largest cell in view
     */
    func autoPlay() {
        
        // only autoplay if viewcontroller is visisble
        guard viewIfLoaded?.window != nil && isVisible else { return }
            
        if blockAutoplayDueToRefresh {
            
            blockAutoplayDueToRefresh = false
            return
            
        }
        var cellToPlay : ContentTableViewCell?
        var foundWinner = false
        var winningPercent: CGFloat = 0.0
        guard let tableView = tableView else { return }
        
        for cell in tableView.visibleCells {
            
            if let contentCell = cell as? ContentTableViewCell, let indexPath = tableView.indexPath(for: cell) {
                
                let rect = tableView.rectForRow(at: indexPath)
                let intersect = rect.intersection(tableView.bounds)
                //  curerntHeight is the height of the cell that is visible
                let onScreenHeight = intersect.height
                if onScreenHeight > winningPercent {
                    
                    let _ = cellToPlay?.stopPlayback()
                    winningPercent = onScreenHeight
                    cellToPlay = contentCell
                    foundWinner = true
                    
                } else {
                    
                    let _ = contentCell.stopPlayback()
                
                }
                
            }
            
        }
        
        if foundWinner, let cellToPlay = cellToPlay {
            
            
            cellToPlay.attemptAutoplay()
            
        }
        
    }
    
    
    
    /**
     Stop playing video on all cells
     */
    func autoStop() {
        guard let tableView = tableView else { return }
        
        for cell in tableView.visibleCells {
            
            if let contentCell = cell as? ContentTableViewCell{
                
                 contentCell.stopPlayback()
                
            }
            
        }
        
    }
    
}

// MARK: - Extensions - UITableViewDelegate, UIScrollViewDelegate


extension StreamTableViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return UIScreen.main.bounds.height
        
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if let contentcell = cell as? ContentTableViewCell {
            
            contentcell.labelDelegate = self
        
        }
    
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if let contentCell = cell as? ContentTableViewCell {
            
           contentCell.stopPlayback()
            
        }
  
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let itemCount = tableView.numberOfRows(inSection: tableView.numberOfSections - 1)
        if  !hasReachedEnd && indexPath.row >= itemCount - 1 {
            
            loadNextPage()
            
        }
        
        return UITableViewCell()
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return streamDelegate?.getMainSectionItemCount() ?? 0
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return UITableViewAutomaticDimension
        
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        
        return 0.0
        
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        return UIView(frame: CGRect.zero)
        
    }
    
}

// MARK: - Extensions - ContentTableViewCellDelegate

extension StreamTableViewController : AdvancedContentDelegate {
    
    func didTapLink(link: URL?, forContentType contentType: Constants.ContentType, withId id: String, contentStyle: Constants.Analytics.Main.Properties.CONTENT_STYLE) {
        
        guard let url = link else { return }
        AnalyticsManager.Content.trackLinkPressed(contentType, contentId: id, location: self)
        if let webViewController = R.storyboard.general.webViewControllerId() {
            
            webViewController.linkUrl = url
            navigationController?.pushViewController(webViewController, animated: true)
            
        }
        
    }
    
    
    func didTapInviteChallengeButton(forChallenge challengeId: String, contentStyle: Constants.Analytics.Main.Properties.CONTENT_STYLE) {
        
        let challenge = services.globalModelsCoordinator.challenge(forChallengeId: challengeId)
        showEditChallenge(for: challenge)
        
    }
    
    func didTapFavoriteResponseButton(forContentType contentType: Constants.ContentType, withId id: String, contentStyle: Constants.Analytics.Main.Properties.CONTENT_STYLE, isFavorited: Bool) {
        
        AnalyticsManager.Content.trackFavoriteResponsePressed(contentType, contentId: id, location: self, contentStyle: contentStyle, isFavorite:  isFavorited)
        
        self.services.globalModelsCoordinator.catalystFavoriteResponse(withId: id, isFavorite: isFavorited)
        
    }
    
    
    func didTapBackButton() {
        
        navigationController?.popViewController(animated: true)
   
    }
    
    func didTapAddCommentButton(forContentType contentType: Constants.ContentType, withId id: String, cell: UITableViewCell, contentStyle : Constants.Analytics.Main.Properties.CONTENT_STYLE) {
        
        AnalyticsManager.Content.trackAddCommentPressed(contentType, contentId: id, location: self, contentStyle: contentStyle)
        // Show Input
        showComments(forContentType : contentType, withId : id, openKeyboard: true)
        
    }
    
    func didTapShowCommentButton(forContentType contentType: Constants.ContentType, withId id: String, contentStyle : Constants.Analytics.Main.Properties.CONTENT_STYLE) {
        
        AnalyticsManager.Content.trackShowCommentsPressed(contentType, contentId: id, location: self, contentStyle: contentStyle)
        
        showComments(forContentType : contentType, withId : id, openKeyboard: false)
        
    }
    
    func didTapShowBadgesButton(forContentType contentType: Constants.ContentType, withId id: String, contentStyle : Constants.Analytics.Main.Properties.CONTENT_STYLE) {
        
        AnalyticsManager.Content.trackResponseBadgeBagPressed(contentId: id, location: self, contentStyle: contentStyle)
        
        
        showBadgeBag(forResponseId : id)
        
    }
    
    func didTapOverflowButton(forContentType contentType: Constants.ContentType, withId id: String, contentStyle : Constants.Analytics.Main.Properties.CONTENT_STYLE) {
        
        launchActionSheet(contentId : id, contentType: contentType)
        
    }
    
    func didTapThreeDotButton(forContentType contentType: Constants.ContentType, withId id: String, contentStyle : Constants.Analytics.Main.Properties.CONTENT_STYLE) {
        
        launchActionSheetForChallenge(contentId: id)
        
    }
    
}


extension StreamTableViewController : MaverickActiveLabelDelegate {
    
    func userTapped(user: User) {
        
        AnalyticsManager.Profile.trackMentionPressed(userId: user.userId, source: .contentDescription)
        
        showProfile(forUserId: user.userId)
        
       
        
    }
    
    func hashtagTapped(tag: Hashtag) {
        
        
        guard let name = tag.name else { return }
        AnalyticsManager.Profile.trackHashtagPressed(tagName: name, source: .contentDescription)
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
