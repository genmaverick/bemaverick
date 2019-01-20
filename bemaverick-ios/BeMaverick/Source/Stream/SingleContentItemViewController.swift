//
//  SingleContentItemViewController.swift
//  Maverick
//
//  Created by Garrett Fritz on 3/1/18.
//  Copyright © 2018 BeMaverick. All rights reserved.
//

import Foundation
import RealmSwift

class SingleContentItemViewController : StreamTableViewController {
    
    /// Response Object
    private var response : Response?
    /// Challenge Object
    private var challenge : Challenge?
    /// Content type being displayed
    private var contentType : Constants.ContentType?
    /// Content ID displayed
    private var contentId : String?
    /// Token to notify data changed
    private var updateToken : NotificationToken?

    deinit {
        
        updateToken?.invalidate()
        
    }
    
    
    override func getTransitionFrame() -> CGRect? {
        
        let origin = view.frame.origin
        let xOrigin = UIScreen.main.bounds.width / 2 - Constants.MaxContentScreenWidth / 2
        let navBarSpacing : CGFloat = 0
        let statusHeight : CGFloat = 20.0
        let frameWidth = Constants.MaxContentScreenWidth
        let contentHeaderHeight : CGFloat = 56.0
        let frameHeight = frameWidth * 4 / 3
        
        let offset = initialOffset ?? .zero
        let newOffsetY = offset.y - (tableView?.contentOffset.y ?? 0.0)
        
        if -newOffsetY > frameHeight {
            
            return .zero
            
        }
        
        let rect = CGRect(origin: CGPoint(x: xOrigin, y: origin.y + navBarSpacing + statusHeight + contentHeaderHeight + newOffsetY), size: CGSize(width: frameWidth, height: frameHeight))
        return rect
        
    }
    
    override func viewDidLoad() {
        
        streamDelegate = self
        super.viewDidLoad()
        tableView?.clipsToBounds = true
        
    }
    
    override func configureView() {
        
        super.configureView()
        tableView?.bounces = false
        tableView?.refreshControl = nil
        tableView?.backgroundColor = .white
        
    }
    
    private func showDisplayFailure() {
        
        if let vc = R.storyboard.main.errorDialogViewControllerId() {
            
            vc.delegate = self
            vc.setValues(description : "Sorry, this content has been removed")
            vc.modalPresentationStyle = .overCurrentContext
            present(vc, animated: false, completion: nil)
            return
            
        }
        
    }
    
    /**
     Don't attempt to play videos when scrolling ends
     */
    override func scrollStopped() {
        
       
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    
        if needsReload {
            
            tableView?.reloadData()
            needsReload = false
        
        }
    
    }
    
    
    /**
     Setup view controller to display an item
     */
    func configure(forContentType contentType: Constants.ContentType, andId id : String) {
        
        self.contentType = contentType
        self.contentId = id
        
    }
    
    /**
     Autplay item right away
     */
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        super.tableView(tableView, willDisplay: cell, forRowAt: indexPath)
        if let cell = cell as? ContentTableViewCell {
            
            cell.setMuteState(muted: false)
            
        }
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.contentTableViewCellID, for: indexPath),
            let contentType = contentType else { return UITableViewCell() }
        
        cell.delegate = self
        
        switch contentType {
            
        case .challenge:
            guard let challenge = challenge else { return UITableViewCell() }
            cell.allowAutoStart(enabled: true)
            let hasResponded = services.globalModelsCoordinator.isChallengeResponded(challengeId : challenge.challengeId)
            let isSaved = services.globalModelsCoordinator.isSaved(contentType: .challenge, withId: challenge.challengeId)
            cell.configure(with: challenge, isSaved: isSaved, hasResponded: hasResponded)
            
             
        case .response:
            guard let response = response else { return UITableViewCell() }
            cell.allowAutoStart(enabled: true)
            ResponseStreamTableViewController.configure(cell: cell, withResponse: response, services : services)
            
            
        }
        
        cell.setBackButton(hidden : false)
        cell.allowAutoStart(enabled: true)
        
        return cell
        
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 1
        
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
        
    }
    
}

extension SingleContentItemViewController : StreamRefreshControllerDelegate {

    
    /**
     Function to be overriden by subclass, this should fire off the API request
     The completion block of request should call refreshCompleted()
     */
    func refreshDataRequest() {
        
    }
    
    /**
     Called on view did load, meant to be overriden to load in data and set the
     data update observer
     */
    func configureData() {
        
        guard let contentType = contentType,
            let contentId = contentId,
            let services = services else { return }
        
        switch contentType {
            
        case .challenge:
            challenge = services.globalModelsCoordinator.challenge(forChallengeId: contentId, fetchDetails: true)
            updateToken = challenge?.observe{ [weak self] changes in
                
                guard let challenge = self?.challenge, !challenge.isDeleted() else {
                    self?.showDisplayFailure()
                    return
                }
                
                let isVisible = self?.isVisible ?? false
                // only reload if viewcontroller is visisble
                if self?.viewIfLoaded?.window != nil && isVisible {
                    
                    self?.tableView?.reloadData()
                
                } else {
                    
                    self?.needsReload = true
                    
                }
                
            }
            response = nil
            
        case .response:
            response = services.globalModelsCoordinator.response(forResponseId: contentId, fetchDetails: true)
            challenge = response?.challengeOwner.first
            updateToken = response?.observe{ [weak self] changes in
              
                
                guard let response = self?.response, response.isActive() else {
                    self?.showDisplayFailure()
                    return
                }
                
                let isVisible = self?.isVisible ?? false
                // only reload if viewcontroller is visisble
                if self?.viewIfLoaded?.window != nil && isVisible {
                    
                    self?.tableView?.reloadData()
                
                } else {
                    
                    self?.needsReload = true
                
                }
                
            }
        }
        
        tableView?.reloadData()
        
    }
    
    /**
     Function to be overriden by subclass, this should fire off the API request
     The completion block of request should call nextPageLoadCompleted()
     */
    func loadNextPageRequest() {
        
    }
    
    /**
     Get item count
     */
    func getMainSectionItemCount() -> Int {
        return 1
    }
    
}

