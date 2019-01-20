//
//  ErrorDialogViewController.swift
//  Maverick
//
//  Created by Garrett Fritz on 6/20/18.
//  Copyright © 2018 BeMaverick. All rights reserved.
//

import Foundation

protocol ErrorDialogViewControllerDelegate : class {
    
    func endDisplay()
    
}

class ErrorDialogViewController : ViewController {
    
    @IBOutlet weak var dialogView: UIView!
    @IBOutlet weak var wallTitle: UILabel!
    @IBOutlet weak var wallDescription: UILabel!
    @IBOutlet weak var closeButton: UIButton!
    @IBAction func closeTapped(_ sender: Any) {
        
        UIView.animate(withDuration: 0.25, animations: {
            
            self.view.alpha = 0
            
        }) { (result) in
            
            self.dismiss(animated: false, completion: nil)
            self.delegate?.endDisplay()
        }
        
    }
    
    var hideStatusBar = false
    weak var delegate : ErrorDialogViewControllerDelegate?
    
    private var titleString = "OOPS!"
    private var descriptionString = "Keep going to unlock this feature"
    
    override var prefersStatusBarHidden: Bool {
        
        return hideStatusBar
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIView.animate(withDuration: 0.25) {
            
            self.view.alpha = 1
            
        }
        
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        configureView()
        
    }
    
    func setValues(description: String, title : String? = nil) {
        
        descriptionString = description
        if let title = title {
            
            titleString = title
        
        }
        
    }
    
    
    private func configureView() {
        
        dialogView.layer.cornerRadius = 20
        dialogView.clipsToBounds = true
        wallTitle.text = titleString
        wallDescription.text = descriptionString
        
    }

}
