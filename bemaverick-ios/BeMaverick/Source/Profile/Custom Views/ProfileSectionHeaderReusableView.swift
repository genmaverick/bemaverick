//
//  ProfileSectionHeaderReusableView.swift
//  Maverick
//
//  Created by Garrett Fritz on 3/5/18.
//  Copyright © 2018 BeMaverick. All rights reserved.
//

import Foundation

protocol ProfileSectionHeaderDelegate : class {
    func segmentChanged(index : Int)
}
class ProfileSectionHeaderReusableView : SectionHeaderCell {
    
    /// segmented view control
    @IBOutlet weak var segmentViewControl: MaverickSegmentedControl!
    
    /**
     Segment tapped action
     */
    @IBAction func segmentChanged(_ sender: Any) {
        
        delegate?.segmentChanged(index: segmentViewControl.selectedSegmentIndex)
        
    }
    
    /// flag to check for initialization
    private var isInitialized = false
    /// tap delegate
    weak var delegate : ProfileSectionHeaderDelegate?
    /// segments to show
    var segments : [ProfileFilterMode] = []
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        backgroundColor = UIColor.MaverickTabBarBackgroundColor
        segmentViewControl.removeAllSegments()
        
    }
    
    /**
     Does nothing for this view
     */
    override func distanceToTop(distance : CGFloat )
    {
       
        
    }
    
    /**
     Setup view with given segments
     */
    func configure(sections: [ProfileFilterMode]?, selected : ProfileFilterMode) {
        
        guard !isInitialized, let sections = sections else { return }
        isInitialized = true
        layoutSubviews()
        layoutIfNeeded()
        
        for i in 0 ..< sections.count {
            
            segmentViewControl.insertSegment(withTitle: sections[i].rawValue, at: i, animated: false)
            if sections[i] == selected {
                segmentViewControl.selectedSegmentIndex = i
            }
            
        }
        
    }
    
}
