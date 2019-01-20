//
//  EditChallengePreviewCollectionViewCell.swift
//  Maverick
//
//  Created by Garrett Fritz on 7/24/18.
//  Copyright © 2018 BeMaverick. All rights reserved.
//

import Foundation
import Kingfisher

protocol EditChallengePreviewDelegate : class {
    
    func addLinkTapped()
    
}


class EditChallengePreviewCollectionViewCell : UICollectionViewCell {
    
    @IBOutlet  var linkAdditionalSpaceConstraint: NSLayoutConstraint!
    @IBOutlet weak var previewImage: UIImageView!
    
    @IBOutlet weak var descriptionHint: UILabel!
    
    @IBOutlet weak var challengeTitleField: UITextField!
    
    @IBOutlet weak var challengeDescriptionTextView: UITextView!
    
    @IBOutlet weak var bottomHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var autoCompleteView: MaverickAutoCompleteView!
    @IBOutlet weak var validationUnderline: UIView!
    
    @IBOutlet weak var addLinkButton: UIButton!
    private var titleLengthCap = 25
    weak var delegate : EditChallengePreviewDelegate?
    @IBOutlet weak var titleCharCount: UILabel!
    
    @IBAction func previewAreaTapped(_ sender: Any) {
        
      endEditting()
        
    }
    
    
    @IBAction func addLinkTapped(_ sender: Any) {
        
         linkAdditionalSpaceConstraint.isActive = false
        bottomHeightConstraint.constant = 1
        challengeDescriptionTextView.textContainer.exclusionPaths = []
        contentView.setNeedsLayout()
        contentView.layoutIfNeeded()
        addLinkButton.isHidden = true
        delegate?.addLinkTapped()
        
    }
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        clipsToBounds = false
        contentView.clipsToBounds = false
        challengeDescriptionTextView.tintColor = UIColor.MaverickPrimaryColor
        challengeTitleField.tintColor = UIColor.MaverickPrimaryColor
        challengeDescriptionTextView.delegate = self
        challengeTitleField.delegate = self
        autoCompleteView.configureWith(textView: challengeDescriptionTextView, delegate: self, services: (UIApplication.shared.delegate as! AppDelegate).services)
     
        validationUnderline.backgroundColor = UIColor.MaverickBadgePrimaryColor
        validationUnderline.isHidden = true
        challengeTitleField.becomeFirstResponder()
        let value = "\(0)/\(titleLengthCap)"
        titleCharCount.text = value
    }
    
    func setLinkVisibility(visible : Bool) {
        
        addLinkButton.isHidden = !visible
        bottomHeightConstraint.constant = !visible ? 1 : 6
        linkAdditionalSpaceConstraint.isActive = visible
        
    }
    
    func configure(with image : UIImage?, imageMedia : MaverickMedia? = nil, title: String? = nil, description : String? = nil, hasLink : Bool, isVerified : Bool) {
        
        if let path = imageMedia?.getUrlForSize(size: LargeContentCollectionViewCell.getCellSize() ), let url = URL(string: path) {
            
            previewImage.kf.indicatorType = .activity
            previewImage.backgroundColor = UIColor(rgba: "00A8B0")
            previewImage.kf.setImage(with: url, placeholder: nil, options: [.transition(.fade(UIImage.fadeInTime))], progressBlock: nil, completionHandler: nil)
            
        } else {
            
            previewImage.image = image
            
        }
        
        setLinkVisibility(visible: !hasLink)
        challengeTitleField.text = title
        challengeDescriptionTextView.text = description
        
        if let description = description {
            
            descriptionHint.isHidden = description != ""
        
        } else {
            
            descriptionHint.isHidden = false
        
        }
        
    }
    
    func endEditting() {
        
        challengeTitleField.resignFirstResponder()
        challengeDescriptionTextView.resignFirstResponder()
        autoCompleteView.clear()
        
    }
    
    func validate() -> Bool {
        
        let spaceRemoved = challengeTitleField.text?.replacingOccurrences(of: " ", with: "") ?? ""
        
        
        if challengeTitleField.text?.count ?? 0 < 2 || spaceRemoved.count < 2 {
            
            challengeTitleField.placeHolderColor = UIColor.MaverickBadgePrimaryColor
            challengeTitleField.text = nil
            validationUnderline.isHidden = false
            titleCharCount.textColor = UIColor.MaverickBadgePrimaryColor
            return false
            
        }
          challengeTitleField.placeHolderColor = UIColor(rgba: "9B9B9Bff")
        titleCharCount.textColor = UIColor(rgba: "9B9B9Bff")
        validationUnderline.isHidden = true
        challengeTitleField.placeHolderColor = descriptionHint.textColor
        return true
        
    }
    
}

extension EditChallengePreviewCollectionViewCell : UITextViewDelegate, UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        guard let text = textField.text else { return true }
        let newLength = text.count + string.count - range.length
        if newLength <= titleLengthCap {
            
            let value = "\(newLength)/\(titleLengthCap)"
            titleCharCount.text = value
            
        }
        
        challengeTitleField.placeHolderColor = UIColor(rgba: "9B9B9Bff")
        titleCharCount.textColor = UIColor(rgba: "9B9B9Bff")
        validationUnderline.isHidden = true
        return newLength <= titleLengthCap
        
    }
    
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        if let input = textView.text {
            
            let testString = (input as NSString).replacingCharacters(in: range, with: text)
            descriptionHint.isHidden =  testString.count > 0
            
        } 
        
        return true
        
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        
        if textView == challengeDescriptionTextView {
            
            descriptionHint.isHidden = !(textView.text.count == 0)
            
        }
        
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        endEditting()
        return true
    
    }
    
}



