//
//  Int+Extensions.swift
//  BeMaverick
//
//  Created by David McGraw on 1/6/18.
//  Copyright © 2018 BeMaverick. All rights reserved.
//

import Foundation

extension Int {
    
    /**
     * Returns a random integer in the range min...max
     */
    public static func random(min: Int, max: Int) -> Int {
        return Int(arc4random_uniform(UInt32(max - min + 1))) + min
    }
    
}
