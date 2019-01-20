//
//  HashtagGroupViewController.swift
//  Maverick
//
//  Created by Garrett Fritz on 7/26/18.
//  Copyright © 2018 BeMaverick. All rights reserved.
//

import Foundation

class HashtagGroupViewController : ViewController {
    
    @IBOutlet weak var segmentControl: MaverickSegmentedControl!
    
    
    /// API + Model services
    var services : GlobalServicesContainer!
    var tagName : String?
    var hashtagPagerViewController : HashtagPagerViewController?
    
    override func trackScreen() {
        
        AnalyticsManager.trackScreen(location: self, withProperties: ["tag" : tagName ?? ""])
        
    }
    
    @IBAction func segmentChanged(_ sender: Any) {
        
         hashtagPagerViewController?.changePage(segmentControl.selectedSegmentIndex)
        
    }
    
    override func viewDidLoad() {
    
        hasNavBar = true
        super.viewDidLoad()
        guard let tagName = tagName else {
            
            backButtonTapped(self)
            return
            
        }
        
        showNavBar(withTitle: "#\(tagName)")
        configureView()
        configureData()
        
    }
    
    private func configureView() {
        
        
    }
    
    private func configureData() {
        
        setTabs()
        hashtagPagerViewController?.configure(with: tagName ?? "", delegate: self, services: services)
        
    }
    
    private func setTabs() {
        
        segmentControl.removeAllSegments()
        
        segmentControl.insertSegment(withTitle: "Challenges", at: segmentControl.numberOfSegments, animated: false)
        segmentControl.insertSegment(withTitle: "Responses", at: segmentControl.numberOfSegments, animated: false)
            
        
        segmentControl.selectedSegmentIndex = 0
        
    }
    
    override func transitionCompleted() {
        
        super.transitionCompleted()
        hashtagPagerViewController?.transitionCompleted()
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let vc = R.segue.hashtagGroupViewController.pagerSegue(segue: segue)?.destination {
            
            hashtagPagerViewController = vc
            hashtagPagerViewController?.pageDelegate = self
            hashtagPagerViewController?.contentPageDelegate = self
            
        }
        
    }

}


extension HashtagGroupViewController : PagerViewControllerDelegate {
    
    func paginatedViewController(paginatedViewController: PagerViewController, didUpdatePageCount count: Int) {
        
    }
    
    func paginatedViewController(paginatedViewController: PagerViewController, didUpdatePageIndex index: Int) {
        
        segmentControl.selectedSegmentIndex = index
        
    }
    
}


extension HashtagGroupViewController : ContentPageViewControllerDelegate {
    
    func transitionItemSelected(selectedImage: UIImage?, selectedFrame: CGRect?) {
        
        self.selectedImage = selectedImage
        self.selectedFrame = selectedFrame
        
    }
    
    
    func toggleSearchVisibility(isVisible : Bool, force: Bool) {
        
        
        
    }
    
}







