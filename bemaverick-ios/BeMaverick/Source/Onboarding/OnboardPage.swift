//
//  OnboardPage.swift
//  Maverick
//
//  Created by Garrett Fritz on 4/26/18.
//  Copyright © 2018 BeMaverick. All rights reserved.
//

import Foundation
import Kingfisher
class OnboardPage : UIViewController {
    
    
    @IBOutlet weak var topConstraintPhone: NSLayoutConstraint?
    @IBOutlet weak var topConstraintIpad: NSLayoutConstraint?
    @IBOutlet weak var fillBackground: UIImageView?
    @IBOutlet weak var lockImageView: UIImageView?
    @IBOutlet weak var trailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var leadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var widthConstraint: NSLayoutConstraint?
    @IBOutlet weak var backgroundImage: UIImageView!
    private var image : UIImage?
    private var fillBackgroundImage : UIImage?
    private var imageUrl : URL?
    private var locked : Bool = false
    private var widthConstraintValue : CGFloat?
    override func viewDidLoad() {
       
        super.viewDidLoad()
        backgroundImage.image = image
        
        if let widthConstraintValue = widthConstraintValue {
        
            trailingConstraint.isActive = false
            leadingConstraint.isActive = false
            widthConstraint?.constant = widthConstraintValue
            
            topConstraintPhone?.constant = 40
            topConstraintIpad?.constant = 40
           
        } else {
       
            widthConstraint?.isActive = false
      
        }
        
        lockImageView?.isHidden = !locked
        if let url = imageUrl {
            
            backgroundImage.kf.setImage(with: url)
            backgroundImage.contentMode = .scaleAspectFill
            
        }
        
        fillBackground?.image = fillBackgroundImage
    
    }
    
    func configure(with image : UIImage?, width : CGFloat? = nil, background : UIImage?) {
   
        self.image = image
        self.widthConstraintValue = width
        self.fillBackgroundImage = background
   
    }
    
    func configure(with imageUrl : URL?, locked : Bool) {
        
        self.imageUrl = imageUrl
        self.locked = locked
        
    }

}
