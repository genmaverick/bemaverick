//
//  MainTabBar.swift
//  BeMaverick
//
//  Created by David McGraw on 9/7/17.
//  Copyright © 2017 BeMaverick. All rights reserved.
//

import UIKit
import PureLayout

class MainTabBar: UITabBar {
    
    // MARK: - Private Properties
    
    
    fileprivate let defaultNoTextImageInset = UIEdgeInsetsMake(6, 0, -6, 0);
    
    // MARK: - Lifecycle
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        configureView()
        
        
        
    }
  
    
    /**
     Configure the tab bar for the main controller. Render as original for the
     selected state to properly display the image.
     */
    func configureView() {
        
        //this removes the hairline seperator
        clipsToBounds = true
        
        barTintColor = UIColor.white
        backgroundColor =  UIColor.MaverickTabBarBackgroundColor
        tintColor = UIColor.black

        
    }
    
}


