//
//  TwoSectionStreamCollectionViewController.swift
//  Maverick
//
//  Created by Garrett Fritz on 3/6/18.
//  Copyright © 2018 BeMaverick. All rights reserved.
//

import Foundation

protocol TwoSectionStreamCollectionViewControllerHeaderDelegate : class {
    
    func getFrame() -> CGRect
    
    func preferredLayoutSizeFittingSize(targetSize:CGSize) -> CGSize
    
}

class TwoSectionStreamCollectionViewController : StreamCollectionViewController {
    /// bool to determine if empty view should be shown. set to true if data is empty and request has completed
    var isEmpty = false
    /// height for the section header
    var sectionHeaderHeight : CGFloat = 44.0
    /// value to indicate if header and title should be displayed
    var isNavHidden = true
    var allowsHiddingNavBar = true
    weak var headerCellDelegate : TwoSectionStreamCollectionViewControllerHeaderDelegate?
    /// to enable the showing and hiding of the header bar we do need to programatically toggle the scroll position, while this happens, this value keeps updates from happening
    private var settingDistance = false
    
    override func configureView() {
        
        super.configureView()
        configureView(withCustomLayout: UICollectionViewFlowLayout())
        (collectionView.collectionViewLayout as? UICollectionViewFlowLayout)?.sectionHeadersPinToVisibleBounds = true

        collectionView.bounces = false
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
   
        if allowsHiddingNavBar {
            
            hasNavBar = !isNavHidden
        
        }
        super.viewWillAppear(animated)
    
    }
    
    /**
     Main section cell size -> typically 3 items wide unless empty or only 1 item
    */
    func getCellSize() -> CGSize {
        
        let spacing = Variables.Content.gridItemSpacing.cgFloatValue()
        var cellWidth = (Constants.MaxContentScreenWidth - spacing * 2)  / 3.0
        var cellHeight = cellWidth / Variables.Content.gridAspectRatio.cgFloatValue()
        
        if isEmpty {
            
            cellWidth = Constants.MaxContentScreenWidth
            cellHeight = Variables.Content.emptyViewHeight.cgFloatValue()
            
        }
        
        return CGSize(width: cellWidth,
                      height: cellHeight)
        
    }
    
    /**
     This is the main work of this view controller, handles the visibility of the nav bar based on the height of the second section.
    */
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        guard  allowsHiddingNavBar else { return }
        if let header = collectionView.supplementaryView(forElementKind: UICollectionElementKindSectionHeader, at: IndexPath(row: 0, section: 1)) as? SectionHeaderCell {
            
            let frame : CGRect = header.convert(header.frame, from: self.view)
            
            guard let headerCell = headerCellDelegate else { return }
            let distanceToTop = headerCell.getFrame().height - scrollView.contentOffset.y
        
            header.distanceToTop(distance: distanceToTop - (frame.height))
            
            if isNavHidden {
                
                if distanceToTop <= frame.height && !settingDistance   {
                    
                   
                    isNavHidden = false
                    settingDistance = true
                   
                    navigationController?.setNavigationBarHidden(isNavHidden, animated: false)
                        
                    scrollView.contentOffset.y += navigationController?.navigationBar.frame.height ?? 0
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) {
                       
                        self.settingDistance = false
                    
                    }
                
                }
                
            } else {
                
                if distanceToTop > 0 && !settingDistance  {
                    settingDistance = true
                    isNavHidden = true
                    navigationController?.setNavigationBarHidden(isNavHidden, animated: false)
                    scrollView.contentOffset.y -= navigationController?.navigationBar.frame.height ?? 0
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) {
                  
                        self.settingDistance = false
                   
                    }
               
                }
                
            }
            
        }
        
    }
    
   override func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        return 2
        
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if section == 0 {
            
            return 1
        
        } else {
        
            return streamDelegate?.getMainSectionItemCount() ?? 0
        
        }
    
    }
    
}

extension TwoSectionStreamCollectionViewController : UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        if section == 0 {
          
            return CGSize.zero
        
        }
        
        return CGSize(width: Constants.MaxContentScreenWidth, height: sectionHeaderHeight)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if indexPath.section == 0 {
            
            if let headerCell = headerCellDelegate {
                // NOTE: here is where we say we want cells to use the width of the collection view
                let requiredWidth = Constants.MaxContentScreenWidth
                // NOTE: here is where we ask our sizing cell to compute what height it needs
                let targetSize = CGSize(width: requiredWidth, height: 0)
                /// NOTE: populate the sizing cell's contents so it can compute accurately
                let adequateSize = headerCell.preferredLayoutSizeFittingSize(targetSize: targetSize)
                return adequateSize
      
            }
        
        }
        
        return getCellSize()
   
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        
        return Variables.Content.gridItemSpacing.cgFloatValue()
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        
        return Variables.Content.gridItemSpacing.cgFloatValue()
        
    }
    
}
