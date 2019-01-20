//
//  EditTextOptionsView.swift
//  BeMaverick
//
//  Created by David McGraw on 12/21/17.
//  Copyright © 2017 BeMaverick. All rights reserved.
//

import UIKit

class EditTextOptionsView: UIView {
    
    // MARK - IBOutlets
    
    /// A scrollview the view for smaller screens
    @IBOutlet weak var scrollView: UIScrollView!
    
    /// A scrollview for the stack view
    @IBOutlet weak var colorScrollView: UIScrollView!
    
    /// A stack view containing the options
    @IBOutlet weak var colorStackView: UIStackView!
    
    /// A scrollview for the stack view
    @IBOutlet weak var fontScrollView: UIScrollView!
    
    /// A stack view containing the options
    @IBOutlet weak var fontStackView: UIStackView!
    
    /// View containing drawing options
    @IBOutlet weak var drawingContentView: UIView!
    
    /// Drawing style
    @IBOutlet weak var brushButton: UIButton!
    
    /// Medium font size
    @IBOutlet weak var brushSizeMediumButton: UIButton!
    
    @IBOutlet weak var contentWidthConstraint: NSLayoutConstraint!
    // MARK: - Private Properties
    
    
    /// The number of fonts under Resources/Editor
    fileprivate let numberOfAvailableFonts = 5
    
    ///
    fileprivate var lastSelectedColorButton: UIButton?
    fileprivate var lastSelectedBrushButton: UIButton?
    fileprivate var lastSelectedBrushSizeButton: UIButton?
    
    // MARK: - IBActions
    
    @IBAction func undoButtonTapped(_ sender: Any) {
        delegate?.didSelectUndoAction()
    }
    
    @IBAction func redoButtonTapped(_ sender: Any) {
        delegate?.didSelectRedoAction()
    }
    
    /**
     Informs the delegate that a drawing option was selected
     */
    @IBAction func didSelectDrawingOption(_ sender: Any) {
        
        if let sender = sender as? UIButton {
            
            sender.isSelected = true
            
            if sender.tag >= Constants.RecordingBrushType.brush.rawValue &&
                sender.tag <= Constants.RecordingBrushType.erase.rawValue {
            
                lastSelectedBrushButton?.isSelected = false
                lastSelectedBrushButton = sender
                delegate?.didSelectBrushType(Constants.RecordingBrushType(rawValue: sender.tag)!)
                
            }
            
            if sender.tag >= Constants.RecordingBrushSize.size1.rawValue &&
                sender.tag <= Constants.RecordingBrushSize.size6.rawValue {
                
                lastSelectedBrushSizeButton?.isSelected = false
                lastSelectedBrushSizeButton = sender
                lastSelectedBrushSizeButton?.removeBorder()
                sender.updateBorder(.MaverickBadgePrimaryColor)
                delegate?.didSelectBrushSize(Constants.RecordingBrushSize(rawValue: sender.tag)!)
                
            }
            
        }
        
    }
    
    // MARK: - Public Properties
    
    /// The object that acts as the delegate of the selector view
    weak var delegate: PostEditorDelegate? {
        didSet {
            delegate?.setInitialColor((lastSelectedColorButton?.backgroundColor)!)
        }
    }
    
    // MARK - Lifecycle
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        colorScrollView.contentInset = UIEdgeInsetsMake(0, 10, 0, 0)
        colorStackView.distribution = .fill
        colorStackView.alignment = .leading
        
        fontScrollView.contentInset = UIEdgeInsetsMake(0, 10, 0, 0)
        fontStackView.distribution = .fill
        fontStackView.alignment = .leading
        
        contentWidthConstraint.constant = UIScreen.main.bounds.width
        
        configureView()
        
    }
    
    
    // MARK: - Private Methods
    
    /**
    */
    fileprivate func configureView() {
    
        // Set colors
        var idx = 0
        
        for color in Variables.Content.getPostTextFontColors() {
            
            let container = UIView(frame: CGRect(x: 0, y: 0, width: 34, height: 70))
            container.backgroundColor = .clear
            
            let button = UIButton(type: .system)
            button.frame = CGRect(x: 0, y: 0, width: 34, height: 34)
            button.tag = idx
            button.backgroundColor = color
            button.addTarget(self, action: #selector(didSelectColor(_:)), for: .touchUpInside)
            container.addSubview(button)
            
            button.layer.cornerRadius = 17
            button.applyBorder(.MaverickBadgePrimaryColor, width: 8)
            
            if idx == 0 {
                lastSelectedColorButton = button
                button.updateBorder(.MaverickBadgePrimaryColor, width: 8)
            } else {
                button.updateBorder(.maverickBackgroundLight, width: 0)
            }
            
            button.addShadow()
            
            colorStackView.addArrangedSubview(container)
            
            container.autoSetDimension(.width, toSize: 34)
            container.autoPinEdge(.top, to: .top, of: colorScrollView)
            container.autoPinEdge(.bottom, to: .bottom, of: colorScrollView)
            
            button.autoSetDimension(.width, toSize: 34)
            button.autoSetDimension(.height, toSize: 34)
            button.autoAlignAxis(toSuperviewAxis: .vertical)
            button.autoAlignAxis(toSuperviewAxis: .horizontal)
            
            idx += 1
            
        }
        
        // Set colors
        for idx in 0..<numberOfAvailableFonts {
            
            let font = getFont(forIndex: idx)
            
            let container = UIView(frame: CGRect(x: 0, y: 0, width: 64, height: 70))
            container.backgroundColor = .clear
            
            let button = UIButton(type: .custom)
            button.frame = CGRect(x: 0, y: 0, width: 60, height: 30)
            button.setTitle(font.name, for: .normal)
            button.titleLabel?.font = font.font
            button.setTitleColor(UIColor.black, for: .normal)
            button.setTitleColor(UIColor.MaverickBadgePrimaryColor, for: .selected)
            button.addTarget(self, action: #selector(didSelectFont(_:)), for: .touchUpInside)
            container.addSubview(button)
            
            button.tag = idx
            button.sizeToFit()
            
            if idx == 0 {
                button.isSelected = true
            }
            
            fontStackView.addArrangedSubview(container)
            
            container.autoSetDimension(.width, toSize: button.frame.width + 14)
            container.autoPinEdge(.top, to: .top, of: fontScrollView)
            container.autoPinEdge(.bottom, to: .bottom, of: fontScrollView)
            
            button.autoSetDimension(.height, toSize: 20)
            button.autoAlignAxis(toSuperviewAxis: .vertical)
            button.autoAlignAxis(toSuperviewAxis: .horizontal)
            
        }
        
        didSelectDrawingOption(brushButton)
        didSelectDrawingOption(brushSizeMediumButton)
        
    }
    
    /**
     Get a font within a range of 0 to `numberOfAvailableFonts` that can be found
     under resources/fonts
    */
    fileprivate func getFont(forIndex index: Int, size: CGFloat = 24.0) -> (name: String, font: UIFont) {
        
        switch index {
        case 0:
            return ("Oswald", R.font.oswaldRegular(size: size)!)
        case 1:
            return ("Arvo", R.font.arvo(size: size)!)
        case 2:
            return ("Bevan", R.font.bevanRegular(size: size)!)
        case 3:
            return ("Amatic", R.font.amaticSCRegular(size: size)!)
        case 4:
            return ("Sans", R.font.ptSansRegular(size: size)!)
        
        default:
            break
        }
        
        return ("Anton", R.font.antonRegular(size: size)!)
        
    }
    
    /**
     Informs the delegate that a color was selected
     */
    @objc fileprivate func didSelectColor(_ sender: Any) {
        
        if let sender = sender as? UIButton {
            
            lastSelectedColorButton?.updateBorder(.maverickBackgroundLight, width: 0)
            sender.updateBorder(.MaverickBadgePrimaryColor, width: 8.0)
            
            lastSelectedColorButton = sender
            
            guard let color = Variables.Content.getPostTextFontColors()[safe: sender.tag] else { return }
            
            delegate?.didSelectColor(color)
           
        }
        
    }
    
    /**
     Informs the delegate that a font was selected
     */
    @objc fileprivate func didSelectFont(_ sender: Any) {
        
        if let sender = sender as? UIButton {
            
            for container in fontStackView.arrangedSubviews {
                
                if let btn = container.subviews.first as? UIButton {
                    btn.isSelected = false
                }
                
            }
            
            sender.isSelected = true
            delegate?.didSelectFont(getFont(forIndex: sender.tag).font)
            
        }
        
    }
    
}
