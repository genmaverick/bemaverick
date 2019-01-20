//
//  MaverickPicker.swift
//  Maverick
//
//  Created by Garrett Fritz on 3/29/18.
//  Copyright © 2018 BeMaverick. All rights reserved.
//

import Foundation
import UIKit
import Photos

@objc protocol MaverickPickerDelegate : class {
    
    func imageSelected(image : UIImage)
    @objc optional func cameraModeSelected()

}

class MaverickPicker: ViewController {
    
    // MARK: - IBOutlets
    
    /// A collection view used to display the fetched content
    @IBOutlet weak var collectionView: UICollectionView!
    
    /// Loading view for fetching networked assets
    @IBOutlet weak var loadingView: LoadingView!
    
    weak var delegate : MaverickPickerDelegate?
    // MARK: - IBActions
    static var selectedImage : UIImage?
    /**
     Leave the asset selector
     */
    @IBAction override func backButtonTapped(_ sender: Any) {
        
        MaverickPicker.selectedImage = nil
        if let nav = navigationController, nav.childViewControllers.count > 1 {
            
            nav.popViewController(animated: true)
        
        } else {
        
            dismiss(animated: true, completion: nil)
        
        }
    
    }
    
    
    
    var aspectRatio : CGFloat = 1.0
    
    // MARK: - Public Properties
    
    /// The result set fetched from the `Photos` framework
    fileprivate(set) var results: PHFetchResult<PHAsset>?
    
    /// Flag to indicate if this picker is for a non-post flow
    var forNonPostFlow = false
    
    // MARK: - Private Properties
    
    /// Caching image manager for the content previews
    fileprivate var imageManager: PHCachingImageManager?
    
    /// The selected asset the user is adding
    fileprivate var selectedAsset: AVAsset?
    
    var shouldCrop = true
    
    // MARK: - Lifecycle
    
    deinit {
            PHPhotoLibrary.shared().unregisterChangeObserver(self)
        log.verbose("💥")
    }
    
    override func viewDidLoad() {
        
        hasNavBar = true
        super.viewDidLoad()
        
        configureView()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        validateLibraryPermissionAndFetch()
        
    }
    
    // MARK: - Private Methods
    
    fileprivate func configureView() {
        // iOS 10 fix to not have white spacing on top
        automaticallyAdjustsScrollViewInsets = false
        
        // Monitor for changes
        PHPhotoLibrary.shared().register(self)
        
        // Fetch videos
        validateLibraryPermissionAndFetch()
        view.backgroundColor = .white
        showNavBar(withTitle: "SELECT IMAGE")
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: R.image.back_purple(),
                                                           style: .plain,
                                                           target: self,
                                                           action: #selector(backButtonTapped(_:)))
        
        navigationItem.leftBarButtonItem?.tintColor = UIColor.MaverickBadgePrimaryColor
        navigationItem.rightBarButtonItem = nil
        
    }
    
    /**
     Checks system photo library permissions and fetches video assets upon
     success
     */
    fileprivate func validateLibraryPermissionAndFetch() {
        
        let status = PHPhotoLibrary.authorizationStatus()
        if status == .authorized {
            
            fetchVideoAssets()
        
        } else if status == .denied || status == .restricted {
        
            let alert = UIAlertController(title: "Need Permission", message: "Please go to your Settings and grant permission for us to see your photos", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Go to Settings", style: .default){action in
                guard let settingsUrl = URL(string: UIApplicationOpenSettingsURLString) else {
                    return
                }
                
                if UIApplication.shared.canOpenURL(settingsUrl) {
                    UIApplication.shared.open(settingsUrl, options: [:], completionHandler: nil)
                }
            })
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { result in
                
                self.backButtonTapped(self)
                
            })
            present(alert, animated: true, completion: nil)
            return
        
        } else {
            
            PHPhotoLibrary.requestAuthorization { status in
                
                DispatchQueue.main.async {
                
                    self.validateLibraryPermissionAndFetch()
                
                }
            }
            
        }
        
    }
    
    /**
     Fetch a list of video assets by `creationDate`
     */
    fileprivate func fetchVideoAssets() {
        
        imageManager = PHCachingImageManager()
        
        let options = PHFetchOptions()
        options.sortDescriptors = [ NSSortDescriptor(key: "creationDate", ascending: false) ]
        options.predicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.image.rawValue)
      
        
        options.fetchLimit = 1000
        
        results = PHAsset.fetchAssets(with: options)
        
        collectionView.reloadData()
        
    }
    
    
    
}


extension MaverickPicker: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int
    {
        return results?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: R.reuseIdentifier.assetId,
                                                            for: indexPath) else
        {
            fatalError("Unexpected cell in asset selector collection view")
        }
        
        if let asset = results?.object(at: indexPath.item) {
        
            cell.stringIdentifier = asset.localIdentifier
            
            imageManager?.requestImage(for: asset,
                                      targetSize: CGSize(width: 100, height: 100),
                                      contentMode: .aspectFill,
                                      options: nil)
            { (image, _) in
                
                if cell.stringIdentifier == asset.localIdentifier && image != nil {
                    cell.imageView?.image = image
                }
                
            }
            
        }
        
        return cell
        
    }
    
}

extension MaverickPicker: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
        
        guard let asset = results?.object(at: indexPath.item) else { return }
        
        if forNonPostFlow {
            requestImageForNonPostFlow(forAsset: asset)
        } else {
            requestImage(forAsset: asset)
        }
        
    }
    
    private func requestImageForNonPostFlow(forAsset asset: PHAsset) {
        
        let options = PHImageRequestOptions()
        options.deliveryMode = .highQualityFormat
        options.isNetworkAccessAllowed = true
        
        imageManager?.requestImageData(for: asset, options: options, resultHandler: { (data, _, _, _) in
            
            guard let data = data else {
                
                let alert = UIAlertController(title: "Whoops!", message: "Unable the load this selection. Please try again.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                return
                
            }
            
            self.selectedImage = UIImage(data: data)
            
            DispatchQueue.main.async {
                
                let trimmer = AssetCropperForNonPostFlowViewController()
                trimmer.photo = self.selectedImage!
                trimmer.delegate = self.delegate
                trimmer.aspectRatioValue = self.aspectRatio
                self.navigationController?.pushViewController(trimmer, animated: true)
                
            }
            
        })
        
    }
    
    private func requestImage(forAsset asset: PHAsset) {
        
        let options = PHImageRequestOptions()
        options.deliveryMode = .highQualityFormat
        options.resizeMode = .exact
        options.isNetworkAccessAllowed = true

        imageManager?.requestImage(for: asset,
                                   targetSize: CGSize(width: Constants.CameraManagerExportSize.width , height: Constants.CameraManagerExportSize.height),
                                   contentMode: PHImageContentMode.aspectFill,
                                   options: options)
        { (image, _) in
            
            guard let image = image else {
                
                let alert = UIAlertController(title: "Whoops!", message: "Unable the load this selection. Please try again.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                return
                
            }
            
            MaverickPicker.selectedImage = image
            
            if self.shouldCrop {
                DispatchQueue.main.async {
                    
                    self.performSegue(withIdentifier: R.segue.maverickPicker.sendToCropper,
                                      sender: self)
                    
                }
            } else {
             
                self.dismiss(animated: true, completion: {
                    
                    self.delegate?.imageSelected(image: image)
                
                })
    
            }
            
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let vc = R.segue.maverickPicker.sendToCropper(segue: segue)?.destination {
            vc.aspectRatio = aspectRatio
            vc.delegate = delegate
            vc.imageToCrop =  MaverickPicker.selectedImage
           
        }
        
    }
    
}

extension MaverickPicker: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        let width = (view.bounds.size.width / 3) - 1
        return CGSize(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat
    {
        return 1
    }
    
}

extension MaverickPicker: PHPhotoLibraryChangeObserver {
    
    /**
     Change notifications may be made on a background queue. Re-dispatch to the
     main queue before acting on the change as we'll be updating the UI.
     */
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        
        DispatchQueue.main.sync {
            
            // Something for the future... insert/reload items if user leaves/returns
            
        }
    }
}

