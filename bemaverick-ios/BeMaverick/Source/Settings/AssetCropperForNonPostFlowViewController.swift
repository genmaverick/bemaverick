//
//  AssetCropperForNonPostFlowViewController.swift
//  Maverick
//
//  Created by Chris Garvey on 9/10/18.
//  Copyright © 2018 BeMaverick. All rights reserved.
//

import UIKit
import Photos


class AssetCropperForNonPostFlowViewController: UIViewController {
    
    // MARK: - IBOutlet
    
    /// Main scroll view
    @IBOutlet weak var scrollView: UIScrollView!
    
    /// Scroll view content width
    @IBOutlet weak var scrollViewContentWidth: NSLayoutConstraint!
    
    /// Scroll view content height
    @IBOutlet weak var scrollViewContentHeight: NSLayoutConstraint!
    
    @IBOutlet weak var previewContentImage: UIView!

    @IBOutlet weak var doneButton: UIButton!

    @IBOutlet weak var imagePreviewView: UIImageView!
    
    @IBOutlet weak var editorContentView: UIView!
    
    @IBOutlet weak var aspectRatio: NSLayoutConstraint!
    
    @IBOutlet weak var topConstraintForPreviewContentView: NSLayoutConstraint!
    
    @IBOutlet weak var upperNavBuffer: UIView!
    
    @IBOutlet weak var upperNav: UIView!
    
    // MARK: - IBActions
    
    @IBAction func backButtonTapped(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func doneButtonTapped(_ sender: Any) {
        
        doneButton.isEnabled = false
        
        if let _ = photo {
            
            let image = getCroppedPreviewImage()
            delegate?.imageSelected(image: image)
            navigationController?.dismiss(animated: true, completion: nil)

        }
        
    }
    
    
    // MARK: - Public Properties
    
    /// A photo that can be cropped
    var photo: UIImage?

    var delegate: MaverickPickerDelegate?
    
    var aspectRatioValue: CGFloat = 1.0

    // MARK: - Lifecycle
    
    deinit {
        log.verbose("💥")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureView()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        configurePreview()
        
    }
    
    
    // MARK: - Private Methods
    
    func configureView() {
        navigationController?.setNavigationBarHidden(true, animated: false)
        doneButton.titleLabel?.textColor = UIColor.MaverickBadgePrimaryColor
    }
    
    /**
     Configure a preloaded asset from Asset Selection or from an index tapped
     on a timeline view
     */
    fileprivate func configurePreview() {
        
        aspectRatio = changeMultiplier(toNewValue: aspectRatioValue, forConstraint: aspectRatio)
        
        imagePreviewView.image = photo
        scrollView.zoomScale = 1.0
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 5.0
        
        if let size = photo?.size {
            
            if size.width < size.height {
                
                let ratio = size.height / size.width
                scrollViewContentWidth.constant = scrollView.bounds.width
                scrollViewContentHeight.constant = scrollViewContentWidth.constant * ratio
                
            } else {
                
                let ratio = size.width / size.height
                scrollViewContentHeight.constant = scrollView.bounds.height
                scrollViewContentWidth.constant = scrollView.bounds.height * ratio
                
            }
            
        }
        
        let availableHeight = view.frame.size.height
        let contentHeight = aspectRatioValue == 1.0 ? view.frame.width : view.frame.width * 3/4
        let newConstraintForHeight = (availableHeight - contentHeight - upperNavBuffer.bounds.height - upperNav.bounds.height) / 2 
        topConstraintForPreviewContentView.constant = newConstraintForHeight
        
    }
    
    func changeMultiplier(toNewValue multiplierValue: CGFloat, forConstraint constraint: NSLayoutConstraint) -> NSLayoutConstraint {
        
        NSLayoutConstraint.deactivate([constraint])
        
        let newConstraint = NSLayoutConstraint(
            item: constraint.firstItem!,
            attribute: constraint.firstAttribute,
            relatedBy: constraint.relation,
            toItem: constraint.secondItem,
            attribute: constraint.secondAttribute,
            multiplier: multiplierValue,
            constant: constraint.constant)
        
        newConstraint.priority = constraint.priority
        
        NSLayoutConstraint.activate([newConstraint])
        return newConstraint
        
    }
    
    /**
     Get a cropped image based on where the mask overlay
     */
    fileprivate func getCroppedPreviewImage() -> UIImage {
        return UIImage(view: previewContentImage)
    }
    
}

extension AssetCropperForNonPostFlowViewController: UIScrollViewDelegate {
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return editorContentView
    }
    
}
