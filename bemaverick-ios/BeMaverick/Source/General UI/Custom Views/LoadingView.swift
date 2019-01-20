//
//  LoadingView.swift
//  BeMaverick
//
//  Created by David McGraw on 2/4/18.
//  Copyright © 2018 BeMaverick. All rights reserved.
//

import UIKit

class LoadingView: UIView {
    
    // MARK: - Static
    
    class func instanceFromNib() -> LoadingView {
        return R.nib.loadingView.firstView(owner: nil)! as LoadingView
    }
    
    // MARK: - IBOutlets
    
    /// The refresh icon
    @IBOutlet weak var iconImageView: UIImageView!
    
    /// A title associated with the refresh
    @IBOutlet weak var titleLabel: UILabel!
    
    /// Progress for the loading view
    @IBOutlet weak var progressView: UIProgressView!
    
    // MARK: - Public Properties
    
    /// Whether the control is refreshing
    open var isRefreshing: Bool = false
    
    // MARK: - Public Methods
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        layer.cornerRadius = 14
        
    }
    
    open func updateProgress(progress: Float) {
        
        progressView?.isHidden = false
        progressView?.setProgress(progress, animated: true)
        
    }
    
    open func startAnimating() {
        
        progressView?.isHidden = true
        
        let anim = CABasicAnimation(keyPath: "transform.rotation.z")
        anim.toValue = -CGFloat(Double.pi * 2)
        anim.duration = 1.0
        anim.isCumulative = true
        anim.repeatCount = HUGE
        iconImageView.layer.add(anim, forKey: "rotation")
        
        self.isHidden = false
        UIView.animate(withDuration: 0.225) {
            self.alpha = 1.0
        }
        
    }
    
    open func stopAnimating() {
        
        UIView.animate(withDuration: 0.225, animations: {
            self.alpha = 0.0
        }) { done in
            
            self.isHidden = false
            self.layer.removeAllAnimations()
            self.iconImageView.transform = CGAffineTransform.identity
            
        }
    }
    
}
