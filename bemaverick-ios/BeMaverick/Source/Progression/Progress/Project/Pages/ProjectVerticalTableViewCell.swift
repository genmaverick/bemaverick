//
//  ProjectVerticalTableViewCell.swift
//  Maverick
//
//  Created by Garrett Fritz on 9/24/18.
//  Copyright © 2018 BeMaverick. All rights reserved.
//

import Foundation

class ProjectVerticalTableViewCell : UITableViewCell {
    
    @IBOutlet weak var itemView: ProjectVerticalProgressItem!
    
    func configure(with projectsProgress : ProjectsProgress, delegate : MyProgressViewControllerDelegate?) {
        
        itemView.configure(with: projectsProgress)
        itemView.delegate = delegate
        
    }
    
}
