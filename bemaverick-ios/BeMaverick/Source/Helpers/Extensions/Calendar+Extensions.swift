//
//  Calendar+Extensions.swift
//  BeMaverick
//
//  Created by David McGraw on 10/18/17.
//  Copyright © 2017 BeMaverick. All rights reserved.
//

import Foundation

extension Calendar {
    
    // MARK: - Public Methods
    
    /**
     Returns the difference between two dates using a custom format
     */
    func dateComponents(_ components: Set<Calendar.Component> = [.day, .hour, .minute, .second],
                        from date: String,
                        to end: String,
                        forFormat format: String = "yyyy-MM-dd'T'HH:mm:ssZZZZZ") -> DateComponents?
    {
        
        let formatter = DateFormatter()
        formatter.dateFormat = format
        
        guard let start = formatter.date(from: date), let end = formatter.date(from: end) else {
                return nil
        }
        
        return dateComponents(components, from: start, to: end)
        
    }
    
}
