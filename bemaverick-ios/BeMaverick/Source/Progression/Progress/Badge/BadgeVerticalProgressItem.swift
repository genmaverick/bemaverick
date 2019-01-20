//
//  BadgeVerticalProgressItem.swift
//  Maverick
//
//  Created by Garrett Fritz on 9/18/18.
//  Copyright © 2018 BeMaverick. All rights reserved.
//

import Foundation

class BadgeVerticalProgressItem : UIView {
    
    @IBOutlet weak var badgeImageView: UIImageView!
    @IBOutlet weak var badgeTitleLabel: UILabel!
    @IBOutlet weak var badgeDescriptionLabel: UILabel!
    @IBOutlet weak var badgeCountLabel: UILabel!
    @IBOutlet weak var badgeCountUnitLabel: UILabel!
    @IBOutlet weak var rightArrowImage: UIImageView!
    @IBOutlet weak var view: UIView!
    
    
    @IBAction func cellTapped(_ sender: Any) {
        
        guard let badgeStats = badgeStats else { return }
        delegate?.badgeTapped(badgeStats: badgeStats)
        
    }
    
    weak var delegate : MyProgressViewControllerDelegate?
    var badgeStats : BadgeStats?
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        setup()
        
    }
    
    required init?(coder: NSCoder) {
        
        super.init(coder: coder)
        setup()
        
    }
    
    private func instanceFromNib() -> UIView {
        
        return R.nib.badgeVerticalProgressItem.firstView(owner: self)!
        
    }
    
    private func setup() {
        
        view = instanceFromNib()
        addSubview(view)
        view.autoPinEdgesToSuperviewEdges()
        view.frame = self.bounds
        view.backgroundColor = UIColor.clear
        rightArrowImage.tintColor = UIColor(rgba: "888888")
        
    }
    
    func configure(with badgeStats : BadgeStats) {
        
        self.badgeStats = badgeStats
        if let index = MBadge.getIndex(ofBadgeId: badgeStats.badgeId) {
            
            let badge = MBadge.getBadge(byIndex: index)
            badgeTitleLabel.text = badge.name
            badgeCountLabel.text = "\(badgeStats.numReceived)"
            BadgerView.setBadgeImage(badge: badge, primary: true, imageView: badgeImageView)
            badgeDescriptionLabel.text = badge.badgeDescription
        }
        
    }
    
}
