//
//  Pen.swift
//  BeMaverick
//
//  Created by David McGraw on 10/23/17.
//  Copyright © 2017 BeMaverick. All rights reserved.
//

import Darwin
import UIKit
import JotUI

class Pen: NSObject {
    
    // MARK: - Public Properties
    
    /// Minimum stroke size
    var minSize: CGFloat        = 8.0
    
    /// Maximum stroke size
    var maxSize: CGFloat        = 17.0
    
    /// Minimum alpha
    var minAlpha: CGFloat       = 0.9
    
    /// Maximum alpha
    var maxAlpha: CGFloat       = 0.9
    
    // Should velocity be calculated into the movement
    var shouldUseVelocity: Bool = true
    
    // Current color of the pen
    var color: UIColor          = .black
    
    // The owning view to improve accuracy
    var drawingView: UIView?
    
    // Texture being used for the object
    fileprivate(set) var texture: JotBrushTexture?
    
    // MARK: - Private Properties
    
    fileprivate(set) var numberOfTouches: Int    = 0
    fileprivate(set) var velocity: CGFloat       = 0
    fileprivate(set) var lastLoc: CGPoint        = .zero
    fileprivate(set) var lastDate: Date          = Date()
    
    // MARK: - Lifecycle
    
    override init() {
        super.init()
    }
        
    init(withMinSize minSize: CGFloat, maxSize: CGFloat, minAlpha: CGFloat, maxAlpha: CGFloat) {
        
        self.minSize = minSize
        self.maxSize = maxSize
        self.minAlpha = minAlpha
        self.maxAlpha = maxAlpha
        
    }
    
    // MARK: - Public Methods
    
    open func updateSize(size: Constants.RecordingBrushSize) {
        
        var penSize: CGFloat = 14.0
        
        switch size {
        case .size1:
            penSize = 8
        case .size2:
            penSize = 11
        case .size3:
            penSize = 14
        case .size4:
            penSize = 17
        case .size5:
            penSize = 20
        case .size6:
            penSize = 23
        }
        
        minSize = penSize / 2.0
        maxSize = penSize
        
    }
    
}

extension Pen: JotViewDelegate {
    
    func stepWidthForStroke() -> CGFloat {
        return 2.0
    }
    
    func supportsRotation() -> Bool {
        return false
    }
    
    func textureForStroke() -> JotBrushTexture! {
        return JotDefaultBrushTexture.sharedInstance()
    }
    
    /**
     Keep the pen fairly smooth.
     
       0 - connecting straight lines
       1 - curvy
     > 1 - is loopy
     < 0 - is knotty
     */
    func smoothness(forCoalescedTouch coalescedTouch: UITouch!, from touch: UITouch!) -> CGFloat {
        return 0.75
    }
    
    /**
     Adjust the alpha of the ink based on pressure or velocity
     */
    func color(forCoalescedTouch coalescedTouch: UITouch!, from touch: UITouch!) -> UIColor! {
        
        var segmentAlpha: CGFloat = 0
        
        if shouldUseVelocity {
        
            segmentAlpha = velocity - 1
            if segmentAlpha > 0 {
                segmentAlpha = 0
            }
            segmentAlpha = minAlpha + abs(segmentAlpha) * (maxAlpha - minAlpha) * touch.force

        } else {
            
            segmentAlpha = minAlpha + (maxAlpha - minAlpha) * touch.force
            if segmentAlpha < minAlpha {
                segmentAlpha = minAlpha
            }
            
        }
        
        return color.withAlphaComponent(segmentAlpha)
        
    }
    
    /**
     Use pressure data to determine the width at a new touch location
     */
    func width(forCoalescedTouch coalescedTouch: UITouch!, from touch: UITouch!) -> CGFloat {
        
        var width: CGFloat = 0
        
        if shouldUseVelocity {
            
            width = (velocity - 1);
            
            if width > 0 {
                width = 0
            }
            
            width = minSize + abs(width) * (maxSize - minSize)
            
            if width < 1 {
                width = 1
            }
            
        } else {
            
            width = (maxSize + minSize) / 2.0
            width *= coalescedTouch.force
            
            if width < minSize {
                width = minSize
            }
            
            if width > maxSize {
                width = maxSize
            }
            
        }
        
        return width
        
    }
    
    func willAddElements(_ elements: [Any]!, to stroke: JotStroke!, fromPreviousElement previousElement: AbstractBezierPathElement!) -> [Any]! {
        return elements
    }
    
    func willBeginStroke(withCoalescedTouch coalescedTouch: UITouch!, from touch: UITouch!) -> Bool {
        
        velocity = 1
        lastDate = Date()
        numberOfTouches = 1
        return true
        
    }
    
    func willMoveStroke(withCoalescedTouch coalescedTouch: UITouch!, from touch: UITouch!) {
        
        numberOfTouches += 1
        if numberOfTouches > 4 {
            numberOfTouches = 4
        }
        
        let duration = Date().timeIntervalSince(lastDate)
        
        if duration > 0.01 {
            
            let vel = velocity(forTouch: touch)
            if vel > 0.0 {
                velocity = velocity(forTouch: touch)
            }
            
            lastDate = Date()
            lastLoc = touch.preciseLocation(in: drawingView)
            
        }
        
    }
    
    func willEndStroke(withCoalescedTouch coalescedTouch: UITouch!, from touch: UITouch!, shortStrokeEnding: Bool) {
        
    }
    
    func didEndStroke(withCoalescedTouch coalescedTouch: UITouch!, from touch: UITouch!) {
        
    }
    
    func willCancel(_ stroke: JotStroke!, withCoalescedTouch coalescedTouch: UITouch!, from touch: UITouch!) {
        
    }
    
    func didCancel(_ stroke: JotStroke!, withCoalescedTouch coalescedTouch: UITouch!, from touch: UITouch!) {
        
    }
    
    /**
     Convenience method to determine the velocity of the touch
     */
    func velocity(forTouch touch: UITouch) -> CGFloat {
        
        let location = touch.preciseLocation(in: nil)
        let previousPoint = touch.precisePreviousLocation(in: nil)
        
        let xVal: Float = Float((location.x - previousPoint.x) * (location.x - previousPoint.x))
        let yVal: Float = Float((location.y - previousPoint.y) * (location.y - previousPoint.y))
        let distanceFromPrevious = CGFloat(sqrtf(xVal + yVal))
        
        let duration = CGFloat(Date().timeIntervalSince(lastDate))
        let velocityMagnitude = distanceFromPrevious / duration
        
        let clampedVelocityMagnitude = fmaxf(20, fminf(3000, Float(velocityMagnitude)))
        let normalizedVelocity = (clampedVelocityMagnitude - 20.0) / (3000.0 - 20.0)
        
        return CGFloat(normalizedVelocity)
        
    }
    
    
}
