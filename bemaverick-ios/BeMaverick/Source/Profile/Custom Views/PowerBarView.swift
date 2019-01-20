//
//  PowerBarView.swift
//  Maverick
//
//  Created by Garrett Fritz on 3/16/18.
//  Copyright © 2018 BeMaverick. All rights reserved.
//

import Foundation

class PowerBarView : UIView {

    /// Parent view
    @IBOutlet weak var view: UIView!
    /// Holding view
    @IBOutlet weak var containerView: UIView!
    /// creative button
    @IBOutlet weak var firstView: UIView!
    /// unique button
    @IBOutlet weak var secondView: UIView!
    /// daring button
    @IBOutlet weak var thirdView: UIView!
    /// unstoppable button
    @IBOutlet weak var fourthView: UIView!
    /// creative label
    @IBOutlet weak var firstLabel: UILabel!
    /// unique label
    @IBOutlet weak var secondLabel: UILabel!
    /// daring label
    @IBOutlet weak var thirdLabel: UILabel!
    /// unstoppable label
    @IBOutlet weak var fourthLabel: UILabel!
    /// Width of power
    @IBOutlet weak var firstWidthConstraint: NSLayoutConstraint!
    /// Width of power
    @IBOutlet weak var secondWidthConstraint: NSLayoutConstraint!
    /// Width of power
    @IBOutlet weak var thirdWidthConstraint: NSLayoutConstraint!
    /// Width of power
    @IBOutlet weak var fourthWidthConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var barcontainerView: UIView!
    
    /// Height of all bars
    @IBOutlet weak var powerHeightConstraint: NSLayoutConstraint!
    
    
    /// local count of badges, helpful for tweak values
    private var firstCount = 0
    /// local count of badges, helpful for tweak values
    private var secondCount = 0
    /// local count of badges, helpful for tweak values
    private var thirdCount = 0
    /// local count of badges, helpful for tweak values
    private var fourthCount = 0
    /// percentage to show in rank view
    private var firstPercent: CGFloat = 0.25
    /// percentage to show in rank view
    private var secondPercent: CGFloat = 0.25
    /// percentage to show in rank view
    private var thirdPercent: CGFloat = 0.25
    /// percentage to show in rank view
    private var fourthPercent: CGFloat = 0.25
    
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        setup()
        
    }
    
    required init?(coder: NSCoder) {
        
        super.init(coder: coder)
        setup()
        
    }
 
    
    func setup() {
        
        view = instanceFromNib()
        addSubview(view)
        view.frame = self.bounds
        
         powerHeightConstraint.constant = 3
        
        firstLabel.text = MBadge.getFirstBadge().name
        if let color = MBadge.getFirstBadge().color {
            firstLabel.textColor = UIColor(rgba: color) ?? UIColor.MaverickBadgePrimaryColor
            firstView.backgroundColor = UIColor(rgba: color) ?? UIColor.MaverickBadgePrimaryColor
        }
        
        secondLabel.text = MBadge.getSecondBadge().name
        if let color = MBadge.getSecondBadge().color {
            secondLabel.textColor = UIColor(rgba: color) ?? UIColor.MaverickBadgePrimaryColor
            secondView.backgroundColor = UIColor(rgba: color) ?? UIColor.MaverickBadgePrimaryColor
        }
        
        thirdLabel.text = MBadge.getThirdBadge().name
        if let color = MBadge.getThirdBadge().color {
            thirdLabel.textColor = UIColor(rgba: color) ?? UIColor.MaverickBadgePrimaryColor
            thirdView.backgroundColor = UIColor(rgba: color) ?? UIColor.MaverickBadgePrimaryColor
        }
        
        fourthLabel.text = MBadge.getFourthBadge().name
        if let color = MBadge.getFourthBadge().color {
            fourthLabel.textColor = UIColor(rgba: color) ?? UIColor.MaverickBadgePrimaryColor
            fourthView.backgroundColor = UIColor(rgba: color) ?? UIColor.MaverickBadgePrimaryColor
        }
    }
   
    func instanceFromNib() -> UIView {
        
        return R.nib.powerBarView.firstView(owner: self)!
        
    }
    
    /**
     Set specific values
     */
    func setValues(first: Int = 1, second: Int = 1, third: Int = 1, fourth: Int = 1) {
        
        firstCount =         first < 0        ? 0 : first
        secondCount =       second < 0      ? 0 : second
        thirdCount =         third < 0        ? 0 : third
        fourthCount =    fourth < 0   ? 0 : fourth
        
        calculateResults()
        
    }
    
    /**
     Calcultate rankings based on badge counts
     */
    private func calculateResults() {
        
        let total = CGFloat(firstCount + secondCount + thirdCount + fourthCount)
        
        if total == 0 {
            
            firstPercent = 0.25
            secondPercent = 0.25
            thirdPercent = 0.25
            fourthPercent = 0.25
            
        } else {
            
            firstPercent = CGFloat(firstCount) / total
            secondPercent = CGFloat(secondCount) / total
            thirdPercent = CGFloat(thirdCount) / total
            fourthPercent = CGFloat(fourthCount) / total
            
        }
        
        var percent = (firstPercent * 100).roundTo(decimalPlaces: 0)
        firstLabel.text = ("\(percent)%")
        
        percent = (secondPercent * 100).roundTo(decimalPlaces: 0)
        secondLabel.text = ("\(percent)%")
        
        percent = (thirdPercent * 100).roundTo(decimalPlaces: 0)
        thirdLabel.text = ("\(percent)%")
        
        percent = (fourthPercent * 100).roundTo(decimalPlaces: 0)
        fourthLabel.text = ("\(percent)%")
        
        setBarSize()
        
    }
    
    /**
     Set Bar Width based on percentages
    */
    private func setBarSize() {
        
        let maxWidth = Constants.MaxContentScreenWidth - 80 - 20 - (3 * 3)
      
        firstWidthConstraint.constant = firstPercent * maxWidth + 20
        secondWidthConstraint.constant = secondPercent * maxWidth + 20
        thirdWidthConstraint.constant = thirdPercent * maxWidth + 20
        fourthWidthConstraint.constant = fourthPercent * maxWidth + 20
        
        setNeedsUpdateConstraints()
    }
}
