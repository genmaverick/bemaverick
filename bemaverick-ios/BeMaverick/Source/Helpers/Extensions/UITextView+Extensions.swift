//
//  UITextView+Extensions.swift
//  BeMaverick
//
//  Created by Garrett Fritz on 1/17/18.
//  Copyright © 2018 BeMaverick. All rights reserved.
//

import Foundation

extension UITextView {
    
    
    func centerVertically() {
        
        let fittingSize = CGSize(width: bounds.width, height: CGFloat.greatestFiniteMagnitude)
        let size = sizeThatFits(fittingSize)
        let topOffset = (bounds.size.height - size.height * zoomScale) / 2
        let positiveTopOffset = max(1, topOffset)
        contentOffset.y = -positiveTopOffset
        
    }
        
    
}
