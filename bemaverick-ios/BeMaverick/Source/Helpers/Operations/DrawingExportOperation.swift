//
//  DrawingExportOperation.swift
//  BeMaverick
//
//  Created by David McGraw on 2/12/18.
//  Copyright © 2018 BeMaverick. All rights reserved.
//

import Foundation
import JotUI

class DrawingExportOperation: BaseMaverickOperation {
    
    private let exportJotView: JotView
    
    private let sessionId: String
    
    var overlayIndex: Int = -1
    
    var errMessage: String?
    
    /**
     `sessionId` should reflect a recording session. A folder will be created
     that will store the ink path, thumbnail (if ever needed), and state.
    */
    init(withExportJotView jotView: JotView, sessionId: String) {
        
        self.exportJotView = jotView
        self.sessionId = "\(sessionId)"
        
    }
    
    override func main() {
        
        guard isCancelled == false else {
            finish(true)
            return
        }
        
        executing(true)
        
        // Export needs to happen on the main thread. Export will handle
        // moving to the background when needed.
        DispatchQueue.main.async {
        
            self.exportJotView.exportImage(to: self.filePath(forName: "ink", ext: "png"),
                                      andThumbnailTo: self.filePath(forName: "info", ext: "plist"),
                                      andStateTo: self.filePath(forName: "ink.thumb", ext: "png"),
                                      withThumbnailScale: 1.0)
            { (ink, thumbnail, state) in
                
                
                
                self.executing(false)
                self.finish(true)
                
            }
            
        }
        
    }
    
    /**
     Creates a document directory with the `sessionId` and provides a path to the
     given name and extension.
    */
    fileprivate func filePath(forName name: String, ext: String) -> String? {
        
        let fm = FileManager.default
        if let documents = fm.urls(for: .documentDirectory, in: .userDomainMask).first {
            
            let filePath = documents.appendingPathComponent("\(sessionId)/\(overlayIndex)")
            if !fm.fileExists(atPath: filePath.path) {
                
                do {
                    try fm.createDirectory(atPath: filePath.path, withIntermediateDirectories: true, attributes: nil)
                } catch {
                    // TODO: ERR
                }
                
            }
            
            return filePath.appendingPathComponent("\(name)").appendingPathExtension("\(ext)").path
            
        }
        
        return nil
        
    }
    
}
