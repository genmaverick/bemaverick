//
//  UserDefaults+Extensions.swift
//  BeMaverick
//
//  Created by David McGraw on 9/27/17.
//  Copyright © 2017 BeMaverick. All rights reserved.
//

import Foundation

extension UserDefaults {
    
    // MARK: - Usage
    
    /**
     False if this is the first time the app has been launched. This is used for
     any necessary cleanup after app deletion (primarily: keychain)
     */
    var appDidCompleteFirstRun: Bool {
        
        get { return bool(forKey: #function) }
        set {
            set(newValue, forKey: #function)
            synchronize()
        }
        
    }
    
    // MARK: - Recording
    
    /**
     If the flash should be active
    */
    var isRecordFlashOn: Bool {
        
        get { return bool(forKey: #function) }
        set {
            set(newValue, forKey: #function)
            synchronize()
        }
        
    }
    
    /**
     If the back device should be active
     */
    var isRecordBackDeviceActive: Bool {
        
        get { return bool(forKey: #function) }
        set {
            set(newValue, forKey: #function)
            synchronize()
        }
        
    }
    
    /**
     The last recorded timer setting measured in seconds
     */
    var recordTimerState: Int {
        
        get { return integer(forKey: #function) }
        set {
            set(newValue, forKey: #function)
            synchronize()
        }
        
    }

    
}
