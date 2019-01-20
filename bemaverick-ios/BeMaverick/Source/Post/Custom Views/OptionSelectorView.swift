//
//  OptionSelectorView.swift
//  BeMaverick
//
//  Created by David McGraw on 10/23/17.
//  Copyright © 2017 BeMaverick. All rights reserved.
//

import UIKit
import SCRecorder

enum SelectorMode {
    case none
 
    case filter
    case background
    case sticker
    case text
    case doodle
}

protocol OptionSelectorViewDelegate: class {
    func enableTappableMinimizerView(_ enabled: Bool)
}

class OptionSelectorView: UIView {
    
    // MARK: - IBOutlets
    
    /// A view containing filter options
    @IBOutlet weak var filterOptionsView: EditFilterOptionsView!
    
    /// A view containing stickers
    @IBOutlet weak var stickerOptionsView: EditStickerOptionsView!
    
    /// A view containing backgrounds
    @IBOutlet weak var backgroundOptionsView: EditBackgroundOptionsView!
    
    
    /// A view containing text and drawing controls
    @IBOutlet weak var textOptionsView: EditTextOptionsView!
    
    var topConstraint: NSLayoutConstraint!
    
    var expansionHeightForStickerOptionsView: CGFloat!
    
    
    // MARK: - Public Properties
    
    weak var optionSelectorViewDelegate: OptionSelectorViewDelegate?
    
    var mode: SelectorMode = .filter {
        
        didSet {
            
            if oldValue != mode {
                
                configureView()
            
            } else if oldValue == .sticker && mode == .sticker {
                
                if stickerOptionsView.isMaximized {
                    
                    minimizeHeight()
                    stickerOptionsView.isMaximized = false
                    optionSelectorViewDelegate?.enableTappableMinimizerView(false)
                    
                } else {
                    
                    maximizeHeight()
                    stickerOptionsView.isMaximized = true
                    optionSelectorViewDelegate?.enableTappableMinimizerView(true)
                    
                }
                
            }
            
        }
        
    }
    
    // MARK: - Layout
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        addSubview(backgroundOptionsView)
        backgroundOptionsView.autoPinEdgesToSuperviewEdges(with: UIEdgeInsetsMake(10, 0, 44, 0))
        
        addSubview(filterOptionsView)
        filterOptionsView.autoPinEdgesToSuperviewEdges(with: UIEdgeInsetsMake(10, 0, 44, 0))
        
        addSubview(stickerOptionsView)
        stickerOptionsView.autoPinEdgesToSuperviewEdges(with: UIEdgeInsetsMake(0, 0, 44, 0))
        stickerOptionsView.editStickerOptionsViewDelegate = self
        
        addSubview(textOptionsView)
        textOptionsView.autoPinEdgesToSuperviewEdges(with: UIEdgeInsetsMake(0, 0, 44, 0))
        
        topConstraint = superview!.constraints.filter { $0.identifier == "topConstraintForOptionSelectorView" }.first!
        
        expansionHeightForStickerOptionsView = setExpansionHeight(forView: stickerOptionsView)
        
    }
    
    deinit {
        log.verbose("💥")
    }
    
    // MARK: - Private Properties
    
    private func configureView() {
        
        filterOptionsView.isHidden = true
        stickerOptionsView.isHidden = true
        textOptionsView.isHidden = true
        backgroundOptionsView.isHidden = true
        
        switch mode {
        case .filter:
            topConstraint.constant = 0
            filterOptionsView.isHidden = false
            optionSelectorViewDelegate?.enableTappableMinimizerView(false)
        case .sticker:
            stickerOptionsView.isHidden = false
            maximizeHeight()
            optionSelectorViewDelegate?.enableTappableMinimizerView(true)
        case .text:
            textOptionsView.isHidden = false
            textOptionsView?.drawingContentView.isHidden = true
            topConstraint.constant = 0
            optionSelectorViewDelegate?.enableTappableMinimizerView(false)
        case .background:
            backgroundOptionsView.isHidden = false
            topConstraint.constant = 0
        case .doodle:
            textOptionsView.isHidden = false
            textOptionsView?.drawingContentView.isHidden = false
            topConstraint.constant = 0
            optionSelectorViewDelegate?.enableTappableMinimizerView(false)
        default:
            break
        }
        
    }
    
    private func setExpansionHeight(forView view: UIView) -> CGFloat {
        return CGFloat(bounds.height * 1.5)
    }
    
}

extension OptionSelectorView: EditStickerOptionsViewDelegate {
    
   func minimizeHeight() {
        topConstraint.constant = 0
        optionSelectorViewDelegate?.enableTappableMinimizerView(false)
        stickerOptionsView.isMaximized = false
    }
    
    func maximizeHeight() {
        
        topConstraint.constant = expansionHeightForStickerOptionsView * -1
        stickerOptionsView.isMaximized = true
        optionSelectorViewDelegate?.enableTappableMinimizerView(true)
    }
    
}
