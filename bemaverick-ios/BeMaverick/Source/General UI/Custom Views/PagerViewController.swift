//
//  PagerViewController.swift
//  Maverick
//
//  Created by Garrett Fritz on 6/13/18.
//  Copyright © 2018 BeMaverick. All rights reserved.
//

import Foundation

class PagerViewController : UIPageViewController {
    
    weak var pageDelegate : PagerViewControllerDelegate?
    var allowLooping : Bool = true
    private var dismissedStarted = false
    var  scrollViewPanGestureRecognzier : UIPanGestureRecognizer?
    func transitionCompleted() {
        for controller in orderedViewControllers() {
            
            if let vc = controller as? ViewController {
                
                vc.transitionCompleted()
            
            }
            
        }
    
    }
    
    func orderedViewControllers() -> [UIViewController] {
        
        return []
        
    }
    
    var currentPage : Int = 0
    private func initializeGestures() {
        
        for subView in view.subviews {
            if let scroll = subView as? UIScrollView {
                scrollViewPanGestureRecognzier = UIPanGestureRecognizer(target: self,
                                                                        action: #selector(handlePanGesture(_:)))
                scrollViewPanGestureRecognzier?.delegate = self
                scroll.addGestureRecognizer(scrollViewPanGestureRecognzier!)
                
            }
        }
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeGestures()
        dataSource = self
        delegate = self
        
        if let firstViewController = orderedViewControllers().first {
            setViewControllers([firstViewController],
                               direction: .forward,
                               animated: true,
                               completion: nil)
        }
        
        pageDelegate?.paginatedViewController(paginatedViewController: self, didUpdatePageCount: orderedViewControllers().count)
        
        
    }
    
    func getSelectedIndex() -> Int {
     
        if let firstViewController = viewControllers?.first,
            let index = orderedViewControllers().index(of: firstViewController){
            return index
        }
        
        return 0
        
        
    }
    
    func setSelectedIndex(index : Int) {
        
       
        
        
    }
    
    private func notifyNewIndex() {
        if let firstViewController = viewControllers?.first,
            let index = orderedViewControllers().index(of: firstViewController) {
            
            pageDelegate?.paginatedViewController(paginatedViewController: self, didUpdatePageIndex: index)
            AnalyticsManager.Main.trackPageSwiped(source: self)
            
        }
    }
    
}

// MARK: UIPageViewControllerDataSource

extension PagerViewController: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    func pageViewController(_ pageViewController: UIPageViewController,
                            didFinishAnimating finished: Bool,
                            previousViewControllers: [UIViewController],
                            transitionCompleted completed: Bool) {
        notifyNewIndex()
    }
    
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        guard let viewControllerIndex = orderedViewControllers().index(of:viewController) else {
            return nil
        }
        
        let previousIndex = viewControllerIndex - 1
        
        // User is on the first view controller and swiped left to loop to
        // the last view controller.
        guard previousIndex >= 0 else {
            if allowLooping {
            
                return orderedViewControllers().last
            
            } else {
            
                return nil
            
            }
        
        }
        
        guard orderedViewControllers().count > previousIndex else {
            return nil
        }
        
        return orderedViewControllers()[previousIndex]
    }
    
    func getCurrentPage() -> Int {
        
        guard let currentViewController = self.viewControllers?.first else { return 0 }
        
        let index = orderedViewControllers().index(of: currentViewController) ?? 0
        return index
    }
    func changePage(_ indexToShow: Int) {
        
        AnalyticsManager.Main.trackUpperNavTabPressed(source: self, index: indexToShow)
        currentPage = indexToShow
        guard let currentViewController = self.viewControllers?.first else { return }
        
        let index = orderedViewControllers().index(of: currentViewController)
        
        if indexToShow == index {
            return
        } else if indexToShow > index! {
            setViewControllers([orderedViewControllers()[indexToShow]],
                               direction: .forward,
                               animated: true,
                               completion: nil)
        } else {
            setViewControllers([orderedViewControllers()[indexToShow]],
                               direction: .reverse,
                               animated: true,
                               completion: nil)
        }
    }
    
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        guard let viewControllerIndex = orderedViewControllers().index(of: viewController) else {
            return nil
        }
        
        let nextIndex = viewControllerIndex + 1
        let orderedViewControllersCount = orderedViewControllers().count
        
        // User is on the last view controller and swiped right to loop to
        // the first view controller.
        guard orderedViewControllersCount != nextIndex else {
           
            if allowLooping {
            
                return orderedViewControllers().first
            
            } else { return nil }
            
        }
        
        guard orderedViewControllersCount > nextIndex else {
            return nil
        }
        
        return orderedViewControllers()[nextIndex]
        
    }
    
    func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int {
        
        return orderedViewControllers().count
        
    }
    
    func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> Int {
        
        guard let firstViewController = viewControllers?.first,
            let firstViewControllerIndex = orderedViewControllers().index(of: firstViewController) else {
                return 0
        }
        
        return firstViewControllerIndex
    }
    
}


protocol PagerViewControllerDelegate: class {
    
    /**
     Called when the number of pages is updated.
     
     - parameter onboardPaginatedViewController: the onboardPaginatedViewController instance
     - parameter count: the total number of pages.
     */
    func paginatedViewController(paginatedViewController: PagerViewController,
                                        didUpdatePageCount count: Int)
    
    /**
     Called when the current index is updated.
     
     - parameter onboardPaginatedViewController: the onboardPaginatedViewController instance
     - parameter index: the index of the currently visible page.
     */
    func paginatedViewController(paginatedViewController: PagerViewController,
                                        didUpdatePageIndex index: Int)
    
}

extension PagerViewController : UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        
        guard !allowLooping else { return false }
        if getCurrentPage() == 0 {
            
            let point = touch.location(in: view)
            if point.x < 20 {
            
                return true
                
            }
            
        }
        
        return false
    
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
       
        return true
    
    }
    
    /**
     Handle dragging the view closest to the touch point
     */
    @objc func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        
        guard !dismissedStarted else { return }
        dismissedStarted = true
        if let _ =  self as? ChallengeDetailsPagerViewController {
            AnalyticsManager.Main.trackChallengeDetailsDismmised(source: .SWIPE)
            
        }
        navigationController?.popViewController(animated: true)
        
    }
    
}
