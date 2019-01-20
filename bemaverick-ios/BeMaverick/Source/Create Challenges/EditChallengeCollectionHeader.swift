//
//  EditChallengeCollectionHeader.swift
//  Maverick
//
//  Created by Garrett Fritz on 7/24/18.
//  Copyright © 2018 BeMaverick. All rights reserved.
//

import Foundation

protocol EditChallengeCollectionHeaderDelegate : class {
    
    func searchTapped()
    
}

class EditChallengeCollectionHeader : UICollectionReusableView {
    
    @IBOutlet weak var searchButton: UIButton!
    
    
    weak var delegate : EditChallengeCollectionHeaderDelegate?
    
    
    @IBAction func searchTapped(_ sender: Any) {
        
        delegate?.searchTapped()
        
    }
    
}
