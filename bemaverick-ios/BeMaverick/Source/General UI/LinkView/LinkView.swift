//
//  LinkView.swift
//  Maverick
//
//  Created by Garrett Fritz on 9/11/18.
//  Copyright © 2018 BeMaverick. All rights reserved.
//

import Foundation


protocol LinkViewDelegate : class {
    
    func linkUpdated(url : URL?, bottomExpanded : Bool)
    func commitToLink()
    
}

class LinkView : UIView {
    /// Parent view
    @IBOutlet weak var view: UIView!
    @IBOutlet weak var imageHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var linkPreviewImage: UIImageView!
    
    @IBOutlet weak var linkTitleLabel: UILabel!
    @IBOutlet weak var linkDescriptionLabel: UILabel!
    
    @IBOutlet weak var linkEntryField: UITextField!
    @IBOutlet weak var bottomContainer: UIView!
    
    @IBOutlet  var labelToImageConstraint: NSLayoutConstraint!
    @IBOutlet  var labelToWallConstraint: NSLayoutConstraint!
    
    @IBOutlet  var activityIndicator: UIActivityIndicatorView!
    @IBOutlet  var clearButton: UIButton!
    
    private var task: DispatchWorkItem? = nil
    var selectedLink : URL? = nil
    private var failedURL : URL? = nil
    weak var delegate : LinkViewDelegate?
    /**
     Dismiss view on empty space tap
     */
    @IBAction func clearTapped(_ sender: Any) {
        
        delegate?.linkUpdated(url: nil, bottomExpanded: false)
        linkEntryField.text = nil
        clearLink()
        
    }
    
    @IBAction func textFieldEditingDidChange(_ sender: Any) {
        
        if linkEntryField.text == nil || linkEntryField.text == "" {
            clearLink()
            return
        }
        self.linkEntryField.textColor = UIColor.black
        
        lookUpLink()
        
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
        linkEntryField.delegate = self
        linkEntryField.tintColor = UIColor.MaverickPrimaryColor
        
        linkEntryField.addTarget(self, action: #selector(LinkView.textFieldEditingDidChange(_:)), for: UIControlEvents.editingChanged)
        clearLink()
        
    }
    
    func instanceFromNib() -> UIView {
        
        return R.nib.linkView.firstView(owner: self)!
        
    }
    
    func clearLink() {
        
        failedURL = selectedLink
        activityIndicator.stopAnimating()
        clearButton.isHidden = true
        bottomContainer.isHidden = true
        
        linkTitleLabel.text = nil
        linkDescriptionLabel.text = nil
        linkPreviewImage.image = nil
        selectedLink = nil
        linkEntryField.textColor = UIColor.black
        
        
    }
    
    func parseLinkURL(urlString string: String) {
        
        var urlString = string
        if urlString != "" && urlString.prefix(4) != "http" {
            urlString = "http://\(urlString)"
        }
        guard let url = URL(string: urlString) else {
            
            self.activityIndicator.stopAnimating()
            self.clearButton.isHidden = false
            return
            
        }
        
        guard url != selectedLink else { return }
        guard url != failedURL else { return }
        OpenGraph.fetch(url: url) { og, error in
            
            self.selectedLink = url
            DispatchQueue.main.async {
                
                guard error == nil else {
                    
                    VideoPlayerView.remoteFileExists(url: url, completionHandler: { found in
                        
                        DispatchQueue.main.async {
                            if found {
                                
                                self.delegate?.linkUpdated(url: self.selectedLink, bottomExpanded: !self.bottomContainer.isHidden)
                                self.linkEntryField.textColor = UIColor.MaverickPrimaryColor
                                
                            } else {
                                
                                self.delegate?.linkUpdated(url: self.selectedLink, bottomExpanded: !self.bottomContainer.isHidden)
                                
                                self.clearLink()
                                
                            }
                            self.activityIndicator.stopAnimating()
                            self.clearButton.isHidden = false
                        }
                        
                    })
                    
                    
                    return
                    
                }
                self.failedURL = nil
                
                self.linkEntryField.textColor = UIColor.MaverickPrimaryColor
                
                self.activityIndicator.stopAnimating()
                self.clearButton.isHidden = false
                if let description = og?[.description] {
                    
                    self.linkTitleLabel.text = og?[.title]
                    self.linkDescriptionLabel.text = description
                    
                } else if let siteName = og?[.siteName]  {
                    
                    self.linkTitleLabel.text = siteName
                    self.linkDescriptionLabel.text = og?[.title]
                    
                } else {
                    
                    self.linkTitleLabel.text = nil
                    self.linkDescriptionLabel.text = nil
                    
                }
                if let height = og?[.imageHeight], let width = og?[.imageWidth] {
                    
                    if let fwidth = Float(width), let fheight = Float(height) {
                        let newHeight = fheight / fwidth * (Float(self.linkPreviewImage.frame.width) )
                        
                        self.imageHeightConstraint.constant = CGFloat(max(newHeight, 50.0))
                    }
                    
                    
                }
                if let path = og?[.image], let imageUrl = URL(string: path) {
                    
                    self.labelToWallConstraint.isActive = false
                    self.labelToImageConstraint.isActive = true
                    
                    self.linkPreviewImage.kf.setImage(with: imageUrl)
                    
                    self.linkPreviewImage.kf.setImage(with: imageUrl, placeholder: nil, options: nil, progressBlock: nil, completionHandler: { (image, error, cache, url) in
                        
                        if let fwidth = image?.size.width, let fheight = image?.size.height {
                            let newHeight = fheight / fwidth * self.linkPreviewImage.frame.width
                            self.imageHeightConstraint.constant = max(newHeight, 50.0)
                            
                        }
                        DispatchQueue.main.async {
                            
                            self.setNeedsLayout()
                            self.layoutIfNeeded()
                            
                        }
                        
                    })
                    
                } else {
                    
                    self.labelToWallConstraint.isActive = true
                    self.labelToImageConstraint.isActive = false
                    self.linkPreviewImage.image = nil
                    
                }
                
                if self.linkPreviewImage.image == nil && self.linkTitleLabel.text == nil && self.linkDescriptionLabel.text == nil {
                    
                    
                    self.bottomContainer.isHidden = true
                    
                    
                } else {
                    
                    self.bottomContainer.isHidden = false
                    
                }
                self.delegate?.linkUpdated(url: self.selectedLink, bottomExpanded: !self.bottomContainer.isHidden)
                self.setNeedsLayout()
                self.layoutIfNeeded()
                
            }
            
        }
        
    }
    
    
    private func lookUpLink() {
        
        task?.cancel()
        clearButton.isHidden = true
        activityIndicator.startAnimating()
        
        task = DispatchWorkItem { [weak self] in
            
            self?.parseLinkURL(urlString: self?.linkEntryField.text ?? "")
            
        }
        // execute task in 2 seconds
        if let task = task {
            
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5, execute: task)
            
        }
        
    }
    
}

extension LinkView : UITextFieldDelegate {
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        clearLink()
        return true
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        delegate?.commitToLink()
        return true
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        //        lookUpLink()
    }
}
