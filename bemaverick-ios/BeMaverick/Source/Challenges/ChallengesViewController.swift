//
//  ChallengesViewController.swift
//  Maverick
//
//  Created by Garrett Fritz on 7/17/18.
//  Copyright © 2018 BeMaverick. All rights reserved.
//

import Foundation

class ChallengesViewController : ViewController {
    
    @IBOutlet weak var segmentControl: MaverickSegmentedControl!
    
    @IBOutlet weak var topViewConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var segmentScrollView: UIScrollView!
    @IBOutlet weak var containerView: UIView!
    
    @IBAction func segmentTapped(_ sender: Any) {
        
        if previousIndex == segmentControl.selectedSegmentIndex {
            
            challengesPagerViewController?.scrollToTop()
            
        }
        
        previousIndex = segmentControl.selectedSegmentIndex
        
    }
    
    
    weak var challengesPagerViewController : ChallengesPagerViewController?
    private var expanded = false
    var services : GlobalServicesContainer!
    var searchController : UISearchController?
    var titles : [String] = []
    var categoryStrings : [String] = []
    var categories : [ChallengesPageViewController.challengePageType] = []
    
    override func viewWillDisappear(_ animated: Bool) {
        
        super.viewWillDisappear(animated)
        services.globalModelsCoordinator.onFABVisibilityChanged.fire(true)
        
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        services.globalModelsCoordinator.onFABVisibilityChanged.fire(false)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
       
        navigationController?.navigationBar.layer.shadowColor = UIColor.clear.cgColor
        
        if DBManager.sharedInstance.shouldSeeTutorial(tutorialVersion : .challenges) {
            
            if let vc = R.storyboard.main.tutorialViewControllerId() {
                
                vc.configureFor(tutorialVersion: .challenges)
                vc.modalPresentationStyle = .overFullScreen
                present(vc, animated: false, completion: nil)
                
            }
            
        }
        
         view.layoutIfNeeded()
        
    }
    
    override func trackScreen() {
        
    }
    
    private var allowSearch = false
    private var previousIndex = 0
    @IBAction func segmentChanged(_ sender: Any) {
        
        challengesPagerViewController?.changePage(segmentControl.selectedSegmentIndex)
        
        previousIndex = segmentControl.selectedSegmentIndex
        
    }
    
    override func viewDidLoad() {
        
        hasNavBar = true
        super.viewDidLoad()
        if #available(iOS 11.0, *) {
            let topPadding = UIApplication.shared.keyWindow?.safeAreaInsets.top ?? 0.0
            topViewConstraint.constant = topPadding / 2 + topViewConstraint.constant
        }
        
        for i in 0 ..< Variables.Content.challengeTabNames.count() {
            
            if let title = Variables.Content.challengeTabNames.object(at: i) as? String, let categoryString = Variables.Content.challengeTabCategories.object(at: i) as? String {
                
                
                guard title != "" else { continue }
                
                var category = ChallengesPageViewController.challengePageType(rawValue: categoryString) ?? .hashtag
                
                if categoryString.prefix(8) == "trending" {
                    
                    category = .trending
                    let versionNumber = categoryString.replacingOccurrences(of: "trending", with: "")
                     categoryStrings.append(versionNumber)
                    
                } else {
                    
                     categoryStrings.append(categoryString)
                    
                }
               
                titles.append( title )
                categories.append(category)
                
            }
            
        }
        
        services = (UIApplication.shared.delegate as! AppDelegate).services
        searchController = UISearchController(searchResultsController: nil)
        searchController?.searchResultsUpdater = self
        searchController?.obscuresBackgroundDuringPresentation = false
        searchController?.searchBar.placeholder = "Search Challenges"
        
        if #available(iOS 11.0, *) {
            
            if allowSearch {
                
                navigationItem.searchController =  searchController
                navigationItem.hidesSearchBarWhenScrolling = false
                
            }
            
        } 
        
        navigationController?.navigationBar.layer.shadowColor = UIColor.clear.cgColor
        definesPresentationContext = true
        setTabs()
        challengesPagerViewController?.configure(with: titles, categories: categories, categoryStrings: categoryStrings, delegate: self, services : services)
        
    }
    
    func scrollToTop() {
        
        challengesPagerViewController?.scrollToTop()
        
    }
    
    override func transitionCompleted() {
        
        super.transitionCompleted()
        challengesPagerViewController?.transitionCompleted()
    
    }
    
    private func setTabs() {
        
        segmentControl.removeAllSegments()
        
        for title in titles {
            
            segmentControl.insertSegment(withTitle: title, at: segmentControl.numberOfSegments, animated: false)
            
        }
        
        segmentControl.selectedSegmentIndex = 0
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let vc = R.segue.challengesViewController.pageSegue(segue: segue)?.destination {
            
            challengesPagerViewController = vc
            challengesPagerViewController?.pageDelegate = self
            challengesPagerViewController?.contentPageDelegate = self
            
        }
        
    }
    
}

extension ChallengesViewController: UISearchResultsUpdating {
    // MARK: - UISearchResultsUpdating Delegate
    func updateSearchResults(for searchController: UISearchController) {
        
        
    }
    
}

extension ChallengesViewController : ContentPageViewControllerDelegate {
   
    func transitionItemSelected(selectedImage: UIImage?, selectedFrame: CGRect?) {
      
        self.selectedImage = selectedImage
        self.selectedFrame = selectedFrame
   
    }
    
    
    func toggleSearchVisibility(isVisible : Bool, force: Bool) {
        
        guard allowSearch, #available(iOS 11.0, *), !(navigationItem.searchController?.isActive ?? false), (force || expanded != isVisible) else { return }
        
        expanded = isVisible || force
        
        if expanded {
            
            navigationItem.searchController =  searchController
            
        } else {
            
            self.navigationItem.searchController?.isActive = false
            let search = UISearchController(searchResultsController: nil)
            self.navigationItem.searchController = search
            self.navigationItem.searchController = nil
            
        }
        
    }
    
}

extension ChallengesViewController : PagerViewControllerDelegate {
    
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
