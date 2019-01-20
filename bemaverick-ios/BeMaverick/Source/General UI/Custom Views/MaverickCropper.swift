//
//  MaverickCropper.swift
//  Maverick
//
//  Created by Garrett Fritz on 3/29/18.
//  Copyright © 2018 BeMaverick. All rights reserved.
//

import UIKit

class MaverickCropper: ViewController, UIScrollViewDelegate {
    
    var aspectRatio : CGFloat = 1.0
    
    @IBOutlet weak var cropHeight: NSLayoutConstraint!
    var imageToCrop : UIImage?
      var delegate : MaverickPickerDelegate?
    
    @IBOutlet var scrollView: UIScrollView!{
        didSet{
            scrollView.delegate = self
            scrollView.minimumZoomScale = 1.0
            scrollView.maximumZoomScale = 5.0
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        cropHeight.constant = view.frame.width / aspectRatio
        
        view.layoutIfNeeded()
    }
   
    
    @IBOutlet var imageView: UIImageView!
    
    @IBOutlet var cropAreaView: UIView!
    
    var cropArea:CGRect{
       
        get{
        
            var factor = imageView.image!.size.width/view.frame.width
            let factorH = imageView.image!.size.height/view.frame.width
            if factor < factorH {
                factor = factorH
            }
            let scale = 1/scrollView.zoomScale
            let imageFrame = imageView.imageFrame()
            let x = (scrollView.contentOffset.x + cropAreaView.frame.origin.x - imageFrame.origin.x) * scale * factor
            let y = (scrollView.contentOffset.y +  imageFrame.origin.y) * scale * factor
            let width = cropAreaView.frame.size.width * scale * factor
            let height = cropAreaView.frame.size.height * scale * factor
            return CGRect(x: x, y: y, width: width, height: height)
        
        }
    }
    
    override func viewDidLoad() {
        
        hasNavBar = true
        super.viewDidLoad()
        imageView.image = imageToCrop
        view.backgroundColor = .white
        
        self.automaticallyAdjustsScrollViewInsets = false
        
        let rightButton = UIBarButtonItem(title: R.string.maverickStrings.save(), style: .plain, target: self, action: #selector(crop(_:)))
        
        navigationItem.rightBarButtonItem = rightButton
        
        showNavBar(withTitle: "Crop Image")
        
        
        
        
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        
        return imageView
    
    }
    
    
    
    @IBAction func crop(_ sender: UIButton) {
        let croppedCGImage = imageView.image?.cgImage?.cropping(to: cropArea)
        let croppedImage = UIImage(cgImage: croppedCGImage!)
        imageView.image = croppedImage
        scrollView.zoomScale = 1
        
        delegate?.imageSelected(image:  imageView.image!)
        navigationController?.dismiss(animated: true, completion: nil)
    }
    
}

extension UIImageView{
    func imageFrame()->CGRect{
        let imageViewSize = self.frame.size
        guard let imageSize = self.image?.size else{return CGRect.zero}
        let imageRatio = imageSize.width / imageSize.height
        let imageViewRatio = imageViewSize.width / imageViewSize.height
        
        if imageRatio < imageViewRatio {
            let scaleFactor = imageViewSize.height / imageSize.height
            let width = imageSize.width * scaleFactor
            let topLeftX = (imageViewSize.width - width) * 0.5
            return CGRect(x: topLeftX, y: 0, width: width, height: imageViewSize.height)
        }else{
            let scalFactor = imageViewSize.width / imageSize.width
            let height = imageSize.height * scalFactor
            let topLeftY = (imageViewSize.height - height) * 0.5
            return CGRect(x: 0, y: topLeftY, width: imageViewSize.width, height: height)
        }
    }
}

