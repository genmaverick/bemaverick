//
//  UIView+Extensions.swift
//  BeMaverick
//
//  Created by David McGraw on 9/27/17.
//  Copyright © 2017 BeMaverick. All rights reserved.
//

import UIKit
import ObjectiveC
import Dispatch

private var GLOWVIEW_KEY = "GLOWVIEW"

extension UIView {
    
    /// An identifier for a custom border layer
    fileprivate var borderIdentifier: String { return "pathBorderLayer" }
    
    /// Search the view's sublayers for the layer named `borderIdentifier`
    fileprivate var borderShapeLayer: CAShapeLayer? {
        
        return layer.sublayers?.filter({ layer -> Bool in
            return layer.name == self.borderIdentifier && (layer as? CAShapeLayer) != nil
        }).first as? CAShapeLayer
        
    }
    
    func takeScreenshot() -> UIImage {
        
        // Begin context
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, false, UIScreen.main.scale)
        
        // Draw view in that context
        drawHierarchy(in: self.bounds, afterScreenUpdates: true)
        
        // And finally, get image
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        if (image != nil)
        {
            return image!
        }
        return UIImage()
    }
    
    
    /**
     Applies a standard gradient from left to right with the primary app colors
     */
    @discardableResult
    func applyGradient(startColor: UIColor = UIColor.gradientMutedStart,
                       endColor: UIColor   = UIColor.gradientMutedEnd,
                       startPoint: CGPoint = CGPoint(x: 0.0, y: 0.5),
                       endPoint: CGPoint   = CGPoint(x: 1.0, y: 0.5)) -> CAGradientLayer
    {
        
        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.frame = bounds
        gradient.colors = [ startColor.cgColor, endColor.cgColor ]
        gradient.locations = [ 0.0, 1.0 ]
        gradient.startPoint = startPoint
        gradient.endPoint = endPoint
        
        layer.insertSublayer(gradient, at: 0)
        
        backgroundColor = .clear
        
        return gradient
        
    }
    
    /**
     Applies a clean border to the view
     */
    func applyBorder(_ color: UIColor = .white, width: CGFloat = 4) {
        
        let path = UIBezierPath(roundedRect: bounds,
                                cornerRadius: layer.cornerRadius)
        
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
        
        var border = borderShapeLayer
        if border == nil {
            border = CAShapeLayer()
            border!.name = borderIdentifier
            layer.addSublayer(border!)
        }
        
        borderShapeLayer!.frame = bounds
        borderShapeLayer!.path = path.cgPath
        borderShapeLayer!.fillColor = UIColor.clear.cgColor
        borderShapeLayer!.strokeColor = color.cgColor
        borderShapeLayer!.lineWidth = width
        
    }
    
    
    func addShadow(color: UIColor = .black,
                   alpha: Float = 0.4,
                   x: CGFloat = 0,
                   y: CGFloat = 0,
                   blur: CGFloat = 2.0 ,
                   spread: CGFloat = 0) {
        
        layer.applySketchShadow(color: color, alpha: alpha, x: x, y: y, blur: blur, spread: spread)
        
    }
    /**
     Update standard shadow
     */
    func addShadow(alpha : Float, offset : CGSize = CGSize(width: 2, height: 2), radius : CGFloat = 2.0) {
        
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowRadius = 2.0
        layer.shadowOpacity = alpha
        layer.shadowOffset = CGSize(width: 2, height: 2)
        layer.masksToBounds = false
    }
    
    /**
     Update an existing border if available
     */
    func updateBorder(_ color: UIColor? = nil, width: CGFloat? = nil) {
        
        if color != nil {
            borderShapeLayer?.strokeColor = color!.cgColor
        }
        
        if width != nil {
            borderShapeLayer?.lineWidth = width!
        }
        
    }
    
    /**
     Remove an existing border if it exists
     */
    func removeBorder() {
        
        layer.mask = nil
        borderShapeLayer?.removeFromSuperlayer()
        
    }
    
   /**
     Create an image from the existing view
     */
    func imageFromView(size: CGSize = .zero) -> UIImage? {
        
        var mutableSize = size
        if mutableSize == .zero {
            mutableSize = bounds.size
        }

        let renderer = UIGraphicsImageRenderer(size: mutableSize)
        return renderer.image { _ in
            drawHierarchy(in: bounds, afterScreenUpdates: true)
        }
        
    }
    
    
    var glowView: UIView? {
        get {
            return objc_getAssociatedObject(self, &GLOWVIEW_KEY) as? UIView
        }
        set(newGlowView) {
            objc_setAssociatedObject(self, &GLOWVIEW_KEY, newGlowView, .OBJC_ASSOCIATION_RETAIN)
        }
    }
    
    func startGlowingWithColor(color:UIColor, intensity:CGFloat) {
        self.startGlowingWithColor(color: color, fromIntensity: 0.1, toIntensity: intensity, repeat: true)
    }
    
    func startGlowingWithColor(color:UIColor, fromIntensity:CGFloat, toIntensity:CGFloat, repeat shouldRepeat:Bool) {
        // If we're already glowing, don't bother
        if self.glowView != nil {
            return
        }
        
        // The glow image is taken from the current view's appearance.
        // As a side effect, if the view's content, size or shape changes,
        // the glow won't update.
        var image:UIImage
        
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, false, UIScreen.main.scale); do {
            self.layer.render(in: UIGraphicsGetCurrentContext()!)
            
            let path = UIBezierPath(rect: CGRect(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height))
            
            color.setFill()
            
            path.fill(with: .sourceAtop, alpha:1.0)
            
            
            image = UIGraphicsGetImageFromCurrentImageContext()!
        }
        
        UIGraphicsEndImageContext()
        
        // Make the glowing view itself, and position it at the same
        // point as ourself. Overlay it over ourself.
        let glowView = UIImageView(image: image)
        glowView.center = self.center
        self.superview!.insertSubview(glowView, aboveSubview:self)
        
        // We don't want to show the image, but rather a shadow created by
        // Core Animation. By setting the shadow to white and the shadow radius to
        // something large, we get a pleasing glow.
        glowView.alpha = 0
        glowView.layer.shadowColor = color.cgColor
        glowView.layer.shadowOffset = CGSize.zero
        glowView.layer.shadowRadius = 10
        glowView.layer.shadowOpacity = 1.0
        
        // Create an animation that slowly fades the glow view in and out forever.
        let animation = CABasicAnimation(keyPath: "opacity")
        animation.fromValue = fromIntensity
        animation.toValue = toIntensity
        animation.repeatCount = shouldRepeat ? .infinity : 0 // HUGE_VAL = .infinity / Thanks http://stackoverflow.com/questions/7082578/cabasicanimation-unlimited-repeat-without-huge-valf
        animation.duration = 1.0
        animation.autoreverses = true
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        
        glowView.layer.add(animation, forKey: "pulse")
        
        // Finally, keep a reference to this around so it can be removed later
        self.glowView = glowView
    }
    
    func glowOnceAtLocation(point: CGPoint, inView view:UIView) {
        self.startGlowingWithColor(color: UIColor.white, fromIntensity: 0, toIntensity: 0.6, repeat: false)
        
        self.glowView!.center = point
        view.addSubview(self.glowView!)
        
        let delay: Double = 2 * Double(Int64(NSEC_PER_SEC))
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + delay) {
            self.stopGlowing()
        }
    }
    
    func glowOnce() {
        self.startGlowing()
        
        let delay: Double = 2 * Double(Int64(NSEC_PER_SEC))
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + delay) {
            self.stopGlowing()
        }
        
    }
    
    // Create a pulsing, glowing view based on this one.
    func startGlowing() {
        self.startGlowingWithColor(color: UIColor.white, intensity:0.6);
    }
    
    // Stop glowing by removing the glowing view from the superview
    // and removing the association between it and this object.
    func stopGlowing() {
        self.glowView!.removeFromSuperview()
        self.glowView = nil
    }
    
}


