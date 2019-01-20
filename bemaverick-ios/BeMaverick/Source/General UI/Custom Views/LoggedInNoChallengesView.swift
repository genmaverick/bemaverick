//
//  LoggedInNoChallengesView.swift
//  Maverick
//
//  Created by Garrett Fritz on 6/20/18.
//  Copyright © 2018 BeMaverick. All rights reserved.
//

import Foundation

protocol LoggedInNoChallengesViewDelegate : class {
    
    func ctaTapped()
    
}

class LoggedInNoChallengesView : UIView {
    
    
    /// Parent view
    @IBOutlet weak var view: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    @IBOutlet weak var widthConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var ctaButton: UIButton!
    
    @IBAction func ctaTapped(_ sender: Any) {
        
        delegate?.ctaTapped()
        
    }
    
    weak var delegate : LoggedInNoChallengesViewDelegate?
    override func awakeFromNib() {
        
        super.awakeFromNib()
        widthConstraint.constant = Constants.MaxContentScreenWidth
        heightConstraint.constant = Variables.Content.emptyViewHeight.cgFloatValue()
        
        ctaButton.addShadow()
    }
    
    
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
        view.backgroundColor = UIColor.clear
        let dark = false
        imageView.alpha = dark ? 0.15 : 0.05
        imageView.tintColor = dark ? .white : .black
        
    }
    
    func instanceFromNib() -> UIView {
        return R.nib.loggedInNoChallengesView.firstView(owner: self)!
    }
    
}
