//
//  Rescale.swift
//  BeMaverick
//
//  Created by David McGraw on 1/8/18.
//  Copyright © 2018 BeMaverick. All rights reserved.
//

import Foundation

/**
 Scale a number within a Range (min, max)
 
    i.e. Rescale(from: (10, 100), to: (10, 40)).rescale(10)
 */
struct Rescale<Type : BinaryFloatingPoint> {
    
    typealias RescaleDomain = (lowerBound: Type, upperBound: Type)
    
    var fromDomain: RescaleDomain
    var toDomain: RescaleDomain
    
    init(from: RescaleDomain, to: RescaleDomain) {
        
        self.fromDomain = from
        self.toDomain = to
        
    }
    
    func interpolate(_ x: Type ) -> Type {
        return self.toDomain.lowerBound * (1 - x) + self.toDomain.upperBound * x;
    }
    
    func uninterpolate(_ x: Type) -> Type {
        
        let b = (self.fromDomain.upperBound - self.fromDomain.lowerBound) != 0 ?
            self.fromDomain.upperBound - self.fromDomain.lowerBound : 1 / self.fromDomain.upperBound;
        
        return (x - self.fromDomain.lowerBound) / b
        
    }
    
    func rescale(_ x: Type )  -> Type {
        return interpolate( uninterpolate(x) )
    }
    
}

