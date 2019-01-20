//
//  LinkViewCollectionViewCell.swift
//  Maverick
//
//  Created by Garrett Fritz on 9/12/18.
//  Copyright © 2018 BeMaverick. All rights reserved.
//

import Foundation


class LinkViewCollectionViewCell : UICollectionViewCell {
    
    
    @IBOutlet weak var linkView: LinkView!
    
    func configure(with url : URL?, delegate : LinkViewDelegate) {
        
        linkView.delegate = delegate
        linkView.parseLinkURL(urlString: url?.absoluteString ?? "")
        linkView.linkEntryField.text =  url?.absoluteString
        
    }
    
}
