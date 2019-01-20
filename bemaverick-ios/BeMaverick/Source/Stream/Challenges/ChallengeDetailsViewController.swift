//
//  ChallengeDetailsViewController.swift
//  Maverick
//
//  Created by Garrett Fritz on 8/15/18.
//  Copyright © 2018 BeMaverick. All rights reserved.
//

import Foundation


class ChallengeDetailsViewController : ViewController {
    
    @IBOutlet weak var containerView: UIView?
    var services : GlobalServicesContainer!
    weak var challengeDetailsPagerViewController : ChallengeDetailsPagerViewController?
    private var challenges : [Challenge] = []
    private var startingIndex = 0
    override var prefersStatusBarHidden: Bool {
        
        return true

    }
    
    override func trackScreen() {
        AnalyticsManager.trackScreen(location: self, withProperties: ["COUNT" : challenges.count])
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        tabBarController?.setTabBarVisible(visible: false, duration: 0.0, animated: false)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        super.viewWillDisappear(animated)
        tabBarController?.setTabBarVisible(visible: true, duration: 0.0, animated: false)
    
    }
    
    override func getTransitionAlphaView() -> [UIView] {
    
        if let containerView = containerView {
        
            return [containerView]
        
        } else {
        
            return []
        
        }
    
    }
    
    override  func getTransitionFrame() -> CGRect? {
        
        
        return challengeDetailsPagerViewController?.getTransitionFrame()
        
    }
    

    func configure(with challenge : Challenge, in challenges : [Challenge] ) {
    
        if challenges.count > 0 {
            
            startingIndex = challenges.index(of: challenge) ?? 0
            self.challenges = challenges
            
        } else {
            
            self.challenges = [challenge]
            
        }
        
    }
    
    override func transitionCompleted() {
        
        super.transitionCompleted()
        challengeDetailsPagerViewController?.transitionCompleted()
        
    }
    
    override func viewDidLoad() {
        
        hasNavBar = false
        super.viewDidLoad()
        modalPresentationCapturesStatusBarAppearance = true
        challengeDetailsPagerViewController?.configure(with: challenges,startingIndex: startingIndex, services: services)
        
    }
    
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .none
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let vc = R.segue.challengeDetailsViewController.pageSegue(segue: segue)?.destination {
            
            challengeDetailsPagerViewController = vc
            challengeDetailsPagerViewController?.pageDelegate = self
            challengeDetailsPagerViewController?.contentPageDelegate = self
            
        }
        
    }
    
}

extension ChallengeDetailsViewController : PagerViewControllerDelegate {
    
    func paginatedViewController(paginatedViewController: PagerViewController, didUpdatePageCount count: Int) {
        
    }
    
    func paginatedViewController(paginatedViewController: PagerViewController, didUpdatePageIndex index: Int) {
        
    }

}


extension ChallengeDetailsViewController : ContentPageViewControllerDelegate {
    
    func transitionItemSelected(selectedImage: UIImage?, selectedFrame: CGRect?) {
        
        self.selectedImage = selectedImage
        self.selectedFrame = selectedFrame
        
    }
    
    
    func toggleSearchVisibility(isVisible : Bool, force: Bool) {
      
        
    }
    
}



