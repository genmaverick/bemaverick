//
//  EntryField.swift
//  Maverick
//
//  Created by Garrett Fritz on 3/12/18.
//  Copyright © 2018 BeMaverick. All rights reserved.
//

import Foundation

protocol TextInputLayoutDelegate : class {
    
    func accesoryButtonTapped(_ sender : TextInputLayout)
    
}

class TextInputLayout : UIView {
    
    /// Main View
    @IBOutlet var view: UIView!
    /// Hint label for view
    @IBOutlet var hintLabel: UILabel!
    /// Entry text field
    @IBOutlet var entryTextView: UITextField!
    /// Underline
    @IBOutlet var underlineView: UIView!
    /// Validation text
    @IBOutlet weak var validationLabel: UILabel!
    /// Small hint label
    @IBOutlet weak var smallHintLabel: UILabel!
    /// Char limit label
    @IBOutlet weak var characterCounter: UILabel!
    
    @IBOutlet weak var accesoryButton: UIButton!
  
    @IBAction func accesoryButtonTapped(_ sender: Any) {
        
        accesoryDelegate?.accesoryButtonTapped(self)
        
    }
    
    /// is displaying large hint
    private var hintLarge = true
  
    /// accesory tap delegate
    private weak var accesoryDelegate : TextInputLayoutDelegate?
    /// max characters
    private var maxChar : Int?
    
    /// pass through delegate
    weak var delegate : UITextFieldDelegate?
    
    var charLimit : Int? {
        
        get {
            return maxChar
        }
        set {
            
            maxChar = newValue
            if let maxChar  = maxChar, maxChar > 0 {
                
                updateCharCounter()
                
            } else {
                
                characterCounter.text = nil
            
            }
            
        }
        
    }
    
    private func updateCharCounter(newCount : Int? = nil) {
        
        if  let maxChar = charLimit {
            var charCount = 0
            
            if let calcCharCount = entryTextView.text?.count {
                charCount = calcCharCount
            }
            if let newCount = newCount {
                charCount = newCount
            }
            let value = "\(charCount)/\(maxChar)"
            characterCounter.text = value
            
        } else {
            
            characterCounter.text = nil
            
        }
        
    }
    
    var text : String? {
        
        get {
            
            if let text = entryTextView.text {
                if text.isEmpty {
                    return nil
                }
            }
            return entryTextView.text
            
        }
        set {
            
            entryTextView.text = newValue
            if newValue != nil && newValue != "" {
                
                shrinkHint()
                
            } else {
                
                expandHint()
                
            }
            
        }
        
    }
    
    var shouldBeGrayedOut = false {
        
        didSet {
            
            if shouldBeGrayedOut {
                
                entryTextView.textColor = UIColor.gray
                smallHintLabel.textColor = UIColor.gray
            
            }
            
        }
        
    }
    
    func setAccesoryButton( normalText : String? = nil , selectedText : String? = nil, delegate : TextInputLayoutDelegate?) {
        
        accesoryButton.isHidden = false
        accesoryDelegate = delegate
        accesoryButton.setTitle(normalText, for: .normal)
        accesoryButton.setTitle(selectedText, for: .selected)
   
    }
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        setup()
        
    }
    
    required init?(coder: NSCoder) {
        
        super.init(coder: coder)
        setup()
        
    }
    
    func setup() {
        
        view = instanceFromNib()
        addSubview(view)
        view.frame = self.bounds
        view.backgroundColor = UIColor.clear
        underlineView.backgroundColor = UIColor.MaverickPrimaryColor
        entryTextView.delegate = self
        entryTextView.tintColor = UIColor.MaverickPrimaryColor
        characterCounter.textColor = UIColor.MaverickPrimaryColor
        accesoryButton.setTitleColor(UIColor.MaverickPrimaryColor, for: .normal)
        accesoryButton.setTitleColor(UIColor.MaverickPrimaryColor, for: .selected)
        accesoryButton.isHidden = true
        smallHintLabel.textColor = UIColor.MaverickDarkTextColor
        hintLabel.textColor = UIColor.MaverickDarkTextColor
        
    }
    
    
    func instanceFromNib() -> UIView {
        
        return R.nib.textInputLayout.firstView(owner: self)!
        
    }
    
    /**
     Set hint text
    */
    func setHints(shortHint : String, fullHint : String? = nil) {
        
        smallHintLabel.text = shortHint
        hintLabel.text = fullHint ?? shortHint
        
    }
    
    /**
     Entry started, show small hint
     */
    fileprivate func shrinkHint() {
        
        guard hintLarge else { return }
        self.hintLarge = false
        smallHintLabel.isHidden = hintLarge
        hintLabel.isHidden = !hintLarge
        
    }
    
    /**
     Entry ended, attempt to show large hint
     */
    fileprivate func expandHint() {
      
        guard !hintLarge else { return }
        guard entryTextView.text == nil || entryTextView.text == "" else { return }
        
        self.hintLarge = true
        smallHintLabel.isHidden = hintLarge
        hintLabel.isHidden = !hintLarge
        
    }
    
    /**
     Set valid and validation text
     */
    func setValidState(isValid : Bool, validationText : String? = nil) {
     
        underlineView.backgroundColor = isValid ? UIColor.MaverickPrimaryColor : UIColor.red
        validationLabel.textColor = isValid ? UIColor.MaverickDarkTextColor : UIColor.red
        validationLabel.text = validationText
        hintLabel.textColor = isValid ? UIColor.MaverickDarkTextColor : UIColor.red
        
    }

   
}

extension TextInputLayout : UITextFieldDelegate {
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        return delegate?.textFieldShouldBeginEditing?(textField) ?? true
    
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        shrinkHint()
        delegate?.textFieldDidBeginEditing?(textField)
        
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        
        return delegate?.textFieldShouldEndEditing?(textField) ?? true
        
    }
    
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextFieldDidEndEditingReason) {
        
        expandHint()
        delegate?.textFieldDidEndEditing?(textField , reason : reason)
         updateCharCounter()
 
    }
    
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        setValidState(isValid: true)
        if let charLimit = charLimit {
            let originalCount = textField.text?.count ?? 0
            var newCount = string.count
            
            if newCount == 0 {
                newCount = -range.length
            }
            
            newCount = originalCount + newCount
            
            if newCount > charLimit {
                return false
            } else {
                updateCharCounter(newCount: newCount)
            }
        }
        return delegate?.textField?(textField, shouldChangeCharactersIn: range, replacementString: string) ?? true
        
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        
        return delegate?.textFieldShouldClear?(textField) ?? true
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
      
        return delegate?.textFieldShouldReturn?(textField) ?? true
    
    }
    
}
