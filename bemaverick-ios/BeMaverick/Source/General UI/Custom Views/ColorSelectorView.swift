//
//  ColorSelectorView.swift
//  BeMaverick
//
//  Created by David McGraw on 10/16/17.
//  Copyright © 2017 BeMaverick. All rights reserved.
//

import UIKit
import PureLayout

protocol ColorSelectorDelegate {
    
    func didSelectColor(color: UIColor)
    
}

class ColorSelectorView: UIView {
    
    // MARK: - Public Properties

    /// Default set of system colors
    let defaultColors: [UIColor] = [ .white, .black, .red, .green, .blue, .cyan, .yellow, .magenta, .purple, .brown, .orange ]
    
    /// The object that acts as the delegate of the view
    var delegate: ColorSelectorDelegate?
    
    // MARK: - Private Properties
    
    /// Scroll view for the color selector
    fileprivate var scrollView: UIScrollView?

    /// Content view within the scroll view
    fileprivate var contentView: UIView?
    
    /// Stack view containing the colors
    fileprivate var stackView: UIStackView?
    
    /// A reference to the selected button
    fileprivate var selectedButton: UIButton?
    
    // MARK: - Lifecycle
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        
        configureView()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSublayers(of layer: CALayer) {
        
        super.layoutSublayers(of: layer)
        
        scrollView?.frame = bounds
        
    }
    
    // MARK: - Private Methods
    
    fileprivate func configureView() {
        
        scrollView = UIScrollView(frame: bounds)
        scrollView!.contentInset = UIEdgeInsetsMake(0, 10, 0, 0)
        scrollView!.isDirectionalLockEnabled = true
        scrollView!.showsHorizontalScrollIndicator = false
        scrollView!.showsVerticalScrollIndicator = false
        addSubview(scrollView!)
        
        contentView = UIView(frame: bounds)
        contentView!.backgroundColor = .clear
        scrollView!.addSubview(contentView!)
        
        stackView = UIStackView(frame: bounds)
        stackView!.spacing = 5.0
        stackView!.alignment = .leading
        stackView!.distribution = .fill
        contentView!.addSubview(stackView!)
        
        stackView!.autoPinEdge(.leading, to: .leading, of: contentView!)
        stackView!.autoPinEdge(.trailing, to: .trailing, of: contentView!)
        stackView!.autoPinEdge(.top, to: .top, of: contentView!)
        stackView!.autoPinEdge(.bottom, to: .bottom, of: contentView!, withOffset: -10.0)
        
        contentView!.autoPinEdge(.top, to: .top, of: scrollView!)
        contentView!.autoPinEdge(.bottom, to: .bottom, of: scrollView!)
        contentView!.autoPinEdge(.leading, to: .leading, of: scrollView!)
        contentView!.autoPinEdge(.trailing, to: .trailing, of: scrollView!)
        contentView!.autoAlignAxis(.horizontal, toSameAxisOf: scrollView!)
        contentView!.autoMatch(.width, to: .width, of: stackView!, withOffset: 0.0)
        
        
        for color in defaultColors {
            
            let button = UIButton(type: .custom)
            button.backgroundColor = color
            button.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
            button.layer.borderColor = UIColor.white.cgColor
            button.layer.borderWidth = 3.0
            button.layer.cornerRadius = 15.0
            button.layer.masksToBounds = true
            button.layer.shouldRasterize = true
            
            stackView!.addArrangedSubview(button)
            
            button.autoSetDimension(.width, toSize: 30.0)
            
            if stackView!.arrangedSubviews.count == 1 {
                
                selectedButton = button
                button.layer.borderColor = UIColor.maverickBrightTeal.cgColor
                
            }
            
        }
        
    }
    
    @objc fileprivate func buttonTapped(_ sender: Any) {
        
        guard let button = sender as? UIButton,
            let color = button.backgroundColor else { return }
        
        selectedButton?.layer.borderColor = UIColor.white.cgColor
        button.layer.borderColor = UIColor.maverickBrightTeal.cgColor
        
        selectedButton = button
        
        delegate?.didSelectColor(color: color)
        
    }
    
}
