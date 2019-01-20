//
//  ContentPageCollectionViewController.swift
//  Maverick
//
//  Created by Garrett Fritz on 8/13/18.
//  Copyright © 2018 BeMaverick. All rights reserved.
//

import Foundation


class ContentPageCollectionViewController : StreamCollectionViewController {
    
    var isEmpty = false
    
    var padding : CGFloat = 28.0
    var gutters : CGFloat = 16.0
    var firstLoad = false
    weak var delegate : ContentPageViewControllerDelegate?
    
    override func refreshCompleted() {
        
        super.refreshCompleted()
        firstLoad = true
        
    }
    
    override func viewDidLoad() {
        
        ignoreNavControl = true
        super.viewDidLoad()
        
            collectionView.contentInset = UIEdgeInsetsMake(gutters, gutters, gutters, gutters)
     
    }
    
    override func configureView() {
        
        super.configureView()
        
        configureView(withCustomLayout: collectionView.collectionViewLayout)
        collectionView.register(R.nib.smallContentCollectionViewCell)
        collectionView.register(R.nib.pagingCollectionViewCell)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.reloadData()
        navigationController?.navigationBar.layer.shadowColor = UIColor.clear.cgColor
        
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
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        return 1
        
    }
    
    func getChallengeCell(challenge : Challenge, indexPath : IndexPath) -> SmallContentCollectionViewCell? {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: R.reuseIdentifier.smallContentCollectionViewCellId,
                                                            for: indexPath) else { return nil }
        
        let hasResponded = services.globalModelsCoordinator.isChallengeResponded(challengeId: challenge.challengeId)
        cell.delegate = self
        cell.configure(with: challenge, isComplete: hasResponded)
        return cell
        
    }
    
    func getResponseCell(response : Response, indexPath : IndexPath) -> SmallContentCollectionViewCell? {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: R.reuseIdentifier.smallContentCollectionViewCellId,
                                                            for: indexPath) else { return nil }
        
        cell.delegate = self
        cell.configure(with: response, hideChallengeTitle : false)
        return cell
        
    }
    
    func getEmptyCell(indexPath : IndexPath) -> UICollectionViewCell? {
        
        if isEmpty {
            
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: R.reuseIdentifier.emptyCollectionCellId, for: indexPath)
            {
                
                cell.emptyView.configure(title: getEmptyTitle(), subtitle: getEmptySubTitle(), dark: false)
                return cell
                
            }
            
        }
        
        return nil
    
    }
    
    
    func getEmptyTitle() -> String {
        
        return "Nothing Yet"
        
    }
    
    func getEmptySubTitle() -> String {
        
        return "Come back later to see more"
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        
        return padding
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        
        return gutters
    
    }
    
    
}


extension ContentPageCollectionViewController : UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if isEmpty {
            
            let cellWidth = Constants.MaxContentScreenWidth
            let cellHeight = Variables.Content.emptyViewHeight.cgFloatValue()
            return CGSize(width: cellWidth,
                          height: cellHeight)
        }
        
        let width = collectionView.frame.width / 2 - gutters  * 3 / 2
        let height = width / Variables.Content.maxStreamAspectRatio.cgFloatValue() + SmallContentCollectionViewCell.lowerSectionHeight + SmallContentCollectionViewCell.upperSectionHeight
        
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

extension ContentPageCollectionViewController : SmallContentCollectionViewCellDelegate {
    
    func cellTapped(cell: SmallContentCollectionViewCell) {
        
        
        //Transition Section
        cell.imageView.isHidden = true
        selectedImage = cell.imageView.image
        
          selectedFrame = cell.convert(cell.midAndLowerSectionContainer.convert(cell.imageView.frame, to: cell), to : nil)
        selectedFrame = CGRect(origin: CGPoint(x: selectedFrame!.origin.x, y: selectedFrame!.origin.y ) , size: selectedFrame!.size)
        delegate?.transitionItemSelected(selectedImage: selectedImage, selectedFrame: selectedFrame)
        //Transition Section
        
        guard let contentType = cell.contentType, let contentId = cell.contentId else { return }
        
        AnalyticsManager.Content.trackSmallItemPressed(contentType, contentId: contentId, location: self)
        
    }
    
    func avatarTapped(userId : String) {
        
          showProfile(forUserId: userId)
        
    }
    
}
