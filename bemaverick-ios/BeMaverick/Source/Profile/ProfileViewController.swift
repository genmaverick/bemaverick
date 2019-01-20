//
//  ProfileViewController.swift
//  BeMaverick
//
//  Created by David McGraw on 10/21/17.
//  Copyright © 2017 BeMaverick. All rights reserved.
//

import UIKit
import RealmSwift
import SCRecorder
import Toast_Swift


typealias DeleteResponseBlock = (_ response: Response) -> ()

enum ProfileFilterMode: String  {
    
    case responses      = "RESPONSES"
    case posts          = "POSTS"
    case challenges     = "CHALLENGES"
    case inspirations   = "BADGED"
    
}

enum ProfileUserMode {
    case maverick, catalyst
}

class ProfileViewController: TwoSectionStreamCollectionViewController {
    
    /// Header item view for user
    private var profileHeader : ProfileHeader!
    /// flag to determine if back button should be displayed
    private var isRootView = false
    /// bool to determine if the user is the loggedinuser
    private var isLoggedInUser = false
    /// An instance of the Camera Manager to fetch saved sessions
    fileprivate var cameraManager: CameraManager = CameraManager()
    /// Contains the draft metadata
    fileprivate var drafts: [[AnyHashable: Any]] = []
    /// user updated notification
    private var notificationToken : NotificationToken?
    /// user to display
    private var user: User!
    /// current selected filter mode
    private var filterMode : ProfileFilterMode = .responses
    /// current user  mode
    private var userMode : ProfileUserMode = .maverick
    /// available filter sets
    private var filters : [ProfileUserMode : [ProfileFilterMode]] = [
        .maverick : [.challenges, .responses, .inspirations],
        .catalyst : [.challenges, .posts, .inspirations],
        ]
    
    
    private var padding : CGFloat = 28.0
    private var gutters : CGFloat = 16.0
    
    /// Property to stop fetching next page
    private var previousChallengesCount = 0
    private var previousResponsesCount = 0
    private var previousInspirationsCount = 0
    /// Property to stop fetching next page
    private var hasReachedChallengesEnd = false
    private var hasReachedResponsesEnd = false
    private var hasReachedInspirationsEnd = false
    
    /// Property to stop fetching next page
    private var isLoadingChallenges = false
    private var isLoadingResponses = false
    private var isLoadingInspirations = false
    
    /// user id of
    var userId: String?
    
    deinit {
        
        notificationToken?.invalidate()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        if isLoggedInUser {
            
            drafts = cameraManager.getAllSavedSessions()
            collectionView.reloadData()
            
        }
        collectionView.superview?.layoutIfNeeded()
        
    }
    
    override func viewDidLayoutSubviews() {
        
        super.viewDidLayoutSubviews()
        let isFollowing = services.globalModelsCoordinator.isFollowingUser(userId: user.userId)
        profileHeader?.configure(withUser: user, hideBackButton : isRootView, userMode: userMode, isFollowing : isFollowing, isLoggedInUser: isLoggedInUser)
        profileHeader?.labelDelegate = self
        self.collectionView.layoutIfNeeded()
        
        
    }
    
    override func configureView() {
        
        super.configureView()
        
        // Track deleted drafts, completed uploads
        if isLoggedInUser {
            configureSignals()
        }
        
        title = user.username
        if isRootView {
            
            tabBarItem.title = R.string.maverickStrings.tabTitleProfile()
            
            
        } else {
            tabBarItem.title = nil
        }
        profileHeader = R.nib.profileHeader.firstView(owner: self)
        headerCellDelegate = profileHeader
        collectionView.register(R.nib.profileHeader)
        collectionView.register(R.nib.createContentCollectionViewCell)
        collectionView.register(R.nib.pagingCollectionViewCell)
        collectionView.register(R.nib.smallContentCollectionViewCell)
        collectionView.register(R.nib.profileSectionHeaderReusableView, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader)
        let lpgr : UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        lpgr.minimumPressDuration = 0.5
        lpgr.delaysTouchesBegan = true
        collectionView?.addGestureRecognizer(lpgr)
        
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        streamDelegate = self
        
    }
    
    private func showDisplayFailure() {
        
        if let vc = R.storyboard.main.errorDialogViewControllerId() {
            
            vc.delegate = self
            vc.setValues(description : "Sorry, this User has been deleted")
            vc.modalPresentationStyle = .overCurrentContext
            present(vc, animated: false, completion: nil)
            return
            
        }
        
    }
    
    @objc func handleLongPress(_ gestureRecognizer : UILongPressGestureRecognizer){
        
        if (gestureRecognizer.state != UIGestureRecognizerState.began){
            return
        }
        
        guard isLoggedInUser && (filterMode == .challenges || filterMode == .responses || filterMode == .posts) else { return }
        
        let p = gestureRecognizer.location(in: collectionView)
        
        if let indexPath = collectionView.indexPathForItem(at: p) {
            
            //address the (+) button on posts filter
            if indexPath.row == 0 && filterMode == .posts  {
                
                return
                
            }
            
            if let cell = collectionView.cellForItem(at: indexPath) as? SmallContentCollectionViewCell {
                
                switch filterMode {
                case .responses:
                    if let draftId = cell.draftId {
                        
                        launchDraftOptionsActionSheet(draftId: draftId, atIndexPath: indexPath)
                        
                    } else if let responseId = cell.contentId {
                        
                        launchMyResponseOptionsActionSheet(response: services.globalModelsCoordinator.response(forResponseId: responseId))
                        
                    }
                case .posts:
                    if let draftId = cell.draftId {
                        
                        launchDraftOptionsActionSheet(draftId: draftId, atIndexPath: indexPath)
                        
                    } else if let responseId = cell.contentId {
                        
                        launchMyResponseOptionsActionSheet(response: services.globalModelsCoordinator.response(forResponseId: responseId))
                        
                    }
                case .challenges:
                    
                    if let challengeId = cell.contentId {
                        
                        launchMyChallengeOptionsActionSheet(challenge: services.globalModelsCoordinator.challenge(forChallengeId: challengeId) )
                        
                    }
                default:
                    return
                }
                
            }
            
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        if section == 0 {
            
            return UIEdgeInsets.zero
            
        }
        
        return UIEdgeInsetsMake(gutters, gutters, gutters, gutters)
        
    }
    
    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        
        return padding
        
    }
    
    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        
        return gutters
        
    }
    
    override func getCellSize() -> CGSize {
        
        if isEmpty {
            
            let cellWidth = Constants.MaxContentScreenWidth
            let cellHeight = Variables.Content.emptyViewHeight.cgFloatValue()
            return CGSize(width: cellWidth,
                          height: cellHeight)
        }
        
        let width = collectionView.frame.width / 2 - gutters  * 3 / 2
        var height = width / Variables.Content.maxStreamAspectRatio.cgFloatValue() + SmallContentCollectionViewCell.lowerSectionHeight + SmallContentCollectionViewCell.upperSectionHeight
        
        if filterMode != .inspirations {
            
            height = height - SmallContentCollectionViewCell.lowerSectionHeight
            
        }
        return CGSize(width: width, height: height)
        
    }
    
    
    
    
    private var sectionHeader : ProfileSectionHeaderReusableView!
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        if sectionHeader == nil {
            
            if let header  = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                             withReuseIdentifier: R.reuseIdentifier.profileSectionHeaderReusableViewId, for: indexPath){
                
                let filtersToUse = filters[userMode]
                sectionHeader = header
                sectionHeader.configure(sections: filtersToUse, selected:  filterMode)
                sectionHeader.delegate = self
                return sectionHeader
                
            }
            
        }
        
        return sectionHeader
        
    }
    
    private func getEmptyText() -> (String, String) {
        
        var titleString = ""
        var subtitleString = ""
        
        switch filterMode {
            
        case .responses:
            
            if isLoggedInUser {
                
                titleString = R.string.maverickStrings.userSelfCreatedResponsesEmptyTitle()
                subtitleString = R.string.maverickStrings.userSelfCreatedResponsesEmptySubTitle()
                
            } else {
                
                titleString = R.string.maverickStrings.userOtherCreatedResponsesEmptyTitle()
                subtitleString = R.string.maverickStrings.userOtherCreatedResponsesEmptySubTitle(user.username ?? "")
                
            }
            
        case .posts:
            
            if isLoggedInUser {
                
                
            } else {
                
                titleString = R.string.maverickStrings.userOtherCreatedPostsEmptyTitle()
                subtitleString = R.string.maverickStrings.userOtherCreatedPostsEmptySubTitle(user.username ?? "")
                
            }
            
        case .challenges:
            
            titleString = R.string.maverickStrings.userOtherCreatedChallengesEmptyTitle()
            subtitleString = R.string.maverickStrings.userOtherCreatedChallengesEmptySubTitle(user.username ?? "")
            
            
            
        case .inspirations:
            
            if isLoggedInUser {
                
                titleString = R.string.maverickStrings.userSelfInsiprationsEmptyTitle()
                subtitleString = R.string.maverickStrings.userSelfInspirationsEmptySubTitle()
                
            } else {
                
                titleString = R.string.maverickStrings.userOtherCreatedResponsesEmptyTitle()
                subtitleString = R.string.maverickStrings.userOtherCreatedResponsesEmptySubTitle(user.username ?? "")
                
            }
            
        }
        
        return (titleString, subtitleString)
        
    }
    
    private func hasReachedEnd() -> Bool {
        
        switch filterMode {
            
        case .challenges:
            return hasReachedChallengesEnd
            
        case .responses:
            return hasReachedResponsesEnd
            
        case .inspirations:
            return hasReachedInspirationsEnd
            
        case .posts:
            return hasReachedResponsesEnd
            
        }
        
  
   
    }
    
    private func attemptNextPage(indexPath : IndexPath ) {
        
        if  !hasReachedEnd() && indexPath.row >= getMainSectionItemCount() - 1 {
            
            loadNextPageRequest()
            
        }
        
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if indexPath.section == 0 {
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: R.reuseIdentifier.profileHeaderId,
                                                          for: indexPath)!
            profileHeader = cell
            headerCellDelegate = cell
            cell.labelDelegate = self
            cell.delegate = self
            guard let user = user else { return cell }
            let isFollowing = services.globalModelsCoordinator.isFollowingUser(userId: user.userId)
            
            cell.configure(withUser : user, hideBackButton: isRootView, userMode: userMode, isFollowing : isFollowing, isLoggedInUser: isLoggedInUser)
            return cell
            
        }
        
        
        if isEmpty {
            
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: R.reuseIdentifier.emptyCollectionCellId, for: indexPath)
            {
                
                if filterMode == .challenges && isLoggedInUser {
                    
                    cell.emptyView.isHidden = true
                    cell.loggedInNoChallengesView.isHidden = false
                    cell.loggedInNoChallengesView.delegate = self
                    
                } else {
                    
                    cell.emptyView.isHidden = false
                    cell.loggedInNoChallengesView.isHidden = true
                    
                }
                
                let (titleString, subtitleString) = getEmptyText()
                
                cell.emptyView.configure(title: titleString, subtitle: subtitleString, dark: false)
                return cell
                
            }
            
        }
        
        attemptNextPage(indexPath: indexPath)
        
        // check for create content cell for catalysts
        if filterMode == .posts && isLoggedInUser && indexPath.row == 0 {
            
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: R.reuseIdentifier.createContentCollectionViewCellId, for: indexPath)
            {
                
                cell.delegate = self
                return cell
                
            }
            
        }
        
        if filterMode == .challenges && isLoggedInUser && indexPath.row == 0 {
            
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: R.reuseIdentifier.createContentCollectionViewCellId, for: indexPath)
            {
                
                cell.delegate = self
                cell.configureViewForCreateChallenge()
                return cell
                
            }
            
        }
        
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: R.reuseIdentifier.smallContentCollectionViewCellId, for: indexPath)
        {
            
            cell.delegate = self
            if (filterMode == .responses || filterMode == .posts) && isLoggedInUser {
                
                let modifier = userMode == .catalyst ? 1 : 0
                
                if let draft = drafts[safe: indexPath.row - modifier],
                    let draftIdentifier = draft[SCRecordSessionIdentifierKey] as? String {
                    
                    var draftChallenge : Challenge? = nil
                    if let draftChallengeId = draft["challengeId"] as? String {
                        
                        draftChallenge = services.globalModelsCoordinator.challenge(forChallengeId: draftChallengeId)
                        
                    }
                    
                    let isUploading = user.uploadingSessionIds.contains(draftIdentifier)
                    cell.configure(withDraft: draftIdentifier, andChallenge: draftChallenge, isUploading: isUploading)
                    
                    return cell
                    
                }
                
            }
            
            var isLoadingCell = false
            switch filterMode {
                
            case .responses:
                if let response = user.createdResponses[safe: indexPath.row - drafts.count] {
                    cell.configure(with: response, hideChallengeTitle: false, hideCreator: true)
                    
                } else {
                    
                    isLoadingCell = true
                    
                }
                
            case .posts:
                let offset = isLoggedInUser ? -1 : 0
                if let response = user.createdResponses[safe: indexPath.row - drafts.count + offset ] {
                    
                    cell.configure(with: response, hideChallengeTitle: false, hideCreator: true)
                
                }  else {
                    
                    isLoadingCell = true
                    
                }
                
            case .challenges:
                
                if let challenge = user.getCreatedChallenges()[safe: indexPath.row - (isLoggedInUser ? 1 : 0)] {
                    
                    let hasResponded = services.globalModelsCoordinator.isChallengeResponded(challengeId : challenge.challengeId)
                    cell.configure(with: challenge, isComplete: hasResponded, hideCreator : true)
                    
                }  else {
                    
                    isLoadingCell = true
                    
                }
                
            case .inspirations:
                if let response = user.getUnownedBadgedResponses()[safe: indexPath.row] {
                    
                    let badged = services.globalModelsCoordinator.getSelectedBadge(userId: user.userId, responseId: response.responseId)
                    cell.configure(with: response, hideChallengeTitle: false, hideCreator: false, badgeGiven: badged)
                    
                }  else {
                    
                    isLoadingCell = true
                    
                }
                
            }
            
            if !isLoadingCell {
                
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
    
    /**
     Provide the user with options associated with a draft.
     */
    private func launchDraftOptionsActionSheet(draftId: String, atIndexPath path: IndexPath) {
        
        let deleteAction = { [unowned self] in
            
            var draftChallengeId = ""
            if let draft = self.drafts[safe: path.row] {
                
                draftChallengeId = draft["challengeId"] as? String ?? ""
                
            }
            CameraManager.removeSavedData(forSessionId: draftId)
            
            if let session = MaverickComposition.processingSession[draftId]  {
                
                session.cancelExport()
                MaverickComposition.processingState[draftId] = .cancelled
                MaverickComposition.processingSession[draftId] = nil
                
            }
            
            self.drafts = self.cameraManager.getAllSavedSessions()
            
            if self.drafts.count > 0 {
                
                self.collectionView.performBatchUpdates({
                    
                    self.collectionView.deleteItems(at: [path])
                    
                }, completion: nil)
                
            } else {
                
                self.collectionView.reloadData()
                
            }
            
            AnalyticsManager.Profile.trackDeleteDraftPressed(challengeId: draftChallengeId)
            
            if let tabBar = UIApplication.shared.keyWindow?.rootViewController as? MainTabBarViewController {
                tabBar.view.makeToast("Deleted")
            }
            
        }
        
        let actionSheetItem = DeleteDraftCustomActionSheetItem(deleteAction: deleteAction)
        
        let maverickActionSheetViewModel = MaverickActionSheetViewModel(title: R.string.maverickStrings.profileDraftResponsesActionSheetTitle(), maverickActionSheetItems: [actionSheetItem], alignment: .leading)
        let maverickActionSheetViewController = MaverickActionSheetVC(viewModel: maverickActionSheetViewModel)
        
        let maverickActionSheetTransitioningDelegate = MaverickActionSheetTransitioningDelegate()
        maverickActionSheetViewController.transitioningDelegate = maverickActionSheetTransitioningDelegate
        transitioningDelegate = maverickActionSheetTransitioningDelegate
        
        present(maverickActionSheetViewController, animated: true, completion: nil)
        return
        
    }
    
    /**
     Provide the user with options associated with a response.
     */
    private func launchMyResponseOptionsActionSheet(response: Response) {
        
        let deleteAction = {
            
            self.services.globalModelsCoordinator.deleteResponse(forResponse: response)
            
            if let tabBar = UIApplication.shared.keyWindow?.rootViewController as? MainTabBarViewController {
                tabBar.view.makeToast("Deleted")
            }
            
        }
        
        let actionSheetItem = ShareDeleteCustomActionSheetItem(response: response, services: services, deleteAction: deleteAction)
        
        let maverickActionSheetViewModel = MaverickActionSheetViewModel(title: R.string.maverickStrings.profileResponsesActionSheetTitle(), maverickActionSheetItems: [actionSheetItem], alignment: .leading)
        let maverickActionSheetViewController = MaverickActionSheetVC(viewModel: maverickActionSheetViewModel)
        
        let maverickActionSheetTransitioningDelegate = MaverickActionSheetTransitioningDelegate()
        maverickActionSheetViewController.transitioningDelegate = maverickActionSheetTransitioningDelegate
        transitioningDelegate = maverickActionSheetTransitioningDelegate
        
        present(maverickActionSheetViewController, animated: true, completion: nil)
        return
        
    }
    
    /**
     Provide the user with options associated with a challenge.
     */
    private func launchMyChallengeOptionsActionSheet(challenge: Challenge) {
        
        let deleteAction = {
            
            self.services.globalModelsCoordinator.deleteChallenge(forChallenge: challenge)
            
            if let tabBar = UIApplication.shared.keyWindow?.rootViewController as? MainTabBarViewController {
                tabBar.view.makeToast("Deleted")
            }
            
            return
            
        }
        
        let editAction = {
            
            if let vc = R.storyboard.userGeneratedChallenge.editChallengeNavControllerId() {
                
                if let editVC = vc.childViewControllers.first as? EditChallengeViewController {
                    
                    editVC.services = self.services
                    editVC.challenge = challenge
                }
                vc.modalPresentationStyle = .fullScreen
                self.present(vc, animated: false, completion: nil)
                
            }
            return
            
        }
        
        let actionSheetItem = ShareDeleteEditCustomActionSheetItem(challenge: challenge, services: services, deleteAction: deleteAction, editAction: editAction)
        
        let maverickActionSheetViewModel = MaverickActionSheetViewModel(title: R.string.maverickStrings.profileChallengesActionSheetTitle(), maverickActionSheetItems: [actionSheetItem], alignment: .leading)
        let maverickActionSheetViewController = MaverickActionSheetVC(viewModel: maverickActionSheetViewModel)
        
        let maverickActionSheetTransitioningDelegate = MaverickActionSheetTransitioningDelegate()
        maverickActionSheetViewController.transitioningDelegate = maverickActionSheetTransitioningDelegate
        transitioningDelegate = maverickActionSheetTransitioningDelegate
        
        present(maverickActionSheetViewController, animated: true, completion: nil)
        return
        
    }
    
    /**
     Provide the user with option associated with blocking another user.
     */
    private func launchBlockUserActionSheet() {
        
        let blockUserAction = { [unowned self] in
            
            self.services.globalModelsCoordinator.blockUser(withId: self.user.userId, isBlocked : true)
            self.navigationController?.view.makeToast("Blocked")
            self.didTapBackButton()
            
        }
        
        let actionSheetItem = BlockUserCustomActionSheetItem(blockUserAction: blockUserAction, blockUserText: "Block \(user.username ?? "user")")
        
        let maverickActionSheetViewModel = MaverickActionSheetViewModel(title: R.string.maverickStrings.profileHeaderActionSheetTitle(), maverickActionSheetItems: [actionSheetItem], alignment: .leading)
        let maverickActionSheetViewController = MaverickActionSheetVC(viewModel: maverickActionSheetViewModel)
        
        let maverickActionSheetTransitioningDelegate = MaverickActionSheetTransitioningDelegate()
        maverickActionSheetViewController.transitioningDelegate = maverickActionSheetTransitioningDelegate
        transitioningDelegate = maverickActionSheetTransitioningDelegate
        
        present(maverickActionSheetViewController, animated: true, completion: nil)
        return
        
    }
    
    /**
     Monitor when uploads have been completed and drafts have potentially changed
     */
    func configureSignals() {
        
        services.globalModelsCoordinator.onResponsesUploadCompletedSignal.subscribe(with: self) { error, _, _, _ in
            
            log.verbose("🔔 Received video uploaded signal - \(error ?? "")")
            
            if self.isLoggedInUser {
                
                self.drafts = self.cameraManager.getAllSavedSessions()
                self.collectionView.reloadData()
                
            }
            
        }
        
    }
    
}

extension ProfileViewController : StreamRefreshControllerDelegate {
    
    func refreshDataRequest() {
        
    }
    
    func configureData() {
        
        if services == nil {
            isRootView = true
            hasNavBar = true
            allowsHiddingNavBar = false
            showNavBar()
            services = (UIApplication.shared.delegate as! AppDelegate).services
        }
        
        let loggedInUserId = services.globalModelsCoordinator.loggedInUser?.userId
        
        if userId == nil {
            
            userId = loggedInUserId
            
        }
        
        guard let userId = userId else { return }
        
        
        
        user = services.globalModelsCoordinator.getUser(withId: userId)
        
        isLoggedInUser = user.userId == loggedInUserId
        
        
        if isLoggedInUser {
            
            services.globalModelsCoordinator.reloadLoggedInUser() { }
            drafts = cameraManager.getAllSavedSessions()
            
        } else {
            
            services.globalModelsCoordinator.getUserDetails(forUserId: userId) { }
            
        }
        
        if user.userType == .maverick {
            
            userMode = .maverick
            filterMode = .challenges
            
        } else {
            
            userMode = .catalyst
            filterMode = .challenges
            
        }
        
        getInspirations(initial: true)
        getResponses(initial: true)
        getChallenges(initial: true)
        
        notificationToken = user.observe({ [weak self] (changes) in
            
            guard let user = self?.user, user.isActive() else {
                
                self?.showDisplayFailure()
                self?.profileHeader.clear()
                return
                
            }
            
            // I hate that reload data is here twice, but the problem is the section header (tabs) is in the wrong place after editing the description and coming back
            guard let weakSelf = self else { return }
            if weakSelf.isLoggedInUser {
                
                weakSelf.drafts = weakSelf.cameraManager.getAllSavedSessions()
                
            }
            
            weakSelf.collectionView.reloadData()
            weakSelf.collectionView.reloadData()
            
        })
        
    }
    
    private func getChallenges(initial: Bool) {
        
        guard let userId = userId, !isLoadingChallenges else { return }
        
        isLoadingChallenges = true
        previousChallengesCount = initial ? 0 : user.createdChallenges.count
       
//        print("👯‍♀️ loading challenges \(initial) : \(previousChallengesCount)")
        services.globalModelsCoordinator.getUserCreatedChallenges(forUserID: userId, offset: initial ? 0 : user.createdChallenges.count){ [weak self] in
            
            self?.isLoadingChallenges = false
            
            self?.hasReachedChallengesEnd = self?.previousChallengesCount ?? 0 >= (self?.user.createdChallenges.count ?? 0)
            
//            print("👯‍♀️ finished challenges hasReachedChallengesEnd: \(self?.hasReachedChallengesEnd) : \(self?.user.createdChallenges.count ?? 0)")
            
            self?.collectionView.reloadData()
            
        }
        
    }
    
    private func getResponses(initial: Bool) {
        
        guard let userId = userId, !isLoadingResponses else { return }
        isLoadingResponses = true
        previousResponsesCount = initial ? 0 : user.createdResponses.count
        services.globalModelsCoordinator.getUserCreatedResponses(forUserID: userId, offset: initial ? 0 : user.createdResponses.count) { [weak self] in
            
            self?.isLoadingResponses = false
            
            self?.hasReachedResponsesEnd = self?.previousResponsesCount ?? 0 >= (self?.user.createdResponses.count ?? 0)
            
            self?.collectionView.reloadData()
            
        }
        
    }
    
    private func getInspirations(initial: Bool) {
        
        guard !isLoadingInspirations else { return }
        isLoadingInspirations = true
        previousInspirationsCount = initial ? 0 :  user.badgedResponses.count
        services.globalModelsCoordinator.getUserBadgedResponses(forUserId: userId, offset: initial ? 0 : user.badgedResponses.count){ [weak self] in
            
            self?.isLoadingInspirations = false
            
            self?.hasReachedInspirationsEnd = self?.previousInspirationsCount ?? 0 >= (self?.user.badgedResponses.count ?? 0)
            
            self?.collectionView.reloadData()
            
        }
        
    }
    
    private func isLoadingData() -> Bool {
        
        switch filterMode {
            
        case .challenges:
            return isLoadingChallenges
            
        case .responses:
            return isLoadingResponses
            
        case .inspirations:
            return isLoadingInspirations
            
        case .posts:
            return isLoadingResponses
            
        }
        
    }
    
    
    func loadNextPageRequest() {
        
        switch filterMode {
            
        case .challenges:
            getChallenges(initial: false)
            
        case .responses:
            getResponses(initial: false)
            
        case .inspirations:
            getInspirations(initial: false)
            
        case .posts:
            getResponses(initial: false)
            
        }
        
    }
    
    func getMainSectionItemCount() -> Int {
        
        var count = 0
        switch filterMode {
            
        case .responses:
            
            let responses = user.createdResponses
            if isLoggedInUser {
                
                count = drafts.count + responses.count
                break
                
            }
            
            count = responses.count
            
        case .inspirations:
            
            count = user.getUnownedBadgedResponses().count
            
        case .challenges:
            
            count = user.getCreatedChallenges().count
            
            if isLoggedInUser {
                
                if count > 0 {
                    count += 1
                }
                
            }
            
        case .posts:
            
            let responses = user.createdResponses
            
            if isLoggedInUser {
                
                count = drafts.count + responses.count + 1
                break
                
            }
            
            count = user.createdResponses.count
            
        }
        
        if count == 0 && !isLoadingData(){
            
            isEmpty = true
            return 1
           
            
        } else {
            
            isEmpty = false
            
            count = count + (hasReachedEnd() ? 0 : 1)
//            print("👯‍♀️ getItemCount: \(count) \(isLoadingData())")
            
            return count
           
            
        }
        
    }
    
}



extension ProfileViewController : ProfileSectionHeaderDelegate {
    
    func segmentChanged(index : Int) {
        
        AnalyticsManager.Profile.trackTabPressed(index: index)
        
        guard var items = filters[userMode] else { return }
        
        filterMode = items[index]
        
        UIView.performWithoutAnimation {
            
            collectionView.reloadSections([1])
            
        }
        
    }
    
}


extension ProfileViewController : ProfileHeaderDelegate {
    
    func didTapQRButton() {
        
        AnalyticsManager.Profile.trackQRPressed()
        if let vc = R.storyboard.inviteFriends.qrViewControllerId() {
            
            vc.services = services
            vc.source = .profile
            vc.modalPresentationStyle = .fullScreen
            present(vc, animated: true, completion: nil)
            return
            
        }
        
    }
    
    func didTapOverflowButton() {
        
        AnalyticsManager.Profile.trackOverflowPressed()
        launchBlockUserActionSheet()
        
    }
    
    func didTapFollowButton(isFollowing: Bool) {
        
        AnalyticsManager.Profile.trackFollowTapped(userId: user.userId, isFollowing: isFollowing, location: self)
        services.globalModelsCoordinator.toggleUserFollow(follow: isFollowing, withId: user.userId) {
            
        }
        
    }
    
    func didTapBadgeButton(badge: MBadge) {
        
        AnalyticsManager.Profile.trackBadgePressed(userId: user.userId, badge: badge)
        
    }
    
    func didTapSettingsButton() {
        
        AnalyticsManager.Profile.trackSettingsPressed()
        if let vc = R.storyboard.settings.profileSettingsId(){
            vc.services = services
            navigationController?.pushViewController(vc, animated: true)
            
        }
        
    }
    
    func didTapShareButton() {
        
        AnalyticsManager.Profile.trackSharePressed()
        shareUser(withId : user.userId)
    }
    
    
    func didTapBackButton() {
        
        navigationController?.popViewController(animated: true)
        
    }
    
    func didTapEditProfile() {
        
        if let vc = R.storyboard.settings.profileEditProfileViewControllerId() {
            vc.services = services
            
            navigationController?.pushViewController(vc, animated: true)
        }
        
    }
    
    func didTapFollowerButton() {
        
        AnalyticsManager.Profile.trackFollowersPressed(userId: user.userId)
        
        if let vc = R.storyboard.profile.usersStoryboardId() {
            vc.configure(withUser: user, followType: .followers)
            vc.services = services
            navigationController?.pushViewController(vc, animated: true)
            
        }
        
    }
    
    func didTapFollowingButton() {
        
        AnalyticsManager.Profile.trackFollowingPressed(userId: user.userId)
        if let vc = R.storyboard.profile.usersStoryboardId() {
            vc.configure(withUser: user, followType: .following)
            vc.services = services
            navigationController?.pushViewController(vc, animated: true)
            
        }
        
    }
    
}


extension ProfileViewController : MaverickActiveLabelDelegate {
    
    func userTapped(user: User) {
        
        AnalyticsManager.Profile.trackMentionPressed(userId: user.userId, source: .bio)
        guard let vc = R.storyboard.profile.profileViewControllerId() else { return }
        
        vc.services = services
        vc.userId =  user.userId
        
        
        navigationController?.pushViewController(vc, animated: true)
        
    }
    
    func hashtagTapped(tag: Hashtag) {
        
        guard let name = tag.name else { return }
        AnalyticsManager.Profile.trackHashtagPressed(tagName: name, source: .bio)
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

extension ProfileViewController : LoggedInNoChallengesViewDelegate {
    
    func ctaTapped() {
        
        AnalyticsManager.CreateChallenge.trackCreateCTA(location: .profile)
        CreateChallengeViewController.attemptToCreateChallenge(services: services, viewController: self)
        
    }
    
}

extension ProfileViewController : SmallContentCollectionViewCellDelegate {
    
    func avatarTapped(userId: String) {
        
        showProfile(forUserId: userId)
    
    }
    
    
    func cellTapped(cell: SmallContentCollectionViewCell) {
        
        if let contentType = cell.contentType, let contentId = cell.contentId {
        
            AnalyticsManager.Content.trackSmallItemPressed(contentType, contentId: contentId, location: self)
        
        }
       
        //Transition Section
        selectedImage = cell.imageView.image
        if let _ = cell as? CreateContentCollectionViewCell {
            
        } else {
        
            selectedFrame = cell.convert(cell.midAndLowerSectionContainer.convert(cell.imageView.frame, to: cell), to : nil)
            selectedFrame = CGRect(origin: CGPoint(x: selectedFrame!.origin.x, y: selectedFrame!.origin.y  ) , size: selectedFrame!.size)
        
        }
        
      
        
        switch filterMode {
            
        case .responses:
            
            if isLoggedInUser, let indexPath = collectionView.indexPath(for: cell), let draft = drafts[safe: indexPath.row] {
                
                if let draftId = draft[SCRecordSessionIdentifierKey] as? String {
                    
                    let (state, _) = MaverickComposition.getProgress(sessionId : draftId)
                    if state == .processing {
                        
                        return
                        
                    }
                    
                }
                
                guard
                    let challengeId = draft["challengeId"] as? String,
                    let challengeTitle = draft["challengeTitle"] as? String,
                    let vc = R.storyboard.post.instantiateInitialViewController(),
                    let draftIdentifier = draft[SCRecordSessionIdentifierKey] as? String,
                    !user.uploadingSessionIds.contains(draftIdentifier),
                    let postVC = vc.viewControllers.first as? PostRecordViewController else {
                        return
                }
                
                postVC.services = services
                postVC.challengeTitle = challengeTitle
                postVC.challengeId = challengeId
                postVC.restoreSessionMetadata = draft
                
                navigationController?.present(vc, animated: true, completion: nil)
                return
                
            }
            
            if let vc = R.storyboard.feed.userResponseStreamViewControllerId() {
                
                vc.services = services
                let indexToScrollTo = (collectionView.indexPath(for: cell)?.row ?? 0) - drafts.count
                vc.configure(userId: user.userId, initialScrollPosition: indexToScrollTo)
                navigationController?.pushViewController(vc, animated: true)
                
            }
            
        case .posts:
            
            if isLoggedInUser, let indexPath = collectionView.indexPath(for: cell) {
                
                if indexPath.row == 0 {
                    
                    guard let vc = R.storyboard.post.instantiateInitialViewController(),
                        let postVC = vc.viewControllers.first as? PostRecordViewController else { return }
                    
                    postVC.services = services
                    postVC.challengeTitle = "Create a New Post"
                    
                    navigationController?.present(vc, animated: true, completion: nil)
                    return
                }
                if let draft = drafts[safe: indexPath.row - 1] {
                    
                    guard
                        let draftIdentifier = draft[SCRecordSessionIdentifierKey] as? String,
                        !user.uploadingSessionIds.contains(draftIdentifier),
                        let vc = R.storyboard.post.instantiateInitialViewController(),
                        let postVC = vc.viewControllers.first as? PostRecordViewController else {
                            return
                    }
                    let challengeId = draft["challengeId"] as? String
                    let challengeTitle = draft["challengeTitle"] as? String
                    postVC.services = services
                    postVC.challengeTitle = challengeTitle ?? ""
                    postVC.challengeId = challengeId
                    postVC.restoreSessionMetadata = draft
                    
                    navigationController?.present(vc, animated: true, completion: nil)
                    return
                    
                }
                
                if let vc = R.storyboard.feed.userResponseStreamViewControllerId() {
                    
                    vc.services = services
                    let indexToScrollTo = (collectionView.indexPath(for: cell)?.row ?? 0) - drafts.count - 1
                    vc.configure(userId: user.userId, initialScrollPosition: indexToScrollTo)
                    navigationController?.pushViewController(vc, animated: true)
                    return
                    
                }
                
            }
            
            if let vc = R.storyboard.feed.userResponseStreamViewControllerId() {
                
                vc.services = services
                let indexToScrollTo = (collectionView.indexPath(for: cell)?.row ?? 0) - drafts.count
                vc.configure(userId: user.userId, initialScrollPosition: indexToScrollTo)
                navigationController?.pushViewController(vc, animated: true)
                
            }
            
        case .challenges:
            
            if isLoggedInUser && collectionView.indexPath(for: cell)?.row == 0 {
                
                AnalyticsManager.CreateChallenge.trackCreateCTA(location: .profile)
                CreateChallengeViewController.attemptToCreateChallenge(services: services, viewController: self)
                return
                
            }
            
            guard let challengeId = cell.contentId else { return }
            showChallengeDetails(forChallenge: challengeId, challenges: Array(user.createdChallenges))
            
        case .inspirations:
            
            if let vc = R.storyboard.feed.userInspirationStreamViewControllerId() {
                vc.services = services
                vc.configure(userId: user.userId, initialScrollPosition: collectionView.indexPath(for: cell)?.row ?? 0)
                navigationController?.pushViewController(vc, animated: true)
            }
            
        }
        
    }
    
}
