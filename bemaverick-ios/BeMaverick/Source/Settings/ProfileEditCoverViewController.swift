//
//  ProfileEditPasswordViewController.swift
//  BeMaverick
//
//  Created by David McGraw on 11/29/17.
//  Copyright © 2017 BeMaverick. All rights reserved.
//

import UIKit
import Kingfisher
import RealmSwift

class ProfileEditCoverViewController: ViewController {
    
    /// ID that keeps track of the clicked cover
    static var selectedId = -1
    
    // MARK: - IBOutlets
    /// View that holds the button pallete
    /// Selected preset image
    @IBOutlet weak var backgroundImage: UIImageView!
    /// Collection of available preset images
    @IBOutlet weak var collectionView: UICollectionView!
    
    // MARK: - Public Properties
    
    /// The `GlobalServicesContainer` that maintains access to global services
    var services: GlobalServicesContainer!
    
    private var loggedInUser = User()
    // MARK: - Private Properties
    private var defaultSelected = true
   
    /// standard covers from config
    private var standardCovers : Results<MaverickMedia>?
    /// list of cover ids from config
    
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        
        hasNavBar = true
        super.viewDidLoad()
        
        configureView()
        
    }
    
    
    // MARK: - Private Methods
    
    /**
     Back button pressed to dismiss
     */
    @objc override func backButtonTapped(_ sender: Any) {
        
        ProfileEditCoverViewController.selectedId = -1
        
        navigationController?.popViewController(animated: true)
        
    }
    
  
    /**
     Save button pressed, dismiss on success
     */
    @objc func saveChangesTapped(_ sender: Any) {
        
        AnalyticsManager.Settings.trackSaveCoverPressed()
        self.navigationController?.popViewController(animated: true)
  
    }
    
     /**
     Configure the default layout
     */
    fileprivate func configureView() {
        // iOS 10 fix to not have white spacing on top
        automaticallyAdjustsScrollViewInsets = false
        
        guard let user = services.globalModelsCoordinator.loggedInUser else {
            
            backButtonTapped(self)
            return
            
        }
      
        
        let rightButton = UIBarButtonItem(title: R.string.maverickStrings.pick(), style: .plain, target: self, action: #selector(saveChangesTapped(_:)))
        
        navigationItem.rightBarButtonItem = rightButton
        
        
        view.backgroundColor = .white
        
        loggedInUser = user
        
        collectionView.register(R.nib.coverCollectionViewCell)
        collectionView.delegate = self
        collectionView.dataSource = self
        // Setup navigation
        
       showNavBar(withTitle:  R.string.maverickStrings.editCoverTitle())
        
        standardCovers = services.globalModelsCoordinator.getPresetCovers()
        
        ProfileEditCoverViewController.selectedId = Int(loggedInUser.profileCoverPresetImageId ?? "0") ??  0
        
         if let coverPath =  user.profileCover {
            
            if let coverPathUrl = coverPath.getUrlForSize(size: backgroundImage.frame), let url = URL(string: coverPathUrl) {
                
                backgroundImage?.kf.setImage(with: url, options: [.transition(.fade(UIImage.fadeInTime))])
                
            } else {
                
                backgroundImage.image = nil
                
            }
            
        }
        
    }
   
}

extension ProfileEditCoverViewController : UICollectionViewDataSource , UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
      
        guard let standardCovers = standardCovers else { return }
        ProfileEditCoverViewController.selectedId = Int(standardCovers[safe: indexPath.row]?.getCoverId() ?? "-1") ?? -1
        if let cell = collectionView.cellForItem(at: indexPath) as? CoverCollectionViewCell {

            backgroundImage.image = cell.coverImage.image

        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
     
        return standardCovers?.count ?? 0
   
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: R.reuseIdentifier.coverId,
                                                      for: indexPath)
         if let coverpath = standardCovers?[safe: indexPath.row]?.getUrlForSize(size: cell?.contentView.frame) {
            
            cell?.setCoverImage(coverPath: coverpath)
            
        }
    
        return cell ?? UICollectionViewCell()
   
    }
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width/2 - 2.5, height: collectionView.frame.width / 2 * 2 / 3 )
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 5.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 5.0
    }
    
    
}

