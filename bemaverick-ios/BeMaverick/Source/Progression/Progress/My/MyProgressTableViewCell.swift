//
//  MyProgressTableViewCell.swift
//  Maverick
//
//  Created by Garrett Fritz on 9/17/18.
//  Copyright © 2018 BeMaverick. All rights reserved.
//

import Foundation

class MyProgressTableViewCell : UITableViewCell {

    /// Parent view
    @IBOutlet weak var myProgressView: MyProgressView!
    
    func configure(with user : User, delegate : MyProgressViewControllerDelegate?) {
        
        myProgressView.configure(with: user)
        myProgressView.delegate = delegate
        
    }
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        myProgressView.addShadow(color: .black, alpha: 0.06, x: 0.0, y: 0.4, blur: 6.0, spread: 0)
    
    }
    
}
