//
//  QRViewController.swift
//  Maverick
//
//  Created by Garrett Fritz on 5/10/18.
//  Copyright © 2018 BeMaverick. All rights reserved.
//

import Foundation
import Branch
import SwiftMessages
import Photos

class QRViewController : ViewController {
    
    @IBOutlet weak var descriptionLabel: UILabel!
    
    @IBOutlet weak var shareableView: ShareableQRView!
    @IBOutlet weak var qrImageView: UIImageView!
    
    @IBOutlet weak var qrViewContainer: UIView!
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var shareCodeButton: CTAButton!
    @IBOutlet weak var saveCodeButton: CTAButton!
    @IBOutlet weak var scanCodeButton: CTAButton!
    
    @IBAction func closeTapped(_ sender: Any) {
        
        dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func sharePressed(_ sender: Any) {
        
        AnalyticsManager.Invite.trackShareQRPressed(source : source)
        if let user = services?.globalModelsCoordinator.loggedInUser,
            let shareable = ShareHelper.shareUser(user: user), let environment = services?.globalModelsCoordinator.authorizationManager.environment.webUrlStringValue {
            
            let linkProperties: BranchLinkProperties = BranchLinkProperties()
            linkProperties.feature = "share"
            linkProperties.channel = "inapp"
            linkProperties.addControlParam("$fallback_url", withValue: R.string.maverickStrings.shareUrl(environment, "user", user.userId))
            linkProperties.addControlParam("$ios_passive_deepview", withValue: "false")
            linkProperties.addControlParam("$uri_redirect_mode", withValue: "1")
            
            
            
            linkProperties.addControlParam("$email_subject", withValue: "Come join your friend, \(user.username ?? ""), on Maverick.")
            
            shareable.showShareSheet(with: linkProperties,
                                     andShareText: R.string.maverickStrings.inviteFriendMessage(user.username ?? ""),
                                     from: self) { (activityType, completed) in
                                        if (completed) {
                                            
                                        } else {
                                            
                                        }
            }
        }
        
    }
    
    @IBAction func savePressed(_ sender: Any) {
        
        AnalyticsManager.Invite.trackSaveQRPressed(source : source)
        validateLibraryPermissionAndFetch()
        
        
    }
    
    var source = Constants.Analytics.Invite.Properties.SOURCE.profile
    private var actionSheetItem : FollowCustomActionSheetItem?
    
    
    private func saveShareableToLibrary() {
        
        let image = UIImage(view : shareableView)
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        
        
        var config = SwiftMessages.Config()
        config.presentationContext = .window(windowLevel: UIWindowLevelNormal)
        config.interactiveHide = true
        config.duration = SwiftMessages.Duration.seconds(seconds: 3.0)
        let messageView: InvitesSentMessageView = try! SwiftMessages.viewFromNib(named: "InvitesSentMessageView")
        
        messageView.configure(with: "Saved code to your camera roll 📷", avatar: nil)
        messageView.configureDropShadow()
        SwiftMessages.show(config: config,
                           view: messageView)
        
        
    }
    
    func getDocumentsDirectory() -> URL {
        
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    
    }
    
    @IBAction func scanPressed(_ sender: Any) {
        
        AnalyticsManager.Invite.trackScanQRPressed(source : source)
        attemptScanner()
        
    }
    
    private func attemptScanner() {
        
        //Camera
        AVCaptureDevice.requestAccess(for: AVMediaType.video) { response in
            if response {
                
                DispatchQueue.main.async {
                    
                    if let imagePicker = R.storyboard.inviteFriends.qrScannerViewControllerId() {
                        
                        imagePicker.modalPresentationStyle = .overFullScreen
                        
                        if let maverickPicker = imagePicker.childViewControllers[0] as? QRScannerViewController {
                            maverickPicker.scannerDelegate = self
                            maverickPicker.delegate = self
                            
                        }
                        
                        self.present(imagePicker, animated: true, completion: nil)
                        
                    }
                    
                }
                
            } else {
                
                let alert = UIAlertController(title: "Need Permission", message: "Please go to your Settings and grant permission for us to use your camera", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Go to Settings", style: .default){action in
                    guard let settingsUrl = URL(string: UIApplicationOpenSettingsURLString) else {
                        return
                    }
                    
                    if UIApplication.shared.canOpenURL(settingsUrl) {
                        UIApplication.shared.open(settingsUrl, options: [:], completionHandler: nil)
                    }
                })
                
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { result in
                    
                    
                })
                
                self.present(alert, animated: true, completion: nil)
                
            }
            
        }
        
    }
    
    
    /// The `GlobalServicesContainer` that maintains access to global services
    var services: GlobalServicesContainer?
    
    deinit {
   
        DeepLinkHelper.overrideListenerEnabled = false
        
    }
    override var prefersStatusBarHidden: Bool {
        get {
            return true
        }
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        DeepLinkHelper.overrideListenerEnabled = true
        configureView()
        configureSignals()
        
        
    }
    
    override func trackScreen() {
        
        AnalyticsManager.Invite.trackInviteScreen(viewController: self, source: source)
        
    }
    
    private func configureSignals() {
        
        services?.globalModelsCoordinator.onOverridenDeepLinkSignal.subscribe(with: self) { [weak self] deepLink in
            
            guard let strongSelf = self, let services = strongSelf.services, let deepLink = deepLink else {
                
                self?.actionSheetItem?.dismissActionSheet()
                AnalyticsManager.Invite.trackQRImageScannedFail(reason: .notUser)
                self?.view.makeToast("Sorry we don't recognize this code")
                
                return
                
            }
            
            if deepLink.deepLink == .user {
                
                AnalyticsManager.Invite.trackQRImageScannedSuccess(userId : deepLink.id, source : self?.source ?? .profile)
                services.globalModelsCoordinator.getUserDetails(forUserId: deepLink.id, completionHandler: {
                    
                    let user = services.globalModelsCoordinator.getUser(withId: deepLink.id)
                    
                    strongSelf.actionSheetItem?.configure(withUser: user)
                    
                })
                
            } else {
                
                strongSelf.actionSheetItem?.dismissActionSheet()
                AnalyticsManager.Invite.trackQRImageScannedFail(reason: .notUser)
                
            }
            
        }
        
    }
    
    private func launchActionSheet() {
        
        
        
        guard let services = services else { return }
        actionSheetItem = FollowCustomActionSheetItem(services: services, user: nil, width: view.frame.size.width)
        if let item = actionSheetItem {
            
            let maverickActionSheetViewModel = MaverickActionSheetViewModel(title: R.string.maverickStrings.followCustomActionSheetTitle(), maverickActionSheetItems: [item], alignment: .leading)
            let maverickActionSheetViewController = MaverickActionSheetVC(viewModel: maverickActionSheetViewModel)
            
            let maverickActionSheetTransitioningDelegate = MaverickActionSheetTransitioningDelegate()
            maverickActionSheetViewController.transitioningDelegate = maverickActionSheetTransitioningDelegate
            transitioningDelegate = maverickActionSheetTransitioningDelegate
            
            present(maverickActionSheetViewController, animated: true, completion: nil)
            
        }
        
    }
    
    private func configureView() {
        
        modalPresentationCapturesStatusBarAppearance = true
        
        qrViewContainer.isHidden = true
        view.backgroundColor = .white
        backgroundView.backgroundColor =  UIColor.MaverickBadgePrimaryColor
        descriptionLabel.textColor = .white
        descriptionLabel.text = "Your friends can scan this code to add you as a follower!"
        
        shareCodeButton.setTitle("SHARE YOUR CODE", for: .normal)
        shareCodeButton.backgroundColor = UIColor.MaverickPrimaryColor
        shareCodeButton.setTitleColor(.white, for: .normal)
        
        saveCodeButton.setTitle("SAVE TO CAMERA ROLL", for: .normal)
        saveCodeButton.backgroundColor = UIColor.MaverickPrimaryColor
        saveCodeButton.setTitleColor(.white, for: .normal)
        
        scanCodeButton.setTitle("SCAN A CODE", for: .normal)
        scanCodeButton.backgroundColor = .white
        scanCodeButton.setTitleColor(UIColor.MaverickPrimaryColor, for: .normal)
        if let loggedInUser = services?.globalModelsCoordinator.loggedInUser, let link = services?.shareService.generateShareLink(forUser: loggedInUser)?.path, let image = generateQRCode(from: link, desiredSize: qrImageView.frame) {
            
            qrImageView.image = image
            
        }
        
        createShareable()
    }
    
    private func createShareable() {
        
        
        if let loggedInUser = services?.globalModelsCoordinator.loggedInUser {
            shareableView.configure(withQRImage: qrImageView.image!, username: loggedInUser.username ?? "", avatarImage: loggedInUser.profileImage)
            
        }
        
        
        
    }
    
    private func generateQRCode(from string : String, desiredSize : CGRect) -> UIImage? {
        
        let data = string.data(using: String.Encoding.isoLatin1)
        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            
            filter.setValue(data, forKey: "inputMessage")
            guard let qrCodeImage = filter.outputImage else { return nil }
            
            let scaleX = desiredSize.size.width / qrCodeImage.extent.size.width
            let scaleY = desiredSize.size.height / qrCodeImage.extent.size.height
            let transform = CGAffineTransform(scaleX: scaleX, y: scaleY)
            
            return UIImage(ciImage: qrCodeImage.transformed(by: transform))
            
        }
        return nil
        
    }
    
    func performQRCodeDetection(image: CIImage) -> String? {
        let detector : CIDetector? = CIDetector(ofType: CIDetectorTypeQRCode, context:nil, options:[CIDetectorAccuracy: CIDetectorAccuracyHigh])
        
        
        var decode : String? = ""
        if let detector = detector {
            let features = detector.features(in: image)
            for feature in features as! [CIQRCodeFeature] {
                decode = feature.messageString
                
            }
        }
        
        return  decode
    }
    
    
    /**
     Checks system photo library permissions and fetches video assets upon
     success
     */
    fileprivate func validateLibraryPermissionAndFetch() {
        
        let status = PHPhotoLibrary.authorizationStatus()
        if status == .authorized {
            
            saveShareableToLibrary()
            
        } else if status == .denied || status == .restricted {
            
            let alert = UIAlertController(title: "Need Permission", message: "Please go to your Settings and grant permission for us save images", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Go to Settings", style: .default){action in
                guard let settingsUrl = URL(string: UIApplicationOpenSettingsURLString) else {
                    return
                }
                
                if UIApplication.shared.canOpenURL(settingsUrl) {
                    UIApplication.shared.open(settingsUrl, options: [:], completionHandler: nil)
                }
            })
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { result in
                
                
            })
            present(alert, animated: true, completion: nil)
            return
            
        } else {
            
            PHPhotoLibrary.requestAuthorization { status in
                
                DispatchQueue.main.async {
                    
                    self.validateLibraryPermissionAndFetch()
                    
                }
            }
            
        }
        
    }
    
}

extension QRViewController: MaverickPickerDelegate {
    
    func cameraModeSelected() {
        
        attemptScanner()
        
    }
    
    func imageSelected(image: UIImage) {
        
        AnalyticsManager.Invite.trackQRLibraryScanned(source: source)
        if let cgImage = image.cgImage {
            
            let ciImage = CIImage(cgImage: cgImage)
            if let value = performQRCodeDetection(image: ciImage), let url = URL(string: value) {
                
                if Branch.getInstance().handleDeepLink(url) {
                    launchActionSheet()
                } else {
                    
                    AnalyticsManager.Invite.trackQRImageScannedFail(reason: .invalidQR)
                    view.makeToast("Sorry we don't recognize this code")
                    
                }
                
            } else {
                
                AnalyticsManager.Invite.trackQRImageScannedFail(reason: .invalidQR)
                view.makeToast("Sorry we don't recognize this code")
                
            }
            
        } else {
            
            AnalyticsManager.Invite.trackQRImageScannedFail(reason: .invalidQR)
            view.makeToast("Sorry we can't scan this photo")
            
        }
        
    }
    
}

extension QRViewController: AVCaptureMetadataOutputObjectsDelegate {
    
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        
        AnalyticsManager.Invite.trackQRCameraScanned(source: source)
        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let stringValue = readableObject.stringValue else { return }
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            
            
            if let url = URL(string: stringValue) {
                
                if Branch.getInstance().handleDeepLink(url) {
                    launchActionSheet()
                } else {
                    
                    AnalyticsManager.Invite.trackQRImageScannedFail(reason: .invalidQR)
                    view.makeToast("Sorry we don't recognize this code")
                    
                }
                
            } else {
                
                AnalyticsManager.Invite.trackQRImageScannedFail(reason: .invalidQR)
                view.makeToast("Sorry we don't recognize this code")
                
            }
            
        }
        
    }
}

