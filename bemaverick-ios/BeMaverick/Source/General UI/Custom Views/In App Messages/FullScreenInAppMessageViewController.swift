//
//  FullScreenInAppMessageViewController.swift
//  Maverick
//
//  Created by Garrett Fritz on 6/26/18.
//  Copyright © 2018 BeMaverick. All rights reserved.
//

import Foundation

@objcMembers
class FullScreenInAppMessageViewController : ViewController {
    
    @IBOutlet weak var mainImageView: UIImageView!
    
    @IBOutlet weak var imageViewRatio: NSLayoutConstraint!
    
    @IBOutlet weak var lowerContentContainer: UIView!
    
    @IBOutlet weak var secondaryButton: UIButton!
    
    @IBOutlet weak var primaryButton: UIButton!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var descriptionLabel: UILabel!
    
    private var backgroundColor : UIColor?
    private var imageBackgroundColor : UIColor?
    private var backgroundImage : UIImage?
    private var titleText : String?
    private var titleColor : UIColor?
    private var descriptionText : String?
    private var descriptionColor : UIColor?
    private var primaryButtonText : String?
    private var primaryButtonTextColor : UIColor?
    private var secondaryButtonText : String?
    private var secondaryButtonTextColor : UIColor?
    private var secondaryButtonAction : String?
    private var cropImage = true
    private var imageRatio : CGFloat = 0.5
    
    private var context: LPActionContext?
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        mainImageView.image = backgroundImage
        mainImageView.backgroundColor = backgroundColor
        mainImageView.contentMode = cropImage ? .scaleAspectFill : .scaleAspectFit
        lowerContentContainer.backgroundColor = backgroundColor
        mainImageView.backgroundColor = imageBackgroundColor
        titleLabel.text = titleText
        titleLabel.textColor = titleColor
        descriptionLabel.text = descriptionText
        descriptionLabel.textColor = descriptionColor
        primaryButton.setTitle(primaryButtonText, for: .normal)
        primaryButton.setTitleColor(primaryButtonTextColor, for: .normal)
        secondaryButton.setTitle(secondaryButtonText, for: .normal)
        secondaryButton.setTitleColor(secondaryButtonTextColor, for: .normal)
        
        let newConstraint = imageViewRatio.constraintWithMultiplier(imageRatio)
        view.removeConstraint(imageViewRatio)
        imageViewRatio = newConstraint
        view.addConstraint(newConstraint)
        view.layoutIfNeeded()
        
    }
    
    @IBAction func secondaryButtonTapped(_ sender: Any) {
        
        if let ctaUrl = secondaryButtonAction, let url = URL(string: ctaUrl), UIApplication.shared.canOpenURL(url) {
            
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
            
        }
       
        dismiss(animated: true, completion: nil)
       
    }
    
    @IBAction func primaryButtonTapped(_ sender: Any) {
        
        context?.runTrackedActionNamed("Primary Button.Action")
        
        dismiss(animated: true, completion: nil)
        
    }
    
}

extension FullScreenInAppMessageViewController  {
    
    static func getDefinitions() -> [LPActionArg] {
        
        return [
            
            LPActionArg(named: "Background Color", with: .white),
            LPActionArg(named: "Image.Background Color", with: UIColor.MaverickPrimaryColor),
            LPActionArg(named: "Title.Text Color", with: UIColor.MaverickBadgePrimaryColor),
            LPActionArg(named: "Title.Text", with: "TITLE HERE"),
            LPActionArg(named: "Description.Text Color", with: .black),
            LPActionArg(named: "Description.Text", with: "Description Text Here"),
            LPActionArg(named: "Primary Button.Action", withAction:nil),
            LPActionArg(named: "Primary Button.Text", with: "Yes"),
            LPActionArg(named: "Primary Button.Text Color", with: UIColor.MaverickBadgePrimaryColor),
            LPActionArg(named: "Secondary Button.Text", with: "No thanks"),
            LPActionArg(named: "Secondary Button.Text Color", with: UIColor.lightGray),
            LPActionArg(named: "Secondary Button.Action", with: "none"),
            LPActionArg(named: "Image.Image", withFile: "none"),
            LPActionArg(named: "Image.Crop", with: true),
            LPActionArg(named: "Image.Ratio", with: 0.5)
            
        ]
        
    }
    
    static func instatiateViewController(context: LPActionContext) -> FullScreenInAppMessageViewController? {
        
        return FullScreenInAppMessageViewController.instatiateViewController(
            
            backgroundColor: context.colorNamed("Background Color"),
            backgroundImage: UIImage(named: context.fileNamed("Image.Image") ?? ""),
            imageBackgroundColor : context.colorNamed("Image.Background Color"),
            cropImage : context.boolNamed("Image.Crop"),
            imageRatio : context.numberNamed("Image.Ratio") as? CGFloat,
            titleText: context.stringNamed("Title.Text"),
            titleColor: context.colorNamed("Title.Text Color"),
            descriptionText: context.stringNamed("Description.Text"),
            descriptionColor: context.colorNamed("Description.Text Color"),
            primaryButtonText: context.stringNamed("Primary Button.Text"),
            primaryButtonTextColor: context.colorNamed("Primary Button.Text Color"),
            secondaryButtonText: context.stringNamed("Secondary Button.Text"),
            secondaryButtonTextColor: context.colorNamed("Secondary Button.Text Color"),
            secondaryButtonAction: context.stringNamed("Secondary Button.Action"),
            lpActionContext: context
            
        )
        
    }
    
    static func instatiateViewController(backgroundColor : UIColor,
                                         backgroundImage : UIImage?,
                                         imageBackgroundColor : UIColor,
                                         cropImage : Bool,
                                         imageRatio : CGFloat?,
                                         titleText : String,
                                         titleColor : UIColor,
                                         descriptionText : String,
                                         descriptionColor : UIColor,
                                         primaryButtonText : String,
                                         primaryButtonTextColor : UIColor,
                                         secondaryButtonText : String?,
                                         secondaryButtonTextColor : UIColor?,
                                         secondaryButtonAction : String?,
                                         lpActionContext: LPActionContext
        
        )  -> FullScreenInAppMessageViewController? {
        
        
        if let vc = R.storyboard.main.fullScreenInAppMessageViewControllerId() {
            
            vc.backgroundColor = backgroundColor
            vc.backgroundImage = backgroundImage
            vc.cropImage = cropImage
            vc.imageRatio = imageRatio ?? 0.5
            vc.titleText = titleText
            vc.titleColor = titleColor
            vc.descriptionText = descriptionText
            vc.descriptionColor = descriptionColor
            vc.primaryButtonText = primaryButtonText
            vc.primaryButtonTextColor = primaryButtonTextColor
            vc.secondaryButtonText = secondaryButtonText
            vc.secondaryButtonTextColor = secondaryButtonTextColor
            vc.secondaryButtonAction = secondaryButtonAction
            vc.imageBackgroundColor = imageBackgroundColor
            vc.context = lpActionContext
            
            return vc
            
        }
        
        return nil
        
    }
    
    
}
