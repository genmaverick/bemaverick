//
//  FullScreenMediaViewController.swift
//  BeMaverick
//
//  Created by Garrett Fritz on 1/31/18.
//  Copyright © 2018 BeMaverick. All rights reserved.
//

import Foundation
import AVKit

class FullScreenMediaViewController : AVPlayerViewController {
    
    private var video: MaverickMedia?
    
    private var services: GlobalServicesContainer?
    
    func configure(withResponse response: Response) {
     
    }
    
    func configure(withChallenge challenge: Challenge) {
       
    }
    
    func configure(withVideo video: MaverickMedia) {
       
        self.video = video
    
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let url = video?.URLOriginal else { return }
        let videoURL = URL(string: url)
        player = AVPlayer(url: videoURL!)
        
    }
  
    
}
