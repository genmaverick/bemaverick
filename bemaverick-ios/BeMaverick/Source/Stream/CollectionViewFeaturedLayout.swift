//
//  CollectionViewFeaturedLayout.swift
//  BeMaverick
//
//  Created by David McGraw on 1/17/18.
//  Copyright © 2018 BeMaverick. All rights reserved.
//

import UIKit

enum FeaturedGroupAlignment {
    
    /// Portrait tile on the left
    case leftAligned
    /// Portrait tile on the right
    case rightAligned
    /// Row of small tiles
    case fullRow
    
}

class CollectionViewFeaturedLayout: UICollectionViewLayout {
    
    // MARK: - Private Properties
    
    /// The height of the loaded content
    fileprivate var contentHeight: CGFloat = 0.0
    /// Space between cells
    fileprivate var cellEdgePadding: CGFloat = 5.0
    /// Defautl size for portrait cells
    fileprivate var tallCellSize: CGSize = CGSize(width: 278.0, height: 410.0)
    /// Default size for square cells
    fileprivate var smallCellSize: CGSize = CGSize(width: 130.0, height: 130.0)
    /// Cache for layout attributes
    var cache = [CollectionViewFeaturedLayoutAttributes]()
    /// The layout alignment for the group in focus
    fileprivate var groupAlignment: FeaturedGroupAlignment = .leftAligned
    
    var aspectRatio : CGFloat = 0.75
    // MARK: - Layout
    
    override func prepare() {
         // Skip if attributes have already been cached
        if !cache.isEmpty && collectionView!.numberOfItems(inSection: 0) == cache.count {
            
//            log.verbose("GARRETT prepare cached")
            return
        
        }
//        log.verbose("GARRETT prepare not cached: \(collectionView!.numberOfItems(inSection: 0))")
        
        cache = [CollectionViewFeaturedLayoutAttributes]()
        groupAlignment = .leftAligned
        var tileSizeWidth: CGFloat = ((UIScreen.main.bounds.width - cellEdgePadding * 2) / 3.0)       // 131
        
        switch (UIScreen.main.traitCollection.userInterfaceIdiom) {
        case .pad:
            tileSizeWidth = ((800 - cellEdgePadding * 2) / 3.0)
        default :
            break
            
        }
        
        aspectRatio = Variables.Content.gridAspectRatio.cgFloatValue()
        // Adjust defaults based on collection view size
        tallCellSize.width = (tileSizeWidth * 2.0) + cellEdgePadding
        smallCellSize.width = tileSizeWidth
        smallCellSize.height = tileSizeWidth / aspectRatio
        tallCellSize.height =  tallCellSize.width / aspectRatio
        
        // Defaults
        var itemWidth   = tallCellSize.width
        var itemHeight  = tallCellSize.height
        
        var xOffset = CGFloat(0)
        var yOffset = CGFloat(0)
        
        // The current position within the "group" of tiles
        var groupPositionIndex: Int = 0
        
        // Used for positioning within each group which may be less than the actual content height
        var adjustedContentHeight: CGFloat = 0
        
        // Iterate items
        for item in 0 ..< collectionView!.numberOfItems(inSection: 0) {
            
            let indexPath = IndexPath(item: item, section: 0)
            
            // Adjust offsets for this item
            if groupAlignment == .leftAligned {
                
                if groupPositionIndex == 0 {
                    
                    itemWidth = tallCellSize.width
                    itemHeight = tallCellSize.height
                    
                    xOffset = 0
                    yOffset = adjustedContentHeight
                    
                } else {
                    
                    itemWidth = smallCellSize.width
                    itemHeight = smallCellSize.height
                    
                    xOffset = tallCellSize.width + cellEdgePadding
                    yOffset = adjustedContentHeight
                    
                    adjustedContentHeight += smallCellSize.height + cellEdgePadding
                    
                }
                
            } else if groupAlignment == .rightAligned {
                
                if groupPositionIndex == 1 {
                    
                    itemWidth = tallCellSize.width
                    itemHeight = tallCellSize.height
                    
                    xOffset = smallCellSize.width + cellEdgePadding
                    yOffset = adjustedContentHeight - (smallCellSize.height + cellEdgePadding)
                    
                } else {
                    
                    itemWidth = smallCellSize.width
                    itemHeight = smallCellSize.height
                    
                    xOffset = 0
                    yOffset = adjustedContentHeight
                    
                    adjustedContentHeight += smallCellSize.height + cellEdgePadding
                    
                }
                
            } else if groupAlignment == .fullRow {
                
                itemWidth = smallCellSize.width
                itemHeight = smallCellSize.height
                
                xOffset = CGFloat(groupPositionIndex) * (smallCellSize.width + cellEdgePadding)
                yOffset = adjustedContentHeight
                
                if groupPositionIndex == 2 {
                    adjustedContentHeight += smallCellSize.height + cellEdgePadding
                }
                
            }
            
            // Update the grouping position and reset if we've moved into the next group
            groupPositionIndex += 1
            
            if checkGroupAlignment(withIndex: groupPositionIndex) {
                groupPositionIndex = 0
            }
            
            // Create attribute for this item and cache it
            let frame = CGRect(x: xOffset, y: yOffset, width: itemWidth, height: itemHeight)
            
            let attributes = CollectionViewFeaturedLayoutAttributes(forCellWith: indexPath)
            attributes.height = contentHeight
            attributes.frame = frame
            cache.append(attributes)
            
            // Prepare offsets for the next item
            contentHeight = max(contentHeight, frame.maxY)
            
        }
        
    }
    
    override var collectionViewContentSize: CGSize {
        return CGSize(width: collectionView!.bounds.width, height: contentHeight)
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        
        var layoutAttributes = [CollectionViewFeaturedLayoutAttributes]()
        
        for attribute in cache {
            
            if attribute.frame.intersects(rect) {
                layoutAttributes.append(attribute)
            }
            
        }
        
        return layoutAttributes
        
    }
    
    // MARK: - Private Methods
    
    /**
     Update `groupAlignment` based on the current index. Index should be the
     NEXT index. So 0, 1, 2, 3 layout. The next index (4) will move to the
     next alignment type.
     */
    fileprivate func checkGroupAlignment(withIndex index: Int) -> Bool {
        
        var didUpdateAlignment = false
        
        switch groupAlignment {
        case .leftAligned:
            
            if index > 2 {
                groupAlignment = .rightAligned
                didUpdateAlignment = true
            }
            
        case .rightAligned:
            
            if index > 2 {
                groupAlignment = .fullRow
                didUpdateAlignment = true
            }
            
        case .fullRow:
            
            if index > 2 {
                groupAlignment = .leftAligned
                didUpdateAlignment = true
            }
            
        }
        
        return didUpdateAlignment
        
    }
    
}

class CollectionViewFeaturedLayoutAttributes: UICollectionViewLayoutAttributes {
    
    var height: CGFloat = 0.0
    
    override func copy(with zone: NSZone? = nil) -> Any {
        let copy = super.copy(with: zone) as! CollectionViewFeaturedLayoutAttributes
        copy.height = height
        return copy
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        if let attributes = object as? CollectionViewFeaturedLayoutAttributes {
            if attributes.height == height {
                return super.isEqual(object)
            }
        }
        return false
    }
    
}
