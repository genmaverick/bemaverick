//
//  StickerBrowserViewController.swift
//  Maverick
//
//  Created by Garrett Fritz on 5/29/18.
//  Copyright © 2018 BeMaverick. All rights reserved.
//

import Foundation
import Messages

class StickerBrowserViewController : MSStickerBrowserViewController {
    
        var stickers : [MSSticker] = []
    override func numberOfStickers(in stickerBrowserView: MSStickerBrowserView) -> Int {
        return stickers.count
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let stickst = createStickers(from: "stickers") {
            stickers = stickst
        }
        
        
    }
    
    override func stickerBrowserView(_ stickerBrowserView: MSStickerBrowserView, stickerAt index: Int) -> MSSticker {
        
        return stickers[index]
    
    }
    
    func createStickers(from folderName: String) -> [MSSticker]? {
        
        guard
            let path = Bundle.main.resourcePath
            else { return nil }
        
        var stickers = [MSSticker]()
        let folderPath = "\(path)/\(folderName)"
        let folderURL = URL(fileURLWithPath: folderPath)
        
        //get a list of urls in the chosen directory
        do {
            let imageURLs = try FileManager.default.contentsOfDirectory(at: folderURL,
                                                                        includingPropertiesForKeys: nil,
                                                                        options: .skipsHiddenFiles)
            //loop through the found urls
            for url in imageURLs {
                //create the sticker and add it, or handle error
                do {
                    let sticker = try MSSticker(contentsOfFileURL: url, localizedDescription: "Maverick Sticker")
                    
                    stickers.append(sticker)
                } catch let error {
                    print(error.localizedDescription)
                }
            }
            
        } catch let error {
            print(error.localizedDescription)
        }
        
        
        //return nil if stickers array is empty
        return stickers.isEmpty ? nil : stickers
    }
    
}
