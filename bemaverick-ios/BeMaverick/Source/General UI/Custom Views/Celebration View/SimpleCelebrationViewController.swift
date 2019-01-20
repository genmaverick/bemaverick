//
//  SimpleCelebrationViewController.swift
//  Maverick
//
//  Created by Garrett Fritz on 4/9/18.
//  Copyright © 2018 BeMaverick. All rights reserved.
//

import Foundation
import AudioToolbox


class SimpleCelebrationViewController : UIViewController {
    
    /// Full screen background image
    @IBOutlet weak var backgroundImage: UIImageView!
    
    /// Top third of the screen, only contains foreground image
    @IBOutlet weak var topContainer: UIView!
    /// main image shown in top container
    @IBOutlet weak var mainImageView: UIImageView!
    /// bottom two thirds of the screen
    @IBOutlet weak var bottomContainer: UIView!
    /// the bacground color for the title label
    @IBOutlet weak var titleContainer: UIView!
    /// title label
    @IBOutlet weak var titleLabel: UILabel!
    /// background color for the description label
    @IBOutlet weak var descriptionContainer: UIView!
    /// description label
    @IBOutlet weak var descriptionLabel: UILabel!
    /// dismiss VC
    @IBOutlet weak var closeButton: UIButton!
    
    @IBOutlet weak var ctaButton: UIButton!
    
    
    override var prefersStatusBarHidden: Bool {
        get {
            return true
        }
    }
    @IBOutlet weak var titleLabelTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var descriptionContainerLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var descriptionContainerTopCosntraint: NSLayoutConstraint!
    @IBOutlet weak var titleContainerWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var descriptionContainerWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var titleContainerTrailingConstraint: NSLayoutConstraint!
    
    var services : GlobalServicesContainer? = nil
    private var titleLabelTrailingConstraint_initial : CGFloat = 0.0
    private var descriptionContainerLeadingConstraint_initial : CGFloat = 0.0
    private var descriptionContainerTopCosntraint_initial : CGFloat = 0.0
    private var titleContainerWidthConstraint_initial : CGFloat = 0.0
    private var descriptionContainerWidthConstraint_initial : CGFloat = 0.0
    private var titleContainerTrailingConstraint_initial : CGFloat = 0.0
    private var descriptionAngle : Float = -3.0
    
    private var ctaText : String? = nil
    private var copy1 : String? = nil
    private var copy1_color : UIColor? = nil
    private var copy1_background_color : UIColor? = nil
    private var copy2 : String? = nil
    private var copy2_color : UIColor? = nil
    private var copy2_background_color : UIColor? = nil
    private var imageUrl : String? = nil
    private var imageFile : UIImage? = nil
    private var backgroundColor : UIColor? = nil
    private var backgroundImage_file : UIImage? = nil
    private var closeButtonCopy : String? = nil
    private var closeButton_color : UIColor? = nil
    private var shouldVibrate = true
    private var deepLinkString : String? = nil
    /// The context passed in from Leanplum that contains customized values.
    @objc var context: LPActionContext!
    
    /**
     Dismiss VC
    */
    @IBAction func closeTapped(_ sender: Any) {
        
        dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func ctaPressed(_ sender: Any) {
        
        if let services = services, let deepLinkUrl = deepLinkString, let url = URL(string: deepLinkUrl)  {
            
            DeepLinkHelper.parseURIScheme(url: url, services: services.globalModelsCoordinator)
            dismiss(animated: false, completion: nil)
            
        }
        
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        let rotationRadian  = CGFloat(GLKMathDegreesToRadians(descriptionAngle))
        descriptionContainer.transform = CGAffineTransform(rotationAngle: rotationRadian)
        
        titleLabelTrailingConstraint_initial = titleLabelTrailingConstraint.constant
        descriptionContainerLeadingConstraint_initial = descriptionContainerLeadingConstraint.constant
        descriptionContainerTopCosntraint_initial = descriptionContainerTopCosntraint.constant
        titleContainerTrailingConstraint_initial = titleContainerTrailingConstraint.constant
        modalPresentationCapturesStatusBarAppearance = true
        
        view.backgroundColor = UIColor.MaverickPrimaryColor
        closeButton.setTitleColor(UIColor.white, for: .normal)
        descriptionContainer.backgroundColor = UIColor.black
        titleContainer.backgroundColor = UIColor.white
        titleLabel.textColor = UIColor.black
        descriptionLabel.textColor = UIColor.white
        
        titleContainerWidthConstraint_initial = titleContainerWidthConstraint.multiplier * Constants.MaxContentScreenWidth
        descriptionContainerWidthConstraint_initial = descriptionContainerWidthConstraint.multiplier * Constants.MaxContentScreenWidth
        
        titleContainerTrailingConstraint.constant = -titleContainerWidthConstraint_initial
        descriptionContainerLeadingConstraint.constant = -descriptionContainerWidthConstraint_initial * cos(rotationRadian) - 20.0
        descriptionContainerTopCosntraint.constant = -descriptionContainerWidthConstraint_initial * sin(rotationRadian)
        
        titleLabel.text = copy1
        titleLabel.textColor = copy1_color
        titleContainer.backgroundColor = copy1_background_color
        
        descriptionLabel.text = copy2
        descriptionLabel.textColor = copy2_color
        descriptionContainer.backgroundColor = copy2_background_color
        
        closeButton.setTitle(closeButtonCopy, for: .normal)
        closeButton.setTitleColor(closeButton_color, for: .normal)
        
        view.backgroundColor = backgroundColor
        
        if let file = backgroundImage_file {
        
            backgroundImage.image = file
        
        }
        
        if let path = imageUrl, let pathUrl = URL(string: path) {
            
            mainImageView.kf.setImage(with: pathUrl, placeholder: imageFile, options: [.transition(.fade(UIImage.fadeInTime))], progressBlock: nil) { (image, error, cache, url) in
                if error != nil {
                       self.mainImageView.image = self.imageFile
                }
            }
            
        } else {
      
            mainImageView.image = imageFile
        
        }
        
        ctaButton.isHidden = deepLinkString == nil
        if let ctaText = ctaText {
        
            ctaButton.setTitle(ctaText, for: .normal)
        
        }
        
        ctaButton.setTitleColor(closeButton_color, for: .normal)
    
        descriptionContainer.layer.allowsEdgeAntialiasing = true
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if shouldVibrate {
            
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
        
        }
    
    }
   
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    
        titleContainerTrailingConstraint.constant = titleContainerTrailingConstraint_initial

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {

            self.descriptionContainerTopCosntraint.constant = self.descriptionContainerTopCosntraint_initial
            self.descriptionContainerLeadingConstraint.constant = self.descriptionContainerLeadingConstraint_initial

            UIView.animate(withDuration: 0.25) {

                self.view.layoutIfNeeded()

            }

        }
        
        UIView.animate(withDuration: 0.25) {
            self.view.layoutIfNeeded()
        }
    
    }
    
    func configure(imageUrl : String?, copy1 : String?, copy2 : String?, backgroundColor : UIColor?, ctaText: String?, deepLinkString : String?, services : GlobalServicesContainer) {
        
        self.services = services
        self.deepLinkString = deepLinkString
        self.ctaText = ctaText
        self.copy1 = copy1
        copy1_color = UIColor.white
        copy1_background_color = UIColor.black
        
        self.copy2 = copy2
        copy2_color = UIColor.white
        copy2_background_color = UIColor.black
        
        closeButtonCopy = "Close"
        closeButton_color = UIColor.white
        self.backgroundColor = backgroundColor
        backgroundImage_file = nil
        imageFile = nil
        self.imageUrl = imageUrl
        
    }
    
    /**
     Retrieves the customizable values from the Leanplum context and then populates the UI elements based on those values.
     */
    @objc func configure(withContext context : LPActionContext) {
        
        self.context = context
        
        shouldVibrate = context.boolNamed(CelebrationViewDefinitions.LPMT_ARG_CELEBRATION_HAS_GOOD_VIBES)
        copy1 = context.stringNamed(SimpleCelebrationViewDefinitions.LPMT_ARG_CELEBRATION_TITLE_TEXT)
   
        copy1_color = context.colorNamed(SimpleCelebrationViewDefinitions.LPMT_ARG_CELEBRATION_TITLE_TEXT_COLOR)
        copy1_background_color = context.colorNamed(SimpleCelebrationViewDefinitions.LPMT_ARG_CELEBRATION_TITLE_BACKGROUND_COLOR)
        
        copy2 = context.stringNamed(SimpleCelebrationViewDefinitions.LPMT_ARG_CELEBRATION_DESCRIPTION_TEXT)
        copy2_color = context.colorNamed(SimpleCelebrationViewDefinitions.LPMT_ARG_CELEBRATION_DESCRIPTION_TEXT_COLOR)
        copy2_background_color = context.colorNamed(SimpleCelebrationViewDefinitions.LPMT_ARG_CELEBRATION_DESCRIPTION_BACKGROUND_COLOR)
        
        closeButtonCopy = context.stringNamed(SimpleCelebrationViewDefinitions.LPMT_ARG_CELEBRATION_BUTTON_TEXT)
        closeButton_color = context.colorNamed(SimpleCelebrationViewDefinitions.LPMT_ARG_CELEBRATION_BUTTON_TEXT_COLOR)
        backgroundColor = context.colorNamed(SimpleCelebrationViewDefinitions.LPMT_ARG_CELEBRATION_BACKGROUND_COLOR)
        
        if let hasBackgroundImage = context.fileNamed(SimpleCelebrationViewDefinitions.LPMT_ARG_CELEBRATION_BACKGROUND_IMAGE) {
            backgroundImage_file = UIImage(named: hasBackgroundImage)
        }
        
        
        if let hasKeyImageByImagePicker = context.fileNamed(SimpleCelebrationViewDefinitions.LPMT_ARG_CELEBRATION_KEY_IMAGE_BY_IMAGE_PICKER) {
            imageFile = UIImage(named: hasKeyImageByImagePicker)
        }
        
       imageUrl = context.stringNamed(SimpleCelebrationViewDefinitions.LPMT_ARG_CELEBRATION_KEY_IMAGE_BY_URL)
        
    }
    
    
}
