//
//  Collection+Extensions.swift
//  BeMaverick
//
//  Created by David McGraw on 10/3/17.
//  Copyright © 2017 BeMaverick. All rights reserved.
//

import Foundation

extension Collection {
    
    /**
     Convenience subscript to retrieve the element at the provided index. If out of bounds
     returns nils.
     */
    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
    
    
}
