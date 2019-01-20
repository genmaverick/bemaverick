//
//  StreamRefresh.swift
//  Maverick
//
//  Created by Garrett Fritz on 3/4/18.
//  Copyright © 2018 BeMaverick. All rights reserved.
//

import Foundation
import Branch
import RealmSwift

protocol StreamRefreshControllerDelegate : class {
    
    /**
     Function to be overriden by subclass, this should fire off the API request
     The completion block of request should call refreshCompleted()
     */
    func refreshDataRequest()
    
    /**
     Called on view did load, meant to be overriden to load in data and set the
     data update observer
     */
    func configureData()
    
    /**
     Function to be overriden by subclass, this should fire off the API request
     The completion block of request should call nextPageLoadCompleted()
     */
    func loadNextPageRequest()
    
    /**
     Get item count
     */
    func getMainSectionItemCount() -> Int
    
}


class StreamRefreshController : ContentViewController {
    
    /// technically scroll stops after a swipe to refresh before new data arrives, so just dont autoplay untill that is over
    internal var blockAutoplayDueToRefresh = false;
    /// Edge insets factoring in the safe areas
    internal var contentEdgeInsets: UIEdgeInsets = .zero
    /// Factor in the upper navigation view on the page controller
    internal var additionalSafeAreaTop: CGFloat = 20
    /// flag to keep from multi loading new pages
    internal var loadingNewPage = false {
        
        didSet {
            
            if let streamTableViewControllerDelegate = streamDelegate as? StreamTableViewController, let streamTableView = streamTableViewControllerDelegate.tableView {
                
                if loadingNewPage {
                    
                    startSpinner(forTableView: streamTableView)
                    
                } else {
                    
                    stopSpinner(forTableView: streamTableView)
                    
                }
                
            }
            
        }
        
    }
    
    /**
     Start the activity indicator for a table view if loading a new page.
     - parameter tableView: The table view that is fetching new page.
     */
    func startSpinner(forTableView tableView: UITableView) {
        
        let spinner = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        spinner.startAnimating()
        spinner.frame = CGRect(x: CGFloat(0), y: CGFloat(0), width: tableView.bounds.width, height: CGFloat(44))
        
        tableView.tableFooterView = spinner
        tableView.tableFooterView?.isHidden = false
        
    }
    
    /**
     Stop the activity indicator for a table view if finished loading a new page.
     - parameter tableView: The table view that has fetched a new page.
     */
    func stopSpinner(forTableView tableView: UITableView) {
        
        tableView.tableFooterView?.isHidden = true
        
    }
    
    /// Property to stop fetching next page
    var previousCount = 0
    /// Property to stop fetching next page
    var hasReachedEnd = false
   
    /// RefreshingView
    var refreshControl : UIRefreshControl?
    /// delegate for all refresh and pagination tasks
    weak var streamDelegate : StreamRefreshControllerDelegate?
    
    
    private var hasInitializedViews = false
    
  
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        guard !hasInitializedViews else { return }
        streamDelegate?.configureData()
        hasInitializedViews = true
        configureView()
        
    }
    
   

    var needsReload = false
    
    func scrollToTop() {
        
        
    }
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        navigationController?.interactivePopGestureRecognizer?.delegate = nil
        
        // iOS 10 fix to not have white spacing on top
        automaticallyAdjustsScrollViewInsets = false

    }
    
    /**
     Notify cells that scrolling has occured
     */
    func notifyScroll() {
        
    }
    
    /**
     Notify cells that scrolling has stopped
     */
    func scrollStopped() {
        
    }
    
    /**
     Called when API request completed, allows for another API request to be launched
     and dismisses the refreshing view
     */
    func refreshCompleted() {
        
        loadingNewPage = false
        blockAutoplayDueToRefresh = false
        refreshControl?.endRefreshing()
        
    }
    
    /**
     Called on view did load, initialize views
     */
    func configureView() {
        
    }
    
    /**
     Swipe to refresh - tied to pull to refresh action
     */
    @objc func refresh(_ refreshControl: UIRefreshControl? = nil) {
        
        blockAutoplayDueToRefresh = true
        hasReachedEnd = false
        if !loadingNewPage {
            
            loadingNewPage = true
            streamDelegate?.refreshDataRequest()
            
        }
        
    }
    
    /**
     Called when API request completed, allows for another API request to be launched
     and checks if we have reached the end of the results
     */
    func nextPageLoadCompleted() {
        
        loadingNewPage = false
        hasReachedEnd = previousCount >= (streamDelegate?.getMainSectionItemCount() ?? 0)
        
    }
    
    /**
     Function called when we get close to end of list, meant to be overriden to load new data
     */
    func loadNextPage() {
        
        if !loadingNewPage {
            
            loadingNewPage = true
            previousCount = streamDelegate?.getMainSectionItemCount() ?? 0
            AnalyticsManager.Main.trackFeedNextPageCalled(source: self, offset: streamDelegate?.getMainSectionItemCount() ?? 0)
            streamDelegate?.loadNextPageRequest()
            
        }
        
    }
    
   
    
}

extension StreamRefreshController : UIScrollViewDelegate {
    
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        
        notifyScroll()
        
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        scrollStopped()
        
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        
        if !decelerate {
            
            scrollStopped()
            
        }
        
    }
    
}

