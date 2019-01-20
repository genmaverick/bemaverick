//
//  EditStickerOptionsView.swift
//  BeMaverick
//
//  Created by David McGraw on 12/21/17.
//  Copyright © 2017 BeMaverick. All rights reserved.
//

import UIKit

protocol EditStickerOptionsViewDelegate: class {
    
    func minimizeHeight()
    func maximizeHeight()
    
}

class EditStickerOptionsView: UIView {
    
    // MARK - IBOutlets

    /// The collection view containing the horizontal list of icons representing each sticker group.
    @IBOutlet weak var stickerGroupSelectorCollectionView: UICollectionView!
    
    /// The collection view containing the stickers for all sticker groups.
    @IBOutlet weak var stickerCollectionView: UICollectionView!
    
    static var completedProjectImages : [UIImage] = []
    
    // MARK: - Private Properties
    
    /// The object that acts as the delegate of the selector view
    weak var delegate: PostEditorDelegate?
    
    /// The array of sticker groups that are available for display obtained from the on-demand resources manager.
    private let availableStickerGroups = Stickers.StickerGroups
    
    /// The delegate that instructs whether the parent view should maximize or minimize.
    weak var editStickerOptionsViewDelegate: EditStickerOptionsViewDelegate?
    
    /// The tap gesture recognizer that is used to maximize/minimize the sticker options view.
    private var tapGestureRecognizer: UITapGestureRecognizer!
    
    /// The swipe up gesture recognizer that is used to maximize the sticker options view.
    private var swipeUpGestureRecognizer: UISwipeGestureRecognizer!
    
    /// The swipe down gesture recognizer that is used to minimize the sticker options view.
    private var swipeDownGestureRecognizer: UISwipeGestureRecognizer!
    
    /// A variable that keeps track of the which group is currently selected in the sticker group selector view.
    private var selectedCellIndex = 0 {
        didSet {
            stickerGroupSelectorCollectionView.reloadData()
        }
    }
    
    /// Flag to keep track of whether scrolling is due to the autoscroll feature when a group selector is pressed.
    private var isAutoScrolling = false
    
    /// the gutters for the sticker collection view.
    private var gutterSize: CGFloat = 24

    /// The padding for the sticker collection view.
    private var paddingSize: CGFloat = 42

    static func getCompletedProjectImages(user: User) {
        
        EditStickerOptionsView.completedProjectImages = []
        
        var projectGroups : [String] = []
        if let projectsProgress = user.progression?.getCompletedProjects() {
            
            for progress in projectsProgress {
                
                if let group = progress.project?.projectGroup {
                    
                    if projectGroups.contains(group) {
                    
                        continue
                    
                    } else {
                        
                        projectGroups.append(group)
                    
                    }
                
                }
                
                if let url = progress.project?.getImageUrl() {
                    
                    UIImageView().kf.setImage(with: url) { (image, error, cache, url) in
                        
                        if let image = image {
                            
                            EditStickerOptionsView.completedProjectImages.append(image)
                            
                        }
                        
                    }
                    
                }
                
            }
            
        }
        
    }
    
    // MARK: - Public Properties
    
    /// The flag tracking whether the sticker option view is currently minimized or maximized on screen.
    var isMaximized = true {
        didSet {
            
            stickerGroupSelectorCollectionView.reloadData()
            
            if isMaximized {
                
                stickerGroupSelectorCollectionView.isUserInteractionEnabled = true
                stickerCollectionView.isUserInteractionEnabled = true

            } else {
                
                stickerGroupSelectorCollectionView.isUserInteractionEnabled = false
                stickerCollectionView.isUserInteractionEnabled = false
                
            }
            
        }
        
    }


    // MARK - Lifecycle
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        configureView()
        setupTapGestureRecognizer()
        setupSwipeGestureRecognizers()
        
        self.isUserInteractionEnabled = true
        
    }
    
    deinit {
        log.verbose("💥")
    }
    
    // MARK: - Private Methods
    
    /**
     Default view configuration that loads stickers
    */
    private func configureView() {
        
        stickerGroupSelectorCollectionView.register(R.nib.stickerGroupSelectorCollectionViewCell)
        stickerGroupSelectorCollectionView.delegate = self
        stickerGroupSelectorCollectionView.dataSource = self
        stickerGroupSelectorCollectionView.tag = 0
        stickerGroupSelectorCollectionView.backgroundColor = UIColor(rgba: "#F4F4F4")
        
        stickerCollectionView.register(R.nib.stickerCollectionViewCell)
        stickerCollectionView.delegate = self
        stickerCollectionView.dataSource = self
        stickerCollectionView.tag = 1
        stickerCollectionView.backgroundColor = .white
        
    }
    
    /**
     Sets up the tap gesture recognizer.
     */
    private func setupTapGestureRecognizer() {
        
        tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        
        self.addGestureRecognizer(tapGestureRecognizer)
        tapGestureRecognizer.cancelsTouchesInView = false 
        
    }
    
    /**
     Sets up the swipe gesture recognizers.
     */
    private func setupSwipeGestureRecognizers() {
        
        swipeUpGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(self.handleSwipe(_:)))
        swipeDownGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(self.handleSwipe(_:)))
        
        swipeUpGestureRecognizer.direction = .up
        swipeDownGestureRecognizer.direction = .down
        
        swipeUpGestureRecognizer.cancelsTouchesInView = false
        swipeDownGestureRecognizer.cancelsTouchesInView = false
        
        self.addGestureRecognizer(swipeUpGestureRecognizer)
        self.addGestureRecognizer(swipeDownGestureRecognizer)
        
    }
    
    /**
     Handles the tap gesture and minimizes or maximizes height as appropriate.
     */
    @objc func handleTap(_ sender: UITapGestureRecognizer) {
        
        guard !isMaximized else { return }
        
        editStickerOptionsViewDelegate?.maximizeHeight()
        isMaximized = true
        
    }
    
    /**
     Handles the swipe gesture and minimizes or maximizes height as appropriate.
     */
    @objc func handleSwipe(_ sender: UISwipeGestureRecognizer) {
        
        switch sender.direction {
            
        case .up:
            
            if !isMaximized {
                
                editStickerOptionsViewDelegate?.maximizeHeight()
                isMaximized = true
                
            } else {
                return
            }
            
        case .down:
            
            if isMaximized {
                
                editStickerOptionsViewDelegate?.minimizeHeight()
                isMaximized = false
                
            } else {
                return
            }
            
        default:
            return
        }
        
    }
    
}

extension EditStickerOptionsView: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if collectionView.tag == 0 {
            
            selectedCellIndex = indexPath.item
            
            let indexPathToScrollTo = IndexPath(item: 0, section: indexPath.row)
            
            if let attributes =  stickerCollectionView.layoutAttributesForSupplementaryElement(ofKind: UICollectionElementKindSectionHeader, at: indexPathToScrollTo) {

                let topOfHeader = CGPoint(x: 0, y: attributes.frame.origin.y - stickerCollectionView.contentInset.top)
                isAutoScrolling = true
                stickerCollectionView.setContentOffset(topOfHeader, animated: false)
                isAutoScrolling = false
                
            }
            
        } else {
            
            if let rewardType = availableStickerGroups[safe: indexPath.section]?.requiredReward() {
               
                if delegate?.isRewardLocked(rewardType: rewardType) ?? true {
                   
                    delegate?.lockedRewardTapped(rewardType : rewardType)
                    return
                
                }
            
            }
            
            guard isMaximized else { return }
            
            if let stickerName = availableStickerGroups[safe: indexPath.section]?.stickerNamesForGroup()[indexPath.item]  {
            
                if let image = UIImage(named: stickerName) {
                    
                    delegate?.didSelectSticker(image, stickerName: stickerName)
                    
                }
                
            } else {
                
                if let image = EditStickerOptionsView.completedProjectImages[safe: indexPath.row] {
                    
                    delegate?.didSelectSticker(image, stickerName: "project")
                    
                }
                
            }
            
            editStickerOptionsViewDelegate?.minimizeHeight()
            isMaximized = false
            
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if collectionView.tag == 0 {
            
            let hasProject = EditStickerOptionsView.completedProjectImages.count > 0 ? 1 : 0
            return availableStickerGroups.count + hasProject
            
        } else {
            
            if let count = availableStickerGroups[safe: section]?.stickerNamesForGroup().count {
                
                return count
            
            }
            
            return EditStickerOptionsView.completedProjectImages.count
            
        }

    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView.tag == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: R.reuseIdentifier.stickerGroupSelectorId, for: indexPath)
            
            if let stickerName = availableStickerGroups[safe: indexPath.item]?.stickerIconForGroup() {
                
                cell?.coverImage.image = UIImage(named: "\(stickerName)_thumb")
                
               
            } else {
                
                 cell?.coverImage.image = R.image.project_default()
                
            }
            
            if indexPath.item == selectedCellIndex {
                cell?.selectCell()
            }
            
            if let rewardType = availableStickerGroups[safe: indexPath.item]?.requiredReward() {
                
                if delegate?.isRewardLocked(rewardType: rewardType) ?? true {
                    
                     cell?.lockCell()
                    
                }
                
            }
            
            return cell ?? UICollectionViewCell()
            
        } else {
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: R.reuseIdentifier.stickerId, for: indexPath)
            
            if let stickerName = availableStickerGroups[safe: indexPath.section]?.stickerNamesForGroup()[indexPath.row] {
                
                cell?.coverImage.image = UIImage(named: "\(stickerName)_thumb")

                if let rewardType = availableStickerGroups[safe: indexPath.section]?.requiredReward() {
                    
                    if delegate?.isRewardLocked(rewardType: rewardType) ?? true {
                        
                        cell?.lockCell()
                        
                    }
                    
                }
            
            } else {
                
                cell?.coverImage.image = EditStickerOptionsView.completedProjectImages[safe: indexPath.row]
                
            }
            
            return cell ?? UICollectionViewCell()
            
        }
        
    }
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        if collectionView.tag == 0 {
            
            return 1
            
        } else {
            
            let completedProject = EditStickerOptionsView.completedProjectImages.count > 0 ? 1 : 0
            return availableStickerGroups.count + completedProject
            
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView,
                                 viewForSupplementaryElementOfKind kind: String,
                                 at indexPath: IndexPath) -> UICollectionReusableView {

        switch kind {

        case UICollectionElementKindSectionHeader:
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                             withReuseIdentifier: "StickerHeaderView",
                                                                             for: indexPath) as! StickerHeaderCollectionReusableView
            
            if let name =  availableStickerGroups[safe : indexPath.section]?.nameForGroup().uppercased() {
                
                headerView.label.text = name
                
            } else {
                
                headerView.label.text = "PROJECTS"
                
            }
            return headerView
        default:
            assert(false, "Unexpected element kind")
            return UICollectionReusableView()
            
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        if collectionView.tag == 1 {
            return CGSize(width: stickerCollectionView.bounds.size.width, height: CGFloat(30))
        }
        
        return CGSize.zero
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if collectionView.tag == 0 {
            
            return CGSize(width: 68, height: 64)
            
        } else {
            
            let cellDimension = floor((stickerCollectionView.bounds.size.width - ((gutterSize * 2) + (paddingSize * 2)) ) / 3)
            return CGSize(width: cellDimension, height: cellDimension)
            
        }
        
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        if collectionView.tag == 0 {
            return UIEdgeInsets(top: 0,left: 0,bottom: 0,right: 0)
        } else {
            return UIEdgeInsets(top: gutterSize, left: gutterSize, bottom: gutterSize, right: gutterSize)
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {

        if collectionView.tag == 1 {
            return gutterSize
        } else {
            return 0
        }

    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {

        if collectionView.tag == 1 {
            return paddingSize 
        } else {
            return 0
        }
        
    }
    
}

extension EditStickerOptionsView: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if scrollView.tag == 1 && !isAutoScrolling {
            
            let collectionView = scrollView as! UICollectionView

            let visibleIndexPaths = collectionView.indexPathsForVisibleItems
            
            let sections = visibleIndexPaths.map { $0.section }
            
            let indexForMode = mode(fromArray: sections)
            
            if let index = indexForMode {
                
                if selectedCellIndex != index {
                    
                    defer {
                        selectedCellIndex = index
                    }
                    
                    if index == 0 {
                        
                        let furthestStartingPoint = CGPoint(x: stickerGroupSelectorCollectionView.frame.origin.x, y: 0)
                        stickerGroupSelectorCollectionView.setContentOffset(furthestStartingPoint, animated: true)

                    } else {

                        stickerGroupSelectorCollectionView.scrollToItem(at: IndexPath(item: index, section: 0), at: .centeredHorizontally, animated: true)
                    }
                    
                }
                
            }
            
        }
        
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        
        if scrollView.tag == 1 {
            isAutoScrolling = false
        }
        
    }
    
    /**
     Helper function to calculate the mode in an array of Ints.
     */
    func mode(fromArray array: [Int]) -> Int? {
        
        let countedSetArray = NSCountedSet(array: array)
        return countedSetArray.max { countedSetArray.count(for: $0) < countedSetArray.count(for: $1) } as? Int
        
    }
    
}

