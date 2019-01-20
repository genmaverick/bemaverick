//
//  UINavigationController+Extensions.swift
//  BeMaverick
//
//  Created by David McGraw on 10/17/17.
//  Copyright © 2017 BeMaverick. All rights reserved.
//

import UIKit

extension UINavigationController {
    
    // MARK: - Public methods
    
    
    /**
     Removes the shadow image and sets the background
    */
    func setNavigationBarBackground(image: UIImage?) {
        
        navigationBar.setBackgroundImage(image, for: .default)
        navigationBar.layer.shadowColor = UIColor.black.cgColor
        navigationBar.layer.shadowOffset = CGSize(width: 0.0, height: 1.1)
        navigationBar.layer.shadowRadius = 1.0
        navigationBar.layer.shadowOpacity = 0.05
        navigationBar.layer.masksToBounds = false
        
        navigationBar.isTranslucent = true
        navigationBar.backgroundColor = .clear
        
    }
    
    /**
 
    */
    func setDefaultTitleAttributes(withColor color: UIColor = .black) {
        
        var attributes: [NSAttributedStringKey : Any] = [ : ]
        attributes[NSAttributedStringKey.foregroundColor] = color
        if let font = R.font.openSansRegular(size: 18.0) {
            attributes[NSAttributedStringKey.font] = font
        }
        navigationBar.titleTextAttributes = attributes
        
    }
        
    /**
     Styles the navigation bar with a transparent background and a back button
     */
    func setDefaultNavigationControllerStyle(_ vc: UIViewController) {
        
        navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationBar.shadowImage = UIImage()
        navigationBar.isTranslucent = true
        navigationBar.backgroundColor = .clear
        navigationBar.tintColor = .white
        
        vc.navigationItem.backBarButtonItem = UIBarButtonItem(title: " ", style: .plain, target: nil, action: nil)
        
    }
    
    /**
     Styles the navigation controller title
    */
    func setNavigationTitleAttributes(withFont font: UIFont, foregroundColor: UIColor) {
        
        var attributes: [NSAttributedStringKey : Any] = [ : ]
        attributes[NSAttributedStringKey.foregroundColor] = foregroundColor
        attributes[NSAttributedStringKey.font] = font
        navigationBar.titleTextAttributes = attributes
        navigationBar.tintColor = foregroundColor
        
    }
    
    /**
     
    */
    func setNavigationBarClear() {
        
        navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationBar.shadowImage = UIImage()
        navigationBar.isTranslucent = true
        navigationBar.backgroundColor = .clear
        navigationBar.tintColor = .white
        view.backgroundColor = .clear
        
    }
    
}
