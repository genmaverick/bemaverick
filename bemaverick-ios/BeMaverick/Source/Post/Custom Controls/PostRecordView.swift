//
//  PostRecordView.swift
//  BeMaverick
//
//  Created by David McGraw on 9/11/17.
//  Copyright © 2017 BeMaverick. All rights reserved.
//

import UIKit

class PostRecordView: UIView {
    
    // MARK: - Private Properties
    
    /// The shape layer for the 'ring'
    fileprivate var ringShapeLayer: CAShapeLayer?
    
    // MARK: - Lifecycle
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        configureView()
        
    }
    
    // MARK: - Public Methods
    
    /*
     Begin animating the shape layer ring
     */
    open func startAnimation(withDuration duration: CGFloat) {
        
        let anim = CABasicAnimation(keyPath: "strokeEnd")
        anim.duration = 60
        anim.fromValue = 0
        anim.toValue = 1.0
        
        ringShapeLayer?.add(anim, forKey: "strokeEnd")
        
    }
    
    /*
     Remove the progress animation
     */
    open func stopAnimation() {
        ringShapeLayer?.removeAllAnimations()
    }
    
    // MARK: - Private Methods
    
    fileprivate func configureView() {
        
        /// Create a circle path
        let path = UIBezierPath(arcCenter: CGPoint(x: frame.size.width / 2, y: frame.size.width / 2),
                                radius: frame.size.width / 2,
                                startAngle: CGFloat(.pi * -1.0) / 2.0,
                                endAngle: 3.0 * CGFloat(.pi / 2.0),
                                clockwise: true)
        
        ringShapeLayer = CAShapeLayer()
        ringShapeLayer!.path = path.cgPath
        ringShapeLayer!.strokeColor = UIColor(red: 33.0/255.0, green: 186.0/255.0, blue: 190.0/255.0, alpha: 1.0).cgColor
        ringShapeLayer!.fillColor = nil
        ringShapeLayer!.lineWidth = 4.0
        ringShapeLayer!.strokeEnd = 0.0
        
        layer.addSublayer(ringShapeLayer!)
        
    }
    
}
