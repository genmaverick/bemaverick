//
//  CelebrationViewController.swift
//  Maverick
//
//  Created by Chris Garvey on 3/14/18.
//  Copyright © 2018 BeMaverick. All rights reserved.
//

import UIKit
import AudioToolbox


protocol CelebrationViewControllerDelegate : class {
    func celebrationDismissed()
}
@objcMembers
class CelebrationViewController: UIViewController {
    
    /**
     Struct containing all of the constants used internally within the class related to the constraints for the labels, which will be animated if enabled.
     
     If the view is within a large screen (for example, iPad), this struct contains a function that will enlarge the off-screen constraints to ensure the labels are moved out the view appropriately.
     */
    private struct Constants {
        
        static let viewForLabel1OnScreenLeadingConstraintValue: CGFloat = -16
        static let viewForLabel1OnScreenTrailingConstraintValue: CGFloat = -8
        static let viewForLabel2OnScreenLeadingConstraintValue: CGFloat = 110
        static let viewForLabel2OnScreenTrailingConstraintValue: CGFloat = -20
        static let viewForLabel3OnScreenLeadingConstraintValue: CGFloat = -32
        static let viewForLabel3OnScreenTrailingConstraintValue: CGFloat = 32
        
        static let viewForLabel1OnScreenBottomConstraintValue: CGFloat = 8
        static let viewForLabel2OnScreenTopConstraintValue: CGFloat = -12
        static let viewForLabel3OnScreenTopConstraintValue: CGFloat = 4
        
        static var viewForLabel1OffScreenBottomConstraintValue: CGFloat!
        static var viewForLabel2OffScreenTopConstraintValue: CGFloat!
        static var viewForLabel3OffScreenTopConstraintValue: CGFloat!
        
        static var viewForLabel1OffScreenLeadingConstraintValue: CGFloat = -416
        static var viewForLabel1OffScreenTrailingConstraintValue: CGFloat = -408
        static var viewForLabel2OffScreenLeadingConstraintValue: CGFloat = 510
        static var viewForLabel2OffScreenTrailingConstraintValue: CGFloat = 380
        static var viewForLabel3OffScreenLeadingConstraintValue: CGFloat = -532
        static var viewForLabel3OffScreenTrailingConstraintValue: CGFloat = -500
        
        /**
         Enlarges the off-screen constraints so that the labels are moved out of the view appropriately.
         */
        static func enlargeOffScreenConstraintsForiPad() {
            
            viewForLabel1OffScreenLeadingConstraintValue *= 2.5
            viewForLabel1OffScreenTrailingConstraintValue *= 2.5
            viewForLabel2OffScreenLeadingConstraintValue *= 2.5
            viewForLabel2OffScreenTrailingConstraintValue *= 2.5
            viewForLabel3OffScreenLeadingConstraintValue *= 2.5
            viewForLabel3OffScreenTrailingConstraintValue *= 2.5
            
        }
        
    }
    
    
    // MARK: - IBOutlets
    
    /// Top most label in set of three that contains customizable text.
    @IBOutlet weak private var label1: UILabel!
    
    /// Middle label in set of three that contains customizable text.
    @IBOutlet weak private var label2: UILabel!
    
    /// Bottom label in set of three that contains customizable text.
    @IBOutlet weak private var label3: UILabel!
    
    
    /// Customizable closing phrase that appears directly below the center labels.
    @IBOutlet weak private var closingPhrase: UILabel!
    
    /// Customizable name that appears directly below the closing phrase.
    @IBOutlet weak private var closingName: UILabel!
    
    
    /// One to three line customizable additional text that appears directly above the button at the bottom of the view.
    @IBOutlet weak private var additionalMessage: UILabel!
    
    
    /// Customizable button (both title and action) that appears at the bottom of the view.
    @IBOutlet weak private var button: UIButton!
    
    
    /// Customizable image that appears at the top of view in a circle format.
    @IBOutlet weak private var keyImageView: RoundedImageView!
    
    
    /// Customizable background image that fills the entire view. If set, the background image will override any custom background color set in Leanplum.
    @IBOutlet weak private var backgroundImageView: UIImageView!
    
    
    /// View that embeds Label 1
    @IBOutlet weak private var viewForLabel1: UIView!
    
    /// View that embeds Label 2
    @IBOutlet weak private var viewForLabel2: UIView!
    
    /// View that embeds Label 3
    @IBOutlet weak private var viewForLabel3: UIView!
    
    // MARK: - IBActions
    
    /**
     Action that will first attempt to execute a custom value from the context if such value exists. Otherwise, the action will dismiss the view controller.
     - parameters:
     - sender: The button that is pressed.
     */
    @IBAction func closeButtonPressed(_ sender: UIButton) {
        
        if animationsEnabled {
           
            reverseAnimations {
                
                self.context?.runTrackedActionNamed(CelebrationViewDefinitions.LPMT_ARG_CELEBRATION_BUTTON_ACTION)
                self.dismiss(animated: true, completion: nil)
                self.delegate?.celebrationDismissed()
            }
            
        } else {
            
            context?.runTrackedActionNamed(CelebrationViewDefinitions.LPMT_ARG_CELEBRATION_BUTTON_ACTION)
            dismiss(animated: true, completion: nil)
            self.delegate?.celebrationDismissed()
        }
    }
    
    
    // MARK: - Public Properties
    
    /// The context passed in from Leanplum that contains customized values.
    var context: LPActionContext?
    
    /// Flag that determines whether animations should be run or not.
    var animationsEnabled: Bool = true
    
    
    // MARK: - Private Properties
    
    /// The leading constraint for Label 1 that will be set depending on whether animations are enabled or not. Tied to superview.
    private var viewForLabel1LeadingConstraint: NSLayoutConstraint!
    
    /// The trailing constraint for Label 1 that will be set depending on whether animations are enabled or not. Tied to superview.
    private var viewForLabel1TrailingConstraint: NSLayoutConstraint!
    
    /// The bottom constraint for Label 1 that will be set depending on whether animations are enabled or not. Tied to keyImageView.bottom.
    private var viewForLabel1BottomConstraint: NSLayoutConstraint!
    
    /// The leading constraint for Label 2 that will be set depending on whether animations are enabled or not. Tied to superview.
    private var viewForLabel2LeadingConstraint: NSLayoutConstraint!
    
    /// The trailing constraint for Label 2 that will be set depending on whether animations are enabled or not. Tied to superview.
    private var viewForLabel2TrailingConstraint: NSLayoutConstraint!
    
    /// The top constraint for Label 2 that will be set depending on whether animations are enabled or not. Tied to Label 1.Bottom.
    private var viewForLabel2TopConstraint: NSLayoutConstraint!
    
    /// The leading constraint for Label 3 that will be set depending on whether animations are enabled or not. Tied to superview.
    private var viewForLabel3LeadingConstraint: NSLayoutConstraint!
    
    /// The trailing constraint for Label 3 that will be set depending on whether animations are enabled or not. Tied to superview.
    private var viewForLabel3TrailingConstraint: NSLayoutConstraint!
    
    /// The top constraint for Label 3 that will be set depending on whether animations are enabled or not. Tied to Label 2.Bottom.
    private var viewForLabel3TopConstraint: NSLayoutConstraint!
    
    
    
    private var  label1_text : String?
    private var  label1_textColor : UIColor?
    private var viewForLabel1_backgroundColor : UIColor?
    
    private var label2_text : String?
    private var label2_textColor : UIColor?
    private var viewForLabel2_backgroundColor : UIColor?
    
    private var label3_text : String?
    private var label3_textColor : UIColor?
    private var viewForLabel3_backgroundColor : UIColor?
    
    private var closingPhrase_text : String?
    private var closingPhrase_textColor : UIColor?
    
    private var closingName_text : String?
    private var closingName_textColor : UIColor?
    
    private var additionalMessage_text : String?
    private var additionalMessage_textColor : UIColor?
    
    private var button_title : String?
    private var button_titleColor : UIColor?
    
    private var view_backgroundColor : UIColor?
    private var backgroundImageView_image : UIImage?
    private var keyImageView_image : UIImage?
    private var keyImageView_image_url : String?
    
    private var shouldVibrate = true
    weak var delegate : CelebrationViewControllerDelegate?
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        populateValues()
        setupView()
        setupHorizontalConstraints()
        setupVerticalConstraints()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        if animationsEnabled {
            
            keyImageView.alpha = 0
            keyImageView.transform = CGAffineTransform(scaleX: 0, y: 0)
            
            closingPhrase.alpha = 0
            closingPhrase.transform = CGAffineTransform(scaleX: 0, y: 0)
            
            closingName.alpha = 0
            closingName.transform = CGAffineTransform(scaleX: 0, y: 0)
            
            additionalMessage.alpha = 0
            button.alpha = 0
            
        }
        
        if shouldVibrate {
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        
        if animationsEnabled {
            forwardAnimations()
        }
        
    }
    
    deinit {
        log.verbose("💥")
    }
    
    private func populateValues() {
        
        label1.text = label1_text
        label1.textColor = label1_textColor ?? .black
        viewForLabel1.backgroundColor = viewForLabel1_backgroundColor ?? .white
        
        label2.text = label2_text
        label2.textColor = label2_textColor  ?? .white
        viewForLabel2.backgroundColor = viewForLabel2_backgroundColor ?? .black
        
        label3.text = label3_text
        label3.textColor = label3_textColor ?? .white
        viewForLabel3.backgroundColor = viewForLabel3_backgroundColor ?? .black
        
        closingPhrase.text = closingPhrase_text
        closingPhrase.textColor = closingName_textColor ?? .white
        
        closingName.text = closingName_text
        closingName.textColor = closingName_textColor ?? .white
        
        additionalMessage.text = additionalMessage_text
        additionalMessage.textColor = additionalMessage_textColor ?? .white
        
        button.setTitle(button_title, for: .normal)
        button.setTitleColor(button_titleColor ?? .white, for: .normal)
        
        view.backgroundColor = view_backgroundColor
        
        if let hasBackgroundImage = backgroundImageView_image {
            
            backgroundImageView.image = hasBackgroundImage
            
        } else {
            
            backgroundImageView.isHidden = true
            
        }
        
        
        if let hasKeyImageByImagePicker = keyImageView_image {
            
            keyImageView.image = hasKeyImageByImagePicker
            
        }
        
        if keyImageView.image == nil {
            
            if let hasKeyImageByUrl = keyImageView_image_url {
                
                setKeyImage(withURL: hasKeyImageByUrl, forImageView: keyImageView)
                
            }
            
        }
        
        
        
    }
    
    // MARK: - Private Functions
    
    /**
     Retrieves the customizable values from the Leanplum context and then populates the UI elements based on those values.
     */
    func configure(label1 : String, label2 : String, label3 : String, closingPhrase: String, closingName: String, additionalMessage : String, buttonTitle: String, backgroundColor : UIColor, mainImage : UIImage) {
        
        label1_text = label1
        label2_text = label2
        label3_text = label3
        closingPhrase_text = closingPhrase
        closingName_text = closingName
        additionalMessage_text = additionalMessage
        button_title = buttonTitle
        view_backgroundColor = backgroundColor
        keyImageView_image = mainImage
        
    }
    /**
     Retrieves the customizable values from the Leanplum context and then populates the UI elements based on those values.
     */ 
    func configure(withContext context: LPActionContext) {
        
        self.context = context
        shouldVibrate = context.boolNamed(CelebrationViewDefinitions.LPMT_ARG_CELEBRATION_HAS_GOOD_VIBES)
        label1_text = context.stringNamed(CelebrationViewDefinitions.LPMT_ARG_CELEBRATION_LABEL1_TEXT)
        label1_textColor = context.colorNamed(CelebrationViewDefinitions.LPMT_ARG_CELEBRATION_LABEL1_TEXT_COLOR)
        viewForLabel1_backgroundColor = context.colorNamed(CelebrationViewDefinitions.LPMT_ARG_CELEBRATION_LABEL1_BACKGROUND_COLOR)
        
        label2_text = context.stringNamed(CelebrationViewDefinitions.LPMT_ARG_CELEBRATION_LABEL2_TEXT)
        label2_textColor = context.colorNamed(CelebrationViewDefinitions.LPMT_ARG_CELEBRATION_LABEL2_TEXT_COLOR)
        viewForLabel2_backgroundColor = context.colorNamed(CelebrationViewDefinitions.LPMT_ARG_CELEBRATION_LABEL2_BACKGROUND_COLOR)
        
        label3_text = context.stringNamed(CelebrationViewDefinitions.LPMT_ARG_CELEBRATION_LABEL3_TEXT)
        label3_textColor = context.colorNamed(CelebrationViewDefinitions.LPMT_ARG_CELEBRATION_LABEL3_TEXT_COLOR)
        viewForLabel3_backgroundColor = context.colorNamed(CelebrationViewDefinitions.LPMT_ARG_CELEBRATION_LABEL3_BACKGROUND_COLOR)
        
        closingPhrase_text = context.stringNamed(CelebrationViewDefinitions.LPMT_ARG_CELEBRATION_CLOSING_PHRASE_TEXT)
        closingPhrase_textColor = context.colorNamed(CelebrationViewDefinitions.LPMT_ARG_CELEBRATION_CLOSING_PHRASE_TEXT_COLOR)
        
        closingName_text = context.stringNamed(CelebrationViewDefinitions.LPMT_ARG_CELEBRATION_CLOSING_NAME_TEXT)
        closingName_textColor = context.colorNamed(CelebrationViewDefinitions.LPMT_ARG_CELEBRATION_CLOSING_NAME_TEXT_COLOR)
        
        additionalMessage_text = context.stringNamed(CelebrationViewDefinitions.LPMT_ARG_CELEBRATION_ADDITIONAL_MESSAGE_TEXT)
        additionalMessage_textColor = context.colorNamed(CelebrationViewDefinitions.LPMT_ARG_CELEBRATION_ADDITIONAL_MESSAGE_TEXT_COLOR)
        
        button_title = context.stringNamed(CelebrationViewDefinitions.LPMT_ARG_CELEBRATION_BUTTON_TEXT)
        button_titleColor = context.colorNamed(CelebrationViewDefinitions.LPMT_ARG_CELEBRATION_BUTTON_TEXT_COLOR)
        
        view_backgroundColor = context.colorNamed(CelebrationViewDefinitions.LPMT_ARG_CELEBRATION_BACKGROUND_COLOR)
        
        if let hasBackgroundImage = context.fileNamed(CelebrationViewDefinitions.LPMT_ARG_CELEBRATION_BACKGROUND_IMAGE) {
            backgroundImageView_image = UIImage(named: hasBackgroundImage)
        }
        
        if let hasKeyImageByImagePicker = context.fileNamed(CelebrationViewDefinitions.LPMT_ARG_CELEBRATION_KEY_IMAGE_BY_IMAGE_PICKER) {
            keyImageView_image = UIImage(named: hasKeyImageByImagePicker)
        }
        
        if keyImageView_image == nil {
            
            if let hasKeyImageByUrl = context.stringNamed(CelebrationViewDefinitions.LPMT_ARG_CELEBRATION_KEY_IMAGE_BY_URL){
                
                keyImageView_image_url = hasKeyImageByUrl
                
            }
            
        }
        
    }
    
    /**
     Sets the KeyImageView using a URL.
     - parameter withURL: The URL that will be used to download the image.
     - parameter forImageView: The UIImageView that will be set with an image from the URL.
     */
    private func setKeyImage(withURL urlPath: String, forImageView imageView: UIImageView) {
        
        if let url = URL(string: urlPath) {
            
            imageView.kf.indicatorType = .activity
            imageView.kf.setImage(with: url, options: [.transition(.fade(UIImage.fadeInTime))])
            
        } else {
            
            imageView.image = nil
            imageView.isHidden = true
            
        }
        
    }
    
    /**
     Sets up the basic aspects of the view, including titling the labels and setting the edge insets of the labels so that the text is correctly displayed on all different sizes of screens.
     */
    private func setupView() {
        
        tilt(viewForLabel1, degrees: -5.0)
        tilt(viewForLabel2, degrees: -3.0)
        tilt(viewForLabel3, degrees: 5.0)
        view.layoutIfNeeded()
        
    }
    
    /**
     Sets the horizontal constraints of the labels depending on whether the labels will be animated or not.
     
     If the view is being displayed on a large screen, the constraints will be enlarged to accomodate those screens.
     */
    private func setupHorizontalConstraints() {
        
        if animationsEnabled && UIScreen.main.bounds.size.width > 600 {
            Constants.enlargeOffScreenConstraintsForiPad()
        }
        
        let superView: Any! = {
            
            if #available(iOS 11.0, *) {
                return view.safeAreaLayoutGuide
            } else {
                return view
            }
            
        }()
        
        let viewForLabel1LeadingConstraintConstant: CGFloat = {
            
            if animationsEnabled {
                return Constants.viewForLabel1OffScreenLeadingConstraintValue
            } else {
                return Constants.viewForLabel1OnScreenLeadingConstraintValue
            }
            
        }()
        
        let viewForLabel1TrailingConstraintConstant: CGFloat = {
            
            if animationsEnabled {
                return Constants.viewForLabel1OffScreenTrailingConstraintValue
            } else {
                return Constants.viewForLabel1OnScreenTrailingConstraintValue
            }
            
        }()
        
        let viewForLabel2LeadingConstraintConstant: CGFloat = {
            
            if animationsEnabled {
                return Constants.viewForLabel2OffScreenLeadingConstraintValue
            } else {
                return Constants.viewForLabel2OnScreenLeadingConstraintValue
            }
            
        }()
        
        let viewForLabel2TrailingConstraintConstant: CGFloat = {
            
            if animationsEnabled {
                return Constants.viewForLabel2OffScreenTrailingConstraintValue
            } else {
                return Constants.viewForLabel2OnScreenTrailingConstraintValue
            }
            
        }()
        
        let viewForLabel3LeadingConstraintConstant: CGFloat = {
            
            if animationsEnabled {
                return Constants.viewForLabel3OffScreenLeadingConstraintValue
            } else {
                return Constants.viewForLabel3OnScreenLeadingConstraintValue
            }
            
        }()
        
        let viewForLabel3TrailingConstraintConstant: CGFloat = {
            
            if animationsEnabled {
                return Constants.viewForLabel3OffScreenTrailingConstraintValue
            } else {
                return Constants.viewForLabel3OnScreenTrailingConstraintValue
            }
            
        }()
        
        viewForLabel1LeadingConstraint = NSLayoutConstraint(item: viewForLabel1, attribute: NSLayoutAttribute.leading, relatedBy: NSLayoutRelation.equal, toItem: superView, attribute: NSLayoutAttribute.leading, multiplier: 1, constant: viewForLabel1LeadingConstraintConstant)
        viewForLabel1TrailingConstraint = NSLayoutConstraint(item: viewForLabel1, attribute: NSLayoutAttribute.trailing, relatedBy: NSLayoutRelation.equal, toItem: superView, attribute: NSLayoutAttribute.centerX, multiplier: 1, constant: viewForLabel1TrailingConstraintConstant)
        
        viewForLabel2LeadingConstraint = NSLayoutConstraint(item: viewForLabel2, attribute: NSLayoutAttribute.leading, relatedBy: NSLayoutRelation.equal, toItem: superView, attribute: NSLayoutAttribute.leading, multiplier: 1, constant: viewForLabel2LeadingConstraintConstant)
        viewForLabel2TrailingConstraint = NSLayoutConstraint(item: viewForLabel2, attribute: NSLayoutAttribute.trailing, relatedBy: NSLayoutRelation.equal, toItem: superView, attribute: NSLayoutAttribute.trailing, multiplier: 1, constant: viewForLabel2TrailingConstraintConstant)
        
        viewForLabel3LeadingConstraint = NSLayoutConstraint(item: viewForLabel3, attribute: NSLayoutAttribute.leading, relatedBy: NSLayoutRelation.equal, toItem: superView, attribute: NSLayoutAttribute.leading, multiplier: 1, constant: viewForLabel3LeadingConstraintConstant)
        viewForLabel3TrailingConstraint = NSLayoutConstraint(item: viewForLabel3, attribute: NSLayoutAttribute.trailing, relatedBy: NSLayoutRelation.equal, toItem: superView, attribute: NSLayoutAttribute.trailing, multiplier: 1, constant: viewForLabel3TrailingConstraintConstant)
        
        NSLayoutConstraint.activate([viewForLabel1LeadingConstraint, viewForLabel1TrailingConstraint, viewForLabel2LeadingConstraint, viewForLabel2TrailingConstraint, viewForLabel3LeadingConstraint, viewForLabel3TrailingConstraint])
        
        view.layoutIfNeeded()
        
    }
    
    /**
     Sets the vertical constraints of the labels depending on whether the labels will be animated or not.
     */
    private func setupVerticalConstraints() {
        
        view.layoutIfNeeded()
        
        let trailingEdgeToSuperViewForLabel1 =  Double(view.center.x + Constants.viewForLabel1OnScreenTrailingConstraintValue)
        let adjacentSideOfLabel1SuperTriangle = trailingEdgeToSuperViewForLabel1 + Double(abs(Constants.viewForLabel1OffScreenLeadingConstraintValue))
        let oppositeSideOfLabel1SuperTriangle = tangentOf(degrees: -5.0) * adjacentSideOfLabel1SuperTriangle
        Constants.viewForLabel1OffScreenBottomConstraintValue = Constants.viewForLabel1OnScreenBottomConstraintValue - CGFloat(oppositeSideOfLabel1SuperTriangle)
        
        let leadingEdgeToSuperViewTrailingForLabel2 =  Double(view.frame.size.width - Constants.viewForLabel2OnScreenLeadingConstraintValue)
        let adjacentSideOfLabel2SuperTriangle = leadingEdgeToSuperViewTrailingForLabel2 + Double(Constants.viewForLabel2OffScreenTrailingConstraintValue)
        let oppositeSideOfLabel2SuperTriangle = tangentOf(degrees: -3.0) * adjacentSideOfLabel2SuperTriangle
        Constants.viewForLabel2OffScreenTopConstraintValue = Constants.viewForLabel2OnScreenTopConstraintValue + CGFloat(oppositeSideOfLabel2SuperTriangle)
        
        let adjacentSideOfLabel3SuperTriangle = abs(Constants.viewForLabel3OffScreenLeadingConstraintValue) + view.frame.size.width + Constants.viewForLabel3OnScreenTrailingConstraintValue
        let oppositeSideOfLabel3SuperTriangle = tangentOf(degrees: 5.0) * Double(adjacentSideOfLabel3SuperTriangle)
        Constants.viewForLabel3OffScreenTopConstraintValue = Constants.viewForLabel3OnScreenTopConstraintValue - CGFloat(oppositeSideOfLabel3SuperTriangle)
        
        let viewForLabel1BottomConstraintConstant: CGFloat = {
            
            if animationsEnabled {
                return Constants.viewForLabel1OffScreenBottomConstraintValue
            } else {
                return Constants.viewForLabel1OnScreenBottomConstraintValue
            }
            
        }()
        
        let viewForLabel2TopConstraintConstant: CGFloat = {
            
            if animationsEnabled {
                return Constants.viewForLabel2OffScreenTopConstraintValue
            } else {
                return Constants.viewForLabel2OnScreenTopConstraintValue
            }
            
        }()
        
        let viewForLabel3TopConstraintConstant: CGFloat = {
            
            if animationsEnabled {
                return Constants.viewForLabel3OffScreenTopConstraintValue
            } else {
                return Constants.viewForLabel3OnScreenTopConstraintValue
            }
            
        }()
        
        viewForLabel1BottomConstraint = NSLayoutConstraint(item: viewForLabel1, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: keyImageView, attribute: NSLayoutAttribute.bottom, multiplier: 1, constant: viewForLabel1BottomConstraintConstant)
        
        viewForLabel2TopConstraint = NSLayoutConstraint(item: viewForLabel2, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: viewForLabel1, attribute: NSLayoutAttribute.bottom, multiplier: 1, constant: viewForLabel2TopConstraintConstant)
        
        viewForLabel3TopConstraint = NSLayoutConstraint(item: viewForLabel3, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: label2, attribute: NSLayoutAttribute.bottom, multiplier: 1, constant: viewForLabel3TopConstraintConstant)
        
        NSLayoutConstraint.activate([viewForLabel1BottomConstraint, viewForLabel2TopConstraint, viewForLabel3TopConstraint])
        
        view.layoutIfNeeded()
        
    }
    
    /**
     Tilts a label a desired number of degrees. Within the class, this is used to tilt the set of three labels that appear in the middle of the view.
     
     - parameters:
     - label: The UILabel that will be titled.
     - degrees: The amount to tilt.
     */
    private func tilt(_ view: UIView, degrees: Double) {
        
        view.transform = CGAffineTransform(rotationAngle: CGFloat(convertToRadiansFrom(degrees: degrees)))
        view.layer.allowsEdgeAntialiasing = true
        
    }
    
    /**
     Converts degrees to radians.
     
     - parameters:
     - degrees: The value to change to radians.
     */
    private func convertToRadiansFrom(degrees: Double) -> Double {
        return degrees * (Double.pi / 180 )
    }
    
    /**
     Calculates the tangent based upon degree.
     
     - parameters:
     - degrees: The value to be calculated.
     */
    private func tangentOf(degrees: Double) -> Double {
        return tan(convertToRadiansFrom(degrees: degrees))
    }
    
    /**
     Starts the forward animation sequence at the start of the view if animations are enabled.
     */
    private func forwardAnimations() {
        
        view.layoutIfNeeded()
        
        // animate Label 1
        viewForLabel1LeadingConstraint.constant = Constants.viewForLabel1OnScreenLeadingConstraintValue
        viewForLabel1TrailingConstraint.constant = Constants.viewForLabel1OnScreenTrailingConstraintValue
        viewForLabel1BottomConstraint.constant = Constants.viewForLabel1OnScreenBottomConstraintValue
        
        UIView.animate(withDuration: 0.2, delay: 0.0, options: [], animations: {
            self.view.layoutIfNeeded()
        }
            , completion: nil)
        
        // animate Label 2
        viewForLabel2LeadingConstraint.constant = Constants.viewForLabel2OnScreenLeadingConstraintValue
        viewForLabel2TrailingConstraint.constant = Constants.viewForLabel2OnScreenTrailingConstraintValue
        viewForLabel2TopConstraint.constant = Constants.viewForLabel2OnScreenTopConstraintValue
        
        UIView.animate(withDuration: 0.2, delay: 0.1, options: [], animations: {
            self.view.layoutIfNeeded()
        }
            , completion: nil)
        
        // animate Label 3
        viewForLabel3LeadingConstraint.constant = Constants.viewForLabel3OnScreenLeadingConstraintValue
        viewForLabel3TrailingConstraint.constant = Constants.viewForLabel3OnScreenTrailingConstraintValue
        viewForLabel3TopConstraint.constant = Constants.viewForLabel3OnScreenTopConstraintValue
        
        UIView.animate(withDuration: 0.2, delay: 0.2, options: [], animations: {
            self.view.layoutIfNeeded()
        }
            , completion: nil)
        
        // animate Key Image
        UIView.animate(withDuration: 0.8, delay: 0.3, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.6, options: [], animations: {
            
            self.keyImageView.alpha = 1
            self.keyImageView.transform = .identity
            
        }, completion: nil)
        
        // animate the Closing Phrase and Name
        UIView.animate(withDuration: 0.7, delay: 0.5, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.6, options: [], animations: {
            
            self.closingPhrase.alpha = 1
            self.closingPhrase.transform = .identity
            
            self.closingName.alpha = 1
            self.closingName.transform = .identity
            
        }, completion: nil)
        
        // animate Additional Message and Button
        UIView.animate(withDuration: 0.7, delay: 0.6, options: [], animations: {
            
            self.additionalMessage.alpha = 1
            self.button.alpha = 1
            
        }, completion: nil)
        
    }
    
    /**
     Starts the reverse animation sequence before the view is dismissed if animations are enabled.
     
     - parameters:
     - completion: This closure that is passed in will be called when the last animation in the sequence completes.
     */
    private func reverseAnimations(completion: @escaping () -> ()) {
        
        // undo Additional Message and Button animation
        UIView.animate(withDuration: 0.4, delay: 0.0, options: [], animations: {
            
            self.additionalMessage.alpha = 0
            self.button.alpha = 0
            
        }, completion: nil)
        
        // undo Closing Phrase and Name animation
        UIView.animate(withDuration: 0.5, delay: 0.2, options: [], animations: {
            
            self.closingPhrase.alpha = 0
            self.closingPhrase.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
            
            self.closingName.alpha = 0
            self.closingName.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
            
        }, completion: nil)
        
        // undo Key Image animation
        UIView.animate(withDuration: 0.5, delay: 0.3, options: [], animations: {
            
            self.keyImageView.alpha = 0
            self.keyImageView.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
            
        }, completion: nil)
        
        // undo Label 3 animation
        viewForLabel3LeadingConstraint.constant = Constants.viewForLabel3OffScreenLeadingConstraintValue
        viewForLabel3TrailingConstraint.constant = Constants.viewForLabel3OffScreenTrailingConstraintValue
        viewForLabel3TopConstraint.constant = Constants.viewForLabel3OffScreenTopConstraintValue
        
        UIView.animate(withDuration: 0.2, delay: 0.4, options: [], animations: {
            self.view.layoutIfNeeded()
        }
            , completion: nil)
        
        // undo Label 2 animation
        viewForLabel2LeadingConstraint.constant = Constants.viewForLabel2OffScreenLeadingConstraintValue
        viewForLabel2TrailingConstraint.constant = Constants.viewForLabel2OffScreenTrailingConstraintValue
        viewForLabel2TopConstraint.constant = Constants.viewForLabel2OffScreenTopConstraintValue
        
        UIView.animate(withDuration: 0.2, delay: 0.5, options: [], animations: {
            self.view.layoutIfNeeded()
        }
            , completion: nil)
        
        // undo Label 1 animation
        viewForLabel1LeadingConstraint.constant = Constants.viewForLabel1OffScreenLeadingConstraintValue
        viewForLabel1TrailingConstraint.constant = Constants.viewForLabel1OffScreenTrailingConstraintValue
        viewForLabel1BottomConstraint.constant = Constants.viewForLabel1OffScreenBottomConstraintValue
        
        UIView.animate(withDuration: 0.2, delay: 0.6, options: [], animations: {
            self.view.layoutIfNeeded()
        }
            , completion: { (value: Bool) in completion()})
        
    }
    
}
