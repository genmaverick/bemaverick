//
//  UILabel+Extensions.swift
//  BeMaverick
//
//  Created by David McGraw on 1/5/18.
//  Copyright © 2018 BeMaverick. All rights reserved.
//

import UIKit

extension UILabel {
    
    /**
     Applies a default shadow to the text, offset 0, 1
    */
    open func applyDefaultDarkShadow() {
        
        layer.shadowOffset = CGSize(width: 0.0, height: 1.0)
        layer.shadowOpacity = 0.5
        layer.shadowRadius = 1.0
        layer.shouldRasterize = true
        
    }
    
    func addImage(initialText : String, endingText : String, image : UIImage?)
    {
        // create an NSMutableAttributedString that we'll append everything to
        let fullString = NSMutableAttributedString(string: initialText)
        
        // create our NSTextAttachment
        let image1Attachment = NSTextAttachment()
        image1Attachment.image = image
        let imageOffsetY:CGFloat = -((image?.size.height ?? 15) / 2)
        image1Attachment.bounds = CGRect(x: 0, y: imageOffsetY, width: image1Attachment.image!.size.width, height: image1Attachment.image!.size.height)
        
        // wrap the attachment in its own attributed string so we can append it
        let image1String = NSAttributedString(attachment: image1Attachment)
        
        // add the NSTextAttachment wrapper to our full string, then add some more text.
        fullString.append(image1String)
        fullString.append(NSAttributedString(string: endingText))
        
        // draw the result in a label
        attributedText = fullString
    }
    
}
