//
//  FeaturedRowTableViewCell.swift
//  Maverick
//
//  Created by Garrett Fritz on 5/21/18.
//  Copyright © 2018 BeMaverick. All rights reserved.
//

import Foundation

protocol FeaturedRowTableViewCellDelegate : class {
    
    func scrollIndexUpdated(row : Int, offset : CGPoint)
    
    func titleAreadTapped(row : Int)
    
    func cellInView(row : Int, index : Int)
    
    func allowCoachMark(contentType : Constants.ContentType) -> Bool
    
}

class FeaturedRowTableViewCell : UITableViewCell {
      @IBOutlet weak var backgroundHighlight: UIView!
    @IBOutlet weak var challengeImage: UIImageView!
    @IBOutlet weak var titleBackground: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBAction func titleTapped(_ sender: Any) {
        
        delegate?.titleAreadTapped(row:  collectionView.tag)
  
    }
    
    weak var delegate : FeaturedRowTableViewCellDelegate?
    var contentType = Constants.ContentType.response
    override func awakeFromNib() {
        
        super.awakeFromNib()
        configureView()
        
    }
    
  
    func setTitle(title : String, contentType : Constants.ContentType, highlighted : Bool ) {
        
        self.contentType = contentType
        titleLabel.text = title
        
        switch contentType {
            
        case .challenge:
            challengeImage.isHidden = false
            titleLabel.textColor = UIColor.MaverickPrimaryColor
        case .response:
            challengeImage.isHidden = true
            titleLabel.textColor = UIColor(rgba: "2C2C2Cf")
            
        }
        
        backgroundHighlight.backgroundColor = highlighted ? UIColor(rgba: "F1F1F1ff") : UIColor.white
        
    }
    
    func showCoachMark(text : String) {
        
        for visible in collectionView.visibleCells {
            
            if let index = collectionView.indexPath(for: visible), index.row == 0, let cell = visible as? LargeContentCollectionViewCell {
                collectionView.bringSubview(toFront: cell)
                cell.showCTACoachMark(text: text, delay: 0.0)
                
            }
            
        }
        
    }
    
    override func prepareForReuse() {
        
        collectionView.setContentOffset(collectionView.contentOffset, animated: false) 
        delegate?.scrollIndexUpdated(row : collectionView.tag, offset: collectionView.contentOffset)
        
    }
    
    private func configureView() {
        collectionView.register(R.nib.largeContentCollectionViewCell)
       
        collectionView.register(R.nib.smallContentCollectionViewCell)
        collectionView.register(R.nib.featuredSeeMoreCollectionViewCell)

        if let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            
            flowLayout.scrollDirection = .horizontal
            collectionView.showsVerticalScrollIndicator = false
            collectionView.showsHorizontalScrollIndicator = false
            
        }
        collectionView.backgroundColor = .clear
        contentView.backgroundColor = .clear
        backgroundColor = .clear
        collectionView.clipsToBounds = false
        contentView.clipsToBounds = false
        clipsToBounds = false
        
    }
    
    func configure(colectionViewDelegate : UICollectionViewDelegate, rowDelegate : FeaturedRowTableViewCellDelegate?, dataSource : UICollectionViewDataSource, preFetch : UICollectionViewDataSourcePrefetching, offset : CGPoint? = nil, row : Int) {
        
        
        collectionView.tag = row
        
        if let offset = offset {
            
            collectionView.contentOffset = offset
            
        }
        delegate = rowDelegate
        collectionView.prefetchDataSource = preFetch
        collectionView.dataSource = dataSource
        collectionView.delegate = colectionViewDelegate
        collectionView.reloadData()
        
    }
    
    func attemptAutoplay() -> Int {
        
        var cellToPlay : LargeContentCollectionViewCell?
        var foundWinner = false
        var winningPercent: CGFloat = 0.0
        var winningIndex = -1
        for cell in collectionView.visibleCells {
            
            if let contentCell = cell as? LargeContentCollectionViewCell, let indexPath = collectionView.indexPath(for: cell) {
                delegate?.cellInView(row: collectionView.tag, index: indexPath.row)
                
                guard let rect = collectionView.layoutAttributesForItem(at: indexPath)?.frame else { return -1 }
                let intersect = rect.intersection(collectionView.bounds)
                //  curentHeight is the height of the cell that is visible
                let onScreenHeight = intersect.width
                if onScreenHeight > winningPercent {
                    
                    winningPercent = onScreenHeight
                    cellToPlay = contentCell
                    foundWinner = true
                    winningIndex = indexPath.row
                    
                }
                
            }
            
        }
        
        if foundWinner, let cellToPlay = cellToPlay {
            
            for cell in collectionView.visibleCells {
             
                if let contentCell = cell as? LargeContentCollectionViewCell {
                  
                    if contentCell == cellToPlay {
                 
                        contentCell.attemptAutoplay()
                    
                    } else {
                    
                        contentCell.stopPlayback()
                    
                    }
                
                }
            
            }
            
        }
        return winningIndex
    }
    
    func stopPlayback() {
        
        for subCell in collectionView.visibleCells {
            
            if let largeCell = subCell as? LargeContentCollectionViewCell {
                
                largeCell.stopPlayback()
                
            }
            
        }
        
    }
    
    func muteTapped(cell : LargeContentCollectionViewCell) {
        
        if let collectionView = collectionView {
            
            for subCell in collectionView.visibleCells {
                
                if let largeCell = subCell as? LargeContentCollectionViewCell {
                    
                    if largeCell.contentId != cell.contentId {
                        
                        largeCell.mute()
                        
                    }
                    
                }
                
            }
            
        }
        
        switch contentType {
            
        case .response:
            if delegate?.allowCoachMark(contentType: contentType) ?? false {
                
                collectionView.bringSubview(toFront: cell)
                let text = R.string.maverickStrings.coachmarkCTAResponse()
                cell.showCTACoachMark(text: text, delay: 1.0)
            
            }
            
        case .challenge:
            if delegate?.allowCoachMark(contentType: contentType) ?? false  {
             
                collectionView.bringSubview(toFront: cell)
                let text = R.string.maverickStrings.coachmarkCTAChallenge()
                cell.showCTACoachMark(text: text, delay: 1.0)
                
            }
            
        }
    
    }
        
    func notifyScroll() {
        
        if let collectionView = collectionView {
            
            for subCell in collectionView.visibleCells {
                
                if let largeCell = subCell as? LargeContentCollectionViewCell {
                    
                    largeCell.dismissBadger()
                    
                }
                
            }
            
        }
        
    }
    
}
