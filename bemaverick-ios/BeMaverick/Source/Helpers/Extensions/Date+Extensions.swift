//
//  Date+Extensions.swift
//  BeMaverick
//
//  Created by Garrett Fritz on 1/29/18.
//  Copyright © 2018 BeMaverick. All rights reserved.
//

import Foundation


extension Date
{
    func toString( dateFormat format  : String ) -> String
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: self)
    }
    
}

