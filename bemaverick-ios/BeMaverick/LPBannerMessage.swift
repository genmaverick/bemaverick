//
//  UploadMessageView.swift
//  BeMaverick
//
//  Created by David McGraw on 2/4/18.
//  Copyright © 2018 BeMaverick. All rights reserved.
//

import SwiftMessages


class LPBannerMessage: MessageView {
    
    // MARK: - IBOutlet
    
    @IBOutlet weak var contentView: UIView!
    
    @IBOutlet weak var closeButtonWidthConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var closeButton: UIButton!
    
    @IBAction func ctaPressed(_ sender: Any) {
        
        if let ctaUrl = ctaUrl, let url = URL(string: ctaUrl), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
        SwiftMessages.hide()
        
    }
    
    @IBAction func closeButtonTapped(_ sender: Any) {
        
        SwiftMessages.hide()
    }
    
    // MARK: - Public Properties
    
    private var ctaUrl : String?
    /// A reference to the global services
    open var services: GlobalServicesContainer = (UIApplication.shared.delegate as! AppDelegate).services
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        
    }
    
    func configure(backgroundColor : UIColor, titleText : String, titleColor : UIColor, ctaText : String, ctaTextColor : UIColor, ctaBackgroundColor : UIColor, ctaEnabled : Bool, ctaUrl : String, hasCloseButton : Bool) {
        
        
        self.backgroundColor = backgroundColor
        
        titleLabel?.text = titleText
        titleLabel?.textColor = titleColor
        button?.setTitle(ctaText, for: .normal)
        button?.backgroundColor = ctaBackgroundColor
        button?.setTitleColor(ctaTextColor, for: .normal)
        closeButton.tintColor = ctaTextColor
        
        self.ctaUrl = ctaUrl
        
        if !hasCloseButton {
            
            closeButtonWidthConstraint.constant = 0
            layoutIfNeeded()
            closeButton.isHidden = true
            
        }
        if !ctaEnabled {
            
            button?.setTitle(nil, for: .normal)
            button?.contentEdgeInsets = .zero
            button?.isHidden = true
            titleLabel?.contentMode = .center
        }
        
        
    }
    
    
    
    
    
}
