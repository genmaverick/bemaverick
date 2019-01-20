//
//  ContentViewController.swift
//  Maverick
//
//  Created by Garrett Fritz on 5/17/18.
//  Copyright © 2018 BeMaverick. All rights reserved.
//

import Foundation


class ContentViewController : ViewController {
    
    /// API + Model services
    var services : GlobalServicesContainer!
    
    /**
     Launch a profile view controller
     */
    func showProfile(forUserId userId: String) {
        
        guard let vc = R.storyboard.profile.profileViewControllerId() else { return }
        
        vc.userId = userId
        vc.services = services
        
        navigationController?.pushViewController(vc, animated: true)
        
    }
    
    func showBadgeBag(forResponseId id : String) {
        
        guard let vc = R.storyboard.feed.badgeBagViewControllerId() else { return }
        let response = services.globalModelsCoordinator.response(forResponseId: id)
        vc.services = services
        vc.configure(withResponse: response)
        
        navigationController?.pushViewController(vc, animated: true)
        
    }
    
    /**
     Launch a Challenge details view controller
     */
    func showChallengeDetails(forChallenge challengeId: String, challenges : [Challenge] = []) {

        if challenges.count == 0 {
            
            if let vc = R.storyboard.challenges.challengeDetailsPageViewControllerId() {
                
                let challenge = services.globalModelsCoordinator.challenge(forChallengeId: challengeId)
                
                vc.configure(with: challenge, startMinimized: false)
                vc.services = services
                navigationController?.pushViewController(vc, animated: true)
                
            }
            
            
        } else if let vc = R.storyboard.challenges.challengeDetailsViewControllerId() {
            
            let challenge = services.globalModelsCoordinator.challenge(forChallengeId: challengeId)
            
            vc.configure(with: challenge, in: challenges)
            vc.services = services
            navigationController?.pushViewController(vc, animated: true)
            
        }
        
    }
    
    /**
     Launch a Challenge response stream view controller
     */
    func showChallengeResponses(forChallenge challengeId: String) {
        
        if let vc = R.storyboard.challenges.challengeDetailsPageViewControllerId() {
            
            let challenge = services.globalModelsCoordinator.challenge(forChallengeId: challengeId)
            
            vc.configure(with: challenge, startMinimized: true)
            
            vc.services = services
            navigationController?.pushViewController(vc, animated: true)
            
        }
        
    }
    
    /**
     Launch a Challenge details view controller or single item view controller for other types
     */
    func showSingleItem(forContentType contentType: Constants.ContentType, contentId: String) {
        
        if contentType == .challenge {
            
            showChallengeDetails(forChallenge: contentId)
            return
            
        }
        
        if let vc = R.storyboard.feed.singleContentItemViewControllerId() {
            vc.services = services
            vc.configure(forContentType: contentType, andId: contentId)
            navigationController?.pushViewController(vc, animated: true)
            
        }
        
    }
    
    /**
     Launch the post experience
     */
    func launchPostFlow(forChallenge challengeId: String) {
        
        if  let loggedinuser = services.globalModelsCoordinator.loggedInUser, loggedinuser.shouldShowVPC()  {
            
            if let vc = R.storyboard.general.onboardVPCNavViewControllerId() {
                
                vc.modalPresentationStyle = .overFullScreen
                present(vc, animated: true, completion: nil)
                
            }
            return
        }
        
        guard let vc = R.storyboard.post.instantiateInitialViewController(),
            let postVC = vc.viewControllers.first as? PostRecordViewController else { return }
        
        let challenge = services.globalModelsCoordinator.challenge(forChallengeId: challengeId)
        
        postVC.services = services
        postVC.challengeTitle = challenge.title ?? postVC.challengeTitle
        postVC.challengeId = challengeId
        
        navigationController?.present(vc, animated: true, completion: nil)
        
    }
    
    /**
     Share a user
     */
    func shareUser(withId id: String) {
        
        let user =  services.globalModelsCoordinator.getUser(withId: id)
     
        guard let username = user.username else { return }
        let actionSheetTitle = "Share \(username)"
        
        let actionSheetItem = ShareFunctionalityCustomActionSheetItem(user: user, services: services)
        
        let maverickActionSheetViewModel = MaverickActionSheetViewModel(title: actionSheetTitle, maverickActionSheetItems: [actionSheetItem], alignment: .leading)
        
        let maverickActionSheetViewController = MaverickActionSheetVC(viewModel: maverickActionSheetViewModel)
        
        let maverickActionSheetTransitioningDelegate = MaverickActionSheetTransitioningDelegate()
        maverickActionSheetViewController.transitioningDelegate = maverickActionSheetTransitioningDelegate
        transitioningDelegate = maverickActionSheetTransitioningDelegate
        
        present(maverickActionSheetViewController, animated: true, completion: nil)
        
    }
    
    /**
     Share a response or a challenge.
     - parameter type: The type of content shared.
     - parameter id: The id of the response or challenge shared.
     */
    func shareContent(ofType type: Constants.ContentType, andId id: String) {
        
        var actionSheetTitle: String = type == .response ? "Share Response!" : "Share Challenge!"
        
        var actionSheetItem: ShareFunctionalityCustomActionSheetItem {
            
            if type == .response {
                
                let response = services.globalModelsCoordinator.response(forResponseId: id)
                
                return ShareFunctionalityCustomActionSheetItem(response: response, services: services)
                
            } else {
                
                let challenge = services.globalModelsCoordinator.challenge(forChallengeId: id)
                
                return ShareFunctionalityCustomActionSheetItem(challenge: challenge, services: services)
                
            }
            
        }
        
        let maverickActionSheetViewModel = MaverickActionSheetViewModel(title: actionSheetTitle, maverickActionSheetItems: [actionSheetItem], alignment: .leading)
        
        let maverickActionSheetViewController = MaverickActionSheetVC(viewModel: maverickActionSheetViewModel)
        
        let maverickActionSheetTransitioningDelegate = MaverickActionSheetTransitioningDelegate()
        maverickActionSheetViewController.transitioningDelegate = maverickActionSheetTransitioningDelegate
        transitioningDelegate = maverickActionSheetTransitioningDelegate
        
        present(maverickActionSheetViewController, animated: true, completion: nil)
        
    }
    
    /**
     Launch a comments view controller
     */
    func showComments(forContentType contentType: Constants.ContentType, withId id: String, openKeyboard : Bool){
        
        guard let vc = R.storyboard.feed.commentsViewControllerId() else { return }
        
        vc.openKeyboard = openKeyboard
        vc.services = services
        switch contentType {
            
        case .response:
            
            let response = services.globalModelsCoordinator.response(forResponseId: id)
            vc.configure(withResponse: response)
            
        case .challenge:
            
            let challenge = services.globalModelsCoordinator.challenge(forChallengeId: id)
            vc.configure(withChallenge: challenge)
            
        }
        
        navigationController?.pushViewController(vc, animated: true)
        
    }
    
    
    
    /**
     Toggle save state for content item
     */
    func toggleSaveChallenge(challengeId id: String, isSaved : Bool) {
        
        services.globalModelsCoordinator.toggleSaveChallenge(withId: id, isSaved: isSaved)
        
    }
    
    func muteTapped(cell: Any?, isMuted : Bool) {
        
    }
    
    func addBadge(responseId id: String, badgeId: String, remove: Bool, cell : Any?) {
        
         if remove {
            
            services.globalModelsCoordinator.deleteBadgeFromResponse(withResponseId: id, badgeId: badgeId) { success in
                
            }
        } else {
            
            services.globalModelsCoordinator.addBadgeToResponse(withResponseId: id, badgeId: badgeId) { success in
                
            }
            
        }
        
    }
    
    func interceptItemSelected(cell : Any?) -> Bool {
        
        return false
        
    }
    
}

extension ContentViewController : BasicContentDelegate {
    
    
    func didTapMuteButton(cell : Any?,  forContentType contentType: Constants.ContentType, withId id: String, contentStyle: Constants.Analytics.Main.Properties.CONTENT_STYLE, isMuted: Bool) {
        
        muteTapped(cell: cell, isMuted: isMuted)
        AnalyticsManager.Content.trackMutePressed(contentType, contentId: id, location: self, contentStyle: contentStyle, isMuted: isMuted)
        
    }
    
    
    func didTapMainArea(cell : Any?, forContentType contentType: Constants.ContentType, withId id: String, contentStyle: Constants.Analytics.Main.Properties.CONTENT_STYLE) {
        
        AnalyticsManager.Content.trackMainPressed(contentType, contentId: id, location: self, contentStyle: contentStyle)
        
        guard !interceptItemSelected(cell : cell) else { return }
        
        if contentStyle == .large {
            
            showSingleItem(forContentType: contentType, contentId: id)
            
        }
        
    }
    
    
    func didTapChallengeTitleButton(forChallenge challengeId: String, fromContentType contentType: Constants.ContentType, withId id: String, contentStyle : Constants.Analytics.Main.Properties.CONTENT_STYLE) {
        
        AnalyticsManager.Content.trackChallengeTitlePressed(forChallenge: challengeId, contentType: contentType, contentId: id, location: self, contentStyle: contentStyle)
        
        if contentStyle == .large {
            
            showSingleItem(forContentType: .challenge, contentId: challengeId)
            
        } else {
            
            showChallengeDetails(forChallenge: challengeId)
            
        }
        
    }
    
    func didTapChallengeResponsesButton(forChallenge challengeId: String, fromContentType contentType: Constants.ContentType, withId id: String, contentStyle : Constants.Analytics.Main.Properties.CONTENT_STYLE) {
        
        AnalyticsManager.Content.trackChallengeResponsesPressed(forChallenge: challengeId, contentType: contentType, contentId: id, location: self, contentStyle: contentStyle)
        
        if contentStyle == .large {
            
            showSingleItem(forContentType: .challenge, contentId: challengeId)
            
        } else {
            
            showChallengeResponses(forChallenge: challengeId)
            
        }
        
    }
    
    func didTapChallengeTimeLeftButton(forChallenge challengeId: String, fromContentType contentType: Constants.ContentType, withId id: String, contentStyle : Constants.Analytics.Main.Properties.CONTENT_STYLE) {
        
        AnalyticsManager.Content.trackChallengeExpireTimePressed(forChallenge: challengeId, contentType: contentType, contentId: id, location: self, contentStyle: contentStyle)
        
        if contentStyle == .large {
            
            showSingleItem(forContentType: .challenge, contentId: challengeId)
            
        } else {
            
            showChallengeDetails(forChallenge: challengeId)
            
        }
        
    }
    
    func didTapShowProfileButton(forUserId userId: String, fromContentType contentType: Constants.ContentType, withId contentId: String, contentStyle : Constants.Analytics.Main.Properties.CONTENT_STYLE) {
        
        AnalyticsManager.Content.trackAuthorPressed(toAuthorId: userId, fromContentType: contentType, contentId: contentId, location: self, contentStyle: contentStyle)
        
        showProfile(forUserId: userId)
        
    }
    
    func didTapBadgeButton(cell : Any?, forContentType contentType: Constants.ContentType, withId id: String, badge: MBadge, remove: Bool, contentStyle : Constants.Analytics.Main.Properties.CONTENT_STYLE) {
        
        AnalyticsManager.Content.trackBadgeTapped(responseId: id, badge: badge, location: self, isBadged: !remove, contentStyle: contentStyle)
        addBadge(responseId: id, badgeId: badge.badgeId, remove: remove, cell : cell)
        
    }
    
    
    func didTapCTAButton(forChallenge challengeId: String, fromContentType contentType: Constants.ContentType, withId id: String, contentStyle : Constants.Analytics.Main.Properties.CONTENT_STYLE) {
        
        AnalyticsManager.Main.trackRespondToChallengePressed(challengeId: challengeId, location: self)
        launchPostFlow(forChallenge : challengeId)
        
    }
    
    func didTapShareButton(forContentType contentType: Constants.ContentType, withId id: String, contentStyle : Constants.Analytics.Main.Properties.CONTENT_STYLE) {
        
        AnalyticsManager.Content.trackSharePressed(contentType, contentId: id, location: self, contentStyle: contentStyle)
        shareContent(ofType: contentType, andId: id)
        
    }
    
    func didTapSaveButton(forContentType contentType: Constants.ContentType, withId id: String, isSaved : Bool, contentStyle : Constants.Analytics.Main.Properties.CONTENT_STYLE) {
        
        AnalyticsManager.Content.trackSavePressed(contentType, contentId: id, location: self, contentStyle: contentStyle, isSaved: isSaved)
        
        if contentType == .challenge {
        
            toggleSaveChallenge(challengeId: id, isSaved: isSaved)
        
        }
        
    }
    
    
    func launchActionSheet(contentId id : String, contentType : Constants.ContentType) {
        
        if contentType == .challenge, let loggedInUser =  services.globalModelsCoordinator.loggedInUser, let  creator = services.globalModelsCoordinator.challenge(forChallengeId: id).getCreator(){
            
            let challenge = services.globalModelsCoordinator.challenge(forChallengeId: id)
            
            let actionSheetTitle = challenge.title ?? "OPTIONS"
            
            let actionSheetItem: MaverickActionSheetItem = creator.userId == loggedInUser.userId ? ShareContentCustomActionSheetItem(forContentType: .challenge, id: id,  services: services) : ShareReportBlockUserCustomActionSheetItem(forChallengeId: id, delegate: self, services: services, user: creator)
            
            let maverickActionSheetViewModel = MaverickActionSheetViewModel(title: actionSheetTitle, maverickActionSheetItems: [actionSheetItem], alignment: .leading)
            
            let maverickActionSheetViewController = MaverickActionSheetVC(viewModel: maverickActionSheetViewModel)
            
            let maverickActionSheetTransitioningDelegate = MaverickActionSheetTransitioningDelegate()
            maverickActionSheetViewController.transitioningDelegate = maverickActionSheetTransitioningDelegate
            transitioningDelegate = maverickActionSheetTransitioningDelegate
            
            present(maverickActionSheetViewController, animated: true, completion: nil)
        }
        
        
        if contentType == .response, let user = services.globalModelsCoordinator.response(forResponseId: id).getCreator() {
            
            let actionSheetTitle = services.globalModelsCoordinator.response(forResponseId: id).challengeOwner.first?.title ?? "OPTIONS"
            
            let actionSheetItem: MaverickActionSheetItem = user.userId == services.globalModelsCoordinator.loggedInUser?.userId ? ShareContentCustomActionSheetItem(forContentType: .response, id: id, services: services) : ShareReportBlockUserCustomActionSheetItem(forResponseId: id, delegate: self, services: services, user: user)
            
            let maverickActionSheetViewModel = MaverickActionSheetViewModel(title: actionSheetTitle, maverickActionSheetItems: [actionSheetItem], alignment: .leading)
            
            let maverickActionSheetViewController = MaverickActionSheetVC(viewModel: maverickActionSheetViewModel)
            
            let maverickActionSheetTransitioningDelegate = MaverickActionSheetTransitioningDelegate()
            maverickActionSheetViewController.transitioningDelegate = maverickActionSheetTransitioningDelegate
            transitioningDelegate = maverickActionSheetTransitioningDelegate
            
            present(maverickActionSheetViewController, animated: true, completion: nil)
            
        }
        
    }
    func showEditChallenge(for challenge : Challenge) {
        
        if let vc = R.storyboard.userGeneratedChallenge.editChallengeNavControllerId() {
            
            if let editVC = vc.childViewControllers.first as? EditChallengeViewController {
                
                editVC.services = self.services
                editVC.challenge = challenge
            }
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: false, completion: nil)
            
        }
        
    }
    
    func launchActionSheetForChallenge(contentId id: String) {
        
        if let loggedInUser = services.globalModelsCoordinator.loggedInUser, let creator = services.globalModelsCoordinator.challenge(forChallengeId: id).getCreator(){
            
            let challenge = services.globalModelsCoordinator.challenge(forChallengeId: id)
            
            let actionSheetTitle: String = {
                
                if challenge.title == nil || challenge.title == "" {
                    return "CHALLENGE OPTIONS"
                } else {
                    
                    return challenge.title!.trimmingCharacters(in: .whitespacesAndNewlines) == "" ? "CHALLENGE OPTIONS" : challenge.title!
    
                }
                
            }()
            
            let editAction = {
                
                self.showEditChallenge(for: challenge)
                
                return
                
            }
            
            let actionSheetItem: MaverickActionSheetItem = creator.userId == loggedInUser.userId ? EditShareChallengeCustomActionSheetItem(challenge: challenge, services: services, editAction: editAction) : ShareReportBlockUserCustomActionSheetItem(forChallengeId: id, delegate: self, services: services, user: creator)
            
            let maverickActionSheetViewModel = MaverickActionSheetViewModel(title: actionSheetTitle, maverickActionSheetItems: [actionSheetItem], alignment: .leading)
            
            let maverickActionSheetViewController = MaverickActionSheetVC(viewModel: maverickActionSheetViewModel)
            
            let maverickActionSheetTransitioningDelegate = MaverickActionSheetTransitioningDelegate()
            maverickActionSheetViewController.transitioningDelegate = maverickActionSheetTransitioningDelegate
            transitioningDelegate = maverickActionSheetTransitioningDelegate
            
            present(maverickActionSheetViewController, animated: true, completion: nil)
            
        }
        
    }
    
}

extension ContentViewController : ErrorDialogViewControllerDelegate {
    
    func endDisplay() {
        
        backButtonTapped(self)
        
    }
    
}
