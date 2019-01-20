//
//  FileManager+Extensions.swift
//  BeMaverick
//
//  Created by David McGraw on 10/16/17.
//  Copyright © 2017 BeMaverick. All rights reserved.
//

import Foundation

extension FileManager {
    
    // MARK: - Public Methods
    
    /**
     Iterates over ALL files within the app's temporary directory and removes them
     from disk.
     */
    func removeAllTemporaryFiles() {
        
        do {
            
            let dir = try contentsOfDirectory(atPath: NSTemporaryDirectory())
            try dir.forEach { [unowned self] file in
                
                let path = String.init(format: "%@%@", NSTemporaryDirectory(), file)
                try self.removeItem(atPath: path)
                
            }
            
        } catch {
            // Ignore
        }
        
    }
    
}
