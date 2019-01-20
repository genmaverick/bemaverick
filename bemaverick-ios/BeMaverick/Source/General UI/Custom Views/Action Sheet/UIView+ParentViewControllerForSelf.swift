//
//  UIView+ParentViewControllerForSelf.swift
//  Maverick
//
//  Created by Chris Garvey on 4/20/18.
//  Copyright © 2018 BeMaverick. All rights reserved.
//

import Foundation

extension UIView {
    
    var parentViewControllerForSelf: UIViewController? {
        
        var parentResponder: UIResponder? = self
        while parentResponder != nil {
            parentResponder = parentResponder!.next
            if let viewController = parentResponder as? UIViewController {
                return viewController
            }
        }
        return nil
    }
    
}
