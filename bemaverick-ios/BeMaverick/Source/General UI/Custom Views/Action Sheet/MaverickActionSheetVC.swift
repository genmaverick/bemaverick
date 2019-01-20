//
//  MaverickActionSheetVC.swift
//  Maverick
//
//  Created by Chris Garvey on 4/11/18.
//  Copyright © 2018 BeMaverick. All rights reserved.
//

import UIKit

class MaverickActionSheetVC: ViewController, UIViewControllerTransitioningDelegate {

    // MARK: - IBOutlet
    
    /// The label for the title bar that appears at the top of the view controller.
    @IBOutlet private weak var titleLabel: UILabel!
    

    // MARK: - IBAction
    
    /// Dismisses the view controller when pressed.
    @IBAction func didPressCloseButton(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    
    // MARK: - Private Properties
    
    /// The title to use for the title bar.
    private var titleBarTitle: String?
    
    /// The view model containing the logic for the view controller
    private var viewModel: MaverickActionSheetViewModel!
    
    
    // MARK: - Life Cycle
    
    /// Custom init that requires a view model.
    init(viewModel: MaverickActionSheetViewModel) {
        super.init(nibName: "MaverickActionSheetVC", bundle: nil)
        
        self.modalPresentationStyle = .custom
        self.viewModel = viewModel

    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureView()
        
    }
    
    deinit {
        log.verbose("💥")
    }
    
    
    // MARK: - Public Functions
    
    /**
     Returns the height of the visible content within the view controller. Used to determine how high the view controller should be launched during its initial animation sequence.
     */
    public func visibleContentHeight() -> Double {
        
        if let customViewHeight = viewModel.customViewHeight {
            return customViewHeight
        }
        
        return Double(view.subviews.map { $0.bounds.size.height }.reduce(0.0, +))
        
    }
    
    
    /**
     Replaces the current content in the view controller with new content.
     - parameter newContent: The new content to replace the current content.
    */
    public func replaceContent(withNewContent newContent: CustomMaverickActionSheetItem) {
        
        adjustHeight(toNewHeight: newContent.myHeight())
        
        let currentView = view.subviews[1]
        
        let newViewModel = MaverickActionSheetViewModel(title: "", maverickActionSheetItems: [newContent], alignment: .leading)
        
        let newContentToAdd = newViewModel.contentToAdd()!
        
        currentView.removeFromSuperview()
        
        view.addSubview(newContentToAdd)
        
        let leadingConstraint = NSLayoutConstraint(item: newContentToAdd, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1, constant: 16)
        let topConstraint = NSLayoutConstraint(item: newContentToAdd, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1, constant: 58)
        let trailingConstraint = NSLayoutConstraint(item: newContentToAdd, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1, constant: -16)
        
        NSLayoutConstraint.activate([leadingConstraint, topConstraint, trailingConstraint])
    
    }
    
    /**
     Handles the tap event and determines whether the tap occured outside the frame of the view controller. If so, the view controller is dismissed.
     - parameter sender: The tap event that has occurred.
     */
    @objc func dismissFromOutsideTouch(_ sender: UITapGestureRecognizer) {
        
        let tappedView = sender.view!
        let location = sender.location(in: tappedView)
        
        if location.y < view.frame.minY {
            dismiss(animated: true, completion: nil)
        }
        
    }
    

    // MARK: - Private Functions
    
    /**
     Configures the view for the MaverickActionSheetViewController.
     */
    private func configureView() {
        
        titleLabel.text = viewModel.titleForTitleBar()
        
        if let contentToAdd = viewModel.contentToAdd() {
            
            view.addSubview(contentToAdd)
            
            let leadingConstraint = NSLayoutConstraint(item: contentToAdd, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1, constant: 16)
            let topConstraint = NSLayoutConstraint(item: contentToAdd, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1, constant: 58)
            let trailingConstraint = NSLayoutConstraint(item: contentToAdd, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1, constant: -16)
            
            NSLayoutConstraint.activate([leadingConstraint, topConstraint, trailingConstraint])
            
            view.layoutIfNeeded()
            
        }
        
    }
    
    /**
     Adjust the height of the view controller to make room for new content.
     - parameter newHeight: The height of the new content to display within the current view controller.
     */
    private func adjustHeight(toNewHeight newHeight: Double) {
        
        UIView.animate(withDuration: 1.0, delay: 0.0, usingSpringWithDamping: 0.3, initialSpringVelocity: 0.6, options: [.curveEaseOut], animations: {
            self.view.center.y -= CGFloat(newHeight) / 2
        }, completion: nil)
        
    }
    
}

