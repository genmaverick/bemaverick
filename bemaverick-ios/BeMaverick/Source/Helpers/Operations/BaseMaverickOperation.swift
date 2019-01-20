//
//  BaseMaverickOperation.swift
//  BeMaverick
//
//  Created by David McGraw on 2/10/18.
//  Copyright © 2018 BeMaverick. All rights reserved.
//

import Foundation

class BaseMaverickOperation: Operation {
    
    open var error: MaverickError?
    
    private var _executing = false {
        
        willSet {
            willChangeValue(forKey: "isExecuting")
        }
        
        didSet {
            didChangeValue(forKey: "isExecuting")
        }
        
    }
    
    private var _finished = false {
        
        willSet {
            willChangeValue(forKey: "isFinished")
        }
        
        didSet {
            didChangeValue(forKey: "isFinished")
        }
        
    }
    
    override var isExecuting: Bool {
        return _executing
    }
    
    override var isFinished: Bool {
        return _finished
    }
    
    func executing(_ executing: Bool) {
        _executing = executing
    }
    
    func finish(_ finished: Bool) {
        _finished = finished
    }
    
}
