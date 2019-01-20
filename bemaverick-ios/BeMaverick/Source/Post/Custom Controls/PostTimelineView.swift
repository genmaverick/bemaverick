//
//  PostTimelineView.swift
//  BeMaverick
//
//  Created by David McGraw on 10/6/17.
//  Copyright © 2017 BeMaverick. All rights reserved.
//

import UIKit

protocol PostTimelineDelegate: class {
    
    func didSelectSegment(atIndex index: Int)
        
}

class PostTimelineView: UIView {
    
    // MARK: - Public Properties
    
    /// Whether the timeline should factor in the max recording duration
    open var shouldLayoutFullWidth: Bool = false
    
    /// The object that acts as the delegate of the timeline view
    open weak var delegate: PostTimelineDelegate?
    
    ///
    open var selectedTimelineIndex: Int = -1
    
    /// If false the timeline will not highlight the selected segment
    open var selectionHightlightEnabled: Bool = false
    
    /// A reference to the amount of time left for the recording
    open var recordingIndicatorButton: UIButton?
    
    // MARK: - Private Properties
    
    /// The record duration the timeline was started with
    fileprivate var maxDuration = Constants.CameraManagerMaxRecordDuration
    
    /// Timeline length of time
    fileprivate var elapsedSeconds = 0
    
    /// The durations loaded within the view
    fileprivate var segmentDurations: [Double] = []
    
    /// The current count
    fileprivate var timerTick = 0
    
    /// The count of segments added to the timeline
    fileprivate var segmentViewCount = 0
    
    /// The padding between segments
    fileprivate var segmentPadding = 0
    
    /// The timer that adjusts the timeline and count
    fileprivate var timer: Timer?
    
    /// The button being expanded
    fileprivate var activeSegmentButton: UIButton?
    
    /// A view used to display the playback progress along the timeline
    fileprivate var progressIndicatorView: UIView?
    
    /// The width of the segment being recorded
    fileprivate var barViewWidthConstraint: NSLayoutConstraint?
    
    /// The leading constraint for the progress view
    fileprivate var progressLeadingConstraint: NSLayoutConstraint?
    
    // MARK: - Public Methods

    /**
     Clear and reset the timeline layout
    */
    open func clearAndResetTimeline() {
        
        setNeedsLayout()
        
        activeSegmentButton = nil
        segmentDurations.removeAll()
        timerTick = 0
        segmentViewCount = 0
        elapsedSeconds = 0
        timer?.invalidate()
        progressLeadingConstraint?.constant = 0
        
        for v in subviews.reversed() {
            v.removeFromSuperview()
        }
        
        
    }
    
    /*
     Add a single segment to an existing timeline layout
    */
    open func addTimelineSegment(withSegmentDuration duration: Double) {
        
        segmentDurations.append(duration)
        
        let paddingOffset = CGFloat(Double(segmentDurations.count) * Double(segmentPadding))
        addSegmentMarker(withWidth: ((bounds.size.width - paddingOffset) / maxDuration) * CGFloat(duration))
        
    }
    
    /**
     Removes the last segment in the timeline and updates the layout
    */
    open func removeSelectedSegment() {
        
        var durations = segmentDurations
        
        if selectedTimelineIndex == -1 {
            _ = durations.popLast()
        } else {
            durations.remove(at: selectedTimelineIndex)
        }
        
        clearAndResetTimeline()
        
        layoutTimeline(withSegmentDurations: durations, maxRecordingLimit: maxDuration)
        
    }
    
    /*
     Layout the timeline segments based on the session segments
    */
    open func layoutTimeline(withSegmentDurations durations: [Double], maxRecordingLimit limit: CGFloat) {
        
        let totalDuration = CGFloat(durations.reduce(0, +))
        if totalDuration == 0 { return }
        
        let maxRecordingLimit = shouldLayoutFullWidth ? totalDuration : limit
        let paddingOffset = CGFloat(Double(durations.count) * Double(segmentPadding))
        
        for duration in durations {
            addSegmentMarker(withWidth: ((bounds.size.width - paddingOffset) / maxRecordingLimit) * CGFloat(duration))
        }

        segmentDurations = durations
        maxDuration = limit
        
        elapsedSeconds = Int(durations.reduce(0, +))
        let secondsRemaining = min(0, Int(maxDuration) - elapsedSeconds)
        recordingIndicatorButton?.setTitle(": \(secondsRemaining)", for: .normal)
        
    }
    
    /**
     Highlight the selected index
    */
    open func setSelectedIndex(atIndex index: Int) {
        
        if index == -1 {
            return
        }
        
        for s in subviews {
            
            if let btn = s as? UIButton, btn.tag != -1 {
            
                if btn.tag != index {
                    s.backgroundColor = .maverickLightRed
                } else {
                    s.backgroundColor = .maverickRed
                }
                
            }
            
        }
        
        selectedTimelineIndex = index
        
    }
        
    /*
     Begin animating the shape layer ring
     */
    open func startAnimation(withDuration duration: Int) {
        
        maxDuration = CGFloat(duration)
        
        addSegmentMarker()
        
        highlightSegment(atIndex: segmentViewCount-1)
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            
            self.recordingIndicatorButton?.setTitle(": \(Int(self.maxDuration) - self.elapsedSeconds)", for: .normal)
            self.recordingIndicatorButton?.isHidden = false
            
            if self.timerTick == duration {
                return
            }
            
            self.timerTick += 1
            self.elapsedSeconds += 1
            
            self.layoutIfNeeded()
            self.setNeedsUpdateConstraints()
            UIView.animate(withDuration: 1.0, delay: 0.0, options: [.beginFromCurrentState, .curveLinear], animations: {
            
                self.barViewWidthConstraint?.constant = (self.bounds.size.width / CGFloat(duration)) * CGFloat(self.timerTick)
                self.layoutIfNeeded()
                
            }, completion: nil)
            
        }
        timer?.fire()
        
    }
    
    /**
     Shows a playback progress indicator on the timeline
    */
    open func updatePlaybackProgress(duration: Double, currentTime: Double) {
        
        if progressIndicatorView == nil {
            
            progressIndicatorView = UIView(frame: CGRect(x: 0, y: 0, width: 2, height: bounds.size.height + 2))
            progressIndicatorView!.backgroundColor = .blue
            addSubview(progressIndicatorView!)
            
            progressIndicatorView?.autoSetDimension(.height, toSize: bounds.size.height + 2)
            progressIndicatorView?.autoSetDimension(.width, toSize: 2)
            progressLeadingConstraint = progressIndicatorView?.autoPinEdge(.leading, to: .leading, of: self)
            progressIndicatorView?.autoPinEdge(.bottom, to: .bottom, of: self)
            
        }
        
        // Factor in the segment padding
        let percentageComplete = currentTime / duration
        let offset = percentageComplete * Double(segmentViewCount * segmentPadding)
        
        setNeedsUpdateConstraints()
        progressLeadingConstraint?.constant = ((bounds.size.width / CGFloat(duration)) * CGFloat(currentTime)) + CGFloat(offset)
        layoutIfNeeded()
        
    }
    
    /*
     Remove the progress animation
     */
    open func stopAnimation(segmentDuration: Double, totalDuration: Double) {
        
        timer?.invalidate()
    
        segmentDurations.append(segmentDuration)
        
        // Stop the animating segment & account for the actual segment duration
        setNeedsUpdateConstraints()
        
        activeSegmentButton?.layer.removeAllAnimations()
        activeSegmentButton?.setBackgroundImage(nil, for: .normal)
        
        recordingIndicatorButton?.isHidden = true
        
        if segmentDuration != 0 {
            barViewWidthConstraint?.constant = (bounds.size.width / CGFloat(maxDuration)) * CGFloat(segmentDuration)
        }
        
        layoutIfNeeded()
                
        reset()
        
    }
    
    /**
     Resets the layout
     */
    open func reset() {
        timerTick = 0
    }
    
    /**
     */
    open func clearHighlightedSegment() {
        
        for s in subviews {
            
            if let btn = s as? UIButton {
                btn.backgroundColor = .maverickRed
            }
            
        }
        
    }
    
    // MARK: - Private Methods
    
    /**
     Adds a new view to indicate segment length. If `activeSegmentView` exists,
     apply a width constraint and it will add a new segment view to the stack.
     */
    fileprivate func addSegmentMarker(withWidth width: CGFloat = 0) {
        
        // Add new segment
        let lastActiveSegmentButton = activeSegmentButton
        
        log.verbose(segmentViewCount)
        
        activeSegmentButton = UIButton(type: .custom)
        activeSegmentButton!.frame = CGRect(x: 0, y: 0, width: width, height: 20.0)
        activeSegmentButton!.tag = segmentViewCount
        activeSegmentButton!.backgroundColor = .red
        activeSegmentButton!.addTarget(self, action: #selector(segmentButtonTapped(_:)), for: .touchUpInside)
        addSubview(activeSegmentButton!)
        sendSubview(toBack: activeSegmentButton!)
        
        barViewWidthConstraint = activeSegmentButton!.autoSetDimension(.width, toSize: width)
        activeSegmentButton!.autoSetDimension(.height, toSize: 20)
        activeSegmentButton!.autoPinEdge(.bottom, to: .bottom, of: self)
        
        if lastActiveSegmentButton != nil {
            let border = CALayer()
            border.backgroundColor = UIColor.white.cgColor
            border.frame = CGRect(x:0, y:0, width:2 , height: activeSegmentButton!.bounds.size.height)
            activeSegmentButton!.layer.addSublayer(border)
            activeSegmentButton!.autoPinEdge(.leading, to: .trailing, of: lastActiveSegmentButton!)
        } else {
            activeSegmentButton!.autoPinEdge(.leading, to: .leading, of: self)
        }
        
        segmentViewCount += 1
        
    }
    
    /**
     */
    fileprivate func getWidthForExistingSegments() -> CGFloat {
        
        var w: CGFloat = 0.0
        for v in subviews {
            w += (v.bounds.size.width + CGFloat(segmentPadding))
        }
        return w
        
    }

    /**
     Informs the delegate that a segment was selected
     */
    @objc fileprivate func segmentButtonTapped(_ sender: Any) {
        
        guard let button = sender as? UIButton else { return }
        
        if !selectionHightlightEnabled {
            
            delegate?.didSelectSegment(atIndex: button.tag)
            return
            
        }

        highlightSegment(atIndex: button.tag)

        delegate?.didSelectSegment(atIndex: selectedTimelineIndex)
        
    }
    
    /**
    */
    fileprivate func highlightSegment(atIndex index: Int) {
        
        if !selectionHightlightEnabled { return }
        
        for s in subviews {
            
            if let btn = s as? UIButton {
                
                if btn.tag == index {
                    s.backgroundColor = .maverickRed
                } else {
                    s.backgroundColor = .maverickLightRed
                }
                
            }
            
        }
        selectedTimelineIndex = index
        
    }
    
}
