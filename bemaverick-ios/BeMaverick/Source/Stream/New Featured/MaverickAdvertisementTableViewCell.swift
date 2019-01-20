//
//  MaverickAdvertisementTableViewCell.swift
//  Maverick
//
//  Created by Garrett Fritz on 5/22/18.
//  Copyright © 2018 BeMaverick. All rights reserved.
//

import Foundation
import Kingfisher

protocol MaverickAdvertisementTableViewCellDelegate : class {
  
    func adTapped(link : URL?, streamId : String, label: String)

}

class MaverickAdvertisementTableViewCell : UITableViewCell {
    
    @IBOutlet weak var mainImage: UIImageView!
    
    @IBAction func itemTapped(_ sender: Any) {
        
        delegate?.adTapped(link : link, streamId : streamId, label: label)
    
    }
    
    private weak var delegate : MaverickAdvertisementTableViewCellDelegate?
    private var link : URL?
    private var streamId = ""
    private var label = ""
   
    
    func configureWith(file : String, deepLink : String?, delegate : MaverickAdvertisementTableViewCellDelegate? = nil, streamId : String?, label: String?) {
        self.label = label ?? ""
        self.streamId = streamId ?? ""
        link = nil
        if let deepLink = deepLink, let url = URL(string: deepLink) {
           
            link = url
        
        }
        
        self.delegate = delegate
        if let url = URL(string: file) {
            
            mainImage.kf.setImage(with: url, placeholder: nil, options: [], progressBlock: nil) { (image, error, cache, url) in
                
                self.mainImage.startAnimating()
            
            }
           
        }
        
    }
    
    
}
