//
//  ProjectsViewController.swift
//  Maverick
//
//  Created by Garrett Fritz on 9/17/18.
//  Copyright © 2018 BeMaverick. All rights reserved.
//

import Foundation

class ProjectsViewController : ViewController {
    
    @IBOutlet weak var segmentControl: MaverickSegmentedControl!
    @IBOutlet weak var segmentScrollView: UIScrollView!
    @IBOutlet weak var containerView: UIView!
    
    @IBAction func segmentChanged(_ sender: Any) {
       
        projectsPagerViewController?.changePage(segmentControl.selectedSegmentIndex)
        previousIndex = segmentControl.selectedSegmentIndex
        
    }
    
    private var previousIndex = 0
    weak var projectsPagerViewController : ProjectsPagerViewController?
    var services : GlobalServicesContainer!
    var user : User?
    var initialFilter : ProjectProgressTableViewCell.ProjectProgressViewFilter = .inProgress
    
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
        
            projectsPagerViewController?.configure( user: user, delegate: self, services : services, initialSection : initialFilter)
        
        }
        
        showNavBar(withTitle: "PROJECTS")
        
    }
    
    func scrollToTop() {
        
        projectsPagerViewController?.scrollToTop()
        
    }
 
    private func setTabs() {
        
        segmentControl.removeAllSegments()
        
        if user?.progression?.hasInProgress() ?? false {
            
            
            segmentControl.insertSegment(withTitle: ProjectProgressTableViewCell.ProjectProgressViewFilter.inProgress.rawValue, at: segmentControl.numberOfSegments, animated: false)
            
        }
        
        if user?.progression?.hasCompleted()  ?? false {
            
            segmentControl.insertSegment(withTitle:  ProjectProgressTableViewCell.ProjectProgressViewFilter.completed.rawValue, at: segmentControl.numberOfSegments, animated: false)
            
        }
        
        
        if initialFilter == .completed  && (user?.progression?.hasCompleted()  ?? false ) {
            
            segmentControl.selectedSegmentIndex = 1
        
        } else {
        
            segmentControl.selectedSegmentIndex = 0
        
        }
        
        
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let vc = R.segue.projectsViewController.pageSegue(segue: segue)?.destination {
            
            projectsPagerViewController = vc
            projectsPagerViewController?.pageDelegate = self
            
            
        }
        
    }
    
}



extension ProjectsViewController : PagerViewControllerDelegate {
    
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
