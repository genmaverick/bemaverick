//
//  BadgerView.swift
//  Maverick
//
//  Created by Garrett Fritz on 2/22/18.
//  Copyright © 2018 BeMaverick. All rights reserved.
//

import Foundation


class BadgerHorizontalView : BadgerView {
    // MARK: - IBOutlets
  
    override func instanceFromNib() -> UIView {
    
        return R.nib.badgerHorizontalView.firstView(owner: self)!
        
    }
    
   
    
    
}

