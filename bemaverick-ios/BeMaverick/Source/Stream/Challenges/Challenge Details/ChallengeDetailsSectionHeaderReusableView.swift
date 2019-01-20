//
//  ChallengeDetailsSectionHeaderReusableView.swift
//  Maverick
//
//  Created by Garrett Fritz on 3/5/18.
//  Copyright © 2018 BeMaverick. All rights reserved.
//

import Foundation

class ChallengeDetailsSectionHeaderReusableView : SectionHeaderCell {
    
    /// title of section
    @IBOutlet weak var label: UILabel!
    /// constraint to center title on reaching top
    @IBOutlet weak var labelLeadingEdge: NSLayoutConstraint!
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        backgroundColor = UIColor.MaverickProfilePowerBackgroundColor
        label.textColor = UIColor.MaverickDarkTextColor
        
    }
    
    /**
     used to offset views based on distance to top
     */
    override func distanceToTop(distance : CGFloat )
    {
        var percent : CGFloat = 1
        if distance > maxDistance {
            percent = 1
        } else if distance < 0 {
            percent = 0
        } else {
            percent = distance / maxDistance
        }
        
        percent  = 1
        if distance > maxFarDistance {
            percent = 1
        } else if distance < 0 {
            percent = 0
        } else {
            percent = distance / maxFarDistance
        }
        
        let centeringDistance = (frame.width - (label.attributedText?.size().width)!) / 2
        
        labelLeadingEdge.constant = 10 + ((centeringDistance - 10) * (1 - percent) )
        
    }
    
    /**
     Set title of view
     */
    func configure(title: String) {
        
        label.text = title
        
    }
    
}
