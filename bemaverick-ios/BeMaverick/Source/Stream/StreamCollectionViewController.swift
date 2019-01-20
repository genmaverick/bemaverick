//
//  StreamCollectionViewController.swift
//  Maverick
//
//  Created by Garrett Fritz on 3/4/18.
//  Copyright © 2018 BeMaverick. All rights reserved.
//

import Foundation
import CoreMedia

class StreamCollectionViewController : StreamRefreshController {

    
    /// A collection view for displaying feed content
    @IBOutlet weak var collectionView : UICollectionView!
    /// Tap gesture that's used to notify when small items get tapped
    var tapGestureRecognizer: UITapGestureRecognizer?
    var initialOffset : CGPoint? = nil
    
    private var isInitialized = false
    
   
    
     override func viewWillDisappear(_ animated: Bool) {
        
        super.viewWillDisappear(animated)
        autoStop()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {

        super.viewWillAppear(animated)
        autoPlay()
        
    }
    
    override func scrollToTop() {
        
        collectionView?.scrollToTop(animated: true)
        
    }
    
    override func viewDidLayoutSubviews() {
        
        super.viewDidLayoutSubviews()
        if !isInitialized {
            
            collectionView.reloadData()
            isInitialized = true
        
        }
    
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        transitionCompleted()
    
    }
    
    override func transitionCompleted() {
    
        super.transitionCompleted()
        guard isInitialized else { return }
        for cell in collectionView.visibleCells {
            if let smallCell = cell as? SmallContentCollectionViewCell {
                let _ = smallCell.contentView
                smallCell.imageView?.isHidden = false
            }
        }
    
        if initialOffset == nil {
        
            initialOffset = collectionView.contentOffset
       
        }
      
    }
    
    /**
     Initialize view with a particular collection view layout, if none set,
     will just be regular flow layout
     */
    func configureView(withCustomLayout layout: UICollectionViewLayout ) {
        
        collectionView.setCollectionViewLayout(layout, animated: false)
        view.backgroundColor = UIColor.MaverickBackgroundColor
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.register(R.nib.largeContentCollectionViewCell)
        collectionView.register(R.nib.emptyCollectionCell)
        
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(refresh(_:)), for: .valueChanged)
        collectionView.refreshControl = refreshControl
        collectionView.backgroundColor = UIColor.MaverickBackgroundColor
        view.backgroundColor = UIColor.MaverickBackgroundColor
        
    }
    
    /**
     attempt to play videos when scrolling stops
     */
    override func scrollStopped() {
        
        autoPlay()
        
    }
    
    
  
    
    
    /**
     Attempt to play video after a new refresh
     */
    override func refreshCompleted() {
        
        super.refreshCompleted()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            
            self.autoPlay()
            
        }
        
    }
    
    /**
     Autoplay the largest cell in view
     */
    func autoPlay() {
        // only autoplay if viewcontroller is visisble
        guard isVisible else { return }
        
        if blockAutoplayDueToRefresh {
            
            blockAutoplayDueToRefresh = false
            return
            
        }
        
        for cell in collectionView?.visibleCells ?? [] {
            
            if let contentCell = cell as? LargeContentCollectionViewCell {
                
                contentCell.attemptAutoplay()
                
            }
            
        }
        
    }
    
    /**
     Stop playing video on all cells
     */
    func autoStop() {
        
        for cell in collectionView?.visibleCells ?? [] {
            
            if let contentCell = cell as? LargeContentCollectionViewCell{
                
               contentCell.stopPlayback()
                
            } else if let contentCell = cell as? SmallContentCollectionViewCell{
                
                contentCell.stopPlayback()
                
            }
            
        }
        
    }
    
    override func nextPageLoadCompleted() {
        
        super.nextPageLoadCompleted()
        if previousCount > (streamDelegate?.getMainSectionItemCount() ?? 0) {
            
            collectionView.reloadData()
            
        }
        
    }
    
}


extension StreamCollectionViewController : UICollectionViewDataSource, UICollectionViewDelegate {
    
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        if let largeCell = cell as? LargeContentCollectionViewCell {
        
            largeCell.stopPlayback()
      
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return streamDelegate?.getMainSectionItemCount() ?? 0
        
    }
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let itemCount = collectionView.numberOfItems(inSection: collectionView.numberOfSections - 1)
        if  !hasReachedEnd && indexPath.row >= itemCount - 3 {
            
            loadNextPage()
            
        }
        
        return UICollectionViewCell()
        
    }
    
  
    
}

