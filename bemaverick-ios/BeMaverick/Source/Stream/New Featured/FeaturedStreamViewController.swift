//
//  FeaturedStreamViewController.swift
//  BeMaverick
//
//  Created by David McGraw on 1/15/18.
//  Copyright © 2018 BeMaverick. All rights reserved.
//

import UIKit
import RealmSwift
import Kingfisher


/**
 `Featured` displays a feed of curated challenges and responses
 */
class FeaturedStreamViewController: StreamRefreshController {
    
    @IBOutlet weak var tableView: UITableView!
    static var hasBadgedThisSession = false
    static var hasTappedPostResponseSession = false
    
    
    private var featuredRows : [FeaturedRowBase] = []
    private var maverickFeed : MaverickFeed?
    private var notificationToken : NotificationToken?
    private var didInteract = false
    private var maxRowSeen = 0
    private var isScrolling = false
    private var hasShownResponseCoachMark = false
    private var hasShownChallengeCoachMark = false
    private var winningRow = -1
    private var winningColumn = -1
    private var featuredRowTitleHeight : CGFloat = 26.0 // title area height for each row
    private var authorHeaderHeight : CGFloat = 56 // height of top section on large content items
    
    private var gridSpacing : CGFloat = 14.0  // spacing for items when we have a challenge responses grid display
    private var halfCTAHeight : CGFloat = 30.0 // half the size of the circular CTA at the bottom of the large content item
    private var tableRowBottomPadding : CGFloat = 20.0 // this value separates the rows vertically by adding content inset on the bottom of the collection view matching the addition in tablerow height
    
    private var tableRowItemDividerHeight : CGFloat = 10.0 // this is the white band spearating items
    private var forceRefresh = false
    
    deinit {
        
        notificationToken?.invalidate()
        
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        super.viewWillDisappear(animated)
        autoStop()
        
        if didInteract {
            
            var rowInfo : [Int : Int] = [ : ]
            for i in 0 ..< featuredRows.count {
                
                let featuredRow = featuredRows[i]
                if featuredRow.maxItem > 0 {
                    
                    rowInfo[i] = featuredRow.maxItem
                    featuredRow.maxItem = 0
                    
                }
                
            }
            
            AnalyticsManager.Content.trackFeaturedPageHorizontalScrollPosition( rowPositions : rowInfo)
            AnalyticsManager.Content.trackFeaturedPageVerticalScrollPosition(maxRow: maxRowSeen)
            didInteract = false
            
            maxRowSeen = 0
            
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        tableView.superview?.layoutIfNeeded()
        longAutoplay()
        
        if DBManager.sharedInstance.shouldSeeTutorial(tutorialVersion : .featured) {
            
            if let vc = R.storyboard.main.tutorialViewControllerId() {
                
                vc.configureFor(tutorialVersion: .featured)
                vc.modalPresentationStyle = .overFullScreen
                present(vc, animated: false, completion: nil)
                
            }
            
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
    private var startTime : Date?
    override func viewDidLoad() {
        
        startTime = Date()
        
        hasNavBar = true
        streamDelegate = self
        super.viewDidLoad()
        services = (UIApplication.shared.delegate as! AppDelegate).services
        tableView.register(R.nib.emptyTableViewCell)
        tableView.register(R.nib.featuredRowTableViewCell)
        tableView.register(R.nib.maverickAdvertisementTableViewCell)
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(refresh(_:)), for: .valueChanged)
        tableView.refreshControl = refreshControl
        
        view.backgroundColor = .white
        tableView.showsHorizontalScrollIndicator = false
        tableView.showsVerticalScrollIndicator = false
        tableView.allowsSelection = false
        tableView.separatorColor = .clear
        
        
    }
    
    override func addBadge(responseId id: String, badgeId: String, remove: Bool, cell : Any?) {
        
        var tokens : [NotificationToken] = []
        
        for row in featuredRows {
            if let token = row.notificationToken {
                
                tokens.append(token)
                
            }
        }
        if let notificationToken = notificationToken {
            tokens.append(notificationToken)
        }
        
        if remove {
            
            services.globalModelsCoordinator.deleteBadgeFromResponse(withResponseId: id, badgeId: badgeId, realmNotificationToken: tokens) { success in
                
            }
        } else {
            
            services.globalModelsCoordinator.addBadgeToResponse(withResponseId: id, badgeId: badgeId, realmNotificationToken: tokens) { success in
                
            }
            
        }
        
    }
    
    override func scrollToTop() {
        
        tableView?.scrollToTop(animated: true)
        
    }
    
    private func updateModules(streams : [MultiContentObject]) {
        
        featuredRows.removeAll()
        
        for stream in streams {
            
            switch stream.type {
                
            case .advertisement:
                featuredRows.append(FeaturedRowAdvertisement(services: services, seeMoreDelegate: self, stream: services.globalModelsCoordinator.getAdvertisementStream(by: stream.id)))
                
            case .challenge :
                let configStream = services.globalModelsCoordinator.getChallengeStream(by: stream.id)
                featuredRows.append(FeaturedChallenges(services: services, seeMoreDelegate: self, stream: configStream, forceRefresh: forceRefresh))
                
            case .response:
                featuredRows.append(FeaturedResponses(services: services, seeMoreDelegate: self, stream: services.globalModelsCoordinator.getResponseStream(by: stream.id), forceRefresh: forceRefresh))
                
            }
            
        }
        
        forceRefresh = false
        
    }
    
    /**
     Stop playing video on all cells
     */
    func autoStop() {
        
        guard tableView != nil else { return }
        for tableCell in tableView.visibleCells {
            
            if let featuredTableCell = tableCell as? FeaturedRowTableViewCell {
                
                featuredTableCell.stopPlayback()
                
            }
            
        }
        
    }
    
    override func scrollStopped() {
        
        isScrolling = false
        autoPlay()
        
    }
    
    override func notifyScroll() {
        
        didInteract = true
        isScrolling = true
        winningRow = -1
        winningColumn = -1
        for tableCell in tableView.visibleCells {
            
            if let featuredTableCell = tableCell as? FeaturedRowTableViewCell {
                
                featuredTableCell.notifyScroll()
                
            }
            
        }
        
    }
    
    /**
     Only allow one video to play sound at a time
     */
    override func muteTapped(cell: Any?, isMuted: Bool) {
        
        if let cell = cell as? LargeContentCollectionViewCell {
            
            if let tag = cell.superview?.tag {
                
                if !isMuted {
                    
                    for tableCell in tableView.visibleCells {
                        
                        if let featuredTableCell = tableCell as? FeaturedRowTableViewCell {
                            
                            if tableView.indexPath(for: featuredTableCell)?.row == tag {
                                
                                featuredTableCell.muteTapped(cell : cell)
                                
                            }
                            
                        }
                        
                    }
                    
                }
                
            }
            
        }
        
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
        var cellToPlay : FeaturedRowTableViewCell?
        var foundWinner = false
        var winningPercent: CGFloat = 0.0
        guard let tableView = tableView else { return }
        
        for cell in tableView.visibleCells {
            
            if let contentCell = cell as? FeaturedRowTableViewCell, let indexPath = tableView.indexPath(for: cell) {
                maxRowSeen = max(maxRowSeen, indexPath.row)
                let rect = tableView.rectForRow(at: indexPath)
                let intersect = rect.intersection(tableView.bounds)
                //  curentHeight is the height of the cell that is visible
                let onScreenHeight = intersect.height
                if onScreenHeight > winningPercent {
                    
                    winningPercent = onScreenHeight
                    cellToPlay = contentCell
                    winningRow = indexPath.row
                    foundWinner = true
                    
                }
                
            }
            
        }
        
        if foundWinner, let cellToPlay = cellToPlay {
            
            for cell in tableView.visibleCells {
                
                if let contentCell = cell as? FeaturedRowTableViewCell {
                    
                    if contentCell == cellToPlay {
                        
                        winningColumn = contentCell.attemptAutoplay()
                        
                    } else {
                        
                        contentCell.stopPlayback()
                        
                    }
                    
                }
                
            }
            
            if allowCoachMarks(contentType : cellToPlay.contentType) {
                if !hasShownResponseCoachMark && cellToPlay.contentType == .response {
                    
                    hasShownResponseCoachMark = true
                    cellToPlay.showCoachMark(text: R.string.maverickStrings.coachmarkCTAResponse())
                    
                } else if !hasShownChallengeCoachMark && cellToPlay.contentType == .challenge {
                    
                    hasShownChallengeCoachMark = true
                    cellToPlay.showCoachMark(text: R.string.maverickStrings.coachmarkCTAChallenge())
                    
                }
                
            }
            
        }
        
    }
    
    private func allowCoachMarks(contentType: Constants.ContentType) -> Bool {
        
        if didInteract {
            
            switch contentType {
                
            case .response:
                return services.globalModelsCoordinator.loggedInUser?.badgedResponses.count  ?? 0 < 5
                
            case .challenge:
                return services.globalModelsCoordinator.loggedInUser?.createdResponses.count  ?? 0 == 0
                
            }
            
        }
        
        return false
        
    }
    override func interceptItemSelected(cell: Any?) -> Bool {
        
        if let cell = cell as? LargeContentCollectionViewCell ,
            
            let collectionView = cell.superview as? UICollectionView, let index = collectionView.indexPath(for: cell)?.row, let featuredRow = featuredRows[safe : collectionView.tag] {
            
            
            selectedImage = cell.imageView.image
            selectedFrame = cell.convert(cell.imageView.frame, to: nil)
            selectedFrame = CGRect(origin: CGPoint(x: selectedFrame!.origin.x, y: selectedFrame!.origin.y ) , size: selectedFrame!.size)
            
            
            
            if let vc = featuredRow.getSeeMoreViewController(index: index) {
                
                navigationController?.pushViewController(vc, animated: true)
                
            }
            
            
        }
        
        return true
        
    }
    
}

extension FeaturedStreamViewController: FeaturedRowTableViewCellDelegate {
    
    
    func allowCoachMark(contentType: Constants.ContentType) -> Bool {
        
        switch contentType {
        case .challenge:
            if !FeaturedStreamViewController.hasTappedPostResponseSession {
                
                return (services.globalModelsCoordinator.loggedInUser?.createdResponses.count ?? 0) == 0
                
            }
            
        case .response:
            if !FeaturedStreamViewController.hasBadgedThisSession {
                
                return (services.globalModelsCoordinator.loggedInUser?.badgedResponses.count ?? 0) < 5
                
            }
            
        }
        
        return false
        
    }
    
    
    func cellInView(row: Int, index: Int) {
        
        if let featuredRow = featuredRows[safe : row]  {
            
            featuredRow.maxItem = max(featuredRow.maxItem, index)
            
        }
        
    }
    
    
    func titleAreadTapped(row: Int) {
        
        if let featuredRow = featuredRows[safe : row]  {
            
            if let vc = featuredRow.getTitleTappedViewController() {
                
                navigationController?.pushViewController(vc, animated: true)
                
            }
            
        }
        
    }
    
    
    func scrollIndexUpdated(row : Int, offset: CGPoint) {
        
        if let featuredRow = featuredRows[safe : row]  {
            
            featuredRow.offset = offset
            
        }
        
    }
    
}

extension FeaturedStreamViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if let contentCell = cell as? FeaturedRowTableViewCell {
            
            contentCell.stopPlayback()
            
        }
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return featuredRows.count
        
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
        
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        
        var attemptedWidth =  Variables.Content.featuredRowPercentWidth.cgFloatValue() * UIScreen.main.bounds.width
        if attemptedWidth > Constants.MaxContentScreenWidth {
            
            attemptedWidth = Constants.MaxContentScreenWidth - 20.0
            
        }
        
        
        return  attemptedWidth / Variables.Content.maxStreamAspectRatio.cgFloatValue() + authorHeaderHeight + halfCTAHeight + featuredRowTitleHeight + tableRowBottomPadding + tableRowItemDividerHeight
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if let featuredRow = featuredRows[safe : indexPath.row] as? FeaturedRowAdvertisement {
            
            var cellHeight : CGFloat = 0.0
            if let image = featuredRow.image, image.width > 0, image.height > 0  {
                
                cellHeight = CGFloat(image.height) / CGFloat(image.width)  * tableView.frame.width
                
            }
            
            return cellHeight
            
        }
        
        var attemptedWidth =  Variables.Content.featuredRowPercentWidth.cgFloatValue() * UIScreen.main.bounds.width
        if attemptedWidth > Constants.MaxContentScreenWidth {
            
            attemptedWidth = Constants.MaxContentScreenWidth - 20.0
            
        }
        
        
        let regularHeight = attemptedWidth / Variables.Content.maxStreamAspectRatio.cgFloatValue() + authorHeaderHeight + halfCTAHeight + featuredRowTitleHeight + tableRowBottomPadding * 2 + tableRowItemDividerHeight
        
        return  regularHeight
        
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if let startTime = startTime {
            
            print("✅ time to load Featured : \(-round(startTime.timeIntervalSinceNow * 1000)) miliseconds")
            
        }
        startTime = nil
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        if isScrolling {
            maxRowSeen = max(maxRowSeen, indexPath.row)
        }
        if let featuredRow = featuredRows[safe : indexPath.row] as? FeaturedRowAdvertisement , let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.maverickAdvertisementTableViewCellId, for: indexPath)  {
            
            if let file = featuredRow.image?.URLOriginal {
                
                cell.configureWith(file: file, deepLink: featuredRow.deeplink, delegate: self, streamId: featuredRow.stream?.streamId, label: featuredRow.stream?.label)
                
                
            }
            
            
            return cell
            
        }
        
        if let featuredRow = featuredRows[safe : indexPath.row] as? FeaturedResponses, let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.featuredRowTableViewCellId, for: indexPath)  {
            
            featuredRow.configure( featuredTableViewCell: cell)
            cell.configure(colectionViewDelegate: self, rowDelegate: self, dataSource: self, preFetch: self, offset:  featuredRows[safe : indexPath.row]?.offset, row : indexPath.row)
            
            return cell
            
        }
        
        if let featuredRow = featuredRows[safe : indexPath.row] as? FeaturedChallenges, let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.featuredRowTableViewCellId, for: indexPath)  {
            
            
            featuredRow.configure( featuredTableViewCell: cell)
            cell.configure(colectionViewDelegate: self, rowDelegate: self, dataSource: self, preFetch: self, offset:  featuredRows[safe : indexPath.row]?.offset, row : indexPath.row)
            
            return cell
            
        }
        
        return UITableViewCell()
        
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
}


extension FeaturedStreamViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UICollectionViewDataSourcePrefetching {
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        if isChallengeAndResponseStream(streamIndex: collectionView.tag) {
            
            return 2
            
        }
        
        return 1
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        if let contentCell = cell as? LargeContentCollectionViewCell {
            
            if let collectionView = contentCell.superview {
                if collectionView.tag == winningRow && indexPath.row == winningColumn {
                    return
                }
            }
            
            contentCell.stopPlayback()
            
        }
        
    }
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        
        guard let feature = featuredRows[safe : collectionView.tag] else { return }
        
        if let featureChallenge = feature as? FeaturedChallenges, let challengeData = featureChallenge.data {
            
            let challenges = indexPaths.compactMap { challengeData[safe: $0.row] }
            let urls = challenges.compactMap { FeaturedChallenges.pathForImage(forItem: $0) }
            //            print("🎥 start prefetching FEATURED ROW: \(featureChallenge.stream?.label ?? "no name") : \(urls.count)")
            ImagePrefetcher(urls: urls) { skippedResources, failedResources, completedResources in
                
                if ImagePrefetcher.logOn {
                    print("🎥 prefetching FEATURED ROW Complete")
                    print("🎥 FEATURED ROW : skippedResources : \(skippedResources.count)")
                    print("🎥 FEATURED ROW : failedResources : \(failedResources)")
                    for resource in failedResources {
                        print("🎥 FEATURED ROW : failedResource \(resource.downloadURL)")
                    }
                    print("🎥 FEATURED ROW : completedResources : \(completedResources.count)")
                }
                
                }.start()
            
        }
        
        if let featureResponse = feature as? FeaturedResponses, let responseData = featureResponse.data {
            
            let challenges = indexPaths.compactMap { responseData[safe: $0.row] }
            let urls = challenges.compactMap { FeaturedResponses.pathForImage(forItem: $0) }
            
            //            print("🎥 start prefetching FEATURED ROW: \(featureResponse.stream?.label ?? "no name") : \(urls.count)")
            ImagePrefetcher(urls: urls) { skippedResources, failedResources, completedResources in
                
                if ImagePrefetcher.logOn {
                    print("🎥 prefetching FEATURED ROW Complete")
                    print("🎥 FEATURED ROW : skippedResources : \(skippedResources.count)")
                    print("🎥 FEATURED ROW : failedResources : \(failedResources)")
                    for resource in failedResources {
                        print("🎥 FEATURED ROW : failedResource \(resource.downloadURL)")
                    }
                    print("🎥 FEATURED ROW : completedResources : \(completedResources.count)")
                }
                
                }.start()
            
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        
        guard let feature = featuredRows[safe : collectionView.tag] else { return 0 }
        
        if isChallengeAndResponseStream(streamIndex: collectionView.tag) {
            
            if section == 0 {
                
                return 1
                
            }
            
        }
        
        return feature.collectionView(collectionView, numberOfItemsInSection: section)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        
        guard let feature = featuredRows[safe : collectionView.tag] else { return UICollectionViewCell() }
        
        
        let baseCell = feature.collectionView(collectionView, cellForItemAt: indexPath)
        
        if let cell = baseCell as? SmallContentCollectionViewCell {
            if isScrolling {
                
                feature.maxItem = max(feature.maxItem, indexPath.row)
                
            }
            
            cell.delegate = self
            return cell
        }
        if let cell = baseCell as? LargeContentCollectionViewCell {
            
            if isScrolling {
                
                feature.maxItem = max(feature.maxItem, indexPath.row)
                
            }
            
            cell.delegate = self
            return cell
            
        }
        
        return baseCell
        
    }
    
    func isChallengeAndResponseStream(streamIndex index : Int) -> Bool {
        
        if let feature = featuredRows[safe : index], let challengeResponse = feature as? FeaturedResponses, challengeResponse.stream?.challenge != nil {
            return true
        }
        
        return false
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        if section == 1 {
            let inset = UIEdgeInsets(top: authorHeaderHeight - SmallContentCollectionViewCell.upperSectionHeight, left: 0.0, bottom: tableRowBottomPadding + halfCTAHeight, right: 20.0)
         
            return inset
            
        }
        
        if isChallengeAndResponseStream(streamIndex: collectionView.tag) {
            
            let inset =  UIEdgeInsets(top: 0.0, left: 20.0, bottom: tableRowBottomPadding, right: 20.0)
        
            return inset
            
            
        }
        let inset = UIEdgeInsets(top: 0.0, left: 20.0, bottom: tableRowBottomPadding, right: 20.0)
        
        return inset
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let fullItemHeight = collectionView.frame.height - tableRowBottomPadding
        let fullItemWidth = (fullItemHeight - authorHeaderHeight - halfCTAHeight) * Variables.Content.gridAspectRatio.cgFloatValue()
        
        if let feature = featuredRows[safe : collectionView.tag] {
            
            if indexPath.section == 1 {
                
                let topAndBottomOffsets : CGFloat = authorHeaderHeight - SmallContentCollectionViewCell.upperSectionHeight
                
                let height = ( fullItemHeight - topAndBottomOffsets - gridSpacing - halfCTAHeight ) / 2
                let width = (( height - SmallContentCollectionViewCell.upperSectionHeight) * Variables.Content.gridAspectRatio.cgFloatValue())
                
                if indexPath.row >= feature.maxItemCount && feature.hasFooter && indexPath.row % 2 == 0 {
                    
                    let seemoreSize = CGSize(width: width, height: height * 2)
                    
                    return seemoreSize
                    
                }
                let size = CGSize(width: width, height: height)
                return size
                
                
            } else if isChallengeAndResponseStream(streamIndex: collectionView.tag) {
                
                return CGSize(width: fullItemWidth , height: fullItemHeight )
                
            }
            
            
            if indexPath.row >= feature.maxItemCount && feature.hasFooter {
                
                return CGSize(width: 200 * Variables.Content.gridAspectRatio.cgFloatValue() , height: fullItemHeight )
                
            }
            
        }
        
        return CGSize(width: fullItemWidth , height: fullItemHeight )
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        
        return gridSpacing
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        
        return gridSpacing
    
        
    }
    
    
}

extension FeaturedStreamViewController : FeaturedSeeMoreCollectionViewCellDelegate {
    
    func moreTapped(tag : Int) {
        
        if let featuredRow = featuredRows[safe : tag] {
            if let vc = featuredRow.getSeeMoreViewController(index: featuredRow.maxItemCount) {
                
                navigationController?.pushViewController(vc, animated: true)
                
            }
        }
        
    }
    
}

extension FeaturedStreamViewController : SmallContentCollectionViewCellDelegate {
    
    func cellTapped(cell: SmallContentCollectionViewCell) {
        
        
        if let collectionView = cell.superview as? UICollectionView, let index = collectionView.indexPath(for: cell)?.row, let featuredRow = featuredRows[safe : collectionView.tag] {
            
            
            selectedImage = cell.imageView.image
            selectedFrame = cell.convert(cell.midAndLowerSectionContainer.convert(cell.imageView.frame, to: cell), to : nil)
            selectedFrame = CGRect(origin: CGPoint(x: selectedFrame!.origin.x, y: selectedFrame!.origin.y ) , size: selectedFrame!.size)
            
            
            
            if let vc = featuredRow.getSeeMoreViewController(index: index, section : 1) {
                
                navigationController?.pushViewController(vc, animated: true)
                
            }
            
            
        }
        
        
        
    }
    
    func avatarTapped(userId: String) {
        
        showProfile(forUserId: userId)
        
    }
    
    
    
    
}

extension FeaturedStreamViewController : MaverickAdvertisementTableViewCellDelegate {
    
    func adTapped(link : URL?, streamId: String, label : String) {
        
        AnalyticsManager.Content.trackPromoPressed(streamId: streamId, label: label)
        if let url = link {
            
            DeepLinkHelper.parseURIScheme(url: url, services: services.globalModelsCoordinator)
            
        }
        
    }
    
}


extension FeaturedStreamViewController : StreamRefreshControllerDelegate {
    
    func configureData() {
        
        maverickFeed = services.globalModelsCoordinator.getMaverickStream()
        
        notificationToken =
            maverickFeed?.streams.observe{ [weak self] changes in
                
                switch changes {
                    
                case .initial(_):
                    break;
                    
                case .update(_,  _,  _,  _):
                    
                    if let streams = self?.maverickFeed {
                        
                        self?.updateModules(streams: Array(streams.streams))
                        self?.tableView.reloadData()
                        self?.refreshCompleted()
                        self?.longAutoplay()
                        
                    }
                    
                case .error:
                    print("error update featured stream: ")
                    
                }
                
                
                
        }
        
        updateModules(streams: Array(services.globalModelsCoordinator.getMaverickStream().streams))
        tableView.reloadData()
        refreshCompleted()
        longAutoplay()
        
    }
    
    func refreshDataRequest() {
        
        forceRefresh = true
        self.services.globalModelsCoordinator.refreshMaverickStream(forceRefresh: true) { [weak self] value in
            
            self?.refreshCompleted()
            self?.longAutoplay()
            
        }
        
    }
    
    func loadNextPageRequest() {
        
        nextPageLoadCompleted()
        
    }
    
    func getMainSectionItemCount() -> Int {
        
        return featuredRows.count
        
    }
    
}

extension ImagePrefetcher {
    
    static var logOn = false
    
}
