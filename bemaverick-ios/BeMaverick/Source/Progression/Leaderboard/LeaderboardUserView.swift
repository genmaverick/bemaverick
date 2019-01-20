//
//  LeaderboardUserView.swift
//  Maverick
//
//  Created by Garrett Fritz on 9/18/18.
//  Copyright © 2018 BeMaverick. All rights reserved.
//

import Foundation


class LeaderboardUserView : UIView {
    
    @IBOutlet weak var rankLabel: UILabel!
    
    @IBOutlet weak var avatarImageView: UIImageView!
    
    @IBOutlet weak var levelLabel: UILabel!
    
    @IBOutlet weak var usernameLabel: BadgeLabel!
    
    @IBOutlet weak var pointLabel: UILabel!
    
    /// Parent view
    @IBOutlet weak var view: UIView!
    
    // MARK: - Lifecycle
    
    @IBAction func cellTapped(_ sender: Any) {
        
        guard let user = user else { return }
        delegate?.userTapped(user : user)
        
    }
    
    weak var delegate : LeaderboardTableViewCellDelegate?
    private var user : User?
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        setup()
        
    }
    
    required init?(coder: NSCoder) {
        
        super.init(coder: coder)
        setup()
        
    }
    
    func instanceFromNib() -> UIView {
        
        return R.nib.leaderboardUserView.firstView(owner: self)!
        
    }
    
    func setup() {
        
        view = instanceFromNib()
        addSubview(view)
        view.autoPinEdgesToSuperviewEdges()
        view.frame = self.bounds
        view.backgroundColor = UIColor.clear
    
        usernameLabel.imageOffset = CGPoint(x: 0.0, y: -2.0)
        
        avatarImageView.layer.cornerRadius = avatarImageView.frame.height / 2
        avatarImageView.clipsToBounds = true
        avatarImageView.layer.borderWidth = 0.5
        avatarImageView.layer.borderColor = UIColor(rgba: "D3D3D3ff")?.cgColor
    }
    
    func configure(with user : User, rank : Int, delegate : LeaderboardTableViewCellDelegate?) {
        
        self.delegate = delegate
        self.user = user
        rankLabel.text = "\(rank)"
        
        if let imagePath = user.profileImage?.getUrlForSize(size: avatarImageView.frame), let url = URL(string: imagePath) {
            
            avatarImageView.kf.setImage(with: url, placeholder: R.image.defaultMaverickAvatar(), options: [.transition(.fade(UIImage.fadeInTime))])
            
        } else {
            
            avatarImageView.image = R.image.defaultMaverickAvatar()
            
        }
        
        usernameLabel.text = user.username
        levelLabel.text = "\(user.progression?.currentLevelNumber ?? 0)"
        let points = user.progression?.totalPoints ?? ((20.0 - Float(rank)) * 100.0)
        
        pointLabel.text = "\(Int(points)) PTS"
        
    }
    
}
