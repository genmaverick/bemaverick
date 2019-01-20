//
//  PostEditorDelegate.swift
//  Maverick
//
//  Created by David McGraw on 3/1/18.
//  Copyright © 2018 BeMaverick. All rights reserved.
//

import Foundation
import SCRecorder

protocol PostEditorDelegate: class {
    
    func lockedRewardTapped(rewardType : Reward.RewardTypes)
    
    func isRewardLocked(rewardType : Reward.RewardTypes) -> Bool
    
    /// Called when the user is done with the option selector
    func didCompleteOptionSelection(withTags tags: [String]?)
    
    /// User tapped on a filter
    func didSelectFilter(_ filter: SCFilter)
    
    /// User tapped on a sticker
    func didSelectSticker(_ image: UIImage, stickerName: String)
    
    /// User tapped on a sticker
    func didSelectBackgroundColor(_ color: UIColor)
    
    /// User tapped on a color
    func didSelectColor(_ color: UIColor)
    
    /// User tapped on a font
    func didSelectFont(_ font: UIFont)
    
    /// User tapped undo
    func didSelectUndoAction()
    
    /// User tapped redo
    func didSelectRedoAction()
    
    /// User tapped on a brush type
    func didSelectBrushType(_ type: Constants.RecordingBrushType)
    
    /// User tapped on a brush size
    func didSelectBrushSize(_ type: Constants.RecordingBrushSize)
    
    /// User updated the Saturation, Brightness or Hue
    func didUpdateFilter(withFilterValues values: [Constants.FilterParameter: CGFloat])
    
    /// Adjust option view bottom offset
    func adjustOptionSelectorViewOffset(_ offset: CGFloat, newAlpha: CGFloat)
    
    /// Set the initial text color
    func setInitialColor(_ color: UIColor)
    
}
