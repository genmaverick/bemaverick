//
//  Double+Extensions.swift
//  BeMaverick
//
//  Created by David McGraw on 10/26/17.
//  Copyright © 2017 BeMaverick. All rights reserved.
//

import Foundation

extension Double {
    
    /**
     Round to a number of places
     */
    func rounded(toPlaces places: Int) -> Double {
        
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
        
    }
    
}
