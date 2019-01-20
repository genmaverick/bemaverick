//
//  BadgesReceivedViewController.swift
//  Maverick
//
//  Created by Garrett Fritz on 9/17/18.
//  Copyright © 2018 BeMaverick. All rights reserved.
//

import Foundation

class BadgesReceivedViewController : ViewController {
    
    @IBOutlet weak var segmentControl: MaverickSegmentedControl!
    @IBOutlet weak var segmentScrollView: UIScrollView!
    @IBOutlet weak var containerView: UIView!
    
    @IBAction func segmentChanged(_ sender: Any) {
        
        badgesReceivedPagerViewController?.changePage(segmentControl.selectedSegmentIndex)
        previousIndex = segmentControl.selectedSegmentIndex
        
    }
    
    private var previousIndex = 0
    weak var badgesReceivedPagerViewController : BadgesReceivedPagerViewController?
    var services : GlobalServicesContainer!
    var initialStat : BadgeStats?
    var user : User?
    
    override func viewDidLoad() {
        
        hasNavBar = true
        super.viewDidLoad()
        services = (UIApplication.shared.delegate as! AppDelegate).services
        configureView()
        
    }
    
    private func configureView() {
        
        navigationController?.navigationBar.layer.shadowColor = UIColor.clear.cgColor
        definesPresentationContext = true
        setTabs()
        if let user = user {
            
            badgesReceivedPagerViewController?.configure( user: user, delegate: self, services : services, initialSection : segmentControl.selectedSegmentIndex)
            
        }
        
        showNavBar(withTitle: "BADGES RECEIVED")
        
    }
    
    func scrollToTop() {
        
        badgesReceivedPagerViewController?.scrollToTop()
        
    }
    
    private func setTabs() {
        
        segmentControl.removeAllSegments()
        
        guard let user = user else { return }
        
        var selectedIndex  = 0
        for badgeStat in user.badgeStats {
            
            guard badgeStat.numReceived > 0 else { continue }
            
            if let index = MBadge.getIndex(ofBadgeId:  badgeStat.badgeId), let name = MBadge.getBadge(byIndex:  index).name  {
                
                if let initialStat = initialStat {
                    if badgeStat.badgeId == initialStat.badgeId {
                        
                        selectedIndex = segmentControl.numberOfSegments
                        
                    }
                    
                }
                
                segmentControl.insertSegment(withTitle: name , at: segmentControl.numberOfSegments, animated: false)
                
            }
            
        }
        
        segmentControl.selectedSegmentIndex = selectedIndex
        
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let vc = R.segue.badgesReceivedViewController.pageSegue(segue: segue)?.destination {
            
            badgesReceivedPagerViewController = vc
            badgesReceivedPagerViewController?.pageDelegate = self
            badgesReceivedPagerViewController?.contentPageDelegate = self
            
        }
        
    }
    
}



extension BadgesReceivedViewController : PagerViewControllerDelegate {
    
    func paginatedViewController(paginatedViewController: PagerViewController, didUpdatePageCount count: Int) {
        
    }
    
    func paginatedViewController(paginatedViewController: PagerViewController, didUpdatePageIndex index: Int) {
        
        segmentControl.selectedSegmentIndex = index
        let segmentWidth = (segmentControl.getSegmentWidth())
        let minSize : CGFloat =  segmentWidth  * CGFloat(index)
        let maxSize : CGFloat = minSize + segmentWidth
        let currentXOffset = segmentScrollView.contentOffset.x
        let minBoundary = currentXOffset
        let maxBoundary = segmentScrollView.frame.width + currentXOffset
        
        if maxSize > maxBoundary {
            
            segmentScrollView.setContentOffset(CGPoint(x: currentXOffset + maxSize - maxBoundary, y: 0), animated: true)
            
        } else if minSize < minBoundary {
            
            segmentScrollView.setContentOffset(CGPoint(x: minSize , y: 0), animated: true)
            
        }
        
    }
    
}


extension BadgesReceivedViewController : ContentPageViewControllerDelegate {
    
    func transitionItemSelected(selectedImage: UIImage?, selectedFrame: CGRect?) {
        
        self.selectedImage = selectedImage
        self.selectedFrame = selectedFrame
        
    }
    
    
    func toggleSearchVisibility(isVisible : Bool, force: Bool) {
        
    }
    
}
