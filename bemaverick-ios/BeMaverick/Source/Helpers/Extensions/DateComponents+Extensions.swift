//
//  DateComponents+Extensions.swift
//  BeMaverick
//
//  Created by David McGraw on 10/19/17.
//  Copyright © 2017 BeMaverick. All rights reserved.
//

import Foundation

extension DateComponents {
    
    /**
     Returns the time remaining as `(x) (component) LEFT`
     */
    func timeRemaining() -> String {
        
        var str = ""
        
        let year = self.year ?? 0
        let month = self.month ?? 0
        let day = self.day ?? 0
        let hour = self.hour ?? 0
        let min = self.minute ?? 0
        let sec = self.second ?? 0
        
        if year > 0 || month > 0 {
            
            if year == 0 {
                if month == 1 {
                    return "\(month) month \(day) days"
                }
                return "\(month) months"
            } else {
                return "\(year) year \(month) months"
            }
        }
        
        
        
        if day > 1 {
            str = "\(day) d"
        } else if day == 1 {
            str = "\(day)d"
        } else if hour > 1 {
            str = "\(hour)hr \(min)min"
        } else if min == 1 {
            str = "\(min)min"
        } else if min == 0 && sec == 0 {
            str = "EXPIRED"
        }
        
        
        return str
        
    }
    
    /**
     Returns the time remaining as `(x) (component) ago`
    */
    func timeRemainingForComment() -> String {
        
        var str = ""
        if let month = self.month, let day = self.day, let hour = self.hour, let min = self.minute, let sec = self.second {
        
            if month == 1 {
                str = "\(month) month ago"
            } else if month > 1 {
                str = "\(month) months ago"
            } else if day == 1 {
                str = "\(day) day ago"
            } else if day > 1 {
                str = "\(day) days ago"
            } else if hour == 1 {
                str = "\(hour) hour ago"
            } else if hour > 1 {
                str = "\(hour) hours ago"
            } else if min == 1 {
                str = "\(min) minute ago"
            } else if min > 1 {
                str = "\(min) minutes ago"
            } else if sec == 1 {
                str = "\(sec) second ago"
            } else if sec > 1 {
                str = "\(sec) seconds ago"
            }
            
        }
        
        return str
        
    }
    
}
