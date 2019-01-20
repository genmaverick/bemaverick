//
//  SCRecordExportOperation.swift
//  BeMaverick
//
//  Created by David McGraw on 2/10/18.
//  Copyright © 2018 BeMaverick. All rights reserved.
//

import Foundation
import SCRecorder

/**
 An operation that exports a recording using `SCAssetExportSession`.
 
 Leverage to prevent export from hitting a locked Asset Writer.
 */
class SCRecordExportOperation: BaseMaverickOperation {
    
    private let exportSession: SCAssetExportSession
    
    var errMessage: String?
    
    init(withExportSession exportSession: SCAssetExportSession) {
        self.exportSession = exportSession
    }
    
    override func main() {
        
        guard isCancelled == false else {
            finish(true)
            return
        }
        
        executing(true)
        
        exportSession.exportAsynchronously {
            
            if self.errMessage != nil {
                self.errMessage = self.exportSession.error?.localizedDescription ?? ""
            }
            
            self.executing(false)
            self.finish(true)
            
        }
        
    }
    
}
