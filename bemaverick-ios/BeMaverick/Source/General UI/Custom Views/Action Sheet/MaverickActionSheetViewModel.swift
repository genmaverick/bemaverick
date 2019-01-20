//
//  MaverickActionSheetViewModel.swift
//  Maverick
//
//  Created by Chris Garvey on 4/11/18.
//  Copyright © 2018 BeMaverick. All rights reserved.
//

import UIKit

class MaverickActionSheetViewModel {
    
    // MARK: Private Properties
    
    /// The title for the title bar.
    private var title: String!
    
    /// The items that will be processed into order to make a final content view.
    private var maverickActionSheetItems: [MaverickActionSheetItem]!
    
    /// The alignment that is used to layout the views in the stack view.
    private var alignment: UIStackViewAlignment
    
    
    // MARK: - Public Property
    
    /// The height of the custom view if applicable.
    public var customViewHeight: Double?
    

    // MARK: - Life Cycle
    
    init(title: String, maverickActionSheetItems: [MaverickActionSheetItem], alignment: UIStackViewAlignment) {
        
        self.title = title
        self.maverickActionSheetItems = maverickActionSheetItems
        self.alignment = alignment
        
        if maverickActionSheetItems.count == 1 && maverickActionSheetItems.first?.myType() == .customView {
            customViewHeight = ((maverickActionSheetItems.first! as? CustomMaverickActionSheetItem)?.myHeight())!
        }
        
    }
    
    // MARK: - Public Functions
    
    /**
     Returns the title for the title bar.
     */
    public func titleForTitleBar() -> String {
        return title
    }
    
    /**
     Returns the content for the content area of the action sheet.
     */
    public func contentToAdd() -> UIView? {
        
        if let contentView = createContent(withItems: maverickActionSheetItems) {
            return contentView
        } else {
            return nil
        }
        
    }

    
    // MARK: - Private Functions
    
    /**
     Creates the content area that will appear below the title bar of the action sheet.
     
     - parameter items: An array of items that will be joined together into a UIStackView.
     */
    private func createContent(withItems items: [MaverickActionSheetItem]) -> UIView? {
        
        if items.isEmpty { return nil }
        
        if maverickActionSheetItems.count == 1 && maverickActionSheetItems.first?.myType() == .customView {
            return maverickActionSheetItems.first! as? UIView
        }
        
        var viewsToAdd = [UIView]()
        
        items.forEach { viewsToAdd.append(alignItemForContentArea($0)) }
        
        let contentAreaStackView = UIStackView(arrangedSubviews: viewsToAdd)
        contentAreaStackView.axis = .vertical
        contentAreaStackView.distribution = .fillProportionally
        contentAreaStackView.alignment = alignment
        contentAreaStackView.spacing = 8.0
        contentAreaStackView.translatesAutoresizingMaskIntoConstraints = false
        
        contentAreaStackView.arrangedSubviews.forEach { subView in

            let leadingConstraint = NSLayoutConstraint(item: subView, attribute: .leading, relatedBy: .equal, toItem: contentAreaStackView, attribute: .leading, multiplier: 1, constant: 16)
            let trailingConstraint = NSLayoutConstraint(item: subView, attribute: .trailing, relatedBy: .equal, toItem: contentAreaStackView, attribute: .trailing, multiplier: 1, constant: -16)

            NSLayoutConstraint.activate([leadingConstraint, trailingConstraint])

        }

        return contentAreaStackView
        
    }
    
    /**
     Aligns the MaverickActionSheetItem to be consistent with how the UIStackView will be laying out the subviews.
     
     parameter maverickActionSheetItem: The item to be aligned.
     */
    private func alignItemForContentArea(_ maverickActionSheetItem: MaverickActionSheetItem) -> UIView {
        
        if maverickActionSheetItem.myType() == .customView {
            
            return maverickActionSheetItem as! UIView
            
        } else {
            
            if maverickActionSheetItem.myType() == .message {
                
                (maverickActionSheetItem as! MaverickActionSheetMessage).textAlignment = textAlignmentForStackViewAlignment(alignment)
                
            } else {
                
                (maverickActionSheetItem as! MaverickActionSheetButton).titleLabel?.textAlignment = textAlignmentForStackViewAlignment(alignment)
                
            }
            
            return maverickActionSheetItem as! UIView
            
        }
        
    }
    
    /**
     Returns the matching text alignment for a UIStackView alignment.
     
     -parameter stackViewAlignment: The UIStackView alignment to be mapped to an NSTextAlignment
     */
    private func textAlignmentForStackViewAlignment(_ stackViewAlignment: UIStackViewAlignment) -> NSTextAlignment {
        
        switch stackViewAlignment {
            
        case .leading:
            return NSTextAlignment.left
        case .center:
            return NSTextAlignment.center
        case .trailing:
            return NSTextAlignment.right
        default:
            return NSTextAlignment.center
            
        }
        
    }
    
}
