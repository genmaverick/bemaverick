//
//  ProgressionViewController.swift
//  Maverick
//
//  Created by Garrett Fritz on 9/13/18.
//  Copyright © 2018 BeMaverick. All rights reserved.
//

import Foundation


class ProgressionViewController : ViewController {
    
    @IBOutlet weak var segmentControl: MaverickSegmentedControl!
    @IBOutlet weak var topViewConstraint: NSLayoutConstraint!
    @IBOutlet weak var segmentScrollView: UIScrollView!
    @IBOutlet weak var containerView: UIView!
    
    @IBAction func segmentTapped(_ sender: Any) {
        
        if previousIndex == segmentControl.selectedSegmentIndex {
            
            progressionPagerViewController?.scrollToTop()
            
        }
        
        previousIndex = segmentControl.selectedSegmentIndex
        
    }
    
    @IBAction func segmentChanged(_ sender: Any) {
        
        progressionPagerViewController?.changePage(segmentControl.selectedSegmentIndex)
        previousIndex = segmentControl.selectedSegmentIndex
        
    }
    
    private var previousIndex = 0
    weak var progressionPagerViewController : ProgressionPagerViewController?
    var services : GlobalServicesContainer!
    
    override func trackScreen() {
        
    }
    
    override func viewDidLoad() {
        
        hasNavBar = true
        super.viewDidLoad()
      
        services = (UIApplication.shared.delegate as! AppDelegate).services
        configureView()
        
    }
    
    private func configureView() {
        
        if #available(iOS 11.0, *) {
            let topPadding = UIApplication.shared.keyWindow?.safeAreaInsets.top ?? 0.0
            topViewConstraint.constant = topPadding / 2 + topViewConstraint.constant
        }
        navigationController?.navigationBar.layer.shadowColor = UIColor.clear.cgColor
        definesPresentationContext = true
        setTabs()
        progressionPagerViewController?.configure( delegate: self, services : services)
        
        
    }
    
    func scrollToTop() {
        
        progressionPagerViewController?.scrollToTop()
        
    }
    
    private func setTabs() {
        
        segmentControl.removeAllSegments()
        segmentControl.insertSegment(withTitle: R.string.maverickStrings.progressionTabTitleMyProgress(), at: segmentControl.numberOfSegments, animated: false)
        segmentControl.insertSegment(withTitle: R.string.maverickStrings.progressionTabTitleLeaderboard(), at: segmentControl.numberOfSegments, animated: false)
        segmentControl.selectedSegmentIndex = 0
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let vc = R.segue.progressionViewController.pageSegue(segue: segue)?.destination {
            
            progressionPagerViewController = vc
            progressionPagerViewController?.pageDelegate = self
            
        }
        
    }
}



extension ProgressionViewController : PagerViewControllerDelegate {
    
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
