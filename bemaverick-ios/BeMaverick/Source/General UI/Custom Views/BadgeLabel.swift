//
//  BadgeLabel.swift
//  Maverick
//
//  Created by Garrett Fritz on 7/31/18.
//  Copyright © 2018 BeMaverick. All rights reserved.
//

import Foundation


class BadgeLabel : UILabel {
    
    var image : UIImage?
    var imageOffset : CGPoint?
    
    override var text: String? {
        
        didSet {
        
            drawImage()
        
        }
    
    }
    

    func setAsOverlay(first : String, last : String) {
        
        guard let image = image else {
            
            attributedText = nil
            return
            
        }
        
        textColor = UIColor.clear
        //Create Attachment
        let imageAttachment =  NSTextAttachment()
        imageAttachment.image = image
        //Set bound to reposition
        let imageOffset = self.imageOffset ?? CGPoint(x: 0.0, y: -3.0)
        imageAttachment.bounds = CGRect(x: imageOffset.x, y: imageOffset.y, width: imageAttachment.image!.size.width, height: imageAttachment.image!.size.height)
        //Create string with attachment
        let attachmentString = NSAttributedString(attachment: imageAttachment)
        //Initialize mutable string
        let attrs: [NSAttributedStringKey: Any] = [NSAttributedStringKey.font : R.font.openSansBold(size: 13.0)!]
        let completeText = NSMutableAttributedString(string: first, attributes: attrs)
        let lastText = NSMutableAttributedString(string: last)
        let  spacer = NSMutableAttributedString(string: " ")
        
        completeText.append(spacer)
        completeText.append(attachmentString)
        completeText.append(spacer)
        completeText.append(lastText)
        
        attributedText = completeText;
        
    }
    
    func drawImage() {
    
        guard let image = image, let text = text else { return }
        //Create Attachment
        let imageAttachment =  NSTextAttachment()
        imageAttachment.image = image
        //Set bound to reposition
        let imageOffset = self.imageOffset ?? CGPoint.zero
        imageAttachment.bounds = CGRect(x: imageOffset.x, y: imageOffset.y, width: imageAttachment.image!.size.width, height: imageAttachment.image!.size.height)
        //Create string with attachment
        let attachmentString = NSAttributedString(attachment: imageAttachment)
        //Initialize mutable string
        let completeText = NSMutableAttributedString(string: text)
         let  spacer = NSMutableAttributedString(string: " ")
        
        completeText.append(spacer)
        completeText.append(attachmentString)
        completeText.append(spacer)
        attributedText = completeText;
        
    }
    
}
