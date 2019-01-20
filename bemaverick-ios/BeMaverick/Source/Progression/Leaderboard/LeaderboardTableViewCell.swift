//
//  ProjectProgressView.swift
//  Maverick
//
//  Created by Garrett Fritz on 9/18/18.
//  Copyright © 2018 BeMaverick. All rights reserved.
//

import Foundation

protocol LeaderboardTableViewCellDelegate : class {
    
    func tabChanged(type : ProgressionLeaderboardViewController.LeaderboardType, time : ProgressionLeaderboardViewController.LeaderboardTime)
    
    func userTapped(user : User)
    
}


class LeaderboardTableViewCell : UITableViewCell {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var segmentControl: MaverickSegmentedControl!
    
    @IBOutlet weak var itemStackView: UIStackView!
    
    @IBAction func segmentValueChanged(_ sender: Any) {
        
        delegate?.tabChanged(type : segmentControl.selectedSegmentIndex == 0 ? .global : .following , time: time)
        
    }
    
    weak var delegate : LeaderboardTableViewCellDelegate?
    private var type : ProgressionLeaderboardViewController.LeaderboardType = .global
    
    private var time : ProgressionLeaderboardViewController.LeaderboardTime = .all
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setTabs()
        containerView.addShadow(color: .black, alpha: 0.06, x: 0.0, y: 0.4, blur: 6.0, spread: 0)
        

    }
    
    
    func configure(with users : [User], type: ProgressionLeaderboardViewController.LeaderboardType, time: ProgressionLeaderboardViewController.LeaderboardTime, delegate : LeaderboardTableViewCellDelegate? ) {
        
        self.time = time
        self.type = type
        
        segmentControl.selectedSegmentIndex = type == .global ? 0 : 1
        for subview in itemStackView.subviews {
            
            subview.removeFromSuperview()
        
        }
        
        for i in 0 ..< min(10, users.count) {
            
            let user = users[i]
            
            let itemView = LeaderboardUserView()
            itemStackView.addArrangedSubview(itemView)
            itemView.layoutIfNeeded()
            itemView.configure(with: user, rank: i + 1, delegate : delegate)
            
        }
        
    }
    
    private func setTabs() {
        
        
        segmentControl.removeAllSegments()
     
        segmentControl.insertSegment(withTitle: ProgressionLeaderboardViewController.LeaderboardType.global.rawValue, at: segmentControl.numberOfSegments, animated: false)
        segmentControl.insertSegment(withTitle: ProgressionLeaderboardViewController.LeaderboardType.following.rawValue, at: segmentControl.numberOfSegments, animated: false)
        segmentControl.selectedSegmentIndex = 0
        
        
    }
    
}
