//
//  UIImage+Extensions.swift
//  BeMaverick
//
//  Created by David McGraw on 10/19/17.
//  Copyright © 2017 BeMaverick. All rights reserved.
//

import UIKit
import Photos
import PromiseKit
import Kingfisher

extension UIImage {
    
    // MARK: - Static
    static let fadeInTime = 0.1
    
    
    class func imageWithLayer(layer: CALayer) -> UIImage? {
        
        UIGraphicsBeginImageContextWithOptions(layer.bounds.size, layer.isOpaque, UIScreen.main.scale)
        layer.render(in: UIGraphicsGetCurrentContext()!)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img
        
    }
    
    
    static let defaultKingfisherDisplayOptions: [KingfisherOptionsInfoItem] = [.transition(.fade(fadeInTime)), .scaleFactor(UIScreen.main.scale)]
    
    class func imageWithColor(color: UIColor, size: CGSize) -> UIImage {
        
        let rect: CGRect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        color.setFill()
        UIRectFill(rect)
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
        
    }
    
    class func getLastPhotoLibraryImage(size: CGSize = CGSize(width: 100, height: 100),
                                        mediaType: PHAssetMediaType = .image,
                                        completionHandler: @escaping (_ image: UIImage?, _ count: Int) -> Void)
    {
        
        let options = PHFetchOptions()
        options.sortDescriptors = [NSSortDescriptor(key:"creationDate", ascending: false)]
        options.fetchLimit = 1
        
        let fetchResult: PHFetchResult = PHAsset.fetchAssets(with: mediaType, options: options)
        
        if fetchResult.count > 0 {
            
            options.fetchLimit = 0
            let totalCount = PHAsset.fetchAssets(with: mediaType, options: options).count
            
            let requestOptions = PHImageRequestOptions()
            requestOptions.isSynchronous = true
            
            PHImageManager.default().requestImage(for: fetchResult.object(at: 0) as PHAsset,
                                                  targetSize: size,
                                                  contentMode: .aspectFill,
                                                  options: requestOptions)
            { (image, _) in
                
                completionHandler(image, totalCount)
                
            }
            
        }
        
    }
    
    // MARK: - Public Methods
    
    /**
     Creates a precomposited rounded image from this object
     */
    var roundedImage: UIImage? {
        
        let rect = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContextWithOptions(size, false, 1)
        UIBezierPath(roundedRect: rect, cornerRadius: size.height).addClip()
        draw(in: rect)
        return UIGraphicsGetImageFromCurrentImageContext()
        
    }
    
    func tintedWithLinearGradientColors(colorsArr: [CGColor?]) -> UIImage? {
        
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale);
        let context = UIGraphicsGetCurrentContext()
        context?.translateBy(x: 0, y: self.size.height)
        context?.scaleBy(x: 1.0, y: -1.0)
        context?.setBlendMode(CGBlendMode.normal)
        let rect = CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height)
        
        // Create gradient
        
        let colors = colorsArr as CFArray
        let space = CGColorSpaceCreateDeviceRGB()
        let gradient = CGGradient.init(colorsSpace: space, colors: colors, locations: nil)
        // Apply gradient
        
        context?.clip(to: rect, mask: self.cgImage!)
        
        context?.drawLinearGradient(gradient!, start: CGPoint.zero, end: CGPoint(x: 0, y: self.size.height), options: CGGradientDrawingOptions(rawValue: 0))
        let gradientImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return gradientImage
        
    }
    
    convenience init(view: UIView) {
        UIGraphicsBeginImageContextWithOptions(view.frame.size, false, UIScreen.main.scale)
        
        view.layer.render(in:UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        self.init(cgImage: image!.cgImage!)
    }
    
}
