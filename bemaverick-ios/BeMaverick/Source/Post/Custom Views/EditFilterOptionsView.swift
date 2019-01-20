//
//  EditFilterOptionsView.swift
//  BeMaverick
//
//  Created by David McGraw on 10/23/17.
//  Copyright © 2017 BeMaverick. All rights reserved.
//

import UIKit
import SCRecorder

class EditFilterOptionsView: UIView {
    
    // MARK - IBOutlets
    
    /// A scrollview for the stack view
    @IBOutlet weak var scrollView: UIScrollView!
    
    /// Move the scroll view out of the way to reveal the saved filter
    @IBOutlet weak var scrollViewLeadingConstraint: NSLayoutConstraint!
    
    /// A stack view containing the options
    @IBOutlet weak var stackView: UIStackView!
    
    // MARK: - Public Properties
    
    /// The object that acts as the delegate of the selector view
    open weak var delegate: PostEditorDelegate?
    
    /// A reference to the filter selector
    open var filters: [SCFilter] = []
    
    /// The default preview image to show the filter with
    open var defaultPreviewImage: UIImage? {
        
        didSet {
            
            refreshAvailableFilters()
       
        }
        
    }
    
    /// The last selected index
    fileprivate(set) var lastSelectedIndex: Int = 0
    
    // MARK: - Private Properties
  
    // MARK - Lifecycle
    
    deinit {
        
        for v in stackView.arrangedSubviews {
            
            for c in v.subviews {
                
                if let iv = c as? UIImageView {
                    iv.image = nil
                }
                
            }
            
        }
        
        log.verbose("💥")
        
    }
    
    override func awakeFromNib() {
    
        super.awakeFromNib()
        
        scrollView.contentInset = UIEdgeInsetsMake(0, 10, 0, 0)
        
        stackView.distribution = .fill
        stackView.alignment = .leading
        
        
    }
    
    // MARK: - Public Methods
    
    /**
    */
    func reloadSelectedFilterStyle() {
        
        setSelectedFilter(atIndex: lastSelectedIndex)
    
    }
    
    /**
     Select the provided filter
    */
    func setSelectedFilter(withFilter filter: SCFilter) {
    
        var idx = 0
        for o in filters {
            
            if o == filter {
                setSelectedFilter(atIndex: idx)
                return
            }
            idx += 1
            
        }
        
    }
    
    // MARK: - Private Methods

    
    /**
     Refreshes the available filters based on the filters included in `cameraFilterSwitcherView`
     */
    fileprivate func refreshAvailableFilters() {
        
        var idx = 0
        for filter in filters  {
            
            
            createFilterNodeView(withFilter: filter, index: idx)
            idx += 1
            
        }
        
    }
    
    /**
     Highlight the selected filter
     */
    fileprivate func setSelectedFilter(atIndex idx: Int) {
        
        if idx != lastSelectedIndex && lastSelectedIndex != -1 {
            deselectFilter(atIndex: lastSelectedIndex)
        }
        lastSelectedIndex = idx
        
        let container = stackView.arrangedSubviews[idx]
        container.backgroundColor = .MaverickBadgePrimaryColor
        
    }
    
    /**
     Remove the highlight for the filter at the index
     */
    fileprivate func deselectFilter(atIndex idx: Int) {
        
        let container = stackView.arrangedSubviews[idx]
        container.backgroundColor = .white
        
    }
    
    /**
     Creates a filter preview node and adds it to the stack view
     */
    fileprivate func createFilterNodeView(withFilter filter: SCFilter, index: Int) {
        
        if defaultPreviewImage == nil {

            for v in stackView.arrangedSubviews.reversed() {
                stackView.removeArrangedSubview(v)
                v.removeFromSuperview()
            }
            return
            
        }
        
        let container = UIView(frame: CGRect(x: 0, y: 0, width: 70, height: 140))
        container.backgroundColor = .white
        
        let image = UIImageView(frame: container.bounds)
        image.backgroundColor = .maverickGrey
        let resizedImage = defaultPreviewImage?.resizedImage(with: .scaleAspectFill, bounds: image.frame.size, interpolationQuality: .high)
        image.image = resizedImage
        image.clipsToBounds = true
        image.contentMode = .scaleAspectFill
        
        DispatchQueue.global(qos: .utility).async {
        
            let processed = filter.uiImage(byProcessingUIImage: resizedImage)
            DispatchQueue.main.async {
                image.image = processed
            }
        
        }
    
        container.addSubview(image)
        image.autoPinEdgesToSuperviewEdges(with: UIEdgeInsetsMake(2, 2, 2, 2))
        
        // ACTION
        let button = UIButton(type: .custom)
        button.frame = container.frame
        button.addTarget(self, action: #selector(didSelectFilter(_:)), for: .touchUpInside)
        button.tag = index
        container.addSubview(button)
        button.autoPinEdgesToSuperviewEdges()
        
        if index == 0 {
            container.backgroundColor = .MaverickBadgePrimaryColor
        }
        
        stackView.addArrangedSubview(container)
        container.autoSetDimension(.width, toSize: 120)
        container.autoPinEdge(.top, to: .top, of: scrollView)
        container.autoPinEdge(.bottom, to: .bottom, of: scrollView)
        
    }
    
    /**
     Informs the delegate that a filter was selected and highlights its
     */
    @objc fileprivate func didSelectFilter(_ sender: Any) {
       
        if let sender = sender as? UIButton {
                
            setSelectedFilter(atIndex: sender.tag)
            delegate?.didSelectFilter(filters[sender.tag])
            
        }
        
    }
    
}

