//
//  EditBackgroundOptionsView.swift
//  BeMaverick
//
//  Created by David McGraw on 12/21/17.
//  Copyright © 2017 BeMaverick. All rights reserved.
//

import UIKit

class EditBackgroundOptionsView: UIView {
    
    // MARK - IBOutlets
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    // MARK: - Public Properties
    
    /// The object that acts as the delegate of the selector view
    weak var delegate: PostEditorDelegate?
    
    
    // MARK - Lifecycle
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
         configureView()
        
    }
    
    /**
     Default view configuration that loads stickers
    */
    fileprivate func configureView() {
        
        collectionView.register(R.nib.editBackgroundViewCell)
        collectionView.delegate = self
        collectionView.dataSource = self
        
        if let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.scrollDirection = .horizontal
        }
        
        
    }
    
}

extension EditBackgroundOptionsView : UICollectionViewDataSource , UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        
        guard let color = Variables.Content.getPostTextBackgroundColors()[safe: indexPath.row] else { return }
            delegate?.didSelectBackgroundColor(color)
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        return Int(Variables.Content.getPostTextBackgroundColors().count)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: R.reuseIdentifier.editBackgroundViewCellId,
                                                      for: indexPath)
        
        if let color = Variables.Content.getPostTextBackgroundColors()[safe: indexPath.row] {
        
            cell?.maverickBackgroundView.backgroundColor = color
        
        }
        
        return cell ?? UICollectionViewCell()
        
    }
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.height, height: collectionView.frame.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 5.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 5.0
    }
    
    
}
