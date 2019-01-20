//
//  UIDevice+Extensions.swift
//  BeMaverick
//
//  Created by David McGraw on 9/19/17.
//  Copyright © 2017 BeMaverick. All rights reserved.
//

import UIKit

extension UIDevice {
    
    /// Quickily check if the application is running in a simulator
    static var isSimulator: Bool {
        
        #if arch(i386) || arch(x86_64)
            return true
        #else
            return false
        #endif
        
    }
    
}
