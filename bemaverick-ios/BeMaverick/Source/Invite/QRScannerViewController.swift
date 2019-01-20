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

class QRScannerViewController : ViewController {
    
    
    @IBOutlet weak var scanCodeButton: UIButton!
    @IBOutlet weak var qrViewContainer: UIView!
    
    @IBOutlet weak var overlayView: UIView!
    
    @IBOutlet weak var qrOutline: UIImageView!
    
    
    @IBAction func closeTapped(_ sender: Any) {
        
        dismiss(animated: true, completion: nil)
        
    }
    
    
    @IBAction func scanPressed(_ sender: Any) {
        
        
         AnalyticsManager.Invite.trackQRLibraryPressed(source : source)
         if let imagePicker = R.storyboard.general.maverickPickerId() {
         imagePicker.modalPresentationStyle = .overFullScreen
         
         if let maverickPicker = imagePicker.childViewControllers[0] as? MaverickPicker {
         
            maverickPicker.delegate = delegate
            maverickPicker.shouldCrop = false
            navigationController?.pushViewController(maverickPicker, animated: true)
            
         }
         
         
         }
        
    }
    
    var source = Constants.Analytics.Invite.Properties.SOURCE.profile
    weak var delegate : MaverickPickerDelegate?
    weak var scannerDelegate : AVCaptureMetadataOutputObjectsDelegate?
    private var captureSession: AVCaptureSession!
    private var previewLayer: AVCaptureVideoPreviewLayer!
    
    private func activatesScanner() {
        
        guard captureSession == nil else {
            
            if captureSession?.isRunning == false {
                
                captureSession?.startRunning()
                
            }
            return
            
        }
        
        
        
        captureSession = AVCaptureSession()
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
        let videoInput: AVCaptureDeviceInput
        
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            return
        }
        
        if (captureSession.canAddInput(videoInput)) {
            captureSession.addInput(videoInput)
        } else {
            failed()
            return
        }
        
        let metadataOutput = AVCaptureMetadataOutput()
        
        if (captureSession.canAddOutput(metadataOutput)) {
            captureSession.addOutput(metadataOutput)
            
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr]
        } else {
            failed()
            return
        }
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = qrViewContainer.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        qrViewContainer.layer.addSublayer(previewLayer)
        
        captureSession.startRunning()
        AnalyticsManager.Invite.trackQRCameraStarted(source: source)
        
        
    }
 
    private func attemptScanner() {
        
        
        //Camera
        AVCaptureDevice.requestAccess(for: AVMediaType.video) { response in
            if response {
                
                   DispatchQueue.main.async {
                
                    self.activatesScanner()
                
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if ( captureSession?.isRunning == false) {
            captureSession.startRunning()
        }
        
      
        
    }
    
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if (captureSession?.isRunning == true) {
            captureSession.stopRunning()
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        
        let rect = qrOutline.frame
        mask(viewToMask: overlayView, maskRect: rect, invert: true)
        
        
    }
    
    func failed() {
        
        let ac = UIAlertController(title: "Scanning not supported", message: "Your device does not support scanning a code from an item. Please use a device with a camera.", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
        captureSession = nil
    
    }
    
  
    
    
    /// The `GlobalServicesContainer` that maintains access to global services
    var services: GlobalServicesContainer?
  
    override func viewDidLoad() {
         hasNavBar = true
        super.viewDidLoad()
        configureView()
      
        
    }
    
    override func trackScreen() {
        
        AnalyticsManager.Invite.trackInviteScreen(viewController: self, source: source)
    
    }
    
    func mask(viewToMask: UIView, maskRect: CGRect, invert: Bool = false) {
        let maskLayer = CAShapeLayer()
        let path = CGMutablePath()
        if (invert) {
            path.addRect(viewToMask.bounds)
        }
        path.addRoundedRect(in: maskRect, cornerWidth: 16, cornerHeight: 16)
        
        maskLayer.path = path
        if (invert) {
            maskLayer.fillRule = kCAFillRuleEvenOdd
        }
        
        // Set the mask of the view.
        viewToMask.layer.mask = maskLayer;
    }
    
    
    private func configureView() {
        
        attemptScanner()
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: R.image.back_purple(),
                                                           style: .plain,
                                                           target: self,
                                                           action: #selector(closeTapped(_:)))
        navigationItem.leftBarButtonItem?.tintColor = UIColor.MaverickBadgePrimaryColor
        
        showNavBar(withTitle: "Scan a Code")
        
        navigationItem.rightBarButtonItem = nil

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
    
    
   
    
}


extension QRScannerViewController: AVCaptureMetadataOutputObjectsDelegate {
    
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        
       
        
        dismiss(animated: true) {
             self.scannerDelegate?.metadataOutput?(output, didOutput: metadataObjects, from: connection)
        }
 
    }

}


