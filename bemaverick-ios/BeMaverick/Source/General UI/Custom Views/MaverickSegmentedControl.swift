//
//  MaverickSegmentControl.swift
//  Maverick
//
//  Created by Garrett Fritz on 3/28/18.
//  Copyright © 2018 BeMaverick. All rights reserved.
//

import Foundation


class MaverickSegmentedControl : UISegmentedControl {
    
    private var underline : UIView?
    private var widthConstraint : NSLayoutConstraint?
    private var leadingConstraint : NSLayoutConstraint?
    var plain : Bool = true {
        
        didSet {
            
            underline?.backgroundColor =  plain ? UIColor.black : UIColor.MaverickPrimaryColor
            tintColor = plain ? UIColor.black : UIColor.MaverickPrimaryColor
            let fontBold = R.font.openSansBold(size: 14.0)!
            setTitleTextAttributes([NSAttributedStringKey.foregroundColor: tintColor, NSAttributedStringKey.font: fontBold], for: .selected)
            
        }
        
    }
    
    func getSegmentWidth() -> CGFloat {
        
        var segmentCount = numberOfSegments
        if segmentCount == 0 {
            segmentCount = 1
        }
        
        return frame.width / CGFloat(segmentCount)
        
    }
    
  
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        
        let currentIndex = selectedSegmentIndex
        super.touchesBegan(touches, with: event)
        
        if currentIndex == selectedSegmentIndex {
            sendActions(for: UIControlEvents.touchDown)
        }
        
    }
  
    override func didChangeValue(forKey key: String) {
        
        super.didChangeValue(forKey: key)
        
        if key == "selectedSegmentIndex" {
            
            var segmentCount = numberOfSegments
            if segmentCount == 0 {
                segmentCount = 1
            }
            
           
            if let underline = underline {
            
                bringSubview(toFront: underline)
            
            }
            
            setUnderlinePositionAndWidth()
            
        }
        
    }
    
    private func setUnderlinePositionAndWidth() {
        
        var segmentCount = numberOfSegments
        if segmentCount == 0 {
            segmentCount = 1
        }
        
        if selectedSegmentIndex >= 0, selectedSegmentIndex < numberOfSegments, let title = titleForSegment(at: selectedSegmentIndex) {
            
            let attr = titleTextAttributes(for: .selected)
            
            let size: CGSize = title.size(withAttributes: attr as? [NSAttributedStringKey : Any])
            let fullWidthValue = frame.width / CGFloat(segmentCount)
            let widthValue = max(size.width, 70)
            
            widthConstraint?.constant = widthValue
            
            let value = ((frame.width / CGFloat(segmentCount)) * CGFloat(selectedSegmentIndex ))
            leadingConstraint?.constant = value + ((fullWidthValue - widthValue) / 2)
            
            UIView.animate(withDuration: 0.25, animations: {
                self.layoutIfNeeded()
            })
            
        }
        
    }
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        underline = UIView(frame: CGRect(x: 0, y: 0, width: frame.width, height: 2))
        guard let underline = underline else { return }
        underline.backgroundColor =  plain ? UIColor.black : UIColor.MaverickPrimaryColor
        addSubview(underline)
        
        underline.autoPinEdge(.bottom, to: .bottom, of: self)
        
        tintColor = plain ? UIColor.black : UIColor.MaverickPrimaryColor
        let heightConstraint = NSLayoutConstraint(item: underline, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: 2)
        
        underline.addConstraint(heightConstraint)
        
        var segmentCount = numberOfSegments
        if segmentCount == 0{
            segmentCount = 1
        }
        let value = frame.width / CGFloat(segmentCount)
        widthConstraint = NSLayoutConstraint(item: underline, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: value)
        underline.addConstraint(widthConstraint!)
       leadingConstraint = underline.autoPinEdge(.leading, to: .leading, of: self, withOffset: 123)
        
        bringSubview(toFront: underline)
        
        let backgroundImage = UIImage.imageWithColor(color: backgroundColor ?? .clear, size: bounds.size)
        setBackgroundImage(backgroundImage, for: .normal, barMetrics: .default)
        setBackgroundImage(backgroundImage, for: .selected, barMetrics: .default)
        setBackgroundImage(backgroundImage, for: .highlighted, barMetrics: .default)
        let fontRegular = R.font.openSansRegular(size: 14.0)!
        let fontBold = R.font.openSansBold(size: 14.0)!
        let deviderImage = UIImage.imageWithColor(color: backgroundColor ?? .clear, size: CGSize(width: 1.0, height: bounds.size.height))
        setDividerImage(deviderImage, forLeftSegmentState: .selected, rightSegmentState: .normal, barMetrics: .default)
        setTitleTextAttributes([NSAttributedStringKey.foregroundColor: UIColor.MaverickTabBarUnselectedColor, NSAttributedStringKey.font: fontRegular], for: .normal)
        setTitleTextAttributes([NSAttributedStringKey.foregroundColor: tintColor, NSAttributedStringKey.font: fontBold], for: .selected)
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        var segmentCount = numberOfSegments
        if segmentCount == 0 {
            
            segmentCount = 1
        
        }
        
        setUnderlinePositionAndWidth()
        layoutIfNeeded()
        
    }
    
    override func insertSegment(withTitle title: String?, at segment: Int, animated: Bool) {
      
        super.insertSegment(withTitle: title, at: segment, animated: animated)
        let value = frame.width / CGFloat(numberOfSegments)
        widthConstraint?.constant = value
        layoutIfNeeded()
        
    }
    
    override func removeSegment(at segment: Int, animated: Bool) {
        
        super.removeSegment(at: segment, animated: animated)
        let value = frame.width / CGFloat(numberOfSegments)
        widthConstraint?.constant = value
        layoutIfNeeded()
    
    }
    
}
