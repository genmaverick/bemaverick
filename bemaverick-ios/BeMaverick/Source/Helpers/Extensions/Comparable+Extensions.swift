//
//  Comparable+Extensions.swift
//  BeMaverick
//
//  Created by David McGraw on 10/23/17.
//  Copyright © 2017 BeMaverick. All rights reserved.
//

import Foundation

extension Comparable {
    
    /**
     Clamp the value to the provided limits
     */
    func clamped(to limits: ClosedRange<Self>) -> Self {
        return min(max(self, limits.lowerBound), limits.upperBound)
    }
    
}
